import logging
import traceback
import uuid
from contextlib import asynccontextmanager
from typing import Any

import uvicorn
from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1.router import router as api_router
from app.core.config import get_settings
from app.core.database import check_db_connection, engine

logger = logging.getLogger("auditchain")
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("AuditChain API starting up (env=%s)", settings.environment)
    db_ok = await check_db_connection()
    if db_ok:
        logger.info("DB connection OK")
    else:
        logger.warning("DB connection FAILED at startup")
    yield
    logger.info("AuditChain API shutting down")
    await engine.dispose()
    logger.info("DB engine disposed")


app = FastAPI(
    title="AuditChain API",
    version="1.0.0",
    description="API de gestión de auditorías para redes de franquicias",
    lifespan=lifespan,
)

# 1. CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# 2. Request ID middleware
@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response


# Routers
# Nota: api_router ya trae prefix="/api/v1" en su definición; no se re-prefija aquí.
app.include_router(api_router)


# Exception handlers
@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": str(exc.detail)},
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    errors = [
        {
            "loc": list(err.get("loc", [])),
            "msg": err.get("msg", ""),
            "type": err.get("type", ""),
        }
        for err in exc.errors()
    ]
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": errors},
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error(
        "Unhandled exception on %s %s\n%s",
        request.method,
        request.url.path,
        traceback.format_exc(),
    )
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"},
    )


# Base endpoints
@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "db": await check_db_connection(),
        "environment": settings.environment,
    }


@app.get("/")
async def root() -> dict[str, str]:
    return {"message": "AuditChain API", "docs": "/docs"}


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.environment == "development",
    )
