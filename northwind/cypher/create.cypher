LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/products.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0")

LOAD CSV WITH HEADERS FROM "https://docs.google.com/spreadsheets/d/1W0EBxO9kMPSMBmTGhE-WKf56bkbWC2MRlDx77Z7UPpk/export?format=csv" AS row
WITH row WHERE row.MfgPartNumber IS NOT NULL
MERGE (n:Product {MfgPartNumber:row.MfgPartNumber})
SET n.LongDescription = row.LongDescription,
    n.VendorID = row.VendorID,
    n.CategoryId = row.CategoryId,
    n.BoxQuantity = row.BoxQuantity,
    n.UnitPrice = toFloat(row.List),
    n.unitsInStock = toInteger(row.Available),
    n.unitsOnOrder = toInteger(row.OnOrder),
    n.reorderLevel = toInteger(row.ReorderPoint),
    n.ProductLifeCycleDescription = row.ProductLifeCycleDescription;

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/categories.csv" AS row
CREATE (n:Category)
SET n = row

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/suppliers.csv" AS row
CREATE (n:Supplier)
SET n = row

CREATE INDEX ON :Product(productID)

CREATE INDEX ON :Category(categoryID)

CREATE INDEX ON :Supplier(supplierID)

MATCH (p:Product),(c:Category)
  WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c)

MATCH (p:Product),(s:Supplier)
  WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p)

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/customers.csv" AS row
CREATE (n:Customer)
SET n = row

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/orders.csv" AS row
CREATE (n:Order)
SET n = row

CREATE INDEX ON :Customer(customerID)

CREATE INDEX ON :Order(orderID)

MATCH (c:Customer),(o:Order)
  WHERE c.customerID = o.customerID
CREATE (c)-[:PURCHASED]->(o)

LOAD CSV WITH HEADERS FROM "http://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
  WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity)

MATCH (s:Supplier)-[r:SUPPLIES]->(p:Product) MERGE (p)-[:SUPPLIED_BY]->(s)