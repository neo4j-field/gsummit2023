//
// This file contains all queries of the README and some additional ones
// Be aware that some might change your data!
//

// Show Operation Point Names and limit the number of returned OPs to 10:
MATCH (op:OperationPointName) RETURN op LIMIT 10;

// Show OPs and limit the number of returned tracks to 50:
MATCH (op:OperationPoint) RETURN op LIMIT 50;

// Show OperationPoints and Sections, have a look how those two queries defer!
MATCH path=(:OperationPoint)--(:OperationPoint) RETURN path LIMIT 100;
MATCH path=(:OperationPoint)-[:SECTION]->(:OperationPoint) RETURN path LIMIT 100;

// using the WHERE clause in two different way:
MATCH (op:OperationPoint {id:'SECst'}) RETURN op;
MATCH (op:OperationPoint) WHERE op.id='SECst' RETURN op;

// Profile and explain some of the queries to see their execution plans:
PROFILE MATCH (op:OperationPoint{id:'DE000BL'}) RETURN op;
PROFILE MATCH (op:OperationPoint) WHERE op.id='DE000BL' RETURN op;

EXPLAIN MATCH (op:OperationPoint  {id:'DE000BL'}) RETURN op;
EXPLAIN MATCH (op:OperationPoint) WHERE op.id='DE000BL' RETURN op;

// Fixing some gaps (see README for more information)

// DK00320 - German border gap
MATCH sg=(op1 WHERE op1.id STARTS WITH 'DE')-[:SECTION]-(op2 WHERE op2.id STARTS WITH 'EU')
MATCH (op3 WHERE op3.id STARTS WITH 'DK')
WITH op2, op3, point.distance(op3.geolocation, op2.geolocation) as distance
ORDER by distance LIMIT 1
MERGE (op3)-[:SECTION {sectionlength: distance/1000.0, fix: true}]->(op2);

// DK00200 - Nyborg gap
MATCH sg=(op1:OperationPoint WHERE op1.id = 'DK00200'),(op2:OperationPoint)-[:NAMED]->(opn:OperationPointName WHERE opn.name = "Nyborg")
MERGE (op1)-[:SECTION {sectionlength: point.distance(op1.geolocation, op2.geolocation)/1000.0, fix: true}]->(op2);

// EU00228 - FR0000016210 through the channel
MATCH sg=(op1 WHERE op1.id STARTS WITH 'UK')-[:SECTION]-(op2 WHERE op2.id STARTS WITH 'EU')
MATCH (op3 WHERE op3.id STARTS WITH 'FR')
WITH op2, op3, point.distance(op3.geolocation, op2.geolocation) as distance
ORDER by distance LIMIT 1
MERGE (op3)-[:SECTION {sectionlength: distance/1000.0, fix: true}]->(op2);


// Find not connected parts for Denmark --> Also try other coutries like DE, FR, IT and so on.
MATCH path=(a:OperationPoint WHERE NOT EXISTS{(a)-[:SECTION]-()})
WHERE a.id STARTS WITH 'DK'
RETURN path;

// or inside the complete dataset
MATCH path=a:OperationPoint WHERE NOT EXISTS{(a)-[:SECTION]-()})
RETURN path;

// Set additional traveltime parameter in seconds for a particular section --> requires speed and 
// sectionlength properties set on this section!
MATCH (:OperationPoint)-[r:SECTION]->(:OperationPoint)
WHERE r.speed > 0
WITH r, r.speed * (1000.0/3600.0) as speed_ms
SET r.traveltim = r.sectionlength / speed_ms
RETURN count(*);

// Shortest Path Queries using different Shortest Path functions in Neo4j

// Cypher shortest path
MATCH sg=shortestPath((op1 WHERE op1.id = 'BEFBMZ')-[SECTION*]-(op2 WHERE op2.id = 'DE000BL')) RETURN sg;

// APOC Dijkstra shortest path with weight sectionlength
MATCH (n:OperationPoint), (m:OperationPoint)
WHERE n.id = "BEFBMZ" and m.id = "DE000BL"
WITH n,m
CALL apoc.algo.dijktra(n, m, 'SECTION', 'sectionlength') YIELD path, weight
RETURN path, weight;

// ******************************************************************************************
// Graph Data Science (GDS)
//
// Project a graph named 'OperationPoints' Graph into memory. We only take the "OperationPoint " 
// Node and the "SECTION" relationship
// ******************************************************************************************

CALL gds.graph.drop('OperationPoints'); // optional, only if projection exists already
CALL gds.graph.project(
    'OperationPoints',
    'OperationPoint',
    {SECTION: {orientation: 'UNDIRECTED'}},
    {
        relationshipProperties: 'sectionlength'
  }
);

// Now we calculate the shortes path using GDS Dijkstra:
MATCH (source:OperationPoint WHERE source.id = 'BEFBMZ'), (target:OperationPoint WHERE target.id = 'DE000BL')
CALL gds.shortestPath.dijkstra.stream('OperationPoints', {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'sectionlength'
})
YIELD inex, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN *;

// Now we use the Weakly Connected Components Algo
CALL gds.wcc.stream('OperationPoints') YIELD nodeId, componentId
WITH collect(gds.util.asode(nodeId).shortcut) AS lista, componentId
RETURN lista,componentId;

// Matching a specific OperationPoint  from the list above --> use the Neo4j browser output to check the network it is belonging to (see the README file for more information). You will figure out, that it is an isolated network of OperationPoint s / stations / etc.:
MATCH (op:OperationPoints) WHERE op.id='BEFBMZ' RETURN op;

// Use the betweenness centrality algo
CALL gds.betweenness.stream('OperationPoints')
YIELD nodeId, score
RETURN gds.util.asNde(nodeId).id AS id, score
ORDER BY score DESC;


// ===================================
//
// Some more special Queries
//
// ===================================
// Using to find the gap ...
MATCH sg=(op1 WHERE op1.id STARTS WITH 'DE')-[:SECTION]-(op2 WHERE op2.id STARTS WITH 'EU')
MATCH (op3 WHERE op3.id STARTS WITH 'DK')
RETURN op2.id, op3.id, point.distance(op3.geolocation, op2.geolocation) as distance
ORDER by distance LIMIT 1;

// ===================================
// Setting a traveltime property on the SECTION relationship to calculate Shortest Path on time
//
// This query MUST run before using the "Speed vs. Time" Dashboard with NeoDash
// 
// Set new traveltime parameter in seconds for a particular section --> requires speed and 
// sectionlength properties set on this section!
// ===================================
MATCH (:OperationPoint)-[r:SECTION]->(:OperationPoint)
WHERE r.speed > 0
WITH r, r.speed * (1000.0/3600.0) as speed_ms
SET r.traveltime = r.sectionlength / speed_ms
RETURN count(*);


// ====================
// Some more simple queries
// ====================

// Find Operation Points in Malmö
MATCH(op:OperationPointName)
WHERE op.name CONTAINS 'Malmö'
RETURN op.name;

// Countries
MATCH (op:OperationPoint)
RETURN DISTINCT substring(lables(op.id),0,2) AS countries ORDER BY countries;


// Find all different types of Operation Points / Labels
MATCH (n)
WITH DISTINCT labels(n) AS allOPs
UNWIND allOPs as ops
RETURN DISTINCT ops;

// Number of different Operation Points including POIs
MATCH (n)
WITH labels(n) AS allOPs
UNWIND allOPs as ops
RETURN  ops, count(ops);

//
// Number of different OP Numbers
// 
MATCH (a:OperationPoint)
WITH substring(a.id,0,2) as country, collect(a.id) as list
RETURN country, list[0];

//
// Cypher shortest path
//

MATCH sg=shortestPath((op1 WHERE op1.id = 'BEFBMZ')-[SECTION*]-(op2 WHERE op2.id = 'DE000BL')) RETURN sg;
MATCH sg=shortestPath((op1 WHERE op1.id = 'FR0000002805')-[SECTION*]-(op2 WHERE op2.id = 'DE000BL')) RETURN sg;
MATCH sg=shortestPath((op1 WHERE op1.id = 'ES60000')-[SECTION*]-(op2 WHERE op2.id = 'DE000BL')) RETURN sg;

//
// APOC dijkstra shortes path
//

MATCH (source:OperationPoint WHERE source.id = 'BEFBMZ'), (target:OperationPoint WHERE target.id = 'DE000BL')
CALL apoc.algo.dijkstra(source, target, 'SECTION', 'sectionlength') yield path as path, weight as weight
RETURN path, weight;

// Shortest path by distance (Rotterdam --> Den Bosch)
MATCH (n:OperationPoint), (m:OperationPoint)
WHERE n.id = "BEFBMZ" and m.id = "DE000BL"
WITH n,m
CALL apoc.algo.dijkstra(n, m, 'SECTION', 'sectionlength') YIELD path, weight
RETURN path, weight;

// Shortest path by travel time (Rotterdam --> Den Bosch)
// MATCH (n:Station), (m:Station)
WHERE n.name = "Rotterdam Centraal" and m.name = "'s Hertogenbosch"
WITH n,m
CALL apoc.algo.dijkstra(n, m, 'ROUTE', 'travel_time_seconds') YIELD path, weight
RETURN path, weight;

// Business Like Queries

// =================================================================================
// This query is provided as is. It propagades speed data to a country that does not 
// have speed data in the EU Railway Agency Database. DO NOT USE it for the graph loaded
// in this workshop!!!
// ================================================================================= 
CALL apoc.periodic.commit(
  "WITH $limit AS thelimit LIMIT $limit
   MATCH ()-[a:SECTION]-()-[b:SECTION]->()-[c:SECTION]-()
   WHERE b.sectionmaxspeed IS NULL
   WITH b, collect(DISTINCT a) + collect(DISTINCT c) as sections
   UNWIND sections AS section
   WITH b, collect(section.sectionmaxspeed) AS speeds
   WHERE speeds <> []
   SET b.sectionmaxspeed = apoc.coll.avg(speeds)
   RETURN count(*)",{limit:10});
