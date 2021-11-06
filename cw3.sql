--4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) 
-- położonych w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to 
-- kryterium zapisz do osobnej tabeli tableB.

SELECT COUNT(popp.geom) 
FROM majrivers, popp
WHERE ST_DWithin(popp.geom, majrivers.geom,1000.0) AND popp.f_codedesc='Building';
	
SELECT COUNT(ST_Intersection(popp.geom,ST_Buffer(majrivers.geom, 1000)))
			 FROM popp, majrivers
			 WHERE f_codedesc='Building';

--5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich 
-- geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
	
SELECT airports.name, airports.geom, airports.elev
INTO TABLE airportsNew
FROM airports

--a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.

-- SELECT (SELECT airportsNew.name 
-- 		FROM airportsNew 
-- 		ORDER BY ST_Y(geom) ASC limit 1) 
--         AS West_Airport,
-- 	    (SELECT airportsNew.name 
-- 		 FROM airportsNew 
--  		 ORDER BY ST_Y(geom) DESC limit 1) 
-- 		 AS East_Airport

(SELECT 'West_airport' AS Airport, airportsNew.name 
 FROM airportsNew 
 ORDER BY ST_Y(geom) ASC limit 1)
 UNION 
(SELECT 'East_Airport', airportsNew.name 
 FROM airportsNew 
 ORDER BY ST_Y(geom) DESC limit 1)
		       
--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie 
-- środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. 
-- Wysokość n.p.m. przyjmij dowolną
														  
INSERT INTO airportsNew 
VALUES('AirportB',(SELECT ST_Centroid(ST_ShortestLine((SELECT geom  
                                                       FROM airportsNew 
		                                       WHERE airportsNew.name='NOATAK'), 
						       (SELECT geom 
					               FROM airportsNew 
						       WHERE airportsNew.name='NIKOLSKI AS')))), 125)
													  
--6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej 
-- linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT ST_Area(ST_Buffer(ST_ShortestLine(lakes.geom, airports.geom),1000)) 
FROM lakes, airports
WHERE lakes.names='Iliamna Lake' AND airports.name='AMBLER'

--7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących 
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps)

SELECT vegdesc, SUM(ST_Area(trees.geom))
FROM trees, tundra, swamp
WHERE ST_CONTAINS(trees.geom, tundra.geom) OR ST_CONTAINS(trees.geom, swamp.geom)
GROUP BY vegdesc

	
