# Graph Summit 2023 EMEA - Workshop Digital Twin

This repository contains the workshop material used during the **Graph Summit 2023 - Building a Graph Solution Workshop**. All code, data, dashboards, Bloom perspectives and slides are available for dowload and free to use.

The aim of the workshop was, to provide a structure way of build a small mini digital twin knowledge graph. It is supposed to answer some basic questions coming from the business and discusses futher, how such digital twin graph could be extended for more insights and business values.

The workshop was build with "Graphistas" in mind new to the Graph Database / Analytics arena or "Graphistas" with a foundational knowledge of Graph databases and Graph Analytics searching for another nice example of the value of graph. 
It provides a playground for further experiments or can be used to "advertise" the value of Neo4j Graph Data Platform inside your company or government agency. Thanks for trying it out!

#### About the data that is been used

The datasets used here, describes a network of railroad tracks and places (so called operation points) 
connected to those tracks (called sections here). Operation Points can be a variaty of places like a Stations, a Switches, etc., see more examples below.

The dataset is essentailly a "small" digital twin of the existing rail network in the EU countries.

The dataset is freely available on the portal of the *European Union Agency for Railways and can be downloaded from their webpage. It offers many more parameters, e.g. type of power source and many more. We are not using all available parameters in this workshop, to keep it's complexity low. Data download is available in different formats e.g. xml or XLMS and we had to convert them into CSV to make loading more comfortable with cypher statements.

- [Original Track/Operation Point Data](https://data-interop.era.europa.eu/search) comes from the European Union Agency for Railways.

---
## Explaining the data set

#### Sections

Sections are parts of the railway network and have a start and end point. Start and end points are operational points of various types like Stations, Switches, Junctions, etc.

The Sections have the following interesting **Properties** loaded to the Graph:

- source: start OP for this section
- target: end OP for this section
- sectionlength: the length in km of that section
- trackspeed: max speed allowed on that section

#### Operation Points

Operational Points are connecting the different sections and can be of various types. Some of which are Stations, Small Stations, Passenger Stops, Switches, Junctions and some more.

Operation Points have the following **Properties** loaded to the Graph:

- id: the internal number of the OP
- extralabel: the kind of OP we deal with, e.g. Station, Junction, Switch, etc.
- name: the name of an OP
- latitude: of the OP
- longtitude: of the OP

Other data is available from the EU portal, but not used in this workshop as mentioned above.

#### Point of Interests (POI)

POIs are distributed through the countries and refer to either a main station (and so to a city), or to a station that is closest by the POI. Reason is, that some POIs are in the country side and there is no station close by. POIs have the following interesting **Properties** loaded to the Graph:

- CITY: City name at or close to the POI
- POI_DESCRIPTION: A short description of the POI
- LINK_FOTO: A URL to a POI Foto
- LINK_WEBSITE: A URL to a Website discussing POIs
- LAT: Latidude of the POI
- LONG: Longditude of the POI
- SECRET: Is the a well know POI (False) or more a secret place (True)

NOTE: POIs are not taken from the EU Railway Agency portal, but manually curated as an additional fun factor of the workshop.

---


## Building the demo environment

The following high level steps are required, to build the demo environment (will be shown in the workshop):

1. Download and install [Neo4j Desktop](https://neo4j.com/download-center/). Since we use some Graph Data Science Algorithms during the demo, we require the **GDS Library** to be installed. **Installation instruction** can be found [here](https://neo4j.com/docs/desktop-manual/current/).
- As an alternative, you can run an [Neo4j Sandbox for Data Scientists](https://sandbox.neo4j.com/?ref=neo4j-home-hero&persona=data-scientist) from (https://sandbox.neo4j.com/ and use an "Blank Sandbox" as shown in the slides.

2. Open Neo4j Browser and run the load-all-data.cypher script from the code directory above. You can cut & paste the complete code into the Neo4j Browser command line.

3. After the script has finished loading, you can check your data model. Run the command ```CALL db.schema.virtualization```in your Browser console. It should look like the following (maybe yours is a bit more mixed up):

<img width="800" alt="Data Model - Digital Twin" src="https://github.com/neo4j-field/gsummit2023/blob/791e76740b212686b73230a1cdca851b643bfbe1/images/data-model-all_labels.png">

If you would hide all labels except the label "OperationPoint" and "OperationPointName" and "POI", you will see the basic data model that looks like this:

<img width="540" alt="Data Model - Digital Twin" src="https://github.com/neo4j-field/gsummit2023/blob/68b41bce4c3ecdd8c73da58f55b7c34790907f4d/images/data-model-with-poi.png">

As you can see now in the data model, there is a OperationPoint label and it is connected to itself with a SECTION relationship. This means, OperationPoints are connected together and make up the track network (as in the real world). A station (or other Operation Units like Switches, Passenger Stop, etc.) are connected as a separate node by the "NAMED" relationship that represents their name, etc..

4. Now you can find certain queries in the `./code` directory in the file called `all_queries.cypher` or if you keep on reading. Try them out by cutting and pasting them into the Neo4j browser like shown below. We will also do that in the workshop!

---
## Run some Cypher queries on your Graph (database)

Let's start with some simple queries. Copy and Paste them into your Neo4j Browser in order to run them.

Show Operation Point Names and limit the number of returned OPs to 10:
```cypher
MATCH (op:OperationPointName) RETURN op LIMIT 10;
```

Show OPs and limit the number of returned tracks to 50:
```cypher
MATCH (op:OperationPoint) RETURN op LIMIT 50;
```

Show OperationPoints and Sections, have a look how those two queries defer!
```cypher
MATCH path=(:OperationPoint)--(:OperationPoint) RETURN path LIMIT 100;

MATCH path=(:OperationPoint)-[:SECTION]->(:OperationPoint) RETURN path LIMIT 100;
```

using the WHERE clause in two different way:
```cypher
MATCH (op:OperationPoint {id:'SECst'}) RETURN op;

MATCH (op:OperationPoint) WHERE op.id='SECst' RETURN op;
```
You can start exploring the graph in Neo4j Browser by clicking on the returned node and then clicking on the graph symbol to extend the node and see attached nodes. Go for a couple of sections and see, where it goes to.

Profile and explain some of the queries to see their execution plans:
```cypher
PROFILE MATCH (op:OperationPoint{id:'DE000BL'}) RETURN op;

PROFILE MATCH (op:OperationPoint) WHERE op.id='DE000BL' RETURN op;

EXPLAIN MATCH (op:OperationPoint  {id:'DE000BL'}) RETURN op;

EXPLAIN MATCH (op:OperationPoint) WHERE op.id='DE000BL' RETURN op;
```

## Fixing some gaps

Before we move on running some more complex queries we figured, there are gaps in some of the sections in Denmark. Maybe otheres also have gaps, but we did not yet find them.

Trying to do a shortest Path between Stockholm and Berlin, did not work initially. With some trail and error wie figured, there were two gaps on the way from Stockholm (id: 'SECst') and Berlin Main Station (id: 'DE000BL'). The gaps were between Nyborg with id DK00039 and OP DK00200. 

A second gap we found at the Border from Denmark to Germany close to Flensburg. The BorderPoint did not have a connection to both railway networks of Denmark and Germany. We fixed that with the following queries:

Fixing the Gaps in Denmark:
```cypher
// DK00320 - German border
MATCH sg=(op1 WHERE op1.id STARTS WITH 'DE')-[:SECTION]-(op2 WHERE op2.id STARTS WITH 'EU')
MATCH (op3 WHERE op3.id STARTS WITH 'DK')
WITH op2, op3, point.distance(op3.geolocation, op2.geolocation) as distance
ORDER by distance LIMIT 1
MERGE (op3)-[:SECTION {sectionlength: distance/1000.0, fix: true}]->(op2);
```

```cypher
// DK00200 - Nyborg
MATCH sg=(op1:OperationPoint WHERE op1.id = 'DK00200'),(op2:OperationPoint)-[:NAMED]->(opn:OperationPointName WHERE opn.name = "Nyborg")
MERGE (op1)-[:SECTION {sectionlength: point.distance(op1.geolocation, op2.geolocation)/1000.0, fix: true}]->(op2);
```

And also connect the UK via the channel:
```cypher
// EU00228 - FR0000016210 through the channel
MATCH sg=(op1 WHERE op1.id STARTS WITH 'UK')-[:SECTION]-(op2 WHERE op2.id STARTS WITH 'EU')
MATCH (op3 WHERE op3.id STARTS WITH 'FR')
WITH op2, op3, point.distance(op3.geolocation, op2.geolocation) as distance
ORDER by distance LIMIT 1
MERGE (op3)-[:SECTION {sectionlength: distance/1000.0, fix: true}]->(op2);
```

What you will also recognize is, that there are parts not connected to the railway network. That might be privately used OPs and sections or it also could be an issue of missing data in the data sets of that particular country. This is a way to find them:

```cypher
// Find not connected parts for Denmark --> Also try other coutries like DE, FR, IT and so on.
MATCH path=(a:OperationPoint WHERE NOT EXISTS{(a)-[:SECTION]-()})
WHERE a.id STARTS WITH 'DK'
RETURN path;

// or inside the complete dataset
MATCH path=(a:OperationPoint WHERE NOT EXISTS{(a)-[:SECTION]-()})
RETURN path;
```

### Last thing before moving to path analysis

You can add a technical property to the SECTION relationships that calculates the time of travel on that section. It assumes, the train is going the max speed for that section. A query to add that is the following:

```cypher
// Set new traveltime parameter in seconds for a particular section --> requires speed and 
// sectionlength properties set on this section!
MATCH (:OperationPoint)-[r:SECTION]->(:OperationPoint)
WHERE r.speed > 0
WITH r, r.speed * (1000.0/3600.0) as speed_ms
SET r.traveltime = r.sectionlength / speed_ms
RETURN count(*);
```
**IMPORTANT** the above query needs to run for the NeoDash Dashboard to run entirely!


### Shortest Path Queries using different Shortest Path functions in Neo4j

```cypher
// Cypher shortest path
MATCH sg=shortestPath((op1 WHERE op1.id = 'BEFBMZ')-[SECTION*]-(op2 WHERE op2.id = 'DE000BL')) RETURN sg;
```


```cypher
// APOC Dijkstra shortest path with weight sectionlength
MATCH (n:OperationPoint), (m:OperationPoint)
WHERE n.id = "BEFBMZ" and m.id = "DE000BL"
WITH n,m
CALL apoc.algo.dijkstra(n, m, 'SECTION', 'sectionlength') YIELD path, weight
RETURN path, weight;
```

### Graph Data Science (GDS)

Project a graph named 'OperationPoints' Graph into memory. We only take the "OperationPoint " Node and the "SECTION"
relationship:
```cypher
// CALL gds.graph.drop('OperationPoints'); /// optional
CALL gds.graph.project(
    'OperationPoints',
    'OperationPoint',
    {SECTION: {orientation: 'UNDIRECTED'}},
    {
        relationshipProperties: 'sectionlength'
    }
);
```
Now we calculate the shortes path using GDS Dijkstra:
```cypher
MATCH (source:OperationPoint WHERE source.id = 'BEFBMZ'), (target:OperationPoint WHERE target.id = 'DE000BL')
CALL gds.shortestPath.dijkstra.stream('OperationPoints', {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'sectionlength'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN *;
```

Now we use the Weakly Connected Components Algo to identify those nodes that are not well connected to the neetwork:
```cypher
CALL gds.wcc.stream('OperationPoints') YIELD nodeId, componentId
WITH collect(gds.util.asNode(nodeId).shortcut) AS lista, componentId
RETURN lista,componentId;
```

Matching a specific OperationPoint  from the list above --> use the Neo4j browser output to check the network it is belonging to (see the README file for more information). You will figure out, that it is an isolated network of OperationPoint s / stations / etc.:
```cypher
MATCH (op:OperationPoints) WHERE op.id='BEFBMZ' RETURN op;
```

Use the betweenness centrality algo, to find out hot spots in terms of
tracks running through a specific OperationPoint .
```cypher
CALL gds.betweenness.stream('OperationPoints')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS id, score
ORDER BY score DESC;
```
There is much more you can do, using this data set. This is just a teaser and we hope you have some more queries you find and test.
