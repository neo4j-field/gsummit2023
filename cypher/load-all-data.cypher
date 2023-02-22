:param filenameOpUnits => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/OperationUnits.csv';
:param filenameTracks => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/Tracks.csv';
// Point of Interest Data
:param filenamePOIs => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/POIs.csv';

//
// Create indexes first
//
CREATE INDEX FOR (n:Station) ON (n.shortcut);
CREATE INDEX FOR (n:Track) ON (n.trackNr);
CREATE INDEX FOR (n:OperationUnit) ON (n.shortcut);
CREATE INDEX FOR (n:OperationUnit) ON (n.geocord);

//============= LOAD Stations first ==================

//
// Load all Operation Units
//
LOAD CSV WITH HEADERS FROM $filenameOpUnits AS line FIELDTERMINATOR ';'
WITH line.TRACK_NUM AS trackNr, line.DIRECTION AS direction, line.KM_I AS kmi, line.KM_L AS kml, line.DESCRIPTION AS description, line.UNIT_KIND AS unitKind, line.SHORTCUT AS shortcut, line.GK_R_DGN AS gkrDgn, line.GK_H_DGN AS gkhDgn, line.LAT AS lat, line.LONG AS long
CREATE (ou:OperationUnit {geocord:point({latitude: toFloat(replace(lat,',','.')),longitude: toFloat(replace(long,',','.'))})})
SET ou.direction = direction,
ou.kmi = toInteger(kmi),
ou.kml = kml,
ou.description = description,
ou.unitKind = unitKind,
ou.shortcut = shortcut,
ou.gkrDgn = toFloat(replace(gkrDgn,',','.')),
ou.gkhDgn = toFloat(replace(gkhDgn,',','.'))
MERGE (t:Track{trackNr:toInteger(trackNr)})
MERGE (ou)-[:ON_TRACK]->(t)
RETURN count(*);

//
// Update Operation Units with additional Label Station
//
MATCH (ou:OperationUnit)
WHERE ou.unitKind = "St"
SET ou:Station
RETURN count(*);

//
// Load Tracks
//
LOAD CSV WITH HEADERS FROM $filenameTracks AS line FIELDTERMINATOR ';'
WITH line.TRACKNR AS trackNr, line.KMSTR_E AS kmstrE, line.KMEND_E AS kmendE, line.KMSTR_V AS kmstrV, line.TRACKNAME AS trackName, line.TRACKSHCUT AS trackShortCut
MATCH (st:Track {trackNr: toInteger(trackNr)})
SET st.kmstrE = toInteger(kmstrE),
st.kmendE = toInteger(kmendE),
st.trackName = trackName,
st.trackShortCut = trackShortCut
RETURN count(*);

//
// Creating Hubs for Operation Units with common shortcuts
//
MATCH (ou:OperationUnit) 
WITH ou.shortcut as shortcut, collect(ou) AS ous, size(collect(ou)) as num where num>1 
WITH *, ous[0] AS first
CREATE (h:Hub {art: first.art,
description: first.description,
long: first.long,
lat: first.lat,
geocord: first.geocord,
shortcut: first.shortcut})
WITH *
UNWIND ous AS ou
CREATE (ou)-[:LOCATED_AT]->(h);

//
// Creating Hubs for Stations
//
MATCH (ou:Station)
WITH ou.shortcut as shortcut, collect(ou) AS ous, size(collect(ou)) as num where num=1
WITH *, ous[0] AS first
CREATE (h:Hub {art: first.art,
description: first.description,
long: first.long,
lat: first.lat,
geocord: first.geocord,
shortcut: first.shortcut})
WITH *
UNWIND ous AS ou
CREATE (ou)-[:LOCATED_AT]->(h);

//
// Chaining up places
//
MATCH (o:Hub)<-[:LOCATED_AT]-(bs:OperationUnit)-[:ON_TRACK]->(s:Track)
WITH *
ORDER BY bs.kmi
WITH collect( DISTINCT o) AS o_, s WHERE size(o_)>1
FOREACH (i in range(0, size(o_) - 2) |
FOREACH (node1 in [o_[i]] |
FOREACH (node2 in [o_[i+1]] |
MERGE (node1)-[:CONNECTED_TO]-(node2))));

//
// Add labels for Operation Unit types, e.g. like switches, stop point, etc.
// This is to illustrate how easy we can add new labels. The Cypher can be
// written much more dense, but then it is harder to understand
//
MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Swch"
SET ou:Switch
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Sp"
SET ou:StopPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Bp"
SET ou:BorderPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "St Swch"
SET ou:StationSwitch
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Rerout"
SET ou:ReRoute
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Stp"
SET ou:StationPart
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Stp Swch"
SET ou:StationPartSwitch
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Cro"
SET ou:Crossing
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Sp Cro"
SET ou:StopPointCrossing
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "St o.S."
SET ou:StationNoService
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "CoPt"
SET ou:ConnectionPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "CoPt"
SET ou:ConnectionPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Hp Bk"
SET ou:StopBlockPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Bk"
SET ou:BlockPoint
RETURN count(*);

MATCH (ou:OperationUnit)
WHERE ou.unitKind = "Trch"
SET ou:TrackChange
RETURN count(*);

//
// Calculating distances between stations
//
// MATCH path=(h1:Hub)--(h2:Hub)
// MATCH path2=(h1)--(ou1:Station)--(t:Track)--(ou2:Station)--(h2)
// RETURN h1.shortcut,h2.shortcut,abs(ou1.kmi-ou2.kmi) as distance, abs(toFloat(replace(trim(split(ou1.kml,'+')[0]),',','.'))-toFloat(replace(trim(split(ou2.kml,'+')[0]),',','.'))) as dist limit 50

//
// Calculating and adding distance property to the CONNECTED_TO relationship
//
MATCH path=(h1:Hub)-[r:CONNECTED_TO]-(h2:Hub)
MATCH path2=(h1)--(ou1:OperationUnit)--(t:Track)--(ou2:OperationUnit)--(h2)
WITH h1,r,h2,round(100*abs(toFloat(replace(trim(split(ou1.kml,'+')[0]),',','.'))-toFloat(replace(trim(split(ou2.kml,'+')[0]),',','.'))))/100 as dist
set r.distance=dist;

// just for checking the tracks length
// MATCH (t:Track) return t.trackShortCut,(toFloat(t.kmendE)-toFloat(t.kmstrE))/10000 as length

//
// Loading Point of Interest and matching the closest station automtically
// by finding the closest distance between geo point of the POI and the next
// available station
//
LOAD CSV WITH HEADERS FROM $filenamePOIs AS line FIELDTERMINATOR ';'
WITH line.CITY AS city, line.POI_DESCRIPTION AS description, line.LINK_FOTO AS linkFoto, line.LINK_WEBSITE AS linkWeb, line.LAT AS lat, line.LONG AS long, line.SECRET AS secret
CREATE (po:POI {geocord:point({latitude: toFloat(lat),longitude: toFloat(long)})})
SET po.description = description,
po.city = city, 
po.linkWebSite = linkWeb,
po.linkFoto = linkFoto,
po.long = toFloat(long),
po.lat = toFloat(lat),
po.secret = toBoolean(secret)
WITH *
MATCH (h:Hub)--(s:Station)
WITH h,collect(s) as stations,po
WITH po,apoc.agg.minItems(h,point.distance(h.geocord,po.geocord)).items[0] AS hub
MERGE (hub)-[:HAS_POI]->(po);

// ==== DONE LOADING ====
