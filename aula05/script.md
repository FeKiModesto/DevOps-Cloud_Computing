# Aula 05 - Front-end Spring x CI/CD Script x Banco Oracle / SQL Server

## 📌 Visão Geral
Nesta atividade, foram realizados dois projetos de Front-end utilizando Spring MVC. A infraestrutura foi criada via **Azure CLI (Cloud Shell)** através de scripts, e o deploy foi automatizado com **GitHub Actions**. Também configuramos monitoramento com **Application Insights**.

1. **Playmix:** Aplicação de gerenciamento de playlists e músicas, utilizando banco de dados **Oracle**.
2. **MovtoDimDim:** Painel administrativo do sistema DimDim, utilizando banco de dados **SQL Server (PaaS)** na Azure.

**Repositórios:**
- [playmix-mvc](https://github.com/FeKiModesto/playmix-mvc)
- [movtodimdim-Java-17](https://github.com/FeKiModesto/movtodimdim-Java-17)

---

## 🎵 Parte 1: Projeto Playmix (Oracle)

### 1. Criação da Infraestrutura via Azure CLI
No Cloud Shell, definimos as variáveis e criamos os recursos:
```bash
RESOURCE_GROUP_NAME="rg-playmix-mvc"
WEBAPP_NAME="playmix-mvc-rm561810"
APP_SERVICE_PLAN="playmix-mvc"
LOCATION="brazilsouth"
RUNTIME="JAVA:17-java17"
GITHUB_REPO_NAME="FeKiModesto/playmix-mvc"
BRANCH="main"
APP_INSIGHTS_NAME="ai-playmix-mvc"

# Criação do Grupo de Recursos
az group create --name $RESOURCE_GROUP_NAME --location "$LOCATION"

# Criar Application Insights
az monitor app-insights component create --app $APP_INSIGHTS_NAME --location "$LOCATION" --resource-group $RESOURCE_GROUP_NAME --application-type web

# Criar o Plano de Serviço (Linux Free F1)
az appservice plan create --name $APP_SERVICE_PLAN --resource-group $RESOURCE_GROUP_NAME --location "$LOCATION" --sku F1 --is-linux

# Criar o Serviço de Aplicativo
az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP_NAME --plan $APP_SERVICE_PLAN --runtime "$RUNTIME"

# Habilitar Autenticação Básica (SCM)
az resource update --resource-group $RESOURCE_GROUP_NAME --namespace Microsoft.Web --resource-type basicPublishingCredentialsPolicies --name scm --parent sites/$WEBAPP_NAME --set properties.allow=true
```

### 2. Configuração de Variáveis de Ambiente
```bash
CONNECTION_STRING=$(az monitor app-insights component show --app $APP_INSIGHTS_NAME --resource-group $RESOURCE_GROUP_NAME --query connectionString --output tsv)

az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING" \
    ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
    XDT_MicrosoftApplicationInsights_Mode="Recommended" \
    XDT_MicrosoftApplicationInsights_PreemptSdk="1" \
    SPRING_DATASOURCE_USERNAME="rm561810" \
    SPRING_DATASOURCE_PASSWORD="SuaSenha" \
    SPRING_DATASOURCE_URL="jdbc:oracle:thin:@//oracle.fiap.com.br:1521/ORCL"

az webapp restart --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP_NAME
az monitor app-insights component connect-webapp --app $APP_INSIGHTS_NAME --web-app $WEBAPP_NAME --resource-group $RESOURCE_GROUP_NAME
```

### 3. Configuração do CI/CD e Tratamento de Falhas
```bash
az webapp deployment github-actions add --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP_NAME --repo $GITHUB_REPO_NAME --branch $BRANCH --login-with-github
```
> O primeiro build falha porque as variáveis de ambiente do banco não estão no GitHub. Para corrigir, adicionamos os Secrets no GitHub (SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, SPRING_DATASOURCE_PASSWORD) e editamos o arquivo YAML do workflow para incluir a seção env. Alternativamente, pode-se usar -DskipTests no comando Maven, mas isso ignora os testes.

### 4. Limpeza
```bash
az group delete --name rg-playmix-mvc --yes --no-wait
```
E no SQL Developer:
```sql
DROP TABLE music CASCADE CONSTRAINTS;
DROP TABLE playlist CASCADE CONSTRAINTS;
DROP TABLE playlist_music CASCADE CONSTRAINTS;
```

---

## 🚗 Parte 2: Projeto MovtoDimDim (SQL Server)

### 1. Criação do SQL Server (PaaS)
O banco foi criado via script PowerShell (create-sql-server.ps1):
- Criação do SQL Server sqlserver-rm561810
- Criação do banco dimdimdb
- Configuração do firewall
- Criação das tabelas automaticamente via Sqlcmd

### 2. Deploy da Aplicação
A infraestrutura do Web App foi criada via script Bash (deploy-movtodimdim.sh), e o deploy foi configurado com GitHub Actions.

**Configuração dos Secrets no GitHub:**
No repositório, acessamos **Settings** → **Secrets and variables** → **Actions** e criamos os seguintes secrets (com os valores reais do banco, que **não devem ser commitados**):
*   `SPRING_DATASOURCE_URL`: A URL de conexão completa do SQL Server (contendo o nome do servidor, banco e credenciais).
*   `SPRING_DATASOURCE_USERNAME`: O usuário administrador do banco (ex: `admsql`).
*   `SPRING_DATASOURCE_PASSWORD`: A senha do banco de dados.

**Ajuste no YAML do Workflow:**
Para que o GitHub Actions consiga ler essas variáveis durante o build, editamos o arquivo `.github/workflows/main_movtodimdim-rm561810.yml` e adicionamos a seção `env` no passo de build:
```yaml
      - name: Build with Maven
        run: mvn clean install
        env:
          SPRING_DATASOURCE_URL: ${{ secrets.SPRING_DATASOURCE_URL }}
          SPRING_DATASOURCE_USERNAME: ${{ secrets.SPRING_DATASOURCE_USERNAME }}
          SPRING_DATASOURCE_PASSWORD: ${{ secrets.SPRING_DATASOURCE_PASSWORD }}
```
### 3. Monitoramento com Application Insights
Acessamos o recurso ```ai-movtodimdim``` no Portal da Azure e validamos o Mapa de Aplicações, que mostrou a conexão do Web App com o SQL Server, com tempo de resposta médio de 187,1 ms para 13 chamadas.

### 4. Limpeza
```bash
az group delete --name rg-movtodimdim --yes --no-wait
```
