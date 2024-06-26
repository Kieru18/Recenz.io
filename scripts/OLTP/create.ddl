-- Cluster
CREATE CLUSTER konta_cluster
    (id_konta NUMBER(4))
    SIZE 1024
    HASHKEYS 100
    TABLESPACE KBD2_1;

-- Tables, PKs, indexes, UK, declarative constraints (checks, UKs), comments

CREATE TABLE browary (
    id_browaru     NUMBER(4) NOT NULL,
    nazwa          VARCHAR2(30 CHAR) NOT NULL,
    data_zalozenia DATE,
    kod_kraju      VARCHAR2(3 CHAR) NOT NULL
) TABLESPACE KBD2_2;

COMMENT ON TABLE browary IS 'Browary, których piwa dostępne w systemie Recenz.io';

CREATE INDEX browary_kraje_fk_i ON
    browary (
        kod_kraju
    ASC ) TABLESPACE KBD2_2;

ALTER TABLE browary ADD CONSTRAINT browar_pk PRIMARY KEY ( id_browaru );

CREATE TABLE konta (
    id_konta NUMBER(4) NOT NULL,
    nazwa    VARCHAR2(15 CHAR) NOT NULL,
    typ      CHAR(1 CHAR) NOT NULL
) CLUSTER konta_cluster (id_konta);

COMMENT ON TABLE konta IS 'Konta wszystkich użytkowników (prywatnych i komercyjnych) systemu Recenz.io';

ALTER TABLE konta
    ADD CONSTRAINT typ_konta_arc_lov_chk CHECK ( typ IN ( 'w', 's' ) );

CREATE INDEX konta_id_konta_typ_idx ON
    konta (
        id_konta
    ASC,
        typ
    ASC );

ALTER TABLE konta ADD CONSTRAINT konta_pk PRIMARY KEY ( id_konta );

ALTER TABLE konta ADD CONSTRAINT konta_nazwa_uk UNIQUE ( nazwa );

ALTER TABLE konta ADD CONSTRAINT konta_id_konta_typ_uk UNIQUE ( id_konta,
                                                                typ );

CREATE TABLE kraje (
    kod_kraju VARCHAR2(3 CHAR) NOT NULL,
    nazwa     VARCHAR2(63 CHAR) NOT NULL,
    CONSTRAINT kraje_pk PRIMARY KEY ( kod_kraju )
) ORGANIZATION INDEX 
  TABLESPACE KBD2_2;
  
COMMENT ON TABLE kraje IS 'Tabela s�ownikowa pomagająca lokalizować browary i miejscowości';
COMMENT ON COLUMN kraje.kod_kraju IS 'Kod kraju zdefiniowany w standardzie ISO 3166-1 alfa-3';

ALTER TABLE kraje ADD CONSTRAINT kraje_nazwa_uk UNIQUE ( nazwa );

CREATE TABLE miejscowosci (
    numer_miejscowosci NUMBER(4) NOT NULL,
    kod_kraju          VARCHAR2(3 CHAR) NOT NULL,
    nazwa              VARCHAR2(35) NOT NULL    
) TABLESPACE KBD2_2;

COMMENT ON TABLE miejscowosci IS 'Tabela grupująca użytkowników w danej lokalizacji';

ALTER TABLE miejscowosci ADD CONSTRAINT miejscowosci_pk PRIMARY KEY ( kod_kraju,
                                                                      numer_miejscowosci );

CREATE TABLE piwa (
    numer_piwa          NUMBER(4) NOT NULL,
    id_browaru          NUMBER(4) NOT NULL,
    nazwa               VARCHAR2(35 CHAR) NOT NULL,
    opis                VARCHAR2(1200 CHAR),
    zawartosc_alkoholu  NUMBER(3, 1) NOT NULL,
    zawartosc_ekstraktu NUMBER(3, 1) NOT NULL,
    goryczka            NUMBER(4),
    barwa               NUMBER(2),
    zdjecie             BLOB,
    id_stylu            NUMBER(4) NOT NULL
) TABLESPACE KBD2_1;

COMMENT ON TABLE piwa IS 'Piwa dostępne do oceny w systemie Recenz.io';
COMMENT ON COLUMN piwa.zawartosc_alkoholu IS 'Zawartość alkoholu mierzona w ABV - procentach objętościowych';
COMMENT ON COLUMN piwa.zawartosc_ekstraktu IS 'Zawartość ekstraktu mierzona w stopniach Ballinga';
COMMENT ON COLUMN piwa.goryczka IS 'Goryczka wyrażona w IBU (International Bitterness Unit)';
COMMENT ON COLUMN piwa.barwa IS 'Barwa wyrażona w EBC (European Brewery Convention)';


CREATE INDEX piwa_style_fk_i ON
    piwa (
        id_stylu
    ASC ) TABLESPACE KBD2_1;

ALTER TABLE piwa ADD CONSTRAINT piwa_pk PRIMARY KEY ( id_browaru,
                                                      numer_piwa );

CREATE TABLE piwowarzy (
    id_konta   NUMBER(4) NOT NULL,
    id_browaru NUMBER(4) NOT NULL
) CLUSTER konta_cluster (id_konta);

COMMENT ON TABLE piwowarzy IS 'Użytkownicy komercyjni reprezentujący browary';

CREATE INDEX piwowarzy_browary_fk_i ON
    piwowarzy (
        id_browaru
    ASC ) TABLESPACE KBD2_1;

ALTER TABLE piwowarzy ADD CONSTRAINT piwowarzy_pk PRIMARY KEY ( id_konta );

CREATE TABLE recenzje (
    numer_recenzji  NUMBER(4) NOT NULL,
    id_browaru      NUMBER(4) NOT NULL,
    numer_piwa      NUMBER(4) NOT NULL,
    id_konta        NUMBER(4),
    typ_konta       CHAR(1),
    czas_recenzji   TIMESTAMP(3) NOT NULL,
    ocena_ogolna    NUMBER(2) NOT NULL,
    smak            NUMBER(2) NOT NULL,
    wyglad          NUMBER(2) NOT NULL,
    aromat          NUMBER(2) NOT NULL,
    komentarz       VARCHAR2(2000 CHAR)
) TABLESPACE KBD2_1;

COMMENT ON TABLE recenzje IS 'Oceny liczbowe i komentarz wystawiany piwom przez użytkowników';

ALTER TABLE recenzje ADD CONSTRAINT recenzje_typ_konta_chk CHECK ( typ_konta = 's' );

COMMENT ON TABLE recenzje IS
    'Oceny liczbowe i komentarz wystawiany piwom przez piwoszy';

COMMENT ON COLUMN recenzje.typ_konta IS
    'Typ konta to piwosz czyli  typ_konta=''s''';

CREATE INDEX recenzje_piwa_fk_i ON
    recenzje (
        id_browaru
    ASC,
        numer_piwa
    ASC ) TABLESPACE KBD2_1;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_pk PRIMARY KEY ( id_browaru,
                                             numer_piwa,
                                             numer_recenzji );

CREATE TABLE style (
    id_stylu NUMBER(4) NOT NULL,
    nazwa    VARCHAR2(40 CHAR) NOT NULL,
    opis     XMLTYPE
) TABLESPACE KBD2_2
LOGGING XMLTYPE COLUMN opis STORE AS BINARY XML (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
    RETENTION
    ENABLE STORAGE IN ROW
    NOCACHE
);

COMMENT ON TABLE style IS 'Gatunki / style do którego należy dane piwo';

ALTER TABLE style ADD CONSTRAINT style_pk PRIMARY KEY ( id_stylu );

CREATE TABLE piwosze (
    id_konta           NUMBER(4) NOT NULL,
    data_urodzenia     DATE NOT NULL,
    plec               CHAR(1 CHAR) NOT NULL,
    numer_miejscowosci NUMBER(4) NOT NULL,
    kod_kraju          VARCHAR2(3 CHAR) NOT NULL
) CLUSTER konta_cluster (id_konta);

COMMENT ON TABLE piwosze IS 'Użytkownicy prywatni aplikacji Recenz.io';

CREATE INDEX piwosze_miejscowosci_fk_i ON
    piwosze (
        kod_kraju
    ASC,
        numer_miejscowosci
    ASC ) TABLESPACE KBD2_1;

ALTER TABLE piwosze ADD constraint piwosze_plec_chk 
    CHECK (plec IN ('K', 'M'))
;
ALTER TABLE piwosze ADD CONSTRAINT piwosze_pk PRIMARY KEY ( id_konta );

-- FKs
ALTER TABLE browary
    ADD CONSTRAINT browar_kraj_fk FOREIGN KEY ( kod_kraju )
        REFERENCES kraje ( kod_kraju );

ALTER TABLE miejscowosci
    ADD CONSTRAINT miejscowosci_kraje_fk FOREIGN KEY ( kod_kraju )
        REFERENCES kraje ( kod_kraju );

ALTER TABLE piwa
    ADD CONSTRAINT piwa_browary_fk FOREIGN KEY ( id_browaru )
        REFERENCES browary ( id_browaru );

ALTER TABLE piwa
    ADD CONSTRAINT piwa_style_fk FOREIGN KEY ( id_stylu )
        REFERENCES style ( id_stylu );

ALTER TABLE piwosze
    ADD CONSTRAINT piwosze_konta_fk FOREIGN KEY ( id_konta )
        REFERENCES konta ( id_konta );

ALTER TABLE piwowarzy
    ADD CONSTRAINT piwowarzy_browary_fk FOREIGN KEY ( id_browaru )
        REFERENCES browary ( id_browaru );

ALTER TABLE piwowarzy
    ADD CONSTRAINT piwowarzy_konta_fk FOREIGN KEY ( id_konta )
        REFERENCES konta ( id_konta );

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_konta_fk FOREIGN KEY ( id_konta,
                                                   typ_konta )
        REFERENCES konta ( id_konta,
                           typ );

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_piwa_fk FOREIGN KEY ( id_browaru,
                                                  numer_piwa )
        REFERENCES piwa ( id_browaru,
                          numer_piwa );

ALTER TABLE piwosze
    ADD CONSTRAINT uzytkownicy_miejscowosci_fk FOREIGN KEY ( kod_kraju,
                                                             numer_miejscowosci )
        REFERENCES miejscowosci ( kod_kraju,
                                  numer_miejscowosci );


CREATE OR REPLACE TRIGGER arc_typ_konta_arc_piwowarzy BEFORE
    INSERT OR UPDATE OF id_konta ON piwowarzy
    FOR EACH ROW
DECLARE
    d CHAR(1 CHAR);
BEGIN
    SELECT
        a.typ
    INTO d
    FROM
        konta a
    WHERE
        a.id_konta = :new.id_konta;

    IF ( d IS NULL OR d <> 'w' ) THEN
        raise_application_error(-20223,
                               'FK piwowarzy_konta_FK in Table piwowarzy violates Arc constraint on Table konta - discriminator column typ doesn''t have value ''w''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_typ_konta_arc_piwosze BEFORE
    INSERT OR UPDATE OF id_konta ON piwosze
    FOR EACH ROW
DECLARE
    d CHAR(1 CHAR);
BEGIN
    SELECT
        a.typ
    INTO d
    FROM
        konta a
    WHERE
        a.id_konta = :new.id_konta;

    IF ( d IS NULL OR d <> 's' ) THEN
        raise_application_error(-20223,
                               'FK piwosze_konta_FK in Table piwosze violates Arc constraint on Table konta - discriminator column typ doesn''t have value ''s''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Sequences and triggers for artificial PKs

CREATE SEQUENCE browary_id_browaru_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER browary_id_browaru_trg BEFORE
    INSERT ON browary
    FOR EACH ROW
    WHEN ( new.id_browaru IS NULL )
BEGIN
    :new.id_browaru := browary_id_browaru_seq.nextval;
END;
/

CREATE SEQUENCE konta_id_konta_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER konta_id_konta_trg BEFORE
    INSERT ON konta
    FOR EACH ROW
    WHEN ( new.id_konta IS NULL )
BEGIN
    :new.id_konta := konta_id_konta_seq.nextval;
END;
/

CREATE SEQUENCE miejscowosci_numer_miejscowosc START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER miejscowosci_numer_miejscowosc BEFORE
    INSERT ON miejscowosci
    FOR EACH ROW
    WHEN ( new.numer_miejscowosci IS NULL )
BEGIN
    :new.numer_miejscowosci := miejscowosci_numer_miejscowosc.nextval;
END;
/

CREATE SEQUENCE piwa_numer_piwa_seq START WITH 1 NOCACHE;

CREATE OR REPLACE TRIGGER piwa_numer_piwa_trg BEFORE
    INSERT ON piwa
    FOR EACH ROW
    WHEN ( new.numer_piwa IS NULL )
BEGIN
    :new.numer_piwa := piwa_numer_piwa_seq.nextval;
END;
/

CREATE SEQUENCE recenzje_numer_recenzji_seq START WITH 1 NOCACHE;

CREATE OR REPLACE TRIGGER recenzje_numer_recenzji_trg BEFORE
    INSERT ON recenzje
    FOR EACH ROW
    WHEN ( new.numer_recenzji IS NULL )
BEGIN
    :new.numer_recenzji := recenzje_numer_recenzji_seq.nextval;
END;
/

CREATE SEQUENCE style_id_stylu_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER style_id_stylu_trg BEFORE
    INSERT ON style
    FOR EACH ROW
    WHEN ( new.id_stylu IS NULL )
BEGIN
    :new.id_stylu := style_id_stylu_seq.nextval;
END;
/


-- Views 

CREATE OR REPLACE VIEW moje_recenzje_piwa AS
    SELECT r.czas_recenzji AS czas_recenzji,
           p.nazwa AS nazwa_piwa, 
           b.nazwa AS nazwa_browaru, 
           r.ocena_ogolna AS ocena_ogolna, 
           r.smak AS smak, 
           r.wyglad AS wyglad, 
           r.aromat AS aromat, 
           r.komentarz AS komentarz 
        FROM recenzje r
        JOIN piwa p on r.numer_piwa = p.numer_piwa
        JOIN browary b on p.id_browaru = b.id_browaru
        JOIN konta k on r.id_konta = k.id_konta
WHERE k.id_konta = USER;
/

COMMENT ON TABLE moje_recenzje_piwa IS 'Perspektywa umożliwiająca użytkownikowi przejrzenie (tylko) własnych ocen piw.';

