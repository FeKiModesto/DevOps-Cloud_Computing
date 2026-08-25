# Aula 02 — PaaS: Criando um Banco SQL no Azure

**Aluno:** Felipe Kirschner Modesto — RM561810  
**Disciplina:** DevOps Tools & Cloud Computing  
**Professor:** Antonio Sergio Rodrigues Figueiredo 
**Módulo:** 11 — Banco de Dados em Nuvem

---

## 1. Criar Resource Group e registrar provider

```bash
az group create --name rg-sql-dimdim --location southafricanorth

az provider register --namespace Microsoft.Sql
```

---

## 2. Criar SQL Server primário

```bash
az sql server create \
  --name sql-server-dimdim-rm561810-southafricanorth \
  --resource-group rg-sql-dimdim \
  --location southafricanorth \
  --admin-user user-dimdim \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true
```

---

## 3. Criar banco de dados

```bash
az sql db create \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --name db-dimdim \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false
```

---

## 4. Liberar acesso público via Firewall

```bash
az sql server firewall-rule create \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

---

## 5. Criar tabela e popular dados (PowerShell)

```powershell
Invoke-Sqlcmd -ServerInstance "sql-server-dimdim-rm561810-southafricanorth.database.windows.net" `
  -Database "db-dimdim" `
  -Username "user-dimdim" `
  -Password "Fiap@2tdsvms" `
  -Query @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='transacoes' AND xtype='U')
BEGIN
  CREATE TABLE transacoes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2),
    data_transacao DATETIME DEFAULT (SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time')
  );
END;

INSERT INTO transacoes (descricao, valor, data_transacao) VALUES
  ('Depósito bancário', 1500.00, '2025-06-01 10:00:00'),
  ('Transferência PIX', -250.00, '2025-06-03 14:30:00'),
  ('Pagamento de conta', -180.50, '2025-06-05 09:15:00'),
  ('Saque em caixa eletrônico', -300.00, '2025-06-07 16:45:00'),
  ('Investimento em poupança', -500.00, '2025-06-10 11:20:00');
"@
```

---

## 6. Criar servidor secundário para replicação

```bash
az sql server create \
  --name sql-server-dimdim-rm561810-westus2 \
  --resource-group rg-sql-dimdim \
  --location southafricanorth \
  --admin-user user-dimdim \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true
```

---

## 7. Criar réplica geográfica do banco

```bash
az sql db replica create \
  --name db-dimdim \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --partner-server sql-server-dimdim-rm561810-westus2 \
  --partner-resource-group rg-sql-dimdim \
  --backup-storage-redundancy Local \
  --zone-redundant false
```

---

## 8. Configurar política de backup LTR

```bash
az sql db ltr-policy set \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --name db-dimdim \
  --weekly-retention P30D \
  --monthly-retention P365D \
  --yearly-retention P1825D \
  --week-of-year 1
```

---

## 9. Criar Grupo de Failover

```bash
az sql failover-group create \
  --name failover-group-dimdim-rm561810 \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --partner-server sql-server-dimdim-rm561810-westus2 \
  --partner-resource-group rg-sql-dimdim \
  --failover-policy Automatic \
  --grace-period 1
```

---

## 10. Associar banco ao Grupo de Failover

```bash
az sql failover-group update \
  --name failover-group-dimdim-rm561810 \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth \
  --add-db db-dimdim
```

---

## 11. Testar Failover manual

```bash
az sql failover-group set-primary \
  --name failover-group-dimdim-rm561810 \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-westus2
```

---

## 12. Reverter Failover

```bash
az sql failover-group set-primary \
  --name failover-group-dimdim-rm561810 \
  --resource-group rg-sql-dimdim \
  --server sql-server-dimdim-rm561810-southafricanorth
```
