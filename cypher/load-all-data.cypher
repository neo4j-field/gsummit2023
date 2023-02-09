:param filenameOpUnits => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/OperationUnits.csv';
:param filenameTracks => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/Tracks.csv';
// Point of Interest Data
:param filenamePOIs => 'https://raw.githubusercontent.com/neo4j-field/gsummit2023/main/data/POIs.csv';

//
// Create indexes first
//
CREATE INDEX FOR (s:Station) ON (s.shortcut);
CREATE INDEX FOR (t:Track) ON (t.TrackNr);
CREATE INDEX FOR (op:OperationUnit) ON (op.shortcut);
CREATE POINT INDEX FOR (s:Station) ON (s.geocord);

//
// Load Tracks
//
LOAD CSV WITH HEADERS FROM $filenameTracks AS line FIELDTERMINATOR ';'
WITH line.TRACKNR AS trackNr, line.KMSTR_E AS kmstrE, line.KMEND_E AS kmendE, line.KMSTR_V AS kmstrV, line.TRACKNAME AS trackName, line.TRACKSHCUT AS trackShortCut
CREATE (t:Track {trackNr: toInteger(trackNr)})
SET t.kmstrE = toInteger(kmstrE),
   t.kmendE = toInteger(kmendE),
   t.trackName = trackName,
   t.trackShortCut = trackShortCut
RETURN count(*);

//
// Load all Operation Units
//
LOAD CSV WITH HEADERS FROM $filenameOpUnits AS line FIELDTERMINATOR ';'
WITH line.TRACK_NUM AS trackNr, line.DIRECTION AS direction, line.KM_I AS kmi, line.DESCRIPTION AS description, line.UNIT_KIND AS unitKind, line.SHORTCUT AS shortcut, line.LAT AS lat, line.LONG AS long
MERGE (ou:OperationUnit {shortcut:shortcut})
SET ou.description = description,
ou.unitKind = unitKind
WITH *
FOREACH (_ IN CASE WHEN ou.unitKind='St' THEN [true] ELSE [] END |
SET ou:Station)
WITH *
MATCH (t:Track{trackNr:toInteger(trackNr)})
MERGE (ou)-[r:IS_AT]->(t)
SET r.direction = direction,
r.kmi = toInteger(kmi),
r.shortcut = shortcut,
r.long = toFloat(replace(long,',','.')),
r.lat = toFloat(replace(lat,',','.')),
r.geocord = point({latitude: toFloat(replace(lat,',','.')),longitude: toFloat(replace(long,',','.'))})
RETURN count(*);

//
// Chaining up places/stations
//
MATCH (st:Station)-[r:IS_AT]->(s:Track)
WITH *
ORDER BY r.kmi
WITH collect(st) AS o_, s WHERE size(o_)>1
FOREACH (i in range(0, size(o_) - 2) |
FOREACH (node1 in [o_[i]] |
 FOREACH (node2 in [o_[i+1]] |
  CREATE (node1)-[:CONNECTED_TO]->(node2))));


//
// Set Track lengths / weights
//
MATCH (t1:Track)<-[r1]-(n:Station)-[r:CONNECTED_TO]->(m:Station)-[r2]->(t2:Track) WHERE r1.lat>0 and r2.lat>0 AND id(n)<id(m)
WITH r, point.distance(r1.geocord, r2.geocord) AS distance
SET r.length = toInteger(distance)
RETURN count(r);


//
// OPTIONAL:
//
// Renaming OUs to the actual kind of Unit, e.g. switch, stop point, etc.
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
// Load all Points of Interest and create relationship to the closest Station near the Point of Interest --> may be the same Geo Coordinates, 
// in case it is a main city e.g. Berlin, or different Coordinates if the PoI is off in the country side!
// 
LOAD CSV WITH HEADERS FROM $filenamePOIs AS line FIELDTERMINATOR ';'
WITH line.SHORTCUT AS shortcut, line.CITY AS city, line.POI_DESCRIPTION AS description, line.LINK_FOTO AS linkFoto, line.LINK_WEBSITE AS linkWeb, line.LAT AS lat, line.LONG AS long, line.SECRET AS secret
CREATE (po:POI {shortcut: shortcut})
    SET po.description = description,
        po.city = city,
        po.linkWebSite = linkWeb,
        po.linkFoto = linkFoto,
        po.long = toFloat(long),
        po.lat = toFloat(lat),
        po.geocord = point({latitude: toFloat(lat),longitude: toFloat(long)}),
        po.secret = toBoolean(secret)
WITH po.shortcut AS scut
MATCH (st:Station {shortcut: scut})
MATCH (po:POI {shortcut: scut})
CREATE (po)-[:HAS_POI]->(st)
RETURN count(*);
