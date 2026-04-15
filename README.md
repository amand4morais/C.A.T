# CAT — Cursos e Aprendizado

Aplicativo mobile desenvolvido em Flutter para gerenciamento de cursos acadêmicos. Permite que alunos visualizem e se inscrevam em cursos disponíveis, e que administradores cadastrem novos cursos na plataforma.

---

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

### Administrador
- Login com credenciais fixas (`admin` / `admin`)
- Painel exclusivo de gerenciamento de cursos
- Cadastro de novos cursos (título e descrição)
- Visualização de todos os cursos cadastrados na plataforma

---

## Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com gerenciamento de estado via **Provider**.

```
Model  →  Repository  →  ViewModel  →  View
```

- **Model**: classes de dados puras (`User`, `Course`)
- **Repository**: acesso e manipulação de dados; padrão Singleton para garantir estado único em memória; `AuthRepository` usa `SharedPreferences` para persistência
- **ViewModel**: lógica de negócio e estado da UI, exposto via `ChangeNotifier`
- **View**: widgets Flutter que consomem o ViewModel via `Consumer<T>`, sem lógica de negócio

A navegação é gerenciada pelo **GoRouter**, com rota inicial dinâmica definida no `main()` com base no estado de login persistido.

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
│   └── course_repository.dart
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

### Dependências principais

| Pacote | Versão | Finalidade |
|---|---|---|
| `provider` | ^6.1.2 | Gerenciamento de estado |
| `go_router` | ^14.x | Navegação declarativa |
| `shared_preferences` | ^2.x | Persistência de sessão e usuários |

> As versões exatas estão registradas no `pubspec.lock`.

---

## Credenciais de Acesso

### Administrador (conta fixa)

| Campo | Valor |
|---|---|
| R.A | `admin` |
| Senha | `admin` |

### Aluno

Realize o cadastro pela tela de registro. O R.A é gerado automaticamente pelo sistema a partir do número **1000** e exibido ao final do cadastro. **Anote o R.A**, pois ele é necessário para o login e não é recuperável pela interface.

---

## Relatório da Equipe

### Integrantes

- Amanda Morais Ribeiro
- José Ernesto Marra Filho
- Leonardo Bonfanti

### Divisão de Atividades

| Integrante | Atividades desenvolvidas |
|---|---|
| Amanda Morais Ribeiro | x |
| José Ernesto Marra Filho | x |
| Leonardo Bonfanti | x |

### Particularidades e Observações

#### Autenticação
A autenticação não utiliza tokens nem criptografia de senha. As senhas são armazenadas em texto puro no `SharedPreferences`, o que é adequado apenas para fins acadêmicos e de demonstração.

#### Conta administrador
As credenciais do administrador (`admin` / `admin`) são fixas e definidas diretamente no código (`AuthRepository`). Não há interface para criação ou alteração de contas administrativas.

#### Funcionalidades não implementadas
- Cancelamento de inscrição em curso
- Persistência de inscrições entre sessões
- Edição ou remoção de cursos pelo administrador
