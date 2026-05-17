from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import usuarios, sucursales, auditores, auditorias, auth
from seed import seed

@asynccontextmanager
async def lifespan(app: FastAPI):
    seed()
    yield

app = FastAPI(
    lifespan=lifespan,
    title="AuditChain API",
    description="Sistema de auditoría para franquicias y cadenas comerciales",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(usuarios.router, prefix="/api/usuarios", tags=["Usuarios"])
app.include_router(sucursales.router, prefix="/api/sucursales", tags=["Sucursales"])
app.include_router(auditores.router, prefix="/api/auditores", tags=["Auditores"])
app.include_router(auditorias.router, prefix="/api/auditorias", tags=["Auditorías"])

@app.get("/")
def root():
    return {"message": "AuditChain API funcionando", "version": "1.0.0"}

@app.get("/health")
def health():
    return {"status": "ok"}
