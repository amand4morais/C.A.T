CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ra TEXT UNIQUE NOT NULL,
  nome TEXT NOT NULL,
  data_nascimento TEXT NOT NULL,
  email TEXT NOT NULL,
  senha TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'aluno',
  cep TEXT,
  logradouro TEXT,
  bairro TEXT,
  localidade TEXT,
  uf TEXT,
  foto_url TEXT
);

ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cep TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS logradouro TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS bairro TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS localidade TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS uf TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS foto_url TEXT;

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
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "avatars_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "avatars_public_insert" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "avatars_public_update" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars');
