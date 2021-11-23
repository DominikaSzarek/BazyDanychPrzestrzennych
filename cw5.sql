create table obiekty (
 id int, 
 nazwa varchar(30), 
 geom geometry)

insert into obiekty values
(1,'obiekt1', st_geomFromText('compoundcurve( (0 1, 1 1), circularstring(1 1, 2 0, 3 1), circularstring(3 1, 4 2, 5 1), (5 1, 6 1) )') ),
(2, 'obiekt2', st_geomFromText('CURVEPOLYGON(compoundcurve((10 6, 14 6), circularstring(14 6, 16 4, 14 2), circularstring(14 2, 12 0, 10 2), (10 2, 10 6)), circularstring(11 2, 12 3, 13 2, 12 1, 11 2))')),
(3, 'obiekt3', st_geomFromText('multicurve( (7 15, 10 17), (10 17, 12 13), (12 13, 7 15) )' )),
(4, 'obiekt4', st_geomFromText('multicurve((20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))')),
(5, 'obiekt5', st_geomFromText('multipoint(30 30 59, 38 32 234)')),
(6, 'obiekt6',  st_geomFromText('geometrycollection(point(4 2), linestring(1 1, 3 2))'))

select * from obiekty

--1 Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4

select st_area(st_buffer(st_shortestline(
	(select obiekty.geom from obiekty where obiekty.nazwa = 'obiekt3'),
    (select obiekty.geom from obiekty where obiekty.nazwa = 'obiekt4')), 5))

--2 Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki
-- Obiekt musi być domknięty.

select st_geometrytype(st_makepolygon(st_addpoint(st_linemerge(st_curvetoline(geom)), st_startpoint(st_linemerge(st_curvetoline(geom))))))
from obiekty 
where nazwa = 'obiekt4'

--3 W tabeli obiekty, jako obiekt7zapisz obiekt złożony z obiektu 3 i obiektu 4
--select * from obiekty

insert into obiekty values 
(7, 'obiekt7', (select st_collect((select geom from obiekty where obiekty.nazwa = 'obiekt3'),
								 (select geom from obiekty where obiekty.nazwa = 'obiekt4'))))
								 
--4 Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie zawierających łuków

select sum(st_area(st_buffer(obiekty.geom, 5)))
from obiekty 
where st_hasarc(obiekty.geom) = false