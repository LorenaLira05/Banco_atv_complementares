-- SEED - DADOS DE EXEMPLO--
-- Seed é um script que popula o banco com dados iniciais
-- de exemplo para facilitar o desenvolvimento e os testes.
-- Todos os usuários têm senha padrão: 123456
-- Rodar APÓS o script principal e os triggers.

INSERT INTO courses (name, code, minimum_required_hours, description, modalidade, turno, semestres) VALUES
(
    'Análise e Desenvolvimento de Sistemas',
    'ADS',
    200,
    'Curso superior de tecnologia focado em desenvolvimento de software.',
    'Presencial',
    'Noturno',
    5
),
(
    'Design Gráfico',
    'DSG',
    160,
    'Curso superior de tecnologia focado em design visual e comunicação.',
    'EAD',
    'Noturno',
    4
);


INSERT INTO categories (name, description) VALUES
('Extensão Universitária', 'Atividades de extensão realizadas dentro ou fora da instituição.'),
('Eventos e Palestras', 'Participação em eventos, seminários, palestras e workshops.'),
('Monitoria Acadêmica', 'Atividades de monitoria em disciplinas do curso.'),
('Curso Livre', 'Cursos extracurriculares relacionados à área de formação.');

-- Regras para ADS
INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 80, false, 'Máximo de 80h em extensão para ADS.'
FROM courses c, categories cat
WHERE c.code = 'ADS' AND cat.name = 'Extensão Universitária';

INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 40, false, 'Máximo de 40h em eventos para ADS.'
FROM courses c, categories cat
WHERE c.code = 'ADS' AND cat.name = 'Eventos e Palestras';

INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 60, false, 'Máximo de 60h em monitoria para ADS.'
FROM courses c, categories cat
WHERE c.code = 'ADS' AND cat.name = 'Monitoria Acadêmica';

INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 40, false, 'Máximo de 40h em cursos livres para ADS.'
FROM courses c, categories cat
WHERE c.code = 'ADS' AND cat.name = 'Curso Livre';

-- Regras para Design Gráfico
INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 60, false, 'Máximo de 60h em extensão para Design.'
FROM courses c, categories cat
WHERE c.code = 'DSG' AND cat.name = 'Extensão Universitária';

INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 40, false, 'Máximo de 40h em eventos para Design.'
FROM courses c, categories cat
WHERE c.code = 'DSG' AND cat.name = 'Eventos e Palestras';

INSERT INTO course_activity_rules (course_id, category_id, min_hours, max_hours, is_required, notes)
SELECT c.id, cat.id, 0, 40, false, 'Máximo de 40h em cursos livres para Design.'
FROM courses c, categories cat
WHERE c.code = 'DSG' AND cat.name = 'Curso Livre';


-- =========================================================
-- USUÁRIOS
-- Todos com senha 123456 já criptografada com bcrypt (10 rounds)
-- Para gerar um novo hash: bcrypt.hash('123456', 10)
-- =========================================================

INSERT INTO users (full_name, email, password_hash, phone, cpf) VALUES
-- Super Admin
('Super Admin',         'admin@senac.br',       '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', NULL,           NULL),
-- Coordenadores
('Ricardo Oliveira',    'ricardo@senac.br',      '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0001', '111.111.111-01'),
('Helena Souza',        'helena@senac.br',       '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0002', '111.111.111-02'),
-- Alunos
('Lucas Oliveira',      'lucas@aluno.senac.br',  '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0003', '222.222.222-01'),
('Ana Clara Mendes',    'ana@aluno.senac.br',    '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0004', '222.222.222-02'),
('Mateus Ferreira',     'mateus@aluno.senac.br', '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0005', '222.222.222-03'),
('Julia Santos',        'julia@aluno.senac.br',  '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0006', '222.222.222-04'),
('Pedro Alves',         'pedro@aluno.senac.br',  '$2a$10$7QJ8v3z1XkLmN9pQrS5tOeWvYuIoKjHgFdSaZxCvBnMqWeLrTyUpI', '(11)99999-0007', '222.222.222-05');


INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email = 'admin@senac.com' AND r.name = 'super_admin';

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email IN ('ricardo@senac.com', 'helena@senac.com') AND r.name = 'coordinator';

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.email IN (
    'lucas@aluno.senac.com',
    'ana@aluno.senac.com',
    'mateus@aluno.senac.com',
    'julia@aluno.senac.com',
    'pedro@aluno.senac.com'
) AND r.name = 'student';

INSERT INTO coordinator_profiles (user_id, departamento, cargo, data_admissao)
SELECT u.id, 'Tecnologia da Informação', 'Coordenador de Área', '2020-01-10'
FROM users u WHERE u.email = 'ricardo@senac.com';

INSERT INTO coordinator_profiles (user_id, departamento, cargo, data_admissao)
SELECT u.id, 'Design e Comunicação', 'Coordenadora de Área', '2019-03-05'
FROM users u WHERE u.email = 'helena@senac.com';

-- VÍNCULOS COORDENADOR x CURSO

INSERT INTO course_coordinators (user_id, course_id)
SELECT u.id, c.id FROM users u, courses c
WHERE u.email = 'ricardo@senac.com' AND c.code = 'ADS';

INSERT INTO course_coordinators (user_id, course_id)
SELECT u.id, c.id FROM users u, courses c
WHERE u.email = 'helena@senac.com' AND c.code = 'DSG';

-- RA é o número de registro acadêmico do aluno

INSERT INTO student_profiles (user_id, ra)
SELECT u.id, '2023001542' FROM users u WHERE u.email = 'lucas@aluno.senac.com';

INSERT INTO student_profiles (user_id, ra)
SELECT u.id, '2023000891' FROM users u WHERE u.email = 'ana@aluno.senac.com';

INSERT INTO student_profiles (user_id, ra)
SELECT u.id, '2022011233' FROM users u WHERE u.email = 'mateus@aluno.senac.com';

INSERT INTO student_profiles (user_id, ra)
SELECT u.id, '2023009988' FROM users u WHERE u.email = 'julia@aluno.senac.com';

INSERT INTO student_profiles (user_id, ra)
SELECT u.id, '2021084456' FROM users u WHERE u.email = 'pedro@aluno.senac.com';


-- =========================================================
-- VÍNCULOS ALUNO x CURSO
-- Lucas, Ana e Mateus estão em ADS
-- Julia e Pedro estão em Design
-- status_matricula: ativo | trancado | pendente_financeiro
-- =========================================================

INSERT INTO user_courses (user_id, course_id, status_matricula)
SELECT u.id, c.id, 'ativo' FROM users u, courses c
WHERE u.email = 'lucas@aluno.senac.com' AND c.code = 'ADS';

INSERT INTO user_courses (user_id, course_id, status_matricula)
SELECT u.id, c.id, 'ativo' FROM users u, courses c
WHERE u.email = 'ana@aluno.senac.com' AND c.code = 'ADS';

INSERT INTO user_courses (user_id, course_id, status_matricula)
SELECT u.id, c.id, 'trancado' FROM users u, courses c
WHERE u.email = 'mateus@aluno.senac.com' AND c.code = 'ADS';

INSERT INTO user_courses (user_id, course_id, status_matricula)
SELECT u.id, c.id, 'ativo' FROM users u, courses c
WHERE u.email = 'julia@aluno.senac.com' AND c.code = 'DSG';

INSERT INTO user_courses (user_id, course_id, status_matricula)
SELECT u.id, c.id, 'pendente_financeiro' FROM users u, courses c
WHERE u.email = 'pedro@aluno.senac.com' AND c.code = 'DSG';


-- =========================================================
-- SUBMISSÕES
-- Cenário variado: pendente, aprovada, reprovada, devolvida
-- =========================================================

-- Lucas - ADS - Evento (submitted = aguardando análise)
INSERT INTO submissions (user_course_id, category_id, title, description, activity_date, requested_hours, status, institution_name)
SELECT uc.id, cat.id,
    'Workshop de UX/UI Design',
    'Participação no workshop de interfaces e experiência do usuário.',
    '2023-10-12',
    20,
    'submitted',
    'SENAC SP'
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.name = 'Eventos e Palestras'
WHERE u.email = 'lucas@aluno.senac.com' AND c.code = 'ADS';

-- Ana - ADS - Extensão (approved)
INSERT INTO submissions (user_course_id, category_id, title, description, activity_date, requested_hours, approved_hours, status, institution_name)
SELECT uc.id, cat.id,
    'Palestra: Futuro da IA',
    'Palestra sobre inteligência artificial e mercado de trabalho.',
    '2023-10-11',
    4,
    4,
    'approved',
    'FIAP'
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.name = 'Extensão Universitária'
WHERE u.email = 'ana@aluno.senac.com' AND c.code = 'ADS';

-- Mateus - ADS - Monitoria (rejected)
INSERT INTO submissions (user_course_id, category_id, title, description, activity_date, requested_hours, status, institution_name)
SELECT uc.id, cat.id,
    'Monitoria de Algoritmos',
    'Monitoria na disciplina de algoritmos e estruturas de dados.',
    '2023-10-10',
    40,
    'rejected',
    'SENAC SP'
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.name = 'Monitoria Acadêmica'
WHERE u.email = 'mateus@aluno.senac.com' AND c.code = 'ADS';

-- Julia - Design - Curso Livre (submitted)
INSERT INTO submissions (user_course_id, category_id, title, description, activity_date, requested_hours, status, institution_name)
SELECT uc.id, cat.id,
    'Curso de Ilustração Digital',
    'Curso online de ilustração digital com foco em design editorial.',
    '2023-10-09',
    30,
    'submitted',
    'Alura'
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.name = 'Curso Livre'
WHERE u.email = 'julia@aluno.senac.com' AND c.code = 'DSG';

-- Pedro - Design - Extensão (returned_for_adjustment)
INSERT INTO submissions (user_course_id, category_id, title, description, activity_date, requested_hours, status, institution_name)
SELECT uc.id, cat.id,
    'Voluntariado Senac Portas Abertas',
    'Participação como voluntário no evento institucional.',
    '2023-10-08',
    8,
    'returned_for_adjustment',
    'SENAC SP'
FROM user_courses uc
JOIN users u ON u.id = uc.user_id
JOIN courses c ON c.id = uc.course_id
JOIN categories cat ON cat.name = 'Extensão Universitária'
WHERE u.email = 'pedro@aluno.senac.com' AND c.code = 'DSG';

-- Histórico de decisões do coordenador nas submissõe

-- Validação da submissão aprovada da Ana
INSERT INTO validations (submission_id, validator_user_id, validation_status, previous_status, comment, approved_hours)
SELECT s.id, u.id, 'approved', 'submitted', 'Atividade válida e dentro do limite da categoria.', 4
FROM submissions s
JOIN user_courses uc ON uc.id = s.user_course_id
JOIN users u ON u.email = 'ricardo@senac.com'
WHERE s.title = 'Palestra: Futuro da IA';

-- Validação da submissão reprovada do Mateus
INSERT INTO validations (submission_id, validator_user_id, validation_status, previous_status, comment, approved_hours)
SELECT s.id, u.id, 'rejected', 'submitted', 'Comprovante ilegível. Necessário reenviar documento original.', NULL
FROM submissions s
JOIN user_courses uc ON uc.id = s.user_course_id
JOIN users u ON u.email = 'ricardo@senac.com'
WHERE s.title = 'Monitoria de Algoritmos';

-- Validação devolvida do Pedro
INSERT INTO validations (submission_id, validator_user_id, validation_status, previous_status, comment, approved_hours)
SELECT s.id, u.id, 'returned_for_adjustment', 'submitted', 'Falta assinatura do responsável no certificado.', NULL
FROM submissions s
JOIN user_courses uc ON uc.id = s.user_course_id
JOIN users u ON u.email = 'helena@senac.com'
WHERE s.title = 'Voluntariado Senac Portas Abertas';
