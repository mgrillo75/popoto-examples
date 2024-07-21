MATCH (customer:Customer {BillToName: "Evolution (1EVWSHO)"})-[r:USES]->(category:Category)
RETURN customer, r, category LIMIT 25;