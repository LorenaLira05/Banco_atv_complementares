# Banco de Dados — Sistema de Atividades Complementares SENAC

Este repositório contém os scripts SQL do banco de dados do sistema de gestão de atividades complementares.

---

## Pré-requisitos

- [PostgreSQL 14+](https://www.postgresql.org/download/)
- [pgAdmin](https://www.pgadmin.org/) 
---

## 🚀 Como configurar o banco do zero

### 1. Crie o banco de dados

Dentro do psql:
```sql
CREATE DATABASE atividades_complementares_senac;

```

---

### 2. Execute os scripts na ordem correta

> ⚠️ A ordem importa! Execute um por vez e verifique se não houve erros antes de continuar.

#### Via pgAdmin:
1. Conecte ao banco `senac_atividades`
2. Abra cada arquivo `.sql` no Query Tool
3. Execute na ordem: `script_principal.sql` → `seed.sql`

---

## Estrutura dos arquivos

```
/
├── script_principal.sql   # Criação das tabelas, enums, índices e views
├── triggers.sql           # Triggers de integridade e automação
├── seed.sql               # Dados de exemplo para desenvolvimento
└── README.md              # Este arquivo
```

---

## Usuários disponíveis após o seed

Todos os usuários têm senha padrão: **`123456`**

| Perfil | E-mail | Curso |
|---|---|---|
| Super Admin | admin@senac.com | — |
| Coordenador | ricardo@senac.com | ADS |
| Coordenador | helena@senac.com | Design Gráfico |
| Aluno | lucas@aluno.senac.com | ADS (ativo) |
| Aluno | ana@aluno.senac.com | ADS (ativo) |
| Aluno | mateus@aluno.senac.com | ADS (trancado) |
| Aluno | julia@aluno.senac.com | Design (ativo) |
| Aluno | pedro@aluno.senac.com | Design (pendente financeiro) |

---

## Visão geral das tabelas

| Tabela | Descrição |
|---|---|
| `users` | Dados pessoais e autenticação de todos os usuários |
| `roles` | Papéis do sistema: `super_admin`, `coordinator`, `student` |
| `user_roles` | Vínculo entre usuário e papel |
| `courses` | Cursos cadastrados na instituição |
| `student_profiles` | Dados específicos do aluno (RA) |
| `coordinator_profiles` | Dados específicos do coordenador (departamento, cargo, etc.) |
| `user_courses` | Vínculo entre aluno e curso + status de matrícula |
| `course_coordinators` | Vínculo entre coordenador e curso (1 coordenador por curso) |
| `categories` | Tipos de atividades complementares |
| `course_activity_rules` | Regras de horas por categoria para cada curso |
| `submissions` | Submissões de atividades feitas pelos alunos |
| `submission_files` | Arquivos/comprovantes das submissões |
| `validations` | Histórico de validações feitas pelos coordenadores |
| `notifications` | Notificações enviadas aos usuários |
| `audit_logs` | Log de auditoria de todas as ações do sistema |

---

## Triggers

| Trigger | Tabela | O que faz |
|---|---|---|
| `trg_*_updated_at` | Várias | Atualiza `updated_at` automaticamente a cada UPDATE |
| `trg_prevent_editing_closed` | `submissions` | Impede edição de submissões já aprovadas ou reprovadas |

---

## Configuração no back-end

No arquivo `.env` do projeto back-end, configure as variáveis de conexão:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=senac_atividades
DB_USER=postgres
DB_PASS=sua_senha
```

---

## ❓ Problemas comuns

**Erro: `role "postgres" does not exist`**
Troque `postgres` pelo seu usuário do PostgreSQL local.

**Erro: `database "senac_atividades" does not exist`**
Rode o passo 1 (criação do banco) antes de executar os scripts.

**Erro: `already exists` em alguma tabela**
O banco já foi criado antes. O `script_principal.sql` tem `DROP TABLE IF EXISTS` no início — pode rodar novamente sem problema, mas **todos os dados serão apagados**.

**Senha do seed não funciona no back-end**
O hash no `seed.sql` é um exemplo. Se não funcionar, gere um novo hash rodando no terminal do projeto back-end:
```javascript
const bcrypt = require('bcryptjs');
bcrypt.hash('123456', 10).then(console.log);
```
Substitua o hash no `seed.sql` pelo valor gerado e rode novamente.
