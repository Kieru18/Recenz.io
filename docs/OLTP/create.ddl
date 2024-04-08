-- Generated by Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   at:        2024-04-08 19:42:31 CEST
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE browary (
    id_browaru     NUMBER(4) NOT NULL,
    nazwa          VARCHAR2(30 CHAR) NOT NULL,
    data_zalozenia DATE,
    kod_kraju      VARCHAR2(3 CHAR) NOT NULL
)
LOGGING;

CREATE INDEX browary_kraje_fk_i ON
    browary (
        kod_kraju
    ASC )
        LOGGING;

ALTER TABLE browary ADD CONSTRAINT browar_pk PRIMARY KEY ( id_browaru );

CREATE TABLE konta (
    id_konta NUMBER(4) NOT NULL,
    nazwa    VARCHAR2(15 CHAR) NOT NULL,
    typ      CHAR(10 CHAR) NOT NULL
)
LOGGING;

ALTER TABLE konta
    ADD CONSTRAINT typ_konta_arc_lov CHECK ( typ IN ( 'piwowar', 'uzytkownik' ) );

ALTER TABLE konta ADD CONSTRAINT konta_pk PRIMARY KEY ( id_konta );

ALTER TABLE konta ADD CONSTRAINT konta_nazwa_uk UNIQUE ( nazwa );

CREATE TABLE kraje (
    kod_kraju VARCHAR2(3 CHAR) NOT NULL,
    nazwa     VARCHAR2(56 CHAR) NOT NULL
)
LOGGING;

ALTER TABLE kraje ADD CONSTRAINT kraje_pk PRIMARY KEY ( kod_kraju );

ALTER TABLE kraje ADD CONSTRAINT kraje_nazwa_uk UNIQUE ( nazwa );

CREATE TABLE miejscowosci (
    numer_miejscowosci NUMBER(4) NOT NULL,
    nazwa              VARCHAR2(35) NOT NULL,
    kod_kraju          VARCHAR2(3 CHAR) NOT NULL
)
LOGGING;

ALTER TABLE miejscowosci ADD CONSTRAINT miejscowosci_pk PRIMARY KEY ( kod_kraju,
                                                                      numer_miejscowosci );

CREATE TABLE piwa (
    numer_piwa          NUMBER(4) NOT NULL,
    nazwa               VARCHAR2(35 CHAR) NOT NULL,
    opis                VARCHAR2(700 CHAR),
    zawartosc_alkoholu  NUMBER(3, 1) NOT NULL,
    zawartosc_ekstraktu NUMBER(3, 1) NOT NULL,
    goryczka            NUMBER(4),
    barwa               NUMBER(2),
    zdjecie             BLOB,
    id_browaru          NUMBER(4) NOT NULL,
    id_stylu            NUMBER(4) NOT NULL
)
LOGGING;

CREATE INDEX piwa_style_fk_i ON
    piwa (
        id_stylu
    ASC )
        LOGGING;

ALTER TABLE piwa ADD CONSTRAINT piwa_pk PRIMARY KEY ( id_browaru,
                                                      numer_piwa );

CREATE TABLE piwowarzy (
    id_konta   NUMBER(4) NOT NULL,
    id_browaru NUMBER(4) NOT NULL
)
LOGGING;

CREATE INDEX piwowarzy_browary_fk_i ON
    piwowarzy (
        id_browaru
    ASC )
        LOGGING;

ALTER TABLE piwowarzy ADD CONSTRAINT piwowarzy_pk PRIMARY KEY ( id_konta );

CREATE TABLE recenzje (
    czas_recenzji  TIMESTAMP(3) NOT NULL,
    ocena_ogolna   NUMBER(2) NOT NULL,
    smak           NUMBER(2) NOT NULL,
    wyglad         NUMBER(2) NOT NULL,
    aromat         NUMBER(2) NOT NULL,
    id_uzytkownika NUMBER(4) NOT NULL,
    id_browaru     NUMBER(4) NOT NULL,
    numer_piwa     NUMBER(4) NOT NULL,
    komentarz      VARCHAR2(2000 CHAR)
)
LOGGING;

CREATE INDEX recenzje_piwa_fk_i ON
    recenzje (
        id_browaru
    ASC,
        numer_piwa
    ASC )
        LOGGING;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_pk PRIMARY KEY ( id_uzytkownika,
                                             id_browaru,
                                             numer_piwa );

CREATE TABLE style (
    id_stylu NUMBER(4) NOT NULL,
    nazwa    VARCHAR2(40 CHAR) NOT NULL,
    opis     XMLTYPE
)
LOGGING XMLTYPE COLUMN opis STORE AS BINARY XML (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
    RETENTION
    ENABLE STORAGE IN ROW
    NOCACHE
);

ALTER TABLE style ADD CONSTRAINT style_pk PRIMARY KEY ( id_stylu );

CREATE TABLE uzytkownicy (
    id_konta           NUMBER(4) NOT NULL,
    data_urodzenia     DATE NOT NULL,
    plec               CHAR(1 CHAR) NOT NULL,
    numer_miejscowosci NUMBER(4) NOT NULL,
    kod_kraju          VARCHAR2(3 CHAR) NOT NULL
)
LOGGING;

CREATE INDEX uzytkownicy_miejscowosci_fk_i ON
    uzytkownicy (
        kod_kraju
    ASC,
        numer_miejscowosci
    ASC )
        LOGGING;

ALTER TABLE uzytkownicy ADD constraint uzytkownicy_plec_chk 
    CHECK (CHECK plec IN ('K', 'M'))
;
ALTER TABLE uzytkownicy ADD CONSTRAINT uzytkownicy_pk PRIMARY KEY ( id_konta );

ALTER TABLE browary
    ADD CONSTRAINT browar_kraj_fk FOREIGN KEY ( kod_kraju )
        REFERENCES kraje ( kod_kraju )
    NOT DEFERRABLE;

ALTER TABLE miejscowosci
    ADD CONSTRAINT miejscowosci_kraje_fk FOREIGN KEY ( kod_kraju )
        REFERENCES kraje ( kod_kraju )
    NOT DEFERRABLE;

ALTER TABLE piwa
    ADD CONSTRAINT piwa_browary_fk FOREIGN KEY ( id_browaru )
        REFERENCES browary ( id_browaru )
    NOT DEFERRABLE;

ALTER TABLE piwa
    ADD CONSTRAINT piwa_style_fk FOREIGN KEY ( id_stylu )
        REFERENCES style ( id_stylu )
    NOT DEFERRABLE;

ALTER TABLE piwowarzy
    ADD CONSTRAINT piwowarzy_browary_fk FOREIGN KEY ( id_browaru )
        REFERENCES browary ( id_browaru )
    NOT DEFERRABLE;

ALTER TABLE piwowarzy
    ADD CONSTRAINT piwowarzy_konta_fk FOREIGN KEY ( id_konta )
        REFERENCES konta ( id_konta )
    NOT DEFERRABLE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_piwa_fk FOREIGN KEY ( id_browaru,
                                                  numer_piwa )
        REFERENCES piwa ( id_browaru,
                          numer_piwa )
    NOT DEFERRABLE;

ALTER TABLE recenzje
    ADD CONSTRAINT recenzje_uzytkownicy_fk FOREIGN KEY ( id_uzytkownika )
        REFERENCES konta ( id_konta )
    NOT DEFERRABLE;

ALTER TABLE uzytkownicy
    ADD CONSTRAINT uzytkownicy_konta_fk FOREIGN KEY ( id_konta )
        REFERENCES konta ( id_konta )
    NOT DEFERRABLE;

ALTER TABLE uzytkownicy
    ADD CONSTRAINT uzytkownicy_miejscowosci_fk FOREIGN KEY ( kod_kraju,
                                                             numer_miejscowosci )
        REFERENCES miejscowosci ( kod_kraju,
                                  numer_miejscowosci )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER fkntm_browary BEFORE
    UPDATE OF kod_kraju ON browary
BEGIN
    raise_application_error(-20225, 'Non Transferable FK constraint  on table browary is violated');
END;
/

CREATE OR REPLACE TRIGGER fkntm_piwa BEFORE
    UPDATE OF id_stylu, id_browaru ON piwa
BEGIN
    raise_application_error(-20225, 'Non Transferable FK constraint  on table piwa is violated');
END;
/

CREATE OR REPLACE TRIGGER fkntm_recenzje BEFORE
    UPDATE OF id_uzytkownika, id_browaru, numer_piwa ON recenzje
BEGIN
    raise_application_error(-20225, 'Non Transferable FK constraint  on table recenzje is violated');
END;
/

CREATE OR REPLACE TRIGGER arc_typ_konta_arc_piwowarzy BEFORE
    INSERT OR UPDATE OF id_konta ON piwowarzy
    FOR EACH ROW
DECLARE
    d CHAR(10 CHAR);
BEGIN
    SELECT
        a.typ
    INTO d
    FROM
        konta a
    WHERE
        a.id_konta = :new.id_konta;

    IF ( d IS NULL OR d <> 'piwowar' ) THEN
        raise_application_error(-20223, 'FK piwowarzy_konta_FK in Table piwowarzy violates Arc constraint on Table konta - discriminator column typ doesn''t have value ''piwowar'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_typ_konta_arc_uzytkownicy BEFORE
    INSERT OR UPDATE OF id_konta ON uzytkownicy
    FOR EACH ROW
DECLARE
    d CHAR(10 CHAR);
BEGIN
    SELECT
        a.typ
    INTO d
    FROM
        konta a
    WHERE
        a.id_konta = :new.id_konta;

    IF ( d IS NULL OR d <> 'uzytkownik' ) THEN
        raise_application_error(-20223, 'FK uzytkownicy_konta_FK in Table uzytkownicy violates Arc constraint on Table konta - discriminator column typ doesn''t have value ''uzytkownik'''
        );
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

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

CREATE SEQUENCE piwa_numer_piwa_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER piwa_numer_piwa_trg BEFORE
    INSERT ON piwa
    FOR EACH ROW
    WHEN ( new.numer_piwa IS NULL )
BEGIN
    :new.numer_piwa := piwa_numer_piwa_seq.nextval;
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



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             9
-- CREATE INDEX                             5
-- ALTER TABLE                             23
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                          10
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
-- CREATE SEQUENCE                          5
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
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
-- WARNINGS                                 0