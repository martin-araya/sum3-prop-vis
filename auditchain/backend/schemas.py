from pydantic import BaseModel, EmailStr
from typing import Optional
from uuid import UUID
from datetime import date, datetime
from enum import Enum


# ─── Enums ───────────────────────────────────────────────────────────────────

class RolEnum(str, Enum):
    admin = "admin"
    supervisor = "supervisor"
    auditor = "auditor"

class EstadoEnum(str, Enum):
    activo = "activo"
    inactivo = "inactivo"

class EstadoAuditoriaEnum(str, Enum):
    pendiente = "pendiente"
    completada = "completada"
    con_observaciones = "con_observaciones"


# ─── Usuario ─────────────────────────────────────────────────────────────────

class UsuarioBase(BaseModel):
    nombre: str
    email: EmailStr
    rol: RolEnum = RolEnum.auditor
    activo: bool = True

class UsuarioCreate(UsuarioBase):
    password: str

class UsuarioUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[EmailStr] = None
    rol: Optional[RolEnum] = None
    activo: Optional[bool] = None
    password: Optional[str] = None

class UsuarioOut(UsuarioBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True


# ─── Sucursal ─────────────────────────────────────────────────────────────────

class SucursalBase(BaseModel):
    nombre: str
    region: str
    direccion: Optional[str] = None
    estado: EstadoEnum = EstadoEnum.activo

class SucursalCreate(SucursalBase):
    pass

class SucursalUpdate(BaseModel):
    nombre: Optional[str] = None
    region: Optional[str] = None
    direccion: Optional[str] = None
    estado: Optional[EstadoEnum] = None

class SucursalOut(SucursalBase):
    id: UUID
    puntaje_promedio: float
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True


# ─── Auditor ──────────────────────────────────────────────────────────────────

class AuditorBase(BaseModel):
    nombre: str
    email: EmailStr
    region: Optional[str] = None
    estado: EstadoEnum = EstadoEnum.activo
    usuario_id: Optional[UUID] = None

class AuditorCreate(AuditorBase):
    pass

class AuditorUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[EmailStr] = None
    region: Optional[str] = None
    estado: Optional[EstadoEnum] = None
    usuario_id: Optional[UUID] = None

class AuditorOut(AuditorBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True


# ─── Auditoria ────────────────────────────────────────────────────────────────

class AuditoriaBase(BaseModel):
    sucursal_id: UUID
    auditor_id: UUID
    fecha: date
    puntaje: int
    estado: EstadoAuditoriaEnum = EstadoAuditoriaEnum.pendiente
    notas: Optional[str] = None

class AuditoriaCreate(AuditoriaBase):
    pass

class AuditoriaUpdate(BaseModel):
    fecha: Optional[date] = None
    puntaje: Optional[int] = None
    estado: Optional[EstadoAuditoriaEnum] = None
    notas: Optional[str] = None

class AuditoriaOut(AuditoriaBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True
