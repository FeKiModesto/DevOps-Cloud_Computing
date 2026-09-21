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
```bash
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

### Aula02 — Azure SQL Database PaaS
Provisionamento de banco de dados relacional gerenciado na nuvem com alta disponibilidade, replicação geográfica e failover automático.

#### O que foi feito:
- Criação do **Resource Group** `rg-sql-dimdim`
- Registro do provider `Microsoft.Sql`
- Criação do **SQL Server primário** `sql-server-dimdim-rm561810-southafricanorth`
- Criação do banco `db-dimdim` (tier Basic, backup Local)
- Liberação de firewall (regra `liberaGeral`: 0.0.0.0 → 255.255.255.255)
- Criação da tabela `transacoes` e inserção de 5 registros via `Invoke-Sqlcmd`
- Criação do **SQL Server secundário** `sql-server-dimdim-rm561810-westus2`
- Criação da **réplica geográfica** do banco
- Configuração de **Backup LTR** (semanal 30d, mensal 365d, anual 1825d)
- Criação do **Grupo de Failover** `failover-group-dimdim-rm561810` (política Automatic, grace-period 1h)
- Associação do banco ao Grupo de Failover
- Teste de failover manual e reversão

#### Arquitetura:
```bash
SQL Server Primário (southafricanorth)
└── db-dimdim (Primary)
↕ replicação geográfica
SQL Server Secundário (westus2)
└── db-dimdim (Secondary)
↕ Grupo de Failover (Automatic)
```

---

### Aula03 — Azure App Service: Web App PaaS
Deploy de aplicações web na nuvem usando Azure App Service, desde sites estáticos até aplicações Spring Boot.

#### O que foi feito:
- Registro do provider `Microsoft.Web`
- Criação do **App Service Plan** `planSites` (SKU F1 — Free, Windows)
- Criação do **Web App** `hello-rm561810` na região `brazilsouth`
- Deploy de site HTML estático (`one-page`) via `az webapp up`
- Atualização do Web App com novo site estático (`static-web-page-terrarium`)
- Configuração do ambiente Java 17 no Web App
- Clone e build do projeto **Spring Pet Clinic** com Maven
- Deploy do `.jar` via `az webapp deploy`

#### Arquitetura:
```bash
App Service Plan (planSites — Free F1)
└── Web App hello-rm561810 (brazilsouth)
├── Deploy 1: one-page (HTML estático)
├── Deploy 2: terrarium (HTML estático)
└── Deploy 3: spring-petclinic-3.3.0-SNAPSHOT.jar (Java 17)
```

---

### Aula04 — API Spring Boot x CI/CD Portal x Banco Oracle
Desenvolvimento de uma API Spring Boot para controle de vagas de estacionamento, com deploy via Portal da Azure e CI/CD automático com GitHub Actions. A API consome um banco de dados Oracle hospedado na FIAP.

**Repositório do Projeto:** [api-springboot-web-app](https://github.com/FeKiModesto/api-springboot-web-app)

*O que foi feito:*
- Criação da tabela tb_vagas e sequence SQ_TB_VAGAS no Oracle (SQL Developer)
- Configuração do application.properties com as credenciais do banco Oracle
- Criação do Web App api-vaga-rm561810 no Portal da Azure (Java 11, Windows, SKU F1)
- Habilitação da Implantação Contínua com GitHub Actions no Portal
- Autorização do Azure na conta do GitHub e seleção do repositório/branch
- Habilitação da Autenticação Básica (SCM)
- Criação de Secrets no GitHub (SPRING_DATASOURCE_URL, USERNAME, PASSWORD) para o build
- Ajuste do workflow YAML para incluir as variáveis de ambiente no passo de build
- Testes das operações GET, POST, PUT e DELETE via Postman
- Verificação da persistência dos dados diretamente no Oracle
- Limpeza do Grupo de Recursos e dos objetos do banco

**Arquitetura:**
```bash
GitHub Actions (CI/CD)
↓
Azure Web App (api-vaga-rm561810) → Oracle DB (FIAP)
```
📄 **Script detalhado:** [aula04/script.md](https://github.com/FeKiModesto/DevOps-Cloud_Computing/blob/main/aula04/script.md)

---

### Aula05 — Front-end Spring x CI/CD Script x Banco Oracle / SQL Server
Realização de dois projetos de Front-end com Spring MVC, com infraestrutura criada via Azure CLI (Cloud Shell) e deploy automatizado com GitHub Actions. Monitoramento com Application Insights.

**Repositórios dos Projetos:** <br>
[playmix-mvc — Gerenciamento de playlists e músicas (Oracle)](https://github.com/FeKiModesto/playmix-mvc) <br>
[movtodimdim-Java-17 — Painel Admin do sistema DimDim (SQL Server)](https://github.com/FeKiModesto/movtodimdim-Java-17)

*O que foi feito:*
### Parte 1 - Playmix (Oracle):
- Criação dos recursos via Azure CLI: Resource Group, Application Insights, App Service Plan (Linux F1), Web App (Java 17)
- Configuração de variáveis de ambiente no Web App (URL do Oracle, usuário, senha, Application Insights)
- Conexão do Web App com o Application Insights
- Configuração do GitHub Actions para build e deploy automáticos
- Criação de Secrets no GitHub e ajuste do workflow YAML
- Testes da aplicação (CRUD de músicas e playlists)
- Verificação do monitoramento no Application Insights
- Limpeza do Grupo de Recursos e das tabelas no Oracle

### Parte 2 - MovtoDimDim (SQL Server):
- Criação do SQL Server e banco dimdimdb via script PowerShell (create-sql-server.ps1)
- Criação das tabelas automaticamente via Sqlcmd
- Deploy do Web App via script Bash (deploy-movtodimdim.sh)
- Configuração de Secrets no GitHub para as credenciais do SQL Server
- Ajuste do workflow YAML para incluir as variáveis de ambiente
- Testes da aplicação (painel admin)
- Análise do Mapa de Aplicações no Application Insights (Web App → SQL Server)
- Limpeza do Grupo de Recursos

**Arquitetura:**
```bash
GitHub Actions (CI/CD)
↓
Azure Web App (Linux F1) → Application Insights
├── Playmix: Oracle DB (FIAP)
└── MovtoDimDim: Azure SQL Database (PaaS)
```

📄 **Script detalhado:** [aula05/script.md](https://github.com/FeKiModesto/DevOps-Cloud_Computing/blob/main/aula05/script.md)

---

## Tecnologias utilizadas
- Microsoft Azure (ACR, ACI, Key Vault, Storage Account, SQL Database, SQL Server, App Service)
- Docker
- Visual Studio Code Web
- Git / GitHub
- Spring Boot (Java 17)
- .NET
- MySQL 8.0
- Azure SQL Database (PaaS)
- Azure App Service (PaaS)
- Azure CLI / PowerShell
- Maven

---

## Autor
Felipe Kirschner Modesto — RM561810
