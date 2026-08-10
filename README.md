# Projeto DevOps - Azure & Cloud Computing

Este repositório contém atividades práticas da disciplina de DevOps, desenvolvidas utilizando ambientes em nuvem através da Microsoft Azure e integração com o Visual Studio Code Web.

---

## Estrutura do projeto

### Aula01 — ACR e ACI (Azure Container Registry + Azure Container Instances)

Implantação do sistema de transações bancárias **DimDim** na nuvem Azure utilizando containers.

#### O que foi feito:

- Build das imagens Docker dos três serviços (MySQL, API Java, API .NET)
- Criação do **Azure Container Registry (ACR)** `moneyhub561810`
- Push das três imagens para o ACR
- Criação do **Azure Storage Account** para persistência do banco de dados
- Criação do **Azure Key Vault** com os secrets da aplicação
- Criação dos três **Azure Container Instances (ACI)**:
  - `mysql-dimdim` — banco de dados MySQL
  - `api-java` — API REST em Spring Boot (Java)
  - `api-dotnet` — API REST em .NET
- Homologação completa com operações GET, POST, PUT e DELETE entre as APIs

#### Scripts de deploy:

| Script | Descrição |
|--------|-----------|
| `01_store-account.sh` | Cria o Storage Account e o File Share para persistência do MySQL |
| `02_key-vault.sh` | Cria o Key Vault e armazena os secrets da aplicação |
| `03_aci-mysql.sh` | Cria o container do MySQL com volume persistente |
| `04_aci-api-java.sh` | Cria o container da API Java (Spring Boot) |
| `05_aci-api-dotnet.sh` | Cria o container da API .NET |

#### Arquitetura:
```
ACR (moneyhub561810.azurecr.io)
├── mysql-dimdim:v1
├── api-dimdim:v1
└── api-transacoes:v1
↓
ACI mysql-dimdim → Storage Account (persistência)
ACI api-java → IP público: porta 8080
ACI api-dotnet → FQDN público: porta 8080
```

---

## Tecnologias utilizadas

- Microsoft Azure (ACR, ACI, Key Vault, Storage Account)
- Docker
- Visual Studio Code Web
- Git / GitHub
- Spring Boot (Java 17)
- .NET
- MySQL 8.0
- Azure CLI

---

## Autor

Felipe Kirschner Modesto — RM561810
