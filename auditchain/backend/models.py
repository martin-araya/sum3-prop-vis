import uuid
from sqlalchemy import Column, String, Boolean, Numeric, SmallInteger, Date, Text, ForeignKey, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base


class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(120), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    hashed_password = Column(String(255), nullable=False)
    rol = Column(String(20), nullable=False, default="auditor")
    activo = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    auditores = relationship("Auditor", back_populates="usuario")


class Sucursal(Base):
    __tablename__ = "sucursales"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(150), nullable=False)
    region = Column(String(100), nullable=False)
    direccion = Column(String(255))
    estado = Column(String(20), nullable=False, default="activo")
    puntaje_promedio = Column(Numeric(5, 2), nullable=False, default=0.00)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    auditorias = relationship("Auditoria", back_populates="sucursal")


class Auditor(Base):
    __tablename__ = "auditores"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(120), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    region = Column(String(100))
    estado = Column(String(20), nullable=False, default="activo")
    usuario_id = Column(UUID(as_uuid=True), ForeignKey("usuarios.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    usuario = relationship("Usuario", back_populates="auditores")
    auditorias = relationship("Auditoria", back_populates="auditor")


class Auditoria(Base):
    __tablename__ = "auditorias"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sucursal_id = Column(UUID(as_uuid=True), ForeignKey("sucursales.id", ondelete="RESTRICT"), nullable=False)
    auditor_id = Column(UUID(as_uuid=True), ForeignKey("auditores.id", ondelete="RESTRICT"), nullable=False)
    fecha = Column(Date, nullable=False)
    puntaje = Column(SmallInteger, nullable=False)
    estado = Column(String(25), nullable=False, default="pendiente")
    notas = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())

    sucursal = relationship("Sucursal", back_populates="auditorias")
    auditor = relationship("Auditor", back_populates="auditorias")
