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

-- Idempotente: cobre projetos cuja tabela profiles já existia antes da
-- Parte 3 (CREATE TABLE acima não adiciona coluna em tabela já existente).
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS foto_url text,
  ADD COLUMN IF NOT EXISTS cep text,
  ADD COLUMN IF NOT EXISTS logradouro text,
  ADD COLUMN IF NOT EXISTS bairro text,
  ADD COLUMN IF NOT EXISTS localidade text,
  ADD COLUMN IF NOT EXISTS uf text;

NOTIFY pgrst, 'reload schema';

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

-- Sequence pra gerar RA de forma atômica, sem colisão entre dispositivos
CREATE SEQUENCE IF NOT EXISTS ra_sequence;

SELECT setval(
  'ra_sequence',
  COALESCE((SELECT MAX(ra::bigint) FROM profiles WHERE ra ~ '^[0-9]+$'), 999) + 1,
  false
);

CREATE OR REPLACE FUNCTION generate_next_ra()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN nextval('ra_sequence')::TEXT;
END;
$$;

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- storage.objects pertence à role supabase_storage_admin: ALTER/CREATE POLICY
-- via SQL Editor falha com "must be owner of table objects". Configure a
-- policy manualmente: Dashboard > Storage > bucket "avatars" > Policies >
-- New policy > For full customization > operations INSERT e UPDATE,
-- target role "anon", expressão: bucket_id = 'avatars'
