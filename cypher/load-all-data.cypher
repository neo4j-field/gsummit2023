:param OpPointsDir => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/nodes';
:param TrackPointDir => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/relationships';
// Point of Interest Data
:param filePOIs => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/POIs.csv';

CREATE CONSTRAINT uc_OperationPoint_id IF NOT EXISTS FOR (op:OperationPoint) REQUIRE op.id IS UNIQUE;
CREATE INDEX index_OperationPointName_name IF NOT EXISTS FOR (opn:OperationPointName) ON (opn.name);

//
// Loading Operations Points from all available countries
//
LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_DE.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "DE"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_BE.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "BE"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_DK.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "DK"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_SE.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "SE"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_FR.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "FR"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_ES.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "ES"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_IT.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "IT"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_CH.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "CH"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_LU.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "LU"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_NL.csv" as row
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "NL"}]->(:OperationPointName {name: row.name});

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_UK.csv" as row FIELDTERMINATOR ";"
MERGE (op:OperationPoint {id: row.id, geolocation: Point({latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)})})
CREATE (op)-[:NAMED {country: "NL"}]->(:OperationPointName {name: row.name});

//
// Chaining up sections
//
LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_DE.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_BE.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_DK.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_SE.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_FR.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_ES.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_IT.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_CH.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_LU.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_NL.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_UK.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)
MATCH (target:OperationPoint WHERE target.id = row.target)
MERGE (source)-[:SECTION {sectionlength: toFloat(row.sectionlength)}]->(target);


LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_DE.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_BE.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_DK.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_SE.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_FR.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_ES.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_IT.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_CH.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_LU.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_NL.csv" as row
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

LOAD CSV WITH HEADERS FROM $OpPointsDir + "/OperationPoint_UK.csv" as row FIELDTERMINATOR ";"
MATCH (op:OperationPoint WHERE op.id = row.id)
CALL apoc.create.addLabels( id(op), [ row.extralabel ] ) YIELD node
RETURN count(*);

//
// Load Speed Data
//
LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_DE_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_BE_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_DK_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_SE_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_FR_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_ES_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_IT_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_CH_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_LU_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_NL_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

LOAD CSV WITH HEADERS FROM $TrackPointDir + "/SECTION_UK_speed.csv" as row
MATCH (source:OperationPoint WHERE source.id = row.source)-[s:SECTION]->(target:OperationPoint WHERE target.id = row.target)
SET s.speed = toFloat(row.trackspeed);

//
// Loading Point of Interest and matching the closest station automtically
// by finding the closest distance between geo point of the POI and the next
// available station / passenger stop geo point
//
LOAD CSV WITH HEADERS FROM $filePOIs AS line FIELDTERMINATOR ';'
WITH line.CITY AS city, line.POI_DESCRIPTION AS description, line.LINK_FOTO AS linkFoto, line.LINK_WEBSITE AS linkWeb, line.LAT AS lat, line.LONG AS long, line.SECRET AS secret
CREATE (po:POI {geolocation:point({latitude: toFloat(lat),longitude: toFloat(long)})})
SET po.description = description,
po.city = city, 
po.linkWebSite = linkWeb,
po.linkFoto = linkFoto,
po.long = toFloat(long),
po.lat = toFloat(lat),
po.secret = toBoolean(secret)
WITH *
MATCH (h:OperationPoint)--(s:Station)
WITH h,collect(s) as stations, po
WITH po,apoc.agg.minItems(h,point.distance(h.geolocation,po.geolocation)).items[0] AS hub
MERGE (hub)-[:HAS_POI]->(po)
RETURN count(hub);

// ==== DONE LOADING ====
