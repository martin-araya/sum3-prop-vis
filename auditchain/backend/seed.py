import hashlib
import uuid
from database import SessionLocal, engine
from models import Base, Usuario, Auditor, Sucursal

def _hash(pw: str) -> str:
    return hashlib.sha256(pw.encode()).hexdigest()

def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.query(Usuario).count() > 0:
            print("Base de datos ya tiene datos. Omitiendo seed.")
            return

        admin = Usuario(
            id=uuid.uuid4(),
            nombre="Admin AuditChain",
            email="admin@auditchain.cl",
            hashed_password=_hash("Admin1234"),
            rol="admin",
            activo=True,
        )
        auditor_user = Usuario(
            id=uuid.uuid4(),
            nombre="Karol Bermúdez",
            email="auditor@auditchain.cl",
            hashed_password=_hash("Auditor1234"),
            rol="auditor",
            activo=True,
        )
        db.add_all([admin, auditor_user])
        db.flush()

        sucursales = [
            Sucursal(id=uuid.uuid4(), nombre="Sucursal Santiago Centro", region="Metropolitana",
                     direccion="Av. Libertador Bernardo O'Higgins 1234", estado="activo", puntaje_promedio=87.5),
            Sucursal(id=uuid.uuid4(), nombre="Sucursal Las Condes", region="Metropolitana",
                     direccion="Av. Apoquindo 4500", estado="activo", puntaje_promedio=92.0),
            Sucursal(id=uuid.uuid4(), nombre="Sucursal Valparaíso", region="Valparaíso",
                     direccion="Av. Brasil 2100", estado="activo", puntaje_promedio=74.3),
            Sucursal(id=uuid.uuid4(), nombre="Sucursal Concepción", region="Biobío",
                     direccion="Av. O'Higgins 890", estado="activo", puntaje_promedio=81.0),
        ]
        db.add_all(sucursales)
        db.flush()

        auditor = Auditor(
            id=uuid.uuid4(),
            nombre="Karol Bermúdez",
            email="auditor@auditchain.cl",
            region="Metropolitana",
            estado="activo",
            usuario_id=auditor_user.id,
        )
        db.add(auditor)
        db.commit()

        print("Seed completado.")
        print("  admin@auditchain.cl   / Admin1234   (rol: admin)")
        print("  auditor@auditchain.cl / Auditor1234 (rol: auditor)")

    finally:
        db.close()

if __name__ == "__main__":
    seed()
