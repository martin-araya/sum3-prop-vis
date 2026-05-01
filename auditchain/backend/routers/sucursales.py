from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from database import get_db
from models import Sucursal
from schemas import SucursalCreate, SucursalUpdate, SucursalOut

router = APIRouter()


# CREATE
@router.post("/", response_model=SucursalOut, status_code=status.HTTP_201_CREATED)
def crear_sucursal(data: SucursalCreate, db: Session = Depends(get_db)):
    sucursal = Sucursal(**data.model_dump())
    db.add(sucursal)
    db.commit()
    db.refresh(sucursal)
    return sucursal


# READ ALL
@router.get("/", response_model=List[SucursalOut])
def listar_sucursales(db: Session = Depends(get_db)):
    return db.query(Sucursal).all()


# READ ONE
@router.get("/{sucursal_id}", response_model=SucursalOut)
def obtener_sucursal(sucursal_id: UUID, db: Session = Depends(get_db)):
    sucursal = db.query(Sucursal).filter(Sucursal.id == sucursal_id).first()
    if not sucursal:
        raise HTTPException(status_code=404, detail="Sucursal no encontrada")
    return sucursal


# UPDATE
@router.put("/{sucursal_id}", response_model=SucursalOut)
def actualizar_sucursal(sucursal_id: UUID, data: SucursalUpdate, db: Session = Depends(get_db)):
    sucursal = db.query(Sucursal).filter(Sucursal.id == sucursal_id).first()
    if not sucursal:
        raise HTTPException(status_code=404, detail="Sucursal no encontrada")
    for key, value in data.model_dump(exclude_none=True).items():
        setattr(sucursal, key, value)
    db.commit()
    db.refresh(sucursal)
    return sucursal


# DELETE
@router.delete("/{sucursal_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_sucursal(sucursal_id: UUID, db: Session = Depends(get_db)):
    sucursal = db.query(Sucursal).filter(Sucursal.id == sucursal_id).first()
    if not sucursal:
        raise HTTPException(status_code=404, detail="Sucursal no encontrada")
    db.delete(sucursal)
    db.commit()
