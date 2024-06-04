-- Generated by Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   at:        2024-04-23 21:17:24 CEST
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c


-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE dni (
    data_recenzji  DATE NOT NULL,
    dzien_tygodnia NUMBER(1) NOT NULL,
    miesiac        NUMBER(2) NOT NULL,
    pora_roku      NUMBER(1) NOT NULL,
    rok            NUMBER(4) NOT NULL
) TABLESPACE KBD2_3
LOGGING;

ALTER TABLE dni ADD CONSTRAINT dni_pk PRIMARY KEY ( data_recenzji );

CREATE TABLE miejsce (
    numer_miejscowosci NUMBER(4) NOT NULL,
    kod_kraju          VARCHAR2(3) NOT NULL,
    nazwa_miejscowosci VARCHAR2(35),
    nazwa_kraju        VARCHAR2(56)
) TABLESPACE KBD2_3
LOGGING;

COMMENT ON COLUMN dni.data_recenzji IS 'Data recenzji bez czasu';
COMMENT ON COLUMN dni.dzien_tygodnia IS 'Dzień tygodnia (1-7), gdzie 1 to poniedziałek, a 7 to niedziela';
COMMENT ON COLUMN dni.miesiac IS 'Miesiąc (1-12), gdzie 1 to styczeń, a 12 to grudzień';
COMMENT ON COLUMN dni.pora_roku IS 'Pora roku (1-4), gdzie 1 to wiosna, 2 lato, 3 jesień, 4 zima';
COMMENT ON COLUMN dni.rok IS 'Rok w formacie czterocyfrowym';

ALTER TABLE miejsce ADD CONSTRAINT miejsce_pk PRIMARY KEY ( numer_miejscowosci,
                                                            kod_kraju );

CREATE TABLE piwa (
    id_piwa             NUMBER(4) NOT NULL,
    nazwa               VARCHAR2(35 CHAR) NOT NULL,
    id_browaru          NUMBER(4) NOT NULL,
    nazwa_browaru       VARCHAR2(30) NOT NULL,
    kod_kraju           VARCHAR2(3) NOT NULL,
    nazwa_kraju         VARCHAR2(56) NOT NULL,
    id_stylu            NUMBER(4) NOT NULL,
    nazwa_stylu         VARCHAR2(40) NOT NULL,
    zawartosc_alkoholu  NUMBER(3, 1) NOT NULL,
    zawartosc_ekstraktu NUMBER(3, 1) NOT NULL,
    goryczka            NUMBER(4) NOT NULL,
    barwa               NUMBER(2) NOT NULL
) TABLESPACE KBD2_3
LOGGING;




ALTER TABLE piwa ADD CONSTRAINT piwa_pk PRIMARY KEY ( id_piwa );

CREATE TABLE plec (
    plec CHAR(1) NOT NULL
) TABLESPACE KBD2_3
LOGGING;

ALTER TABLE plec ADD CONSTRAINT plec_pk PRIMARY KEY ( plec );

CREATE TABLE recenzje (
    data_i_czas_recenzji DATE NOT NULL,
    ocena_ogolna NUMBER(2) NOT NULL,
    smak NUMBER(2) NOT NULL,
    wyglad NUMBER(2) NOT NULL,
    aromat NUMBER(2) NOT NULL,
    id_piwa NUMBER(4) NOT NULL,
    plec CHAR(1) NOT NULL,
    rok_urodzenia NUMBER(4) NOT NULL,
    miejsce_nr_miejscowosci NUMBER(4) NOT NULL,
    miejsce_kod_kraju VARCHAR2 (3) NOT NULL,
    data_recenzji DATE GENERATED ALWAYS AS (TRUNC(data_i_czas_recenzji)) VIRTUAL NOT NULL,
    czas_recenzji VARCHAR2(8) GENERATED ALWAYS AS (TO_CHAR(data_i_czas_recenzji, 'HH24:MI:SS')) VIRTUAL NOT NULL
)
PARTITION BY RANGE (data_i_czas_recenzji)
INTERVAL (NUMTOYMINTERVAL(6, 'MONTH'))
(PARTITION partycja_1 VALUES LESS THAN (TO_DATE('2020-01-01', 'YYYY-MM-DD')))
TABLESPACE KBD2_4
LOGGING;



COMMENT ON TABLE recenzje IS
    'plec, rok urodzenia oraz miesjce to cechy recenzentów. Rozbite ponieważ korzystamy z indeksów bitowych lecz kombinacji miejsce-rok byłoby bardzo dużo.'
    ;

COMMENT ON COLUMN recenzje.data_recenzji IS
    'Kolumna wirtualna zawierająca informacje o dacie, bez czasu. 
Stworzona azeby być kluczem obcym do tabeli dni.';

COMMENT ON COLUMN recenzje.czas_recenzji IS
    'Kolumna wirtualna zawierająca informacje o godzinie, bez daty.
';

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_pk PRIMARY KEY ( id_piwa,
                                             czas_recenzji,
                                             data_recenzji );

CREATE TABLE rok_urodzenia (
    rok_urodzenia NUMBER(4) NOT NULL
) TABLESPACE KBD2_3
LOGGING;

ALTER TABLE rok_urodzenia ADD CONSTRAINT rok_urodzenia_pk PRIMARY KEY ( rok_urodzenia );

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_dni_fk FOREIGN KEY ( data_recenzji )
        REFERENCES dni ( data_recenzji )
    DISABLE NOVALIDATE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_miejsce_fk FOREIGN KEY ( miejsce_nr_miejscowosci,
                                                     miejsce_kod_kraju )
        REFERENCES miejsce ( numer_miejscowosci,
                             kod_kraju )
    DISABLE NOVALIDATE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_piwo_fk FOREIGN KEY ( id_piwa )
        REFERENCES piwa ( id_piwa )
    DISABLE NOVALIDATE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_plec_fk FOREIGN KEY ( plec )
        REFERENCES plec ( plec )
    DISABLE NOVALIDATE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_rok_urodzenia_fk FOREIGN KEY ( rok_urodzenia )
        REFERENCES rok_urodzenia ( rok_urodzenia )
    DISABLE NOVALIDATE;
    
    

CREATE BITMAP INDEX recenzje_plec_FK_I ON recenzje (plec) LOCAL TABLESPACE KBD2_4;
CREATE BITMAP INDEX recenzje_miejsce_FK_I ON recenzje (miejsce_nr_miejscowosci, miejsce_kod_kraju) LOCAL TABLESPACE KBD2_4;
CREATE BITMAP INDEX recenzje_rok_urodzenia_FK_I ON recenzje (rok_urodzenia) LOCAL TABLESPACE KBD2_4;
CREATE BITMAP INDEX recenzje_piwa_FK_I ON recenzje (id_piwa) LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_dzien_tygodnia_JI ON recenzje (dni.dzien_tygodnia)
FROM recenzje, dni
WHERE recenzje.data_recenzji = dni.data_recenzji LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_miesiac_JI ON recenzje (dni.miesiac)
FROM recenzje, dni
WHERE recenzje.data_recenzji = dni.data_recenzji LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_pora_roku_JI ON recenzje (dni.pora_roku)
FROM recenzje, dni
WHERE recenzje.data_recenzji = dni.data_recenzji LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_rok_JI ON recenzje (dni.rok)
FROM recenzje, dni
WHERE recenzje.data_recenzji = dni.data_recenzji LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_plec_JI ON recenzje (plec.plec)
FROM recenzje, plec
WHERE recenzje.plec = plec.plec LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_nazwa_browaru_JI ON recenzje (piwa.nazwa_browaru)
FROM recenzje, piwa
WHERE recenzje.id_piwa = piwa.id_piwa LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_rok_urodzenia_JI ON recenzje (rok_urodzenia.rok_urodzenia)
FROM recenzje, rok_urodzenia
WHERE recenzje.rok_urodzenia = rok_urodzenia.rok_urodzenia LOCAL TABLESPACE KBD2_4;

CREATE BITMAP INDEX recenzje_nr_miejscowosci_JI ON recenzje (miejsce.numer_miejscowosci)
FROM recenzje, miejsce
WHERE recenzje.miejsce_nr_miejscowosci = miejsce.numer_miejscowosci AND recenzje.miejsce_kod_kraju = miejsce.kod_kraju LOCAL TABLESPACE KBD2_4;



-- PODS_REC
CREATE MATERIALIZED VIEW PODS_REC (
  ID_PIWA,
  NAZWA_PIWA,
  LICZBA_RECENZJI,
  SREDNIA_OCENA_OGOLNA,
  SREDNIA_OCENA_SMAKU,
  SREDNIA_OCENA_WYGLADU,
  SREDNIA_OCENA_AROMATU
)
ORGANIZATION HEAP
PCTFREE 10 PCTUSED 40
INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE KBD2_3
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
AS SELECT
  p.id_piwa,
  p.nazwa,
  COUNT(*) AS liczba_recenzji,
  AVG(r.ocena_ogolna) AS srednia_ocena_ogolna,
  AVG(r.smak) AS srednia_ocena_smaku,
  AVG(r.wyglad) AS srednia_ocena_wygladu,
  AVG(r.aromat) AS srednia_ocena_aromatu
FROM recenzje r JOIN piwa p ON (r.id_piwa = p.id_piwa)
GROUP BY p.id_piwa, p.nazwa;

-- PODS_REC_MIEJSC_MIES
CREATE MATERIALIZED VIEW PODS_REC_MIEJSC_MIES (
  ID_PIWA,
  NAZWA_PIWA,
  NUMER_MIEJSCOWOSCI,
  NAZWA_MIEJSCOWOSCI,
  MIESIAC,
  LICZBA_RECENZJI,
  SREDNIA_OCENA_OGOLNA
)
ORGANIZATION HEAP
PCTFREE 10 PCTUSED 40
INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE KBD2_3
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT
  r.id_piwa AS id_piwa, 
  p.nazwa AS nazwa_piwa,
  m.numer_miejscowosci AS nr_miejscowosci,
  m.nazwa_miejscowosci AS nazwa_miejscowosci,
  EXTRACT(MONTH FROM r.data_recenzji) AS miesiac,
  COUNT(*) AS liczba_recenzji,
  AVG(r.ocena_ogolna) AS srednia_ocena_ogolna
FROM recenzje r
JOIN miejsce m ON (r.miejsce_nr_miejscowosci = m.numer_miejscowosci AND r.miejsce_kod_kraju = m.kod_kraju)
JOIN piwa p ON (r.id_piwa = p.id_piwa)
GROUP BY r.id_piwa, p.nazwa, m.numer_miejscowosci, m.nazwa_miejscowosci, EXTRACT(MONTH FROM r.data_recenzji);

-- SR_REC_STYL
CREATE MATERIALIZED VIEW SR_REC_STYL (
  ID_STYLU,
  NAZWA_STYLU,
  SREDNIA_OCENA_OGOLNA,
  SREDNIA_SMAK,
  SREDNIA_WYGLAD,
  SREDNIA_AROMAT
)
ORGANIZATION HEAP
PCTFREE 10 PCTUSED 40
INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE KBD2_3
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT
  p.id_stylu,
  p.nazwa_stylu,
  AVG(r.ocena_ogolna) AS srednia_ocena_ogolna,
  AVG(r.smak) AS srednia_smak,
  AVG(r.wyglad) AS srednia_wyglad,
  AVG(r.aromat) AS srednia_aromat
FROM recenzje r
JOIN piwa p ON r.id_piwa = p.id_piwa
GROUP BY p.id_stylu, p.nazwa_stylu;

-- SR_REC_STYL_PLEC_MIES
CREATE MATERIALIZED VIEW SR_REC_STYL_PLEC_MIES (
  ID_STYLU,
  NAZWA_STYLU,
  PLEC,
  MIESIAC,
  SREDNIA_OCENA_OGOLNA
)
ORGANIZATION HEAP
PCTFREE 10 PCTUSED 40
INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE KBD2_3
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT
  p.id_stylu,
  p.nazwa_stylu,
  pl.plec,
  EXTRACT(MONTH FROM r.data_recenzji) AS miesiac,
  AVG(r.ocena_ogolna) AS srednia_ocena_ogolna
FROM recenzje r
JOIN piwa p ON r.id_piwa = p.id_piwa
JOIN plec pl ON r.plec = pl.plec
GROUP BY p.id_stylu, p.nazwa_stylu, pl.plec, EXTRACT(MONTH FROM r.data_recenzji);

-- SR_REC_PROD_MIES
CREATE MATERIALIZED VIEW SR_REC_PROD_MIES (
  ID_BROWARU,
  NAZWA_BROWARU,
  MIESIAC,
  NUMER_MIEJSCOWOSCI,
  NAZWA_MIEJSCOWOSCI,
  ROK_URODZENIA,
  PLEC,
  LICZBA_RECENZJI
)
ORGANIZATION HEAP
PCTFREE 10 PCTUSED 40
INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE(
  INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT
)
TABLESPACE KBD2_3
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT
  p.id_browaru,
  p.nazwa_browaru,
  EXTRACT(MONTH FROM r.data_recenzji) AS miesiac,
  m.numer_miejscowosci,
  m.nazwa_miejscowosci,
  ro.rok_urodzenia,
  pl.plec,
  COUNT(*) AS liczba_recenzji
FROM recenzje r
JOIN plec pl ON r.plec = pl.plec
JOIN rok_urodzenia ro ON r.rok_urodzenia = ro.rok_urodzenia
JOIN miejsce m ON (r.miejsce_nr_miejscowosci = m.numer_miejscowosci AND r.miejsce_kod_kraju = m.kod_kraju)
JOIN piwa p ON r.id_piwa = p.id_piwa
GROUP BY p.id_browaru, p.nazwa_browaru, EXTRACT(MONTH FROM r.data_recenzji), m.numer_miejscowosci, m.nazwa_miejscowosci, ro.rok_urodzenia, pl.plec;


COMMIT;

-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             6
-- CREATE INDEX                             0
-- ALTER TABLE                             11
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        2
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 2