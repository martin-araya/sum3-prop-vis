import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class SucursalBase(BaseModel):
    nombre: str
    region: str
    direccion: str | None = None


class SucursalCreate(SucursalBase):
    pass


class SucursalUpdate(BaseModel):
    nombre: str | None = None
    region: str | None = None
    direccion: str | None = None
    activo: bool | None = None


class SucursalOut(SucursalBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    puntaje_promedio: float
    activo: bool
    creado_en: datetime
