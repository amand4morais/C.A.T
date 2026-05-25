CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ra TEXT UNIQUE NOT NULL,
  nome TEXT NOT NULL,
  data_nascimento TEXT NOT NULL,
  email TEXT NOT NULL,
  senha TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'aluno'
);

CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE
);

INSERT INTO profiles (ra, nome, email, senha, role)
VALUES ('admin', 'Administrador', 'admin@cat.com', 'admin', 'admin');
