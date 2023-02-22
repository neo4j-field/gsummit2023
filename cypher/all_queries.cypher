// Show stations
MATCH (s:Station) RETURN s LIMIT 10;

//Show tracks
MATCH (t:Track) RETURN t LIMIT 10;

//Show stations and tracks
MATCH path=(s:Station)--(t:Track) RETURN path LIMIT 10;

MATCH path=(s:Station)-[:ON_TRACK]->(t:Track) RETURN path LIMIT 10;

//WHERE clause
MATCH (s:Station{shortcut:'BWES'}) RETURN s;

MATCH (s:Station) WHERE s.shortcut='BWES' RETURN s;

//Profile and explain
PROFILE MATCH (s:Station{shortcut:'BWES'}) RETURN s;

PROFILE MATCH (s:Station) WHERE s.shortcut='BWES' RETURN s;

EXPLAIN MATCH (s:Station{shortcut:'BWES'}) RETURN s;

EXPLAIN MATCH (s:Station) WHERE s.shortcut='BWES' RETURN s;

//Assets in Track where Berlin-Westend station is
MATCH (h:Hub)-[r]-(s:Station{shortcut:'BWES'})-[i:ON_TRACK]-(t:Track)-[has]-(a) RETURN *;

//Stop points on the track where Berlin-Westend station is
MATCH (h:Hub)-[r]-(s:Station{shortcut:'BWES'})-[i:ON_TRACK]-(t:Track)-[has]-(a:StopPoint) RETURN *;

//Above queries can be assigned to variable path

// Shortest Paths using APOC Disjkstra Procedure --> could be done with GDS, too
MATCH (from:Hub{shortcut:'AWLA'}), (to:Hub{shortcut:'MRO'})
CALL apoc.algo.dijkstra(from, to, 'CONNECTED_TO', 'distance') yield path AS path, weight AS weight
RETURN size(nodes(path)), weight;

//Return only stations (activate connect result nodes)
MATCH (from:Hub{shortcut:'AWLA'}), (to:Hub{shortcut:'MRO'})
CALL apoc.algo.dijkstra(from, to, 'CONNECTED_TO', 'distance') yield path AS path, weight AS weight
UNWIND nodes(path) AS nodo
RETURN [(nodo)--(:Station) | nodo] AS nodos;

//
// GDS
//

// Project a graph named 'Hubs' into memory. We only take the "Hub" Node and the "CONNECTED_TO"
// relationship
CALL gds.graph.project('Hubs','Hub','CONNECTED_TO');

// Now we use the Weakly Connected Components Algo to identify those nodes 
// that are not well connected to the neetwork
CALL gds.wcc.stream('Hubs') YIELD nodeId, componentId
WITH collect(gds.util.asNode(nodeId).shortcut) AS lista, componentId
RETURN lista,componentId;




// Matching a specific Hub from the list above --> use the Neo4j browser output to check
// the network it is belonging to (see the README file for more information). You will 
// figure out, that it is an isolated network of hubs / stations / etc.
MATCH (h:Hub) WHERE h.shortcut='ABAH' RETURN h;

// Use the betweenness centrality algo, to find out hot spots in terms of
// tracks running through a specific hub.
CALL gds.betweenness.stream('Hubs')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).shortcut AS shortcut, gds.util.asNode(nodeId).description AS description, score
ORDER BY score DESC;
