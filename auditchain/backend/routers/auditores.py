from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from database import get_db
from models import Auditor
from schemas import AuditorCreate, AuditorUpdate, AuditorOut

router = APIRouter()


# CREATE
@router.post("/", response_model=AuditorOut, status_code=status.HTTP_201_CREATED)
def crear_auditor(data: AuditorCreate, db: Session = Depends(get_db)):
    existe = db.query(Auditor).filter(Auditor.email == data.email).first()
    if existe:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    auditor = Auditor(**data.model_dump())
    db.add(auditor)
    db.commit()
    db.refresh(auditor)
    return auditor


# READ ALL
@router.get("/", response_model=List[AuditorOut])
def listar_auditores(db: Session = Depends(get_db)):
    return db.query(Auditor).all()


# READ ONE
@router.get("/{auditor_id}", response_model=AuditorOut)
def obtener_auditor(auditor_id: UUID, db: Session = Depends(get_db)):
    auditor = db.query(Auditor).filter(Auditor.id == auditor_id).first()
    if not auditor:
        raise HTTPException(status_code=404, detail="Auditor no encontrado")
    return auditor


# UPDATE
@router.put("/{auditor_id}", response_model=AuditorOut)
def actualizar_auditor(auditor_id: UUID, data: AuditorUpdate, db: Session = Depends(get_db)):
    auditor = db.query(Auditor).filter(Auditor.id == auditor_id).first()
    if not auditor:
        raise HTTPException(status_code=404, detail="Auditor no encontrado")
    for key, value in data.model_dump(exclude_none=True).items():
        setattr(auditor, key, value)
    db.commit()
    db.refresh(auditor)
    return auditor


# DELETE
@router.delete("/{auditor_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_auditor(auditor_id: UUID, db: Session = Depends(get_db)):
    auditor = db.query(Auditor).filter(Auditor.id == auditor_id).first()
    if not auditor:
        raise HTTPException(status_code=404, detail="Auditor no encontrado")
    db.delete(auditor)
    db.commit()
