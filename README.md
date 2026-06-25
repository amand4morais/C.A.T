# CAT — Cursos e Aprendizado

Aplicativo mobile desenvolvido em Flutter para gerenciamento de cursos acadêmicos. Permite que alunos visualizem e se inscrevam em cursos disponíveis, e que administradores cadastrem, editem e removam cursos na plataforma.

## Sumário
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Configuração](#instalação-e-configuração)
- [Credenciais de Acesso](#credenciais-de-acesso)
- [Relatório da Equipe](#relatório-da-equipe)

---

## Funcionalidades

### Aluno
- Cadastro com geração automática de R.A numérico sequencial
- Login com R.A e senha, com persistência de sessão entre execuções
- Visualização dos cursos nos quais está inscrito (tela principal)
- Busca/filtro de cursos em tempo real
- Navegação para detalhes de cada curso
- Inscrição em cursos disponíveis via modal e diálogo de confirmação
- Indicação visual de cursos já inscritos na listagem
- Indicador de carregamento (`CircularProgressIndicator`) durante requisições de rede

### Administrador
- Login com credenciais fixas (admin / admin)
- Painel exclusivo de gerenciamento de cursos
- Cadastro de novos cursos (título e descrição)
- Edição de cursos existentes
- Remoção de cursos com diálogo de confirmação
- Visualização de todos os cursos cadastrados na plataforma
- Indicador de carregamento (`CircularProgressIndicator`) durante requisições de rede

### Entrega 3 — Integração com APIs e Recursos Nativos

Funcionalidades adicionadas ao Perfil do Utilizador na terceira entrega:

- Captura de foto de perfil utilizando a câmera nativa do dispositivo ou escolha a partir da galeria
- Upload e armazenamento em nuvem da imagem de perfil (Supabase Storage)
- Preenchimento automático de dados de endereço (Logradouro, Bairro, Cidade, UF) a partir da digitação do CEP, consumindo a API pública do ViaCEP

---

## Arquitetura

O projeto segue o padrão MVVM (Model-View-ViewModel) com gerenciamento de estado via Provider.

```
Model  →  Repository  →  ViewModel  →  View
```

- **Model:** classes de dados puras (`User`, `Course`)
- **Repository:** acesso e manipulação de dados; padrão Singleton para garantir estado único em memória; `AuthRepository` usa `SharedPreferences` para persistência
- **ViewModel:** lógica de negócio e estado da UI (`isLoading`, `errorMessage`), exposto via `ChangeNotifier`
- **View:** widgets Flutter que consomem o ViewModel via `Consumer<T>`, sem lógica de negócio

A navegação é gerenciada pelo GoRouter, com rota inicial dinâmica definida no `main()` com base no estado de login persistido.

### Entrega 2 — Integração com Nuvem (Supabase)

Na segunda entrega, os repositórios migraram de persistência local para o Supabase (PostgreSQL na nuvem):

- **AuthRepository:** mantém `SharedPreferences` apenas para sessão local (R.A logado); todos os dados de utilizadores residem na tabela `profiles` do Supabase
- **CourseRepository:** todas as operações de leitura, inserção, atualização e remoção de cursos comunicam diretamente com as tabelas `courses` e `enrollments` do Supabase
- As chaves de acesso são carregadas via `flutter_dotenv` a partir do ficheiro `.env` na raiz do projeto

---

## Estrutura de Pastas

```
lib/
├── main.dart
├── models/
│   ├── course_model.dart
│   └── user_model.dart
├── repositories/
│   ├── auth_repository.dart
│   ├── course_repository.dart
│   └── viacep_repository.dart
├── router/
│   └── app_router.dart
├── viewmodels/
│   ├── auth_viewmodel.dart
│   └── course_viewmodel.dart
├── views/
│   ├── add_course_view.dart
│   ├── admin_home_view.dart
│   ├── available_courses_view.dart
│   ├── course_details_view.dart
│   ├── home_view.dart
│   ├── login_view.dart
│   ├── profile_view.dart
│   └── register_view.dart
└── widgets/
    ├── course_card.dart
    ├── course_details_modal.dart
    └── registration_confirm_dialog.dart
```

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Flutter SDK | 3.18.0 |
| Dart SDK | 3.11.4 |
| Android SDK | API 21+ |
| Xcode (iOS) | 14.0+ |

Verifique sua instalação do Flutter com:

```bash
flutter doctor
```

---

## Instalação e Configuração

### 1. Clonar o repositório
```bash
git clone <url-do-repositorio>
cd cat_cursos
```

### 2. Instalar dependências
```bash
flutter pub get
```

### 3. Verificar dispositivos disponíveis
```bash
flutter devices
```

### 4. Executar o aplicativo
```bash
# Em modo debug (recomendado para desenvolvimento)
flutter run

# Em um dispositivo específico
flutter run -d <device-id>

# Em modo release
flutter run --release
```

### Entrega 2 — Configuração do Supabase

#### 5. Criar projeto no Supabase
Acesse [supabase.com](https://supabase.com), crie um novo projeto e anote a **Project URL** e a **anon public key** (em **Settings → API**).

#### 6. Executar o schema do banco de dados
No painel do Supabase, acesse **SQL Editor** e execute o conteúdo completo do ficheiro `database/schema.sql`. Isso criará as tabelas `profiles`, `courses` e `enrollments`, desativará o RLS e inserirá o administrador padrão.

#### 7. Configurar as chaves de acesso
Crie um ficheiro `.env` na raiz do projeto com o seguinte conteúdo:

```
SUPABASE_URL=https://<seu-projeto>.supabase.co
SUPABASE_ANON_KEY=<sua-anon-key>
```

As chaves são lidas em `lib/main.dart` via `flutter_dotenv`.

### Entrega 3 — Testes Nativos

> **Atenção:** para testar corretamente a funcionalidade de Câmera, o aplicativo deve ser compilado e executado em um **dispositivo físico (celular real) conectado via cabo USB**. Emuladores não possuem câmera real funcional, o que impede a validação completa dessa funcionalidade.

#### 8. Gerar o APK para produção
```bash
flutter build apk --release
```
O APK gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.

### Dependências principais

| Pacote | Versão | Finalidade |
|---|---|---|
| provider | ^6.1.2 | Gerenciamento de estado |
| go_router | ^14.x | Navegação declarativa |
| shared_preferences | ^2.x | Persistência de sessão local |
| supabase_flutter | ^2.x | Integração com banco de dados Supabase (Entrega 2) |
| flutter_dotenv | ^5.x | Carregamento de variáveis de ambiente via `.env` (Entrega 2) |
| http | ^1.2.1 | Consumo da API REST do ViaCEP (Entrega 3) |
| image_picker | ^1.1.1 | Acesso à câmera e galeria nativas do dispositivo (Entrega 3) |

As versões exatas estão registradas no `pubspec.lock`.

---

## Credenciais de Acesso

### Administrador (conta fixa)

| Campo | Valor |
|---|---|
| R.A | `admin` |
| Senha | `admin` |

#### Testando as funcionalidades de administrador

Após o login, você será redirecionado ao **Painel do Administrador**, identificado pela cor roxa e pelo título **"Gerenciar Cursos"**.

**Cadastrar novo curso:** toque no ícone `+` na AppBar → preencha título e descrição → toque em "Cadastrar Curso".

**Editar curso:** toque no ícone `⋮` no card do curso → selecione "Editar" → altere as informações → toque em "Salvar Alterações".

**Remover curso:** toque no ícone `⋮` no card do curso → selecione "Remover" → confirme no diálogo. O curso é removido da plataforma e das inscrições de todos os alunos.

Em todas as operações, um `CircularProgressIndicator` é exibido no centro da tela enquanto a operação está em andamento. Em caso de erro, uma mensagem é exibida com a opção "Tentar novamente".

### Aluno

Realize o cadastro pela tela de registro. O R.A é gerado automaticamente pelo sistema a partir do número 1000 e exibido ao final do cadastro. Anote o R.A, pois ele é necessário para o login e não é recuperável pela interface.

---

## Relatório da Equipe

### Integrantes

- Amanda Morais Ribeiro
- José Ernesto Marra Filho
- Leonardo Bonfanti

### Divisão de Atividades

| Integrante | Entrega 1 | Entrega 2 | Entrega 3 |
|---|---|---|---|
| Amanda Morais Ribeiro | Página inicial, detalhes de curso, adquirir curso, página de perfil e README | CRUD de cursos, refatoração da autenticação | Atualização do método `updateProfile` e gerenciamento de imagem no `AuthViewModel` |
| José Ernesto Marra Filho | Estrutura MVVM, verificação de login, perfil de admin, cadastro de cursos, correção de erros | Criação do banco de dados no Supabase, integração das chaves via `.env`, injeção de dependências, correções e refinamentos finais | Integração com o ViaCEP (`viacep_repository.dart`), configuração de permissões nativas e infraestrutura para o Supabase Storage |
| Leonardo Bonfanti | Rotas, telas de login/cadastro, filtro de cursos, exclusão e edição de cursos | Adição do campo `data_nascimento`, melhorias nas views e correção de erros de funcionalidade | Implementação da tela de perfil (`profile_view.dart`) com lógica de UI para foto de perfil e endereço |

### Particularidades e Observações

**Autenticação**
A autenticação não utiliza tokens nem criptografia de senha. As senhas são armazenadas em texto puro na tabela `profiles` do Supabase, o que é adequado apenas para fins acadêmicos e de demonstração.

**Conta administrador**
As credenciais do administrador (`admin` / `admin`) são inseridas diretamente no banco de dados via `database/schema.sql`. O reconhecimento do perfil admin é feito verificando se o R.A é igual a `'admin'` no `AuthRepository`. Não há interface para criação ou alteração de contas administrativas.

**Row Level Security (RLS)**
O RLS foi desativado em todas as tabelas do Supabase (`ALTER TABLE ... DISABLE ROW LEVEL SECURITY`) para simplificar o acesso durante o desenvolvimento académico. Em ambiente de produção real, políticas de RLS adequadas deveriam ser configuradas.

**Funcionalidades não implementadas**
- Cancelamento de inscrição em curso