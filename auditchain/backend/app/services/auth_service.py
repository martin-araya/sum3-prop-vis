import uuid

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    create_access_token,
    create_refresh_token,
    verify_token,
)
from app.repositories.usuario_repository import UsuarioRepository
from app.schemas.auth import TokenResponse


async def login(db: AsyncSession, email: str, password: str) -> TokenResponse:
    repo = UsuarioRepository(db)
    user = await repo.authenticate(email, password)

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales inválidas",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario inactivo",
            headers={"WWW-Authenticate": "Bearer"},
        )

    sub = str(user.id)
    return TokenResponse(
        access_token=create_access_token({"sub": sub, "rol": user.rol}),
        refresh_token=create_refresh_token({"sub": sub}),
    )


async def refresh(db: AsyncSession, refresh_token: str) -> TokenResponse:
    payload = verify_token(refresh_token, expected_type="refresh")

    sub = payload.get("sub")
    if not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token sin subject",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = uuid.UUID(sub)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token inválido",
            headers={"WWW-Authenticate": "Bearer"},
        )

    repo = UsuarioRepository(db)
    user = await repo.get(user_id)

    if user is None or not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado o inactivo",
            headers={"WWW-Authenticate": "Bearer"},
        )

    sub_str = str(user.id)
    return TokenResponse(
        access_token=create_access_token({"sub": sub_str, "rol": user.rol}),
        refresh_token=create_refresh_token({"sub": sub_str}),
    )
