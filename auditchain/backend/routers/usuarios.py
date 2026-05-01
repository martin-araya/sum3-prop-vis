from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
import hashlib

from database import get_db
from models import Usuario
from schemas import UsuarioCreate, UsuarioUpdate, UsuarioOut

router = APIRouter()

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


# CREATE
@router.post("/", response_model=UsuarioOut, status_code=status.HTTP_201_CREATED)
def crear_usuario(data: UsuarioCreate, db: Session = Depends(get_db)):
    existe = db.query(Usuario).filter(Usuario.email == data.email).first()
    if existe:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    usuario = Usuario(
        nombre=data.nombre,
        email=data.email,
        hashed_password=hash_password(data.password),
        rol=data.rol,
        activo=data.activo
    )
    db.add(usuario)
    db.commit()
    db.refresh(usuario)
    return usuario


# READ ALL
@router.get("/", response_model=List[UsuarioOut])
def listar_usuarios(db: Session = Depends(get_db)):
    return db.query(Usuario).all()


# READ ONE
@router.get("/{usuario_id}", response_model=UsuarioOut)
def obtener_usuario(usuario_id: UUID, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario


# UPDATE
@router.put("/{usuario_id}", response_model=UsuarioOut)
def actualizar_usuario(usuario_id: UUID, data: UsuarioUpdate, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if data.nombre is not None:
        usuario.nombre = data.nombre
    if data.email is not None:
        usuario.email = data.email
    if data.rol is not None:
        usuario.rol = data.rol
    if data.activo is not None:
        usuario.activo = data.activo
    if data.password is not None:
        usuario.hashed_password = hash_password(data.password)
    db.commit()
    db.refresh(usuario)
    return usuario


# DELETE
@router.delete("/{usuario_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_usuario(usuario_id: UUID, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    db.delete(usuario)
    db.commit()
