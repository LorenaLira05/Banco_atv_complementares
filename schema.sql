CREATE TYPE user_status_enum AS ENUM (
    'active',
    'inactive',
    'blocked'

);
 
CREATE TYPE submission_status_enum AS ENUM (
    'draft',
    'submitted',
    'under_review',
    'approved',
    'rejected',
    'returned_for_adjustment'

);
 
CREATE TYPE validation_status_enum AS ENUM (
    'approved',
    'rejected',
    'returned_for_adjustment'

);
 
CREATE TYPE notification_type_enum AS ENUM (
    'submission_created',
    'submission_updated',
    'submission_approved',
    'submission_rejected',
    'submission_returned',
    'system_alert'

);
 
CREATE TYPE file_type_enum AS ENUM (
    'pdf',
    'image',
    'other'

);

-- USUÁRIOS

CREATE TABLE users (
    id                  BIGSERIAL PRIMARY KEY,
    full_name           VARCHAR(150) NOT NULL,
    email               VARCHAR(150) NOT NULL UNIQUE,
    password_hash       VARCHAR(255) NOT NULL,
    phone               VARCHAR(25),
    cpf                 VARCHAR(20),
    status              user_status_enum NOT NULL DEFAULT 'active',
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,
    last_login_at       TIMESTAMP

);

-- PAPÉIS DO SISTEMA

CREATE TABLE roles (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(50) NOT NULL UNIQUE,
    description         VARCHAR(255)

);
 
INSERT INTO roles (name, description) VALUES
('super_admin', 'Administração global da plataforma'),
('coordinator', 'Coordenação e validação das submissões'),
('student', 'Aluno responsável por submeter atividades');
 
CREATE TABLE user_roles (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    role_id             BIGINT NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    CONSTRAINT fk_user_roles_user

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_user_roles_role

        FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
 
    CONSTRAINT uq_user_role UNIQUE (user_id, role_id)

);

-- CURSOS

CREATE TABLE courses (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(150) NOT NULL,
    code                VARCHAR(30) NOT NULL UNIQUE,
    minimum_required_hours INTEGER NOT NULL DEFAULT 0,
    description         TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP

);

-- VÍNCULO ALUNO x CURSO

CREATE TABLE user_courses (

    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    course_id           BIGINT NOT NULL,
    enrollment_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    CONSTRAINT fk_user_courses_user

        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_user_courses_course

        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
 
    CONSTRAINT uq_user_course UNIQUE (user_id, course_id)

);
 
-- VÍNCULO COORDENADOR x CURSO

CREATE TABLE course_coordinators (

    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    course_id           BIGINT NOT NULL,
    assigned_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
 
    CONSTRAINT fk_course_coordinators_user

        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_course_coordinators_course

        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
 
    CONSTRAINT uq_course_coordinator UNIQUE (user_id, course_id)

);

-- CATEGORIAS DE ATIVIDADES COMPLEMENTARES

CREATE TABLE categories (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL UNIQUE,
    description         TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP

);

-- REGRAS POR CURSO E CATEGORIA

CREATE TABLE course_activity_rules (

    id                  BIGSERIAL PRIMARY KEY,
    course_id           BIGINT NOT NULL,
    category_id         BIGINT NOT NULL,
    min_hours           INTEGER NOT NULL DEFAULT 0,
    max_hours           INTEGER NOT NULL DEFAULT 0,
    is_required         BOOLEAN NOT NULL DEFAULT FALSE,
    notes               TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,
 
    CONSTRAINT fk_rules_course

        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_rules_category

        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
 
    CONSTRAINT uq_course_category_rule UNIQUE (course_id, category_id)

);
 
-- SUBMISSÕES DE ATIVIDADES

CREATE TABLE submissions (

    id                  BIGSERIAL PRIMARY KEY,
    user_course_id      BIGINT NOT NULL,
    category_id         BIGINT NOT NULL,
    title               VARCHAR(200) NOT NULL,
    description         TEXT,
    activity_date       DATE NOT NULL,
    submitted_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    requested_hours     NUMERIC(6,2) NOT NULL,
    approved_hours      NUMERIC(6,2),
    status              submission_status_enum NOT NULL DEFAULT 'submitted',
 
    -- Campos para apoio de OCR / dados críticos

    institution_name    VARCHAR(150),
    certificate_number  VARCHAR(100),
    organizer_name      VARCHAR(150),
 
    -- rastreamento

    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,
 
    CONSTRAINT fk_submissions_user_course

        FOREIGN KEY (user_course_id) REFERENCES user_courses(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_submissions_category

        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT

);

-- ARQUIVOS/COMPROVANTES DA SUBMISSÃO

CREATE TABLE submission_files (

    id                  BIGSERIAL PRIMARY KEY,
    submission_id       BIGINT NOT NULL,
    original_filename   VARCHAR(255) NOT NULL,
    storage_path        VARCHAR(500) NOT NULL,
    file_type           file_type_enum NOT NULL DEFAULT 'pdf',
    mime_type           VARCHAR(100),
    file_size_kb        INTEGER,
    uploaded_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Apoio a OCR

    ocr_extracted_text  TEXT,

    ocr_confidence      NUMERIC(5,2),
 
    CONSTRAINT fk_submission_files_submission

        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE

);
 
-- VALIDAÇÕES

CREATE TABLE validations (

    id                  BIGSERIAL PRIMARY KEY,
    submission_id       BIGINT NOT NULL,
    validator_user_id   BIGINT NOT NULL,
    validation_status   validation_status_enum NOT NULL,
    previous_status     submission_status_enum,
    comment             TEXT,
    validated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_hours      NUMERIC(6,2),
 
    CONSTRAINT fk_validations_submission

        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_validations_validator

        FOREIGN KEY (validator_user_id) REFERENCES users(id) ON DELETE RESTRICT

);

-- NOTIFICAÇÕES

CREATE TABLE notifications (

    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    submission_id       BIGINT,
    type                notification_type_enum NOT NULL,
    title               VARCHAR(150) NOT NULL,
    message             TEXT NOT NULL,
    sent_via_email      BOOLEAN NOT NULL DEFAULT TRUE,
    is_read             BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at             TIMESTAMP,
 
    CONSTRAINT fk_notifications_user

        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 
    CONSTRAINT fk_notifications_submission

        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE SET NULL

);

-- Rastreabilidade das ações relevantes

CREATE TABLE audit_logs (

    id                 BIGSERIAL PRIMARY KEY,
    user_id             BIGINT,
    action              VARCHAR(100) NOT NULL,
    entity_name         VARCHAR(100) NOT NULL,
    entity_id           BIGINT,
    details             JSONB,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    CONSTRAINT fk_audit_logs_user

        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL

);

-- ÍNDICES

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_courses_user ON user_courses(user_id);
CREATE INDEX idx_user_courses_course ON user_courses(course_id);
CREATE INDEX idx_course_coordinators_user ON course_coordinators(user_id);
CREATE INDEX idx_course_coordinators_course ON course_coordinators(course_id);
CREATE INDEX idx_rules_course ON course_activity_rules(course_id);
CREATE INDEX idx_rules_category ON course_activity_rules(category_id);
CREATE INDEX idx_submissions_user_course ON submissions(user_course_id);
CREATE INDEX idx_submissions_category ON submissions(category_id);
CREATE INDEX idx_submissions_status ON submissions(status);
CREATE INDEX idx_submissions_activity_date ON submissions(activity_date);
CREATE INDEX idx_validations_submission ON validations(submission_id);
CREATE INDEX idx_validations_validator ON validations(validator_user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_name, entity_id);
 
-- Visão resumida das submissões

CREATE OR REPLACE VIEW vw_submission_overview AS
SELECT
    s.id AS submission_id,
    u.id AS user_id,
    u.full_name AS student_name,
    c.id AS course_id,
    c.name AS course_name,
    cat.name AS category_name,
    s.title,
    s.requested_hours,
    s.approved_hours,
    s.status,
    s.activity_date,
    s.submitted_at
FROM submissions s
JOIN user_courses uc ON uc.id = s.user_course_id
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.id = s.category_id;
 
-- Visão de progresso do aluno por curso

CREATE OR REPLACE VIEW vw_student_progress AS

SELECT
    u.id AS user_id,
    u.full_name,
    c.id AS course_id,
    c.name AS course_name,
    c.minimum_required_hours,
    COALESCE(SUM(s.approved_hours), 0) AS total_approved_hours,
    ROUND(
        (COALESCE(SUM(s.approved_hours), 0) / NULLIF(c.minimum_required_hours, 0)) * 100,
        2
    ) AS progress_percentage

FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
LEFT JOIN submissions s ON s.user_course_id = uc.id
GROUP BY u.id, u.full_name, c.id, c.name, c.minimum_required_hours;
 
