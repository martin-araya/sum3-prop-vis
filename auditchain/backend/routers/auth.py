import hashlib
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt
from sqlalchemy.orm import Session

from database import get_db
from models import Usuario

router = APIRouter()

_SECRET = "auditchain-2024-jwt-secret"
_ALGO = "HS256"
_EXPIRE_MINUTES = 60 * 24


def _hash(pw: str) -> str:
    return hashlib.sha256(pw.encode()).hexdigest()


def _make_token(payload: dict) -> str:
    data = {**payload, "exp": datetime.utcnow() + timedelta(minutes=_EXPIRE_MINUTES)}
    return jwt.encode(data, _SECRET, algorithm=_ALGO)


@router.post("/login")
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.email == form.username).first()
    if not user or user.hashed_password != _hash(form.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Credenciales incorrectas")
    if not user.activo:
        raise HTTPException(status_code=400, detail="Usuario inactivo")

    token = _make_token({
        "sub": str(user.id),
        "email": user.email,
        "nombre": user.nombre,
        "rol": user.rol,
    })
    return {
        "access_token": token,
        "token_type": "bearer",
        "usuario": {
            "id": str(user.id),
            "nombre": user.nombre,
            "email": user.email,
            "rol": user.rol,
        },
    }
