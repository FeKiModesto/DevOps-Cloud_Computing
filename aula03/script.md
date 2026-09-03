# Aula 03 — Azure App Service: Criando um Web App na Nuvem

**Aluno:** Felipe Kirschner Modesto — RM561810  
**Disciplina:** DevOps Tools & Cloud Computing  
**Professor:** Antonio Sergio Rodrigues Figueiredo  
**Módulo:** 12 — Conceitos de Web App

---

## 1. Registrar provider e clonar projeto inicial

```bash
az provider register --namespace Microsoft.Web

git clone https://github.com/profjoaomenk/one-page.git
cd one-page
```

---

## 2. Criar App Service Plan, Web App e fazer deploy do site estático (one-page)

```bash
az webapp up \
  --resource-group rg-sites \
  --location brazilsouth \
  --plan planSites \
  --name hello-rm561810 \
  --html \
  --sku F1 \
  --logs
```

---

## 3. Atualizar Web App com novo site estático (terrarium)

```bash
cd
git clone https://github.com/profjoaomenk/static-web-page-terrarium.git
cd static-web-page-terrarium

az webapp up \
  --resource-group rg-sites \
  --location brazilsouth \
  --plan planSites \
  --name hello-rm561810 \
  --html \
  --sku F1 \
  --logs
```

---

## 4. Clonar e compilar o projeto Spring Pet Clinic

```bash
cd
git clone https://github.com/profjoaomenk/spring-jar-petclinic.git
cd spring-jar-petclinic

mvn clean package
```

---

## 5. Configurar Web App para executar Java

```bash
az webapp config set \
  --resource-group rg-sites \
  --name hello-rm561810 \
  --java-version 17 \
  --java-container JAVA \
  --java-container-version LATEST
```

---

## 6. Deploy do JAR da Pet Clinic

```bash
cd target

az webapp deploy \
  --resource-group rg-sites \
  --name hello-rm561810 \
  --src-path ./spring-petclinic-3.3.0-SNAPSHOT.jar \
  --type jar
```

---

## 7. Limpar recursos

```bash
az group delete --name rg-sites --yes --no-wait
```
