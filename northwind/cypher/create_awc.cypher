CREATE CONSTRAINT product_MfgPartNumber IF NOT EXISTS FOR (p:Product) REQUIRE (p.MfgPartNumber) IS UNIQUE;
CREATE CONSTRAINT category_CategoryId IF NOT EXISTS FOR (c:Category) REQUIRE (c.CategoryId) IS UNIQUE;
CREATE CONSTRAINT supplier_VendorID IF NOT EXISTS FOR (s:Supplier) REQUIRE (s.VendorID) IS UNIQUE;
CREATE CONSTRAINT customer_AccountCode IF NOT EXISTS FOR (c:Customer) REQUIRE (c.AccountCode) IS UNIQUE;
CREATE CONSTRAINT order_SalesOrderNumber IF NOT EXISTS FOR (o:Order) REQUIRE (o.SalesOrderNumber) IS UNIQUE;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1W0EBxO9kMPSMBmTGhE-WKf56bkbWC2MRlDx77Z7UPpk/export?format=csv" AS row
WITH row WHERE row.MfgPartNumber IS NOT NULL
MERGE (n:Product {MfgPartNumber: row.MfgPartNumber})
SET n += row,
    n.List = toFloat(row.List),
    n.Available = toInteger(row.Available),
    n.OnOrder = toInteger(row.OnOrder),
    n.ReorderPoint = toInteger(row.ReorderPoint),
    n.ProductLifeCycleDescription = row.ProductLifeCycleDescription;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1BmtIgMUIZOoO_QfeysQQzARkKnD8yD-peo3EP8MN8YY/export?format=csv" AS row
WITH row WHERE row.CategoryId IS NOT NULL
MERGE (n:Category {CategoryId: row.CategoryId})
SET n += row;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jp_UqDnPEf60UQgokv1fwBok1VEqSI6mksOr_29lF1U/export?format=csv" AS row
WITH row WHERE row.VendorID IS NOT NULL
MERGE (n:Supplier {VendorID: row.VendorID})
SET n += row;

MATCH (p:Product), (c:Category)
WHERE p.CategoryId = c.CategoryId
MERGE (p)-[:PART_OF]->(c);

MATCH (p:Product), (s:Supplier)
WHERE p.VendorID = s.VendorID
MERGE (s)-[:SUPPLIES]->(p);

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/18PgfKfTTDSE-isYsJjFqtnAMrFXs-kQTczp6y9kqbQY/export?format=csv" AS row
WITH row WHERE row.AccountCode IS NOT NULL
MERGE (n:Customer {AccountCode: row.AccountCode})
SET n += row;

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1j0K1BuhuuHTFSZgzJ02Zd9u6hlUDKa49Q9uDeeDDg0c/export?format=csv" AS row
WITH row WHERE row.SalesOrderNumber IS NOT NULL
MERGE (n:Order {SalesOrderNumber: row.SalesOrderNumber})
SET n += row,
    n.AccountCode = row.AccountCode,
    n.ODSalesPerson = row.ODSalesPerson,
    n.OrderDate = row.OrderDate,
    n.ShipToAddress1 = row.ShipToAddress1,
    n.ShipToCity = row.ShipToCity,
    n.ShipToState = row.ShipToState,
    n.ShipToZipcode = row.ShipToZipcode,
    n.ShipToCountry = row.ShipToCountry,
    n.ShipVia = row.ShipVia,
    n.Freight = toFloat(row.Freight),
    n.ShipToName = row.ShipToName,
    n.ShippedDate = row.ShippedDate,
    n.NeedDate = row.NeedDate;

MATCH (c:Customer), (o:Order)
WHERE c.AccountCode = o.AccountCode
MERGE (c)-[:PURCHASED]->(o);

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1jSkkGLzPXKv36jITIj8IG60TNS2BpMzqWlyw3zV4bX0/export?format=csv" AS row
WITH row WHERE row.MfgPartNumber IS NOT NULL AND row.SalesOrderNumber IS NOT NULL
MATCH (p:Product), (o:Order)
WHERE p.MfgPartNumber = row.MfgPartNumber AND o.SalesOrderNumber = row.SalesOrderNumber
MERGE (o)-[details:ORDERS]->(p)
SET details.OrderQuantity = toInteger(row.OrderQuantity),
    details.UnitPrice = toFloat(row.UnitPrice),
    details.Rebate = toFloat(row.Rebate);

MATCH (s:Supplier)-[r:SUPPLIES]->(p:Product)
MERGE (p)-[:SUPPLIED_BY]->(s);
