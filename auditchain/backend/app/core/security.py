from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import get_settings

_settings = get_settings()

_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Dev mode: no RSA keys needed
_DEV_MODE = _settings.secret_key == "dev"
_ALGORITHM = "HS256" if _DEV_MODE else "RS256"
_SIGN_KEY = "dev-secret" if _DEV_MODE else _settings.secret_key
_VERIFY_KEY = "dev-secret" if _DEV_MODE else _settings.public_key


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=_settings.access_token_expire_minutes)
    )
    payload = {
        **data,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "access",
    }
    return jwt.encode(payload, _SIGN_KEY, algorithm=_ALGORITHM)


def create_refresh_token(data: dict) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=_settings.refresh_token_expire_days)
    payload = {
        **data,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "refresh",
    }
    return jwt.encode(payload, _SIGN_KEY, algorithm=_ALGORITHM)


def verify_token(token: str, expected_type: str = "access") -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token inválido o expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, _VERIFY_KEY, algorithms=[_ALGORITHM])
    except JWTError:
        raise credentials_exception

    if payload.get("type") != expected_type:
        raise credentials_exception

    return payload


def get_password_hash(password: str) -> str:
    return _pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return _pwd_context.verify(plain, hashed)
