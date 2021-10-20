CREATE TABLE ksiegowosc.pracownicy (
	ID_pracownika INT PRIMARY KEY NOT NULL,
	imie VARCHAR(30),
	nazwisko VARCHAR(30) NOT NULL,
	adres VARCHAR(200),
	telefon INT
);

CREATE TABLE ksiegowosc.godziny (
	ID_godziny INT PRIMARY KEY NOT NULL,
	data DATE,
	liczba_godzin FLOAT,
	ID_pracownika INT REFERENCES ksiegowosc.pracownicy(ID_pracownika)
); 


CREATE TABLE ksiegowosc.pensja (
	ID_pensji INT PRIMARY KEY NOT NULL,
	stanowisko VARCHAR(50),
	kwota FLOAT
);


CREATE TABLE ksiegowosc.premia (
	ID_premii INT PRIMARY KEY NOT NULL,
	rodzaj VARCHAR(50),
	kwota FLOAT NOT NULL
);
	

CREATE TABLE ksiegowosc.wynagrodzenie (
	ID_wynagrodzenia INT PRIMARY KEY NOT NULL,
	data DATE,
	ID_pracownika INT REFERENCES ksiegowosc.pracownicy(ID_pracownika),
	ID_godziny INT REFERENCES ksiegowosc.godziny(ID_godziny),
	ID_pensji INT REFERENCES ksiegowosc.pensja(ID_pensji),
	ID_premii INT REFERENCES ksiegowosc.premia(ID_premii) 
);

-- dodaj komentarze do tabeli

COMMENT ON TABLE ksiegowosc.pracownicy IS 'Tabela zawierająca informacje o pracownikach firmy';
COMMENT ON TABLE ksiegowosc.godziny IS 'Tabela zawierająca informacje o przepracowanych godzinach w miesiącu';
COMMENT ON TABLE ksiegowosc.pensja IS 'Tabela zawierajaca informacje dotyczące miesięcznego wynagrodzenia pracowników';
COMMENT ON TABLE ksiegowosc.premia IS 'Tabela zawierająca informacje dotyczące premii dla pracowników';
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Tabela, w której występują powiązania pomiędzy pozostałymi tabelami';

-- wypełnij każdą tabele 10 rekordami

INSERT INTO ksiegowosc.pracownicy (ID_pracownika, imie, nazwisko, adres, telefon) VALUES
	(1, 'Adam','Nowak', 'Długa 4', 977837372),
	(2, 'Krzysztof','Kras', 'Mickiewicza 40', 746293748),
	(3, 'Karol','Paciorek', 'Lekka 3', 859284920),
	(4, 'Wołodymir','Markowicz', 'Stronnicza 7', 947284728),
	(5, 'Artur','Loczek', 'Jarzynowa 10', 792531493),
	(6, 'Marek','Drab', 'Tarnowska 9', 938472393),
	(7, 'Jolanta','Kroczek', 'Kleberga 38', 739285730),
	(8, 'Monika','Las', 'Krótka 2', 839453729),
	(9, 'Adrian','Nasiadka', 'Radłowska 89', 983765823),
	(10,'Wiktoria','Przepiórka', 'Sienkiewicza 43', 633828473);
	
INSERT INTO ksiegowosc.godziny (ID_godziny, data, liczba_godzin, ID_pracownika) VALUES
	(1,'2020-06-01', 160, 1),
	(2,'2020-06-01', 160, 2),
	(3,'2020-06-01', 160, 3),
	(4,'2020-06-01', 160, 4),
	(5,'2020-06-01', 160, 5),
	(6,'2020-06-01', 120, 6),
	(7,'2020-06-01', 120, 7),
	(8,'2020-06-01', 160, 8),
	(9,'2020-06-01', 70, 9),
	(10,'2020-06-01', 160, 10);

INSERT INTO ksiegowosc.pensja (ID_pensji, stanowisko, kwota) VALUES
	(1,'Front-end Developer', 7000),
	(2,'Junior Full-Stack Developer', 7000),
	(3,'Senior Full-Stack Developer', 13000),
	(4,'Back-end Developer', 8000),
	(5,'Senior Full-Stack Developer', 13000),
	(6,'Accountant', 5000),
	(7,'Data Base Administrator', 6000),
	(8,'Back-end Developer', 8000),
	(9,'IT Consultant', 4000),
	(10,'Front-end Developer', 7000);

INSERT INTO ksiegowosc.premia (ID_premii, rodzaj, kwota) VALUES
	(1, 'uznaniowa', 400),
	(2, 'zadaniowa', 300),
	(3, 'regulaminowa', 200);

INSERT INTO ksiegowosc.wynagrodzenie (ID_wynagrodzenia, data, ID_pracownika, ID_godziny, ID_pensji, ID_premii) VALUES
	(1, '2020-07-31', 1, 1, 1, 2),
	(2, '2020-07-31', 2, 2, 2, 2),
	(3, '2020-07-31', 3, 3, 3, 1),
	(4, '2020-07-31', 4, 4, 4, 2),
	(5, '2020-07-31', 5, 5, 5, 1),
	(6, '2020-07-31', 6, 6, 6, 3),
	(7, '2020-07-31', 7, 7, 7, 3),
	(8, '2020-07-31', 8, 8, 8, 2),
	(9, '2020-07-31', 9, 9, 9, 3),
	(10 ,'2020-07-31', 10, 10, 10, 2);

--a Wyświetl tylko id pracownika oraz jego nazwisko

SELECT ID_pracownika, nazwisko FROM ksiegowosc.pracownicy;

--b Wyświetl id pracowników, których płaca jest większa niż 1000

SELECT pracownicy.ID_pracownika, pensja.kwota 
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.wynagrodzenie ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
INNER JOIN ksiegowosc. pensja ON wynagrodzenie.ID_pensji = pensja.ID_pensji
WHERE pensja.kwota > 1000;

SELECT * FROM ksiegowosc.wynagrodzenie;
SELECT * FROM ksiegowosc.pracownicy;
SELECT * FROM ksiegowosc.pensja;
SELECT * FROM ksiegowosc.godziny;

--c Wyświetl id pracowników nieposiadających premii, których płaca jest większa niż 2000

SELECT ID_pracownika 
FROM ksiegowosc.wynagrodzenie 
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii 
INNER JOIN ksiegowosc.pensja ON wynagrodzenie.ID_pensji = pensja.ID_pensji
WHERE premia.ID_premii = 0 AND pensja.kwota > 2000;

--d Wyświetl pracowników, których pierwsza litera imienia zaczyna się na literę ‘J’

SELECT ID_pracownika, imie, nazwisko 
FROM ksiegowosc.pracownicy
WHERE imie LIKE 'A%';

--e Wyświetl pracowników, których nazwisko zawiera literę ‘n’ oraz imię kończy się na literę ‘a

SELECT ID_pracownika, imie, nazwisko
FROM ksiegowosc.pracownicy
WHERE imie LIKE '%n%' AND imie LIKE '%a';

--f Wyświetl imię i nazwisko pracowników oraz liczbę ich nadgodzin, przyjmując, iż standardowy czas pracy to 160 h miesięcznie

SELECT imie, nazwisko, godziny.liczba_godzin - 140 AS nadgodziny
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.godziny ON pracownicy.ID_pracownika = godziny.ID_pracownika
WHERE godziny.liczba_godzin >= 140;

--g Wyświetl imię i nazwisko pracowników, których pensja zawiera się w przedziale 1500 –3000PLN

SELECT imie, nazwisko 
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.wynagrodzenie ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
INNER JOIN ksiegowosc.pensja ON wynagrodzenie.ID_pensji = pensja.ID_pensji
WHERE pensja.kwota BETWEEN 3000 AND 6000;

--h Wyświetl imię i nazwisko pracowników, którzy pracowali w nadgodzinachi nie otrzymali premii

SELECT imie, nazwisko 
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.wynagrodzenie ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii
INNER JOIN ksiegowosc.godziny ON wynagrodzenie.ID_godziny = godziny.ID_godziny 
WHERE (godziny.liczba_godzin - 140) > 0 AND premia.ID_premii = 0;


--i Uszereguj pracowników według pensji

SELECT pracownicy.ID_pracownika, imie, nazwisko, pensja.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.wynagrodzenie ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
INNER JOIN ksiegowosc.pensja ON wynagrodzenie.ID_pensji = pensja.ID_pensji
ORDER BY pensja.kwota ASC; 

--j Uszereguj pracowników według pensji i premii malejąco

SELECT pracownicy.ID_pracownika, imie, nazwisko, pensja.kwota, premia.kwota
FROM ksiegowosc.pracownicy 
INNER JOIN ksiegowosc.wynagrodzenie ON pracownicy.ID_pracownika = wynagrodzenie.ID_pracownika
INNER JOIN ksiegowosc.pensja ON wynagrodzenie.ID_pensji = pensja.ID_pensji
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii
ORDER BY pensja.kwota DESC, premia.kwota DESC;
 
--k Zlicz i pogrupuj pracowników według pola ‘stanowisko’

SELECT COUNT(pensja.stanowisko), stanowisko
FROM ksiegowosc.pensja
GROUP BY pensja.stanowisko;

--l Policz średnią, minimalną i maksymalną płacę dla stanowiska ‘kierownik’ (jeżeli takiego nie masz, to przyjmij dowolne inne)

SELECT AVG(pensja.kwota) AS srednie_wynagrodzenie, MIN(pensja.kwota) AS minimalne_wynagrodzenie, MAX(pensja.kwota) AS maksymalne_wynagrodzenie
FROM ksiegowosc.pensja
WHERE pensja.stanowisko = 'Front-end Developer';

--m Policz sumę wszystkich wynagrodzeń

SELECT SUM(pensja.kwota) + SUM(premia.kwota) AS SUMA_pensji
FROM ksiegowosc.pensja
INNER JOIN ksiegowosc.wynagrodzenie ON pensja.ID_pensji = wynagrodzenie.ID_pensji
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii;

--f Policz sumę wynagrodzeń w ramach danego stanowiska

SELECT pensja.stanowisko,SUM(pensja.kwota), SUM(premia.kwota), SUM(pensja.kwota) + SUM(premia.kwota) AS SUMA
FROM ksiegowosc.pensja
INNER JOIN ksiegowosc.wynagrodzenie ON pensja.ID_pensji = wynagrodzenie.ID_pensji
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii
GROUP BY pensja.stanowisko;

--g Wyznacz liczbę premii przyznanych dla pracowników danego stanowiska

SELECT COUNT(premia.ID_premii), stanowisko
FROM ksiegowosc.pensja
INNER JOIN ksiegowosc.wynagrodzenie ON pensja.ID_pensji = wynagrodzenie.ID_pensji
INNER JOIN ksiegowosc.premia ON wynagrodzenie.ID_premii = premia.ID_premii
GROUP BY pensja.stanowisko;

--h Usuń wszystkich pracowników mających pensję mniejszą niż 1200 zł

DELETE ksiegowosc.pracownicy FROM ksiegowosc.premie INNER JOIN (ksiegowosc.pensje INNER JOIN ksiegowosc.wynagrodzenie ON pensje.ID_pensji = wynagrodzenie.ID_pensji) ON premie.ID_premii = wynagrodzenie.ID_premii 
WHERE pensje.kwota <= 4000; 




















