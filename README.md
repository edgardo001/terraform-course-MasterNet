# MasterNet

Plataforma educativa en línea construida con **.NET 10** y **Arquitectura Limpia (DDD/CQRS)**, desplegada en **Microsoft Azure** mediante **Terraform** como Infraestructura como Código (IaC) y **GitHub Actions** para CI/CD.

---

## Arquitectura

El proyecto sigue los principios de **Clean Architecture** con 5 capas:

```mermaid
graph TD
    subgraph Presentación
        WebApi[MasterNet.WebApi]
    end
    subgraph Infraestructura
        Infrastructure[MasterNet.Infrastructure]
    end
    subgraph Persistencia
        Persistence[MasterNet.Persistence]
    end
    subgraph Aplicación
        Application[MasterNet.Application]
    end
    subgraph Dominio
        Domain[MasterNet.Domain]
    end

    WebApi --> Application
    WebApi --> Infrastructure
    Application --> Domain
    Application --> Persistence
    Infrastructure --> Application
    Persistence --> Domain
    Infrastructure --> Persistence
```

| Capa | Proyecto | Responsabilidad |
|------|----------|----------------|
| **Domain** | `MasterNet.Domain` | Entidades, Value Objects, Abstracciones (`BaseEntity`, `IGenericRepository`, `IUnitOfWork`, `ISpecification`) |
| **Application** | `MasterNet.Application` | Casos de uso CQRS (Commands/Queries), `Result<T>`, validaciones, interfaces de servicio |
| **Persistence** | `MasterNet.Persistence` | EF Core DbContext, repositorios, Unit of Work, migraciones, seed data |
| **Infrastructure** | `MasterNet.Infrastructure` | JWT Token Service, Cloudinary (fotos), reportes CSV, UserAccessor |
| **WebApi** | `MasterNet.WebApi` | Controladores REST, middleware de errores, OData, Health Checks |

### Flujo de una solicitud

```mermaid
sequenceDiagram
    actor User as Cliente
    participant API as WebApi
    participant MW as ExceptionMiddleware
    participant Auth as JWT Auth
    participant Ctrl as Controller
    participant Mediator as Core.MediatOR
    participant Handler as Command/Query Handler
    participant Repo as Repository
    participant DB as SQL Server

    User->>API: HTTP Request
    API->>MW: Pasa por middleware
    MW->>Auth: Valida JWT (si aplica)
    Auth->>Ctrl: Usuario autenticado
    Ctrl->>Mediator: Envía IRequest<T>
    Mediator->>Mediator: Pipeline behaviors (validación)
    Mediator->>Handler: Ejecuta handler
    Handler->>Repo: Consulta/escribe datos
    Repo->>DB: SQL Query
    DB-->>Repo: Resultado
    Repo-->>Handler: Datos
    Handler-->>Mediator: Result<T>
    Mediator-->>Ctrl: Respuesta
    Ctrl-->>User: HTTP Response
```

### Librerías personalizadas

```mermaid
graph LR
    subgraph Core.MediatOR
        direction TB
        IMediator --> IRequestHandler
        IRequestHandler --> IPipelineBehavior
    end
    subgraph Core.Mappy
        direction TB
        IMapper --> IConfigurationProvider
        IConfigurationProvider --> IMappingProfile
    end
    WebApi[WebApi] --> Core.MediatOR
    WebApi --> Core.Mappy
    Application --> Core.MediatOR
    Application --> Core.Mappy
```

- **`Core.MediatOR`** — Implementación propia del patrón Mediator (CQRS) con soporte para pipeline behaviors
- **`Core.Mappy`** — Mapeador objeto-a-objeto propio con `ProjectTo<T>` para IQueryable

---

## Tecnologías

### Backend
- .NET 10 (SDK `10.0.100-rc.1`)
- ASP.NET Core Web API
- Entity Framework Core 10
- Microsoft.AspNetCore.Identity
- JWT Bearer Authentication
- OData (Microsoft.AspNetCore.OData 9.4.0)
- Swagger UI

### Base de datos
- Azure SQL Database (SQL Server)
- SQLite (para pruebas locales)

### Infraestructura en Azure

```mermaid
graph TD
    subgraph "Azure - East US"
        RG[Resource Group<br/>nu-masternet-dev-eus-rg]
        SQL[SQL Server<br/>nu-masternet-dev-eus-sqlserver-main]
        DB[(SQL Database<br/>nu-masternet-dev-eus-db)]
        ACR[Container Registry<br/>numasternet{env_id}eusacr]
        LAW[Log Analytics<br/>nu-masternet-{env_id}-eus-law]
        ACAE[Container App Environment<br/>nu-masternet-dev-eus-acae]
        ACA[Container App<br/>nu-masternet-dev-eus-aca]
    end

    subgraph "Azure Storage"
        STATE[(Terraform State<br/>nuiacdeveusac)]
    end

    RG --> SQL
    RG --> ACR
    RG --> LAW
    RG --> ACAE
    SQL --> DB
    ACAE --> ACA
    ACAE --> LAW
    ACA -.-> ACR
    ACA -.-> SQL
```

| Recurso | Nombre |
|---------|--------|
| Resource Group | `nu-masternet-dev-eus-rg` |
| SQL Server | `nu-masternet-dev-eus-sqlserver-main` |
| SQL Database | `nu-masternet-dev-eus-db` |
| Container Registry | `numasternet{env_id}eusacr` |
| Log Analytics | `nu-masternet-{env_id}-eus-law` |
| Container App Environment | `nu-masternet-dev-eus-acae` |
| Container App | `nu-masternet-dev-eus-aca` |

### DevOps
- Terraform (azurerm 4.47.0)
- GitHub Actions
- Docker / Docker Compose

---

## API Endpoints

### Cursos
| Método | Ruta | Auth |
|--------|------|------|
| GET | `/api/courses` | Anónimo (paginado) |
| GET | `/api/courses/{id}` | Anónimo |
| POST | `/api/courses` | `COURSE_WRITE` |
| PUT | `/api/courses/{id}` | `COURSE_UPDATE` |
| DELETE | `/api/courses/{id}` | `COURSE_DELETE` |
| GET | `/api/courses/report` | Anónimo (CSV) |

### Instructores
| Método | Ruta | Auth |
|--------|------|------|
| GET | `/api/instructors` | Anónimo |
| POST | `/api/instructors` | Anónimo |

### Precios y Ratings
| Método | Ruta | Auth |
|--------|------|------|
| GET | `/api/prices` | Anónimo |
| GET | `/api/ratings` | Anónimo |

### Cuenta
| Método | Ruta | Auth |
|--------|------|------|
| POST | `/api/account/login` | Anónimo |
| POST | `/api/account/register` | Anónimo |
| GET | `/api/account/me` | Autorizado |

### Dispositivos
| Método | Ruta | Auth |
|--------|------|------|
| GET | `/api/devices` | Anónimo |

### Reportes
| Método | Ruta | Auth |
|--------|------|------|
| GET | `/odata/courses` | Anónimo (OData) |

### Health Check
| Método | Ruta |
|--------|------|
| GET | `/health` |

---

## Roles y Políticas

### Roles
- **ADMIN** — Acceso completo a todas las políticas
- **CLIENT** — Solo lectura y ratings

### Policies (10)
`COURSE_READ`, `COURSE_WRITE`, `COURSE_UPDATE`, `COURSE_DELETE`, `COMMENT_READ`, `COMMENT_WRITE`, `COMMENT_UPDATE`, `COMMENT_DELETE`, `RATING_READ`, `RATING_WRITE`

---

## Seed Data

Al iniciar por primera vez, la aplicación:
1. Ejecuta migraciones automáticas
2. Crea los roles ADMIN y CLIENT
3. Crea usuarios de prueba:
   - `vaxidrez` (Admin) — `Password123$`
   - `johndoe` (Client) — `Password123$`
4. Carga datos desde archivos JSON en `src/MasterNet.Persistence/SeedData/`

---

## Base de Datos

```mermaid
erDiagram
    courses {
        guid Id PK
        string Title
        string Description
        datetime CreatedAt
        datetime UpdatedAt
    }
    instructors {
        guid Id PK
        string Name
        string LastName
        string Email
        string Phone
    }
    prices {
        guid Id PK
        decimal CurrentPrice
        decimal Promotion
        string Currency
    }
    ratings {
        guid Id PK
        int Score
        string Comment
        guid CourseId FK
        string Author
    }
    images {
        guid Id PK
        string Url
        string PublicId
        guid CourseId FK
    }
    devices {
        guid Id PK
        string DeviceName_Name
    }
    courses_instructors {
        guid CourseId FK
        guid InstructorId FK
    }
    courses_prices {
        guid CourseId FK
        guid PriceId FK
    }
    AspNetUsers {
        guid Id PK
        string UserName
        string Email
        string PasswordHash
    }
    AspNetRoles {
        guid Id PK
        string Name
    }

    courses ||--o{ ratings : has
    courses ||--o{ images : has
    courses ||--o{ courses_instructors : has
    courses ||--o{ courses_prices : has
    instructors ||--o{ courses_instructors : has
    prices ||--o{ courses_prices : has
    AspNetUsers }|--|| AspNetRoles : has
```

### Tablas principales
- `courses`, `instructors`, `prices`, `ratings`, `images`
- `devices` (con Value Object `DeviceName`)
- `courses_instructors`, `courses_prices` (join many-to-many)
- `AspNetUsers`, `AspNetRoles`, `AspNetUserRoles`, `AspNetRoleClaims` (Identity)

---

## Infraestructura (Terraform)

Los archivos IaC están en el directorio `iac/`:

| Archivo | Propósito |
|---------|-----------|
| `setup.tf` | Provider, backend |
| `vars.tf` | Variables de entrada |
| `resource-group.tf` | Resource Group |
| `azure-sql-db.tf` | SQL Server + Database + Firewall |
| `azure-container-apps.tf` | Container App |
| `azure-container-app-env.tf` | Container App Environment |
| `acr.tf` | Container Registry |
| `azure-law.tf` | Log Analytics Workspace |

El estado de Terraform se almacena en Azure Storage (`nuiacdeveusac` / contenedor `terraform`).

---

## CI/CD (GitHub Actions)

```mermaid
graph LR
    subgraph "GitHub"
        REPO[Repositorio main]
        IAC_WF[iac-deploy.yaml]
        API_WF[api-deploy.yaml]
    end
    subgraph "IaC"
        TF_INIT[terraform init]
        TF_VAL[terraform validate]
        TF_PLAN[terraform plan]
        TF_APPLY[terraform apply]
    end
    subgraph "API"
        BUILD[Docker Build]
        PUSH[Docker Push to ACR]
        DEPLOY[Deploy to ACA]
    end

    REPO -. cambio en iac/** .-> IAC_WF
    REPO -. cambio en src/** .-> API_WF
    IAC_WF --> TF_INIT --> TF_VAL --> TF_PLAN --> TF_APPLY
    API_WF --> BUILD --> PUSH --> DEPLOY
    API_WF -. requiere IaC exitoso .-> IAC_WF
```

### `iac-deploy.yaml`
- **Trigger:** Cambios en `iac/**` en la rama `main`
- **Flujo:** `init` → `validate` → `plan` → `apply`
- **Backend:** Azure Storage (`nuiacdeveusac`)

### `api-deploy.yaml`
- **Trigger:** Pushes a `main` (depende de IaC exitoso)
- **Flujo:** Build Docker → Push a ACR → Deploy a Container App

---

## Desarrollo Local

### Requisitos previos

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| .NET SDK | `10.0.100-rc.1` | Compilación y ejecución |
| Docker Desktop | Última | SQL Server local (Azure SQL Edge) |
| Azure CLI | Última | Autenticación con Azure (opcional) |
| Terraform | >= 1.x | Infraestructura local (opcional) |

### Ejecutar en desarrollo

```mermaid
flowchart TD
    A[Clonar repositorio] --> B[docker-compose up -d]
    B --> C[dotnet restore]
    C --> D[dotnet build]
    D --> E[dotnet run <br/>--project src/MasterNet.WebApi]
    E --> F[API en localhost:5000]
    F --> G[Swagger en /swagger]
    E --> H[(SQL Server Local<br/>Azure SQL Edge)]
```

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd MasterNet

# 2. Iniciar SQL Server local con Docker Compose
#    Usa azure-sql-edge en puerto 1433
docker-compose up -d

# 3. Restaurar paquetes NuGet
dotnet restore

# 4. Compilar la solución
dotnet build

# 5. Iniciar la API (las migraciones se ejecutan automáticamente)
dotnet run --project src/MasterNet.WebApi
```

La API estará disponible en:
- **API:** `http://localhost:5000`
- **Swagger:** `http://localhost:5000/swagger`
- **Health Check:** `http://localhost:5000/health`

### Usuarios de prueba (seed data)

| Usuario | Rol | Contraseña |
|---------|-----|------------|
| `vaxidrez` | ADMIN | `Password123$` |
| `johndoe` | CLIENT | `Password123$` |

### Ejecutar con Docker

```bash
# Build de la imagen
docker build -f MasterNet.Dockerfile -t masternet-api .

# Ejecutar contenedor (requiere SQL Server configurado aparte)
docker run -p 8080:80 masternet-api
```

### Ejecutar pruebas

```bash
dotnet test tests/MasterNet.Application.UnitTests
```

---

## Despliegue a Producción

### Diagrama del Pipeline Completo

```mermaid
flowchart TD
    subgraph "Desarrollador"
        DEV[git push a main]
    end
    subgraph "GitHub Actions"
        IAC[iac-deploy.yaml]
        API[api-deploy.yaml]
    end
    subgraph "Terraform"
        INIT[terraform init]
        VAL[terraform validate]
        PLAN[terraform plan]
        APPLY[terraform apply]
    end
    subgraph "Azure"
        ACR[Container Registry]
        ACA[Container App]
        SQL[(SQL Database)]
    end
    subgraph "Docker"
        BUILD[Build Image]
        PUSH[Push Image]
    end

    DEV --> IAC
    IAC --> INIT --> VAL --> PLAN --> APPLY
    APPLY --> ACR
    APPLY --> ACA
    APPLY --> SQL

    DEV --> API
    API --> BUILD --> PUSH --> ACR
    ACR -.-> ACA
    ACA -.-> SQL
```

### Paso 1: Infraestructura con Terraform

```bash
# Navegar al directorio de IaC
cd iac

# Inicializar Terraform (configura el backend en Azure Storage)
terraform init

# Validar la configuración
terraform validate

# Ver el plan de cambios
terraform plan

# Aplicar la infraestructura en Azure
terraform apply -auto-approve
```

**Archivos de IaC:**

| Archivo | Recurso que crea |
|---------|-----------------|
| `setup.tf` | Provider y backend |
| `vars.tf` | Variables de entrada |
| `resource-group.tf` | Resource Group |
| `azure-sql-db.tf` | SQL Server + Database + Firewall Rule |
| `azure-container-apps.tf` | Container App |
| `azure-container-app-env.tf` | Container App Environment |
| `acr.tf` | Container Registry |
| `azure-law.tf` | Log Analytics Workspace |

### Paso 2: CI/CD Automático (GitHub Actions)

**Workflow IaC (`.github/workflows/iac-deploy.yaml`)**
- Se activa automáticamente al hacer push a `main` con cambios en `iac/`
- Ejecuta `init` → `validate` → `plan` → `apply`
- Aprovisiona/actualiza todos los recursos de Azure

**Workflow API (`.github/workflows/api-deploy.yaml`)**
- Se activa al hacer push a `main` con cambios en `src/`
- Construye la imagen Docker multi-stage
- La publica en Azure Container Registry (ACR)
- Despliega la nueva imagen en Azure Container App (ACA)
- La ACA se conecta a Azure SQL Database

### Paso 3: Verificar el despliegue

```bash
# Obtener la URL de la Container App
az containerapp show \
  --name nu-masternet-dev-eus-aca \
  --resource-group nu-masternet-dev-eus-rg \
  --query properties.configuration.ingress.fqdn

# Verificar health check
curl https://<fqdn>/health

# Probar login con usuario seed
curl -X POST https://<fqdn>/api/account/login \
  -H "Content-Type: application/json" \
  -d '{"email":"vaxidrez","password":"Password123$"}'
```

### Variables de entorno requeridas

| Variable | Descripción |
|----------|-------------|
| `ConnectionStrings__DefaultConnection` | Cadena de conexión a Azure SQL |
| `JwtSettings__Key` | Clave secreta para firmar JWT |
| `JwtSettings__Issuer` | Emisor del token JWT |
| `JwtSettings__Audience` | Audiencia del token JWT |
| `Cloudinary__CloudName` | Nombre del cloud en Cloudinary |
| `Cloudinary__ApiKey` | API Key de Cloudinary |
| `Cloudinary__ApiSecret` | API Secret de Cloudinary |

---

## Estructura del Proyecto

```
MasterNet/
├── .github/workflows/          # CI/CD pipelines
├── iac/                        # Terraform (IaC)
├── libs/
│   ├── Core.Mappy/             # Mapeador personalizado
│   └── Core.MediatOR/          # Mediator personalizado (CQRS)
├── src/
│   ├── MasterNet.Domain/       # Capa de dominio
│   ├── MasterNet.Application/  # Capa de aplicación
│   ├── MasterNet.Persistence/  # Capa de persistencia
│   ├── MasterNet.Infrastructure/ # Capa de infraestructura
│   └── MasterNet.WebApi/       # API REST
├── tests/
│   └── MasterNet.Application.UnitTests/
├── MasterNet.Dockerfile        # Docker multi-stage
├── docker-compose.yml          # SQL Server local
├── global.json                 # SDK version
└── MasterNet.sln               # Solución .NET
```

---

## Licencia

Este proyecto es con fines educativos como parte de un curso de Terraform.
