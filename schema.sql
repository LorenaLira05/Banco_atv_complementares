CREATE DATABASE IF NOT EXISTS atividades_complementares_senac

-- ENUMS
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
    cpf                 VARCHAR(20) UNIQUE,
    status              user_status_enum NOT NULL DEFAULT 'active',
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,
    last_login_at       TIMESTAMP
);

-- PAPÉIS

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
    id                      BIGSERIAL PRIMARY KEY,
    name                    VARCHAR(150) NOT NULL,
    code                    VARCHAR(30) NOT NULL UNIQUE,
    minimum_required_hours  INTEGER NOT NULL DEFAULT 0,
    description             TEXT,
    modalidade              VARCHAR(30),
    turno                   VARCHAR(30),
    semestres               INTEGER,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP
);


-- PERFIL DO ALUNO
CREATE TABLE student_profiles (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL UNIQUE,
    ra                  VARCHAR(20) UNIQUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,

    CONSTRAINT fk_student_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- PERFIL DO COORDENADOR

CREATE TABLE coordinator_profiles (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL UNIQUE,
    departamento            VARCHAR(100),
    cargo                   VARCHAR(100),
    data_nascimento         DATE,
    data_admissao           DATE,
    observacoes_internas    TEXT,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP,

    CONSTRAINT fk_coordinator_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- VÍNCULO ALUNO x CURSO

CREATE TABLE user_courses (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    course_id           BIGINT NOT NULL,
    enrollment_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    status_matricula    VARCHAR(30) NOT NULL DEFAULT 'ativo',
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

-- CATEGORIAS DE ATIVIDADES

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

-- SUBMISSÕES

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
    institution_name    VARCHAR(150),
    certificate_number  VARCHAR(100),
    organizer_name      VARCHAR(150),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP,

    CONSTRAINT fk_submissions_user_course
        FOREIGN KEY (user_course_id) REFERENCES user_courses(id) ON DELETE CASCADE,

    CONSTRAINT fk_submissions_category
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

-- ARQUIVOS DAS SUBMISSÕES

CREATE TABLE submission_files (
    id                  BIGSERIAL PRIMARY KEY,
    submission_id       BIGINT NOT NULL,
    original_filename   VARCHAR(255) NOT NULL,
    storage_path        VARCHAR(500) NOT NULL,
    file_type           file_type_enum NOT NULL DEFAULT 'pdf',
    mime_type           VARCHAR(100),
    file_size_kb        INTEGER,
    uploaded_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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

-- LOGS DE AUDITORIA

CREATE TABLE audit_logs (
    id                  BIGSERIAL PRIMARY KEY,
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
CREATE INDEX idx_student_profiles_user ON student_profiles(user_id);
CREATE INDEX idx_student_profiles_ra ON student_profiles(ra);
CREATE INDEX idx_coordinator_profiles_user ON coordinator_profiles(user_id);
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

-- VIEWS

CREATE OR REPLACE VIEW vw_submission_overview AS
SELECT
    s.id AS submission_id,
    u.id AS user_id,
    u.full_name AS student_name,
    sp.ra,
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
LEFT JOIN student_profiles sp ON sp.user_id = u.id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.id = s.category_id;

CREATE OR REPLACE VIEW vw_student_progress AS
SELECT
    u.id AS user_id,
    u.full_name,
    sp.ra,
    c.id AS course_id,
    c.name AS course_name,
    c.minimum_required_hours,
    uc.status_matricula,
    COALESCE(SUM(s.approved_hours), 0) AS total_approved_hours,
    ROUND(
        (COALESCE(SUM(s.approved_hours), 0) / NULLIF(c.minimum_required_hours, 0)) * 100,
        2
    ) AS progress_percentage
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
LEFT JOIN student_profiles sp ON sp.user_id = u.id
JOIN courses c ON c.id = uc.course_id
LEFT JOIN submissions s ON s.user_course_id = uc.id
GROUP BY u.id, u.full_name, sp.ra, c.id, c.name, c.minimum_required_hours, uc.status_matricula;

-- TRIGGERS

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_submissions_updated_at
    BEFORE UPDATE ON submissions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_coordinator_profiles_updated_at
    BEFORE UPDATE ON coordinator_profiles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_student_profiles_updated_at
    BEFORE UPDATE ON student_profiles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_course_activity_rules_updated_at
    BEFORE UPDATE ON course_activity_rules
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


CREATE OR REPLACE FUNCTION prevent_editing_closed_submission()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IN ('approved', 'rejected') THEN
        RAISE EXCEPTION 'Não é possível editar uma submissão com status %.', OLD.status;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_editing_closed
    BEFORE UPDATE ON submissions
    FOR EACH ROW EXECUTE FUNCTION prevent_editing_closed_submission();

ALTER TABLE course_coordinators 
ADD CONSTRAINT uq_course_one_coordinator UNIQUE (course_id);

-- 2FA: colunas na tabela users
ALTER TABLE users 
ADD COLUMN two_factor_code VARCHAR(255),
ADD COLUMN two_factor_expires_at TIMESTAMP,
ADD COLUMN two_factor_attempts INT DEFAULT 0;

-- 2FA: tabela de dispositivos confiáveis
CREATE TABLE trusted_devices (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    device_token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_trusted_devices_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_trusted_devices_user ON trusted_devices(user_id);

-- Adicional para data science

CREATE TYPE nivel_alerta_enum AS ENUM (
    'baixo',
    'medio',
    'alto',
    'info'
);

CREATE TYPE perfil_destino_enum AS ENUM (
    'aluno',
    'coordenador',
    'superadmin',
    'geral'
);

CREATE TYPE prioridade_enum AS ENUM (
    'baixa',
    'media',
    'alta'
);

CREATE TYPE nivel_risco_enum AS ENUM (
    'baixo',
    'medio',
    'alto'
);

CREATE TYPE status_execucao_enum AS ENUM (
    'em_andamento',
    'sucesso',
    'falha',
    'parcial'
);

-- Insights automáticos gerados pelos scripts Python para os dashboards

CREATE TABLE insights (
    id                  BIGSERIAL PRIMARY KEY,
    perfil_destino      perfil_destino_enum NOT NULL,
    referencia_tipo     VARCHAR(50)         NOT NULL,
    referencia_id       BIGINT,
    tipo_insight        VARCHAR(80)         NOT NULL,
    titulo              VARCHAR(200)        NOT NULL,
    descricao           TEXT                NOT NULL,
    nivel_alerta        nivel_alerta_enum   NOT NULL DEFAULT 'info',
    valor_numerico      NUMERIC(10, 2),
    data_geracao        TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_insights_perfil
    ON insights(perfil_destino);

CREATE INDEX idx_insights_referencia
    ON insights(referencia_tipo, referencia_id);

CREATE INDEX idx_insights_nivel_alerta
    ON insights(nivel_alerta);

CREATE INDEX idx_insights_data_geracao
    ON insights(data_geracao DESC);

-- Recomendações baseadas em regras de negócio por perfil de usuário

CREATE TABLE recomendacoes (
    id                  BIGSERIAL PRIMARY KEY,
    perfil_destino      perfil_destino_enum NOT NULL,
    referencia_id       BIGINT              NOT NULL,
    nome_regra          VARCHAR(100)        NOT NULL,
    titulo              VARCHAR(200)        NOT NULL,
    recomendacao        TEXT                NOT NULL,
    motivo              TEXT                NOT NULL,
    prioridade          prioridade_enum     NOT NULL DEFAULT 'media',
    data_geracao        TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recomendacoes_perfil
    ON recomendacoes(perfil_destino);

CREATE INDEX idx_recomendacoes_referencia
    ON recomendacoes(referencia_id);

CREATE INDEX idx_recomendacoes_prioridade
    ON recomendacoes(prioridade);

CREATE INDEX idx_recomendacoes_data
    ON recomendacoes(data_geracao DESC);

-- Histórico de classificação de risco calculado por aluno e curso

CREATE TABLE classificacao_risco (
    id                      BIGSERIAL PRIMARY KEY,
    aluno_id                BIGINT             NOT NULL,
    curso_id                BIGINT             NOT NULL,
    percentual_conclusao    NUMERIC(5, 2)      NOT NULL,
    submissoes_pendentes    INTEGER            NOT NULL DEFAULT 0,
    submissoes_rejeitadas   INTEGER            NOT NULL DEFAULT 0,
    dias_sem_submeter       INTEGER            NOT NULL DEFAULT 0,
    horas_aprovadas         NUMERIC(8, 2)      NOT NULL DEFAULT 0,
    horas_restantes         NUMERIC(8, 2)      NOT NULL DEFAULT 0,
    nivel_risco             nivel_risco_enum   NOT NULL,
    justificativa           TEXT               NOT NULL,
    data_calculo            TIMESTAMP          NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_risco_aluno
        FOREIGN KEY (aluno_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_risco_curso
        FOREIGN KEY (curso_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_risco_aluno
    ON classificacao_risco(aluno_id);

CREATE INDEX idx_risco_curso
    ON classificacao_risco(curso_id);

CREATE INDEX idx_risco_nivel
    ON classificacao_risco(nivel_risco);

CREATE INDEX idx_risco_data
    ON classificacao_risco(data_calculo DESC);

CREATE OR REPLACE VIEW vw_risco_atual AS
SELECT DISTINCT ON (aluno_id, curso_id)
    id,
    aluno_id,
    curso_id,
    percentual_conclusao,
    submissoes_pendentes,
    submissoes_rejeitadas,
    dias_sem_submeter,
    horas_aprovadas,
    horas_restantes,
    nivel_risco,
    justificativa,
    data_calculo
FROM classificacao_risco
ORDER BY
    aluno_id,
    curso_id,
    data_calculo DESC;

-- Log de cada execução dos scripts Python da pipeline

CREATE TABLE pipeline_execucoes (
    id                              BIGSERIAL PRIMARY KEY,
    nome_pipeline                   VARCHAR(100)         NOT NULL,
    status_execucao                 status_execucao_enum NOT NULL DEFAULT 'em_andamento',
    inicio_execucao                 TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fim_execucao                    TIMESTAMP,
    quantidade_registros_lidos      INTEGER DEFAULT 0,
    quantidade_registros_gravados   INTEGER DEFAULT 0,
    mensagem                        TEXT
);

CREATE INDEX idx_pipeline_nome
    ON pipeline_execucoes(nome_pipeline);

CREATE INDEX idx_pipeline_status
    ON pipeline_execucoes(status_execucao);

CREATE INDEX idx_pipeline_inicio
    ON pipeline_execucoes(inicio_execucao DESC);
