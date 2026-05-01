from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from uuid import UUID

from database import get_db
from models import Auditoria, Sucursal
from schemas import AuditoriaCreate, AuditoriaUpdate, AuditoriaOut

router = APIRouter()


def actualizar_puntaje_sucursal(sucursal_id: UUID, db: Session):
    """Recalcula el puntaje promedio de la sucursal tras cambios en auditorías."""
    promedio = db.query(func.avg(Auditoria.puntaje)).filter(
        Auditoria.sucursal_id == sucursal_id
    ).scalar()
    sucursal = db.query(Sucursal).filter(Sucursal.id == sucursal_id).first()
    if sucursal:
        sucursal.puntaje_promedio = round(float(promedio or 0), 2)
        db.commit()


# CREATE
@router.post("/", response_model=AuditoriaOut, status_code=status.HTTP_201_CREATED)
def crear_auditoria(data: AuditoriaCreate, db: Session = Depends(get_db)):
    if not 0 <= data.puntaje <= 100:
        raise HTTPException(status_code=400, detail="El puntaje debe estar entre 0 y 100")
    auditoria = Auditoria(**data.model_dump())
    db.add(auditoria)
    db.commit()
    db.refresh(auditoria)
    actualizar_puntaje_sucursal(data.sucursal_id, db)
    return auditoria


# READ ALL
@router.get("/", response_model=List[AuditoriaOut])
def listar_auditorias(db: Session = Depends(get_db)):
    return db.query(Auditoria).order_by(Auditoria.fecha.desc()).all()


# READ ONE
@router.get("/{auditoria_id}", response_model=AuditoriaOut)
def obtener_auditoria(auditoria_id: UUID, db: Session = Depends(get_db)):
    auditoria = db.query(Auditoria).filter(Auditoria.id == auditoria_id).first()
    if not auditoria:
        raise HTTPException(status_code=404, detail="Auditoría no encontrada")
    return auditoria


# UPDATE
@router.put("/{auditoria_id}", response_model=AuditoriaOut)
def actualizar_auditoria(auditoria_id: UUID, data: AuditoriaUpdate, db: Session = Depends(get_db)):
    auditoria = db.query(Auditoria).filter(Auditoria.id == auditoria_id).first()
    if not auditoria:
        raise HTTPException(status_code=404, detail="Auditoría no encontrada")
    if data.puntaje is not None and not 0 <= data.puntaje <= 100:
        raise HTTPException(status_code=400, detail="El puntaje debe estar entre 0 y 100")
    for key, value in data.model_dump(exclude_none=True).items():
        setattr(auditoria, key, value)
    db.commit()
    db.refresh(auditoria)
    actualizar_puntaje_sucursal(auditoria.sucursal_id, db)
    return auditoria


# DELETE
@router.delete("/{auditoria_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_auditoria(auditoria_id: UUID, db: Session = Depends(get_db)):
    auditoria = db.query(Auditoria).filter(Auditoria.id == auditoria_id).first()
    if not auditoria:
        raise HTTPException(status_code=404, detail="Auditoría no encontrada")
    sucursal_id = auditoria.sucursal_id
    db.delete(auditoria)
    db.commit()
    actualizar_puntaje_sucursal(sucursal_id, db)
