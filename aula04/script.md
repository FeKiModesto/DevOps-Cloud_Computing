# Aula 04 - API Spring Boot x CI/CD Portal x Banco Oracle

## 📌 Visão Geral
Nesta atividade, foi desenvolvida uma API Spring Boot para o controle de vagas de estacionamento. O deploy foi realizado diretamente pelo **Portal da Azure** (Serviço de Aplicativo), integrado ao **GitHub Actions** para CI/CD automático (Build e Deploy a cada commit). A API consome um banco de dados **Oracle** hospedado na FIAP.

**Repositório do Projeto:** [api-springboot-web-app](https://github.com/FeKiModesto/api-springboot-web-app)

---

## 🛠️ Passo a Passo Executado

### 1. Criação dos Objetos no Banco Oracle (SQL Developer)
Antes de começar, criamos a tabela e a sequência no banco Oracle da FIAP:
```sql
CREATE TABLE tb_vagas (
  cd_vaga NUMBER NOT NULL,
  cd_estacionamento NUMBER NOT NULL,
  ds_localizacao VARCHAR2(10) NOT NULL,
  ds_andar VARCHAR2(10) NOT NULL,
  ds_disponivel CHAR(1) NOT NULL
);

ALTER TABLE tb_vagas ADD CONSTRAINT tb_vagas_pk PRIMARY KEY (cd_vaga);

CREATE SEQUENCE SQ_TB_VAGAS START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

INSERT INTO tb_vagas(cd_vaga, cd_estacionamento, ds_localizacao, ds_andar, ds_disponivel) 
VALUES (SQ_TB_VAGAS.nextval, 1, 'A01', 'T', '0'); -- Não está disponível

INSERT INTO tb_vagas(cd_vaga, cd_estacionamento, ds_localizacao, ds_andar, ds_disponivel) 
VALUES (SQ_TB_VAGAS.nextval, 1, 'A02', 'T', '1'); -- Disponível

commit;
```
### 2. Configuração do Projeto
Foi realizado o Fork do repositório api-springboot-web-app. No arquivo src/main/resources/application.properties, configuramos as credenciais do banco Oracle:
```sql
spring.datasource.url= jdbc:oracle:thin:@oracle.fiap.com.br:1521:orcl
spring.datasource.username=seuRM
spring.datasource.password=SuaSenha
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.jpa.database-platform=org.hibernate.dialect.Oracle10gDialect
```
> ⚠️ Atenção: A FIAP trava a conta após 3 tentativas de senha incorreta. Tome cuidado ao commitar as credenciais.

### 3. Criação do Web App no Portal da Azure
- Acessamos o Portal da Azure e pesquisamos por "Serviços de Aplicativos".
- Clicamos em Criar → Aplicativo Web.
- Configurações Básicas:
  - Assinatura: Azure para Estudantes
  - Grupo de Recursos: rg-api-webapp
  - Nome: api-vaga-rm561810 (Único globalmente)
  - Publicar: Código
  - Pilha de runtime: Java 11
  - Pilha do servidor Web Java: Java SE (Embedded Web Server)
  - Sistema Operacional: Windows (Permite habilitar GitHub Actions direto na criação)
  - Região: Brazil South
  - Plano de preços: Gratuito F1

### 4. Configuração do CI/CD (GitHub Actions)
- Na aba Implantação, habilitamos a Implantação Contínua.
- Autorizamos o acesso do Azure à nossa conta do GitHub.
- Selecionamos o repositório api-springboot-web-app e a branch main.
- Importante: Na seção Configurações de autenticação, habilitamos a Autenticação Básica.
- O Azure criou automaticamente o workflow .github/workflows/main_api-vaga-rm561810.yml.
- O primeiro build falhou porque as variáveis do banco não estavam no GitHub. Para resolver, adicionamos os Secrets no repositório (SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, SPRING_DATASOURCE_PASSWORD) e editamos o YAML para incluí-los na seção env do passo "Build with Maven".

### 5. Testes com POSTMAN
Com o deploy concluído, testamos os endpoints da API:

- GET ```https://api-vaga-rm561810.azurewebsites.net/vagas``` (Listar todas as vagas)
- POST ```https://api-vaga-rm561810.azurewebsites.net/vagas``` (Criar nova vaga)
### json:
```json
{
  "idEstacionamento": 3,
  "localizacao": "B03",
  "andar": "3 ANDAR",
  "disponivel": true
}
```
- PUT ```https://api-vaga-rm561810.azurewebsites.net/vagas/5``` (Atualizar vaga)
- DELETE ```https://api-vaga-rm561810.azurewebsites.net/vagas/5``` (Excluir vaga)

### 6. Limpeza
Ao final, excluímos o Grupo de Recursos para evitar custos:
```bash
az group delete --name rg-api-webapp --yes --no-wait
```
E no SQL Developer, removemos os objetos do banco:
```bash
DROP SEQUENCE SQ_TB_VAGAS;
DROP TABLE tb_vagas;
```
