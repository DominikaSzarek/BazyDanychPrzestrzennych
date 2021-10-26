CREATE TABLE buildings
(
	ID INT,
	name VARCHAR(50),
	geometry GEOMETRY
);

-- SELECT * FROM buildings,roads, poi 
-- SELECT * FROM roads;
-- SELECT * FROM poi;

CREATE TABLE roads
(
	ID INT,
	name VARCHAR(50),
	geometry GEOMETRY
);

CREATE TABLE poi
(
	ID INT,
	name VARCHAR(50),
	geometry GEOMETRY
);

INSERT INTO buildings VALUES
	(1, 'BuildingA', 'POLYGON((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))'),
	(2, 'BuildingB', 'POLYGON((4 7, 4 5, 6 5, 6 7, 4 7))'),
	(3, 'BuildingC', 'POLYGON((3 8, 3 6, 5 6, 5 8, 3 8))'),
	(4, 'BuildingD', 'POLYGON((9 9, 9 8, 10 8, 10 9, 9 9))'),
	(5, 'BuildingE', 'POLYGON((1 2, 1 1, 2 1, 2 2, 1 2))');
 
INSERT INTO roads VALUES
	(1, 'RoadX', 'LINESTRING(0 4.5, 12 4.5)'),
	(2, 'RoadY', 'LINESTRING(7.5 0, 7.5 10.5)');

INSERT INTO poi VALUES
	(1, 'G', 'POINT(1 3.5)'),
	(2, 'H', 'POINT(5.5 1.5)'),
	(3, 'I', 'POINT(9.5 6)'),
	(4, 'J', 'POINT(6.5 6)'),
	(5, 'K', 'POINT(6 9.5)');

--a Wyznacz całkowitą długość dróg w analizowanym mieście

SELECT SUM(ST_LENGTH(geometry)) 
FROM roads;

--b Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA

SELECT ST_asText(geometry), ST_Area(geometry), ST_Perimeter(geometry)
FROM buildings
WHERE name = 'BuildingA';

--c Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie

SELECT name, ST_area(geometry) 
FROM buildings
ORDER BY name ASC;

--d Wypisz nazwy i obwody 2 budynków o największej powierzchni

SELECT name, ST_Perimeter(geometry)
FROM buildings 
ORDER BY  ST_area(geometry) DESC LIMIT(2);

--e Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G
----cross join, parametry st_distance

SELECT ST_Distance(
		ST_GeomFromText('POLYGON((3 8, 3 6, 5 6, 5 8, 3 8))'),
	    ST_GeomFromText('POINT(1 3.5)'))
		AS distance;

SELECT ST_Distance(buildings.geometry, poi.geometry) 
AS Distance
FROM buildings, poi
WHERE buildings.name='BuildingC' AND poi.name='G';

--f Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB
----intersection
----distance subquery

SELECT ST_Area(ST_Difference((SELECT buildings.geometry 
							  FROM buildings 
							  WHERE buildings.name='BuildingC'), ST_Buffer((SELECT buildings.geometry 
																			FROM buildings 
																			WHERE buildings.name='BuildingB'), 0.5))) 
																			AS Area;
							 
--g Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX. 

SELECT buildings.name, ST_Centroid(buildings.geometry) 
AS Centroid 
FROM buildings, roads
WHERE ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_Centroid(roads.geometry)) AND roads.name='RoadX';

--h Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7),
-- które nie są wspólne dla tych dwóch obiektów

SELECT ST_Area(ST_SymDifference((SELECT buildings.geometry
								FROM buildings
								WHERE buildings.name='BuildingC'), ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0))) 
								AS Area;
						