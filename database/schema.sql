CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ra TEXT UNIQUE NOT NULL,
  nome TEXT NOT NULL,
  data_nascimento TEXT NOT NULL,
  email TEXT NOT NULL,
  senha TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'aluno',
  foto_url text,
  cep text,
  logradouro text,
  bairro text,
  localidade text,
  uf text
);

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL
);

ALTER TABLE courses DISABLE ROW LEVEL SECURITY;

CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE
);

ALTER TABLE enrollments DISABLE ROW LEVEL SECURITY;

INSERT INTO profiles (ra, nome, email, senha, data_nascimento, role)
VALUES ('admin', 'Administrador do Sistema', 'admin@cat.com', 'admin', '2000-01-01', 'admin');

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
