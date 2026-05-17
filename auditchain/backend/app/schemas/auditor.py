import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr


class AuditorBase(BaseModel):
    nombre: str
    email: EmailStr
    region: str | None = None


class AuditorCreate(AuditorBase):
    usuario_id: uuid.UUID


class AuditorUpdate(BaseModel):
    nombre: str | None = None
    email: EmailStr | None = None
    region: str | None = None
    activo: bool | None = None


class AuditorOut(AuditorBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    usuario_id: uuid.UUID
    activo: bool
    creado_en: datetime
