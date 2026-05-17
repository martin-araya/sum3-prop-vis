-- AuditChain Database Init
-- Compatible con PostgreSQL 16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE FUNCTION public.recalcular_puntaje_sucursal() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE target_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN target_id := OLD.sucursal_id;
    ELSE target_id := NEW.sucursal_id;
    END IF;
    UPDATE public.sucursales
    SET puntaje_promedio = COALESCE((SELECT ROUND(AVG(puntaje)::NUMERIC,2) FROM public.auditorias WHERE sucursal_id = target_id), 0),
    updated_at = NOW() WHERE id = target_id;
    RETURN NULL;
END; $$;

CREATE FUNCTION public.set_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := NOW(); RETURN NEW; END; $$;

CREATE TABLE public.usuarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre varchar(120) NOT NULL,
    email varchar(255) NOT NULL,
    hashed_password varchar(255) NOT NULL,
    rol varchar(20) DEFAULT 'auditor' NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT usuarios_rol_check CHECK (rol IN ('admin','supervisor','auditor'))
);

CREATE TABLE public.sucursales (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre varchar(150) NOT NULL,
    region varchar(100) NOT NULL,
    direccion varchar(255),
    estado varchar(20) DEFAULT 'activo' NOT NULL,
    puntaje_promedio numeric(5,2) DEFAULT 0.00 NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT sucursales_estado_check CHECK (estado IN ('activo','inactivo'))
);

CREATE TABLE public.auditores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre varchar(120) NOT NULL,
    email varchar(255) NOT NULL,
    region varchar(100),
    estado varchar(20) DEFAULT 'activo' NOT NULL,
    usuario_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT auditores_estado_check CHECK (estado IN ('activo','inactivo'))
);

CREATE TABLE public.auditorias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sucursal_id uuid NOT NULL,
    auditor_id uuid NOT NULL,
    fecha date NOT NULL,
    puntaje smallint NOT NULL,
    estado varchar(25) DEFAULT 'pendiente' NOT NULL,
    notas text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT auditorias_estado_check CHECK (estado IN ('pendiente','completada','con_observaciones')),
    CONSTRAINT auditorias_puntaje_check CHECK (puntaje >= 0 AND puntaje <= 100)
);

ALTER TABLE ONLY public.usuarios ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.usuarios ADD CONSTRAINT usuarios_email_key UNIQUE (email);
ALTER TABLE ONLY public.sucursales ADD CONSTRAINT sucursales_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.auditores ADD CONSTRAINT auditores_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.auditores ADD CONSTRAINT auditores_email_key UNIQUE (email);
ALTER TABLE ONLY public.auditorias ADD CONSTRAINT auditorias_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auditores ADD CONSTRAINT auditores_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.auditorias ADD CONSTRAINT auditorias_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES public.sucursales(id) ON DELETE RESTRICT;
ALTER TABLE ONLY public.auditorias ADD CONSTRAINT auditorias_auditor_id_fkey FOREIGN KEY (auditor_id) REFERENCES public.auditores(id) ON DELETE RESTRICT;

CREATE INDEX idx_sucursales_estado ON public.sucursales(estado);
CREATE INDEX idx_sucursales_region ON public.sucursales(region);
CREATE INDEX idx_auditores_estado ON public.auditores(estado);
CREATE INDEX idx_auditorias_sucursal_id ON public.auditorias(sucursal_id);
CREATE INDEX idx_auditorias_auditor_id ON public.auditorias(auditor_id);
CREATE INDEX idx_auditorias_fecha ON public.auditorias(fecha DESC);

CREATE TRIGGER trg_updated_at_usuarios BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_updated_at_sucursales BEFORE UPDATE ON public.sucursales FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_updated_at_auditores BEFORE UPDATE ON public.auditores FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_updated_at_auditorias BEFORE UPDATE ON public.auditorias FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_recalcular_puntaje AFTER INSERT OR UPDATE OR DELETE ON public.auditorias FOR EACH ROW EXECUTE FUNCTION public.recalcular_puntaje_sucursal();

INSERT INTO public.usuarios (id, nombre, email, hashed_password, rol, activo) VALUES
('45795fb3-8756-4d08-ad95-606b59c22122', 'Admin Principal', 'admin@auditchain.cl', '60fe74406e7f353ed979f350f2fbb6a2e8690a5fa7d1b0c32983d1d8b3f95f67', 'admin', true),
('b1c2d3e4-f5a6-7890-abcd-ef1234567890', 'Supervisor Zona', 'supervisor@auditchain.cl', '05bd415216a71d7cddca64e7cba081bd7e1e03cb8d355adb276923c88c6d4c52', 'supervisor', true);

INSERT INTO public.sucursales (id, nombre, region, direccion, estado) VALUES
('37c5c733-434e-4310-b5e9-c01822b41ea6', 'Sucursal Centro', 'Región Metropolitana', 'Av. Libertador Bernardo OHiggins 1234', 'activo'),
('48d6d844-545f-4421-c6fa-d12933b52fb7', 'Sucursal Providencia', 'Región Metropolitana', 'Av. Providencia 2140', 'activo'),
('59e7e955-656e-5532-d7eb-e23a44c63ec8', 'Sucursal Maipú', 'Región Metropolitana', 'Av. Américo Vespucio Sur 1200', 'inactivo');

INSERT INTO public.auditores (id, nombre, email, region, estado, usuario_id) VALUES
('796d71ef-4775-4c03-8e38-7beac16a3ed6', 'Valentina Rojas', 'v.rojas@auditchain.cl', 'Región Metropolitana', 'activo', '45795fb3-8756-4d08-ad95-606b59c22122'),
('8a7e82f0-5886-5d14-9f49-8cfbd27b4fe7', 'Matías Fernández', 'm.fernandez@auditchain.cl', 'Región de Valparaíso', 'activo', 'b1c2d3e4-f5a6-7890-abcd-ef1234567890'),
('9b8f93a1-6997-6e25-ae5a-9dacc38c5af8', 'Catalina Muñoz', 'c.munoz@auditchain.cl', 'Región Metropolitana', 'inactivo', null);

INSERT INTO public.auditorias (sucursal_id, auditor_id, fecha, puntaje, estado, notas) VALUES
('37c5c733-434e-4310-b5e9-c01822b41ea6', '796d71ef-4775-4c03-8e38-7beac16a3ed6', '2025-03-15', 87, 'completada', 'Sin observaciones relevantes'),
('48d6d844-545f-4421-c6fa-d12933b52fb7', '8a7e82f0-5886-5d14-9f49-8cfbd27b4fe7', '2025-03-18', 72, 'con_observaciones', 'Señalética dañada en entrada'),
('59e7e955-656e-5532-d7eb-e23a44c63ec8', '796d71ef-4775-4c03-8e38-7beac16a3ed6', '2025-03-20', 55, 'con_observaciones', 'Uniforme incorrecto y vitrina desordenada'),
('37c5c733-434e-4310-b5e9-c01822b41ea6', '9b8f93a1-6997-6e25-ae5a-9dacc38c5af8', '2025-04-02', 91, 'completada', 'Excelente cumplimiento de estándares');
