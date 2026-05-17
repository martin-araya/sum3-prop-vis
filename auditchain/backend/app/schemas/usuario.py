import uuid
from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UsuarioBase(BaseModel):
    nombre: str
    email: EmailStr
    rol: str = "auditor"


class UsuarioCreate(UsuarioBase):
    password: Annotated[str, Field(min_length=8)]


class UsuarioUpdate(BaseModel):
    nombre: str | None = None
    email: EmailStr | None = None
    activo: bool | None = None


class UsuarioOut(UsuarioBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    activo: bool
    creado_en: datetime
