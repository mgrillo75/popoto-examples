LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1W0EBxO9kMPSMBmTGhE-WKf56bkbWC2MRlDx77Z7UPpk/export?format=csv" AS row
WITH row WHERE row.MfgPartNumber IS NOT NULL
CREATE (n:Product)
SET n = row,
n.List = toFloat(row.List),
n.Available = toInteger(row.Available),
n.OnOrder = toInteger(row.OnOrder),
n.ReorderPoint = toInteger(row.ReorderPoint),
n.ProductLifeCycleDescription = row.ProductLifeCycleDescription

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1BmtIgMUIZOoO_QfeysQQzARkKnD8yD-peo3EP8MN8YY/export?format=csv" AS row
WITH row WHERE row.CategoryId IS NOT NULL
CREATE (n:Category)
SET n = row
    
    
LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jp_UqDnPEf60UQgokv1fwBok1VEqSI6mksOr_29lF1U/export?format=csv" AS row
WITH row WHERE row.VendorID IS NOT NULL
CREATE (n:Supplier)
SET n = row
    
CREATE INDEX ON :Product(MfgPartNumber)

CREATE INDEX ON :Category(CategoryId)

CREATE INDEX ON :Supplier(VendorID)

MATCH (p:Product),(c:Category)
  WHERE p.CategoryId = c.CategoryId
CREATE (p)-[:PART_OF]->(c)

MATCH (p:Product),(s:Supplier)
  WHERE p.VendorID = s.VendorID
CREATE (s)-[:SUPPLIES]->(p)

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/18PgfKfTTDSE-isYsJjFqtnAMrFXs-kQTczp6y9kqbQY/export?format=csv" AS row
WITH row WHERE row.AccountCode IS NOT NULL
CREATE (n:Customer)
SET n = row

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1j0K1BuhuuHTFSZgzJ02Zd9u6hlUDKa49Q9uDeeDDg0c/export?format=csv" AS row
WITH row WHERE row.SalesOrderNumber IS NOT NULL
CREATE (n:Order)
SET n = row

CREATE INDEX ON :Customer(AccountCode)

CREATE INDEX ON :Order(SalesOrderNumber)

MATCH (c:Customer),(o:Order)
  WHERE c.AccountCode = o.AccountCode
CREATE (c)-[:PURCHASED]->(o)

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jSkkGLzPXKv36jITIj8IG60TNS2BpMzqWlyw3zV4bX0/export?format=csv" AS row
WITH row WHERE row.SalesOrderNumber IS NOT NULL
MATCH (p:Product), (o:Order)
  WHERE p.MfgPartNumber = row.MfgPartNumber AND o.SalesOrderNumber = row.SalesOrderNumber
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.OrderQuantity = toInteger(row.OrderQuantity)

MATCH (s:Supplier)-[r:SUPPLIES]->(p:Product) MERGE (p)-[:SUPPLIED_BY]->(s)