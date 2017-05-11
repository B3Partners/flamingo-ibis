--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.7
-- Dumped by pg_dump version 9.6.2
-- /usr/bin/pg_dump --port 5432 --username "mark" --role "postgres" --no-password  --format plain --schema-only --no-privileges --no-tablespaces --verbose --no-unlogged-table-data --file "/tmp/ibis.sql" --schema "\"Economie\"" --schema "\"IBIS4\"" "ibis"

-- Started on 2017-05-11 14:20:42 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 10 (class 2615 OID 97009798)
-- Name: Economie; Type: SCHEMA; Schema: -; Owner: ibis
--

CREATE SCHEMA "Economie";


ALTER SCHEMA "Economie" OWNER TO ibis;

--
-- TOC entry 9 (class 2615 OID 96929253)
-- Name: IBIS4; Type: SCHEMA; Schema: -; Owner: ibis
--

CREATE SCHEMA "IBIS4";


ALTER SCHEMA "IBIS4" OWNER TO ibis;

SET search_path = "IBIS4", pg_catalog;

--
-- TOC entry 1276 (class 1255 OID 97011356)
-- Name: update_kavel_oppervlak(); Type: FUNCTION; Schema: IBIS4; Owner: ibis
--

CREATE FUNCTION update_kavel_oppervlak() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.kaveloppervlak = round(st_area(new.geom)::numeric, 0);
    RETURN NEW;	
END;
$$;


ALTER FUNCTION "IBIS4".update_kavel_oppervlak() OWNER TO postgres;

SET search_path = "Economie", pg_catalog;

SET default_with_oids = true;

--
-- TOC entry 189 (class 1259 OID 97009805)
-- Name: EcMO_Leegstand; Type: TABLE; Schema: Economie; Owner: ibis
--

CREATE TABLE "EcMO_Leegstand" (
    pkid bigint NOT NULL,
    datum character varying(20),
    wijziging character varying(255),
    aanbodtype character varying(255),
    soort character varying(255),
    gebouwnaam character varying(255),
    straat character varying(255),
    huisnummmer character varying(255),
    naam character varying(255),
    url character varying(255),
    shorturl character varying(255),
    plaats character varying(255),
    geom public.geometry(Point,28992)
);


ALTER TABLE "EcMO_Leegstand" OWNER TO postgres;

SET search_path = "IBIS4", pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 190 (class 1259 OID 97011357)
-- Name: EcMo_Prov_werkghd_enquete_copy; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE "EcMo_Prov_werkghd_enquete_copy" (
    bedr_nam character varying(60),
    sbi_nam character varying(180),
    klasse_omvang character varying(2),
    geom public.geometry(Point,28992)
);


ALTER TABLE "EcMo_Prov_werkghd_enquete_copy" OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 97011363)
-- Name: bedrijven_grootteklasse; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE bedrijven_grootteklasse (
    klasse character varying(3) NOT NULL,
    beschrijving character varying(255)
);


ALTER TABLE bedrijven_grootteklasse OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 192 (class 1259 OID 97011366)
-- Name: bedrijvenkavels; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE bedrijvenkavels (
    ibis_id bigint NOT NULL,
    gt_key bigint NOT NULL,
    terreinid integer,
    workflow_status character varying(50) NOT NULL,
    datummutatie date NOT NULL,
    status character varying(70),
    uitgegevenaan character varying(255),
    eigenaartype character varying(20),
    eerstejaaruitgifte integer,
    verouderingsstatus character varying(50),
    milieuwet_code bigint,
    gemeentenaam character varying(100),
    geom public.geometry(Polygon,28992),
    kaveloppervlak numeric,
    record_created_reason character varying(100),
    CONSTRAINT valid_workflow_status CHECK (((workflow_status)::text = ANY (ARRAY[('definitief'::character varying)::text, ('bewerkt'::character varying)::text, ('archief'::character varying)::text, ('afgevoerd'::character varying)::text])))
);


ALTER TABLE bedrijvenkavels OWNER TO postgres;

--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN bedrijvenkavels.kaveloppervlak; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON COLUMN bedrijvenkavels.kaveloppervlak IS 'Berekende oppervlakte uit de geometrie. Deze wordt vanuit de trigger calc_kavel_oppervlak berekend.';


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN bedrijvenkavels.record_created_reason; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON COLUMN bedrijvenkavels.record_created_reason IS 'Bevat de reden waarom een bepaald record door het systeem is aangemaakt. als hij lees is dan is het een standaard nieuwe kavel. Bij splitsingen, en als gevolg van wijzigingen in arcgis, worden hier de originele kavel-gt-keys weergegeven.';


--
-- TOC entry 193 (class 1259 OID 97011373)
-- Name: bedrijvenkavels_gt_key_seq; Type: SEQUENCE; Schema: IBIS4; Owner: ibis
--

CREATE SEQUENCE bedrijvenkavels_gt_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bedrijvenkavels_gt_key_seq OWNER TO postgres;

--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 193
-- Name: bedrijvenkavels_gt_key_seq; Type: SEQUENCE OWNED BY; Schema: IBIS4; Owner: ibis
--

ALTER SEQUENCE bedrijvenkavels_gt_key_seq OWNED BY bedrijvenkavels.gt_key;


--
-- TOC entry 194 (class 1259 OID 97011375)
-- Name: bedrijventerrein; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE bedrijventerrein (
    ibis_id integer NOT NULL,
    rin_nr integer,
    datummutatie date NOT NULL,
    reden character varying(70),
    workflow_status character varying(50) NOT NULL,
    a_bestemming character varying(30),
    a_grootstedeel double precision,
    a_haruimtegebruik double precision,
    a_kernnaam character varying(25),
    a_ovwkavelgrootte character varying(20),
    a_planfase character varying(100),
    a_plannaam character varying(255),
    a_statusrpb character varying(100),
    a_type character varying(100),
    c_hyperlink character varying(255),
    c_onderhoudemail character varying(100),
    c_onderhoudnaam character varying(100),
    c_onderhoudtelefoon character varying(15),
    c_organisatie character varying(100),
    c_postcodeplaats character varying(50),
    c_verkoopadres character varying(100),
    c_verkoopemail character varying(100),
    c_verkoopnaam character varying(100),
    c_verkooptelefoon character varying(15),
    c_verkoopwebsite character varying(255),
    o_afstandvliegveld integer,
    o_collbeheer character varying(20),
    o_collinkoop character varying(50),
    o_collvoorz character varying(25),
    o_internet character varying(100),
    o_maxhuur bigint,
    o_maxverkoop bigint,
    o_milieuzone character varying(20),
    o_externebereikbaarheid character varying(20),
    o_minhuur bigint,
    o_minverkoop bigint,
    o_naamvliegveld character varying(100),
    o_overslag character varying(100),
    o_parkeergelegenheid character varying(100),
    o_spoorontsluiting character varying(100),
    o_waterontsluiting character varying(100),
    o_wegontsluiting character varying(100),
    geom public.geometry(MultiPolygon,28992),
    gt_pkey bigint NOT NULL,
    gemeente_naam character varying(100),
    o_milieuwet_code bigint,
    CONSTRAINT valid_workflow_status CHECK (((workflow_status)::text = ANY (ARRAY[('definitief'::character varying)::text, ('bewerkt'::character varying)::text, ('archief'::character varying)::text, ('afgevoerd'::character varying)::text])))
);


ALTER TABLE bedrijventerrein OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 97011382)
-- Name: bedrijventerrein_gt_pkey_seq; Type: SEQUENCE; Schema: IBIS4; Owner: ibis
--

CREATE SEQUENCE bedrijventerrein_gt_pkey_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bedrijventerrein_gt_pkey_seq OWNER TO postgres;

--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 195
-- Name: bedrijventerrein_gt_pkey_seq; Type: SEQUENCE OWNED BY; Schema: IBIS4; Owner: ibis
--

ALTER SEQUENCE bedrijventerrein_gt_pkey_seq OWNED BY bedrijventerrein.gt_pkey;


SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 97011384)
-- Name: code; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE code (
    id integer NOT NULL,
    soort character varying(20) NOT NULL,
    waarde character varying(100) NOT NULL,
    actueel boolean NOT NULL,
    oudecode character varying(10),
    volgorde integer
);


ALTER TABLE code OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 97011387)
-- Name: code_id_seq; Type: SEQUENCE; Schema: IBIS4; Owner: ibis
--

CREATE SEQUENCE code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code_id_seq OWNER TO postgres;

--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 197
-- Name: code_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS4; Owner: ibis
--

ALTER SEQUENCE code_id_seq OWNED BY code.id;


--
-- TOC entry 198 (class 1259 OID 97011389)
-- Name: codes_milieuwet; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE codes_milieuwet (
    id integer NOT NULL,
    waarde character varying(100) NOT NULL
);


ALTER TABLE codes_milieuwet OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 199 (class 1259 OID 97011392)
-- Name: gemeente; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE gemeente (
    id integer NOT NULL,
    cbscode character varying(4),
    naam character varying(100),
    provincie character varying(50),
    vvr_id smallint,
    corop character varying(65),
    deelregio character varying(65),
    geom public.geometry(Polygon,28992)
);


ALTER TABLE gemeente OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 97011398)
-- Name: gemeente_id_seq; Type: SEQUENCE; Schema: IBIS4; Owner: ibis
--

CREATE SEQUENCE gemeente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gemeente_id_seq OWNER TO postgres;

--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 200
-- Name: gemeente_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS4; Owner: ibis
--

ALTER SEQUENCE gemeente_id_seq OWNED BY gemeente.id;


SET default_with_oids = false;

--
-- TOC entry 201 (class 1259 OID 97011400)
-- Name: gt_pk_metadata; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE gt_pk_metadata (
    table_schema character varying(32) NOT NULL,
    table_name character varying(32) NOT NULL,
    pk_column character varying(32) NOT NULL,
    pk_column_idx integer,
    pk_policy character varying(32),
    pk_sequence character varying(64),
    CONSTRAINT gt_pk_metadata_pk_policy_check CHECK (((pk_policy)::text = ANY (ARRAY[('sequence'::character varying)::text, ('assigned'::character varying)::text, ('autoincrement'::character varying)::text])))
);


ALTER TABLE gt_pk_metadata OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 202 (class 1259 OID 97011404)
-- Name: kavelhistorie; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE kavelhistorie (
    ibis_id bigint NOT NULL,
    terreinid integer,
    status character varying(70),
    uitgiftejaar integer,
    uitgiftemaand integer,
    uitgegevenaan character varying(255),
    gemeentenaam character varying(100),
    eigenaartype character varying(100),
    kaveloppervlak integer,
    geom public.geometry(Polygon,28992),
    bouwjaar_oudste_bagpand integer
);


ALTER TABLE kavelhistorie OWNER TO postgres;

SET default_with_oids = false;

--
-- TOC entry 203 (class 1259 OID 97011410)
-- Name: kaveluitgiftes; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE kaveluitgiftes (
    terreinid bigint,
    datummutatie date,
    jaar bigint,
    gt_key bigint,
    uitgegevenaan character varying(255),
    oppervlak numeric,
    datumtijd_gegevens timestamp without time zone,
    geom public.geometry
);


ALTER TABLE kaveluitgiftes OWNER TO postgres;

SET default_with_oids = true;

--
-- TOC entry 204 (class 1259 OID 97011416)
-- Name: regio; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE regio (
    id integer NOT NULL,
    vvr_id integer,
    vvr_naam character varying(50),
    geom public.geometry(MultiPolygon,28992)
);


ALTER TABLE regio OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 97011422)
-- Name: v_actuele_kavels; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_actuele_kavels AS
 SELECT bedrijvenkavels.gt_key,
    bedrijvenkavels.ibis_id,
    bedrijvenkavels.workflow_status,
    bedrijvenkavels.datummutatie,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    bedrijvenkavels.uitgegevenaan,
    bedrijvenkavels.eerstejaaruitgifte,
    bedrijvenkavels.gemeentenaam,
    bedrijvenkavels.kaveloppervlak,
    bedrijvenkavels.eigenaartype,
    bedrijvenkavels.verouderingsstatus,
    bedrijvenkavels.milieuwet_code,
    bedrijvenkavels.geom
   FROM bedrijvenkavels
  WHERE ((bedrijvenkavels.workflow_status)::text = ANY (ARRAY['definitief'::text, 'bewerkt'::text]));


ALTER TABLE v_actuele_kavels OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 97011426)
-- Name: v_actuele_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_actuele_terreinen AS
 SELECT bedrijventerrein.ibis_id,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datummutatie,
    bedrijventerrein.reden,
    bedrijventerrein.workflow_status,
    bedrijventerrein.a_bestemming,
    bedrijventerrein.a_grootstedeel,
    bedrijventerrein.a_haruimtegebruik,
    bedrijventerrein.a_kernnaam,
    bedrijventerrein.a_ovwkavelgrootte,
    bedrijventerrein.a_planfase,
    bedrijventerrein.a_plannaam,
    bedrijventerrein.a_statusrpb,
    bedrijventerrein.a_type,
    bedrijventerrein.c_hyperlink,
    bedrijventerrein.c_onderhoudemail,
    bedrijventerrein.c_onderhoudnaam,
    bedrijventerrein.c_onderhoudtelefoon,
    bedrijventerrein.c_organisatie,
    bedrijventerrein.c_postcodeplaats,
    bedrijventerrein.c_verkoopadres,
    bedrijventerrein.c_verkoopemail,
    bedrijventerrein.c_verkoopnaam,
    bedrijventerrein.c_verkooptelefoon,
    bedrijventerrein.c_verkoopwebsite,
    bedrijventerrein.o_afstandvliegveld,
    bedrijventerrein.o_collbeheer,
    bedrijventerrein.o_collinkoop,
    bedrijventerrein.o_collvoorz,
    bedrijventerrein.o_internet,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
    bedrijventerrein.o_milieuzone,
    bedrijventerrein.o_externebereikbaarheid,
    bedrijventerrein.o_minhuur,
    bedrijventerrein.o_minverkoop,
    bedrijventerrein.o_naamvliegveld,
    bedrijventerrein.o_overslag,
    bedrijventerrein.o_parkeergelegenheid,
    bedrijventerrein.o_spoorontsluiting,
    bedrijventerrein.o_waterontsluiting,
    bedrijventerrein.o_wegontsluiting,
    bedrijventerrein.geom,
    bedrijventerrein.gt_pkey,
    bedrijventerrein.gemeente_naam,
    bedrijventerrein.o_milieuwet_code
   FROM bedrijventerrein
  WHERE ((bedrijventerrein.workflow_status)::text = ANY (ARRAY['definitief'::text, 'bewerkt'::text]));


ALTER TABLE v_actuele_terreinen OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 97011431)
-- Name: v_gemeente_en_regio_envelopes; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_gemeente_en_regio_envelopes AS
 SELECT gemeente.id AS gem_id,
    gemeente.naam,
    gemeente.cbscode,
    gemeente.provincie,
    gemeente.corop,
    gemeente.deelregio,
    regio.vvr_naam,
    regio.vvr_id,
    public.st_envelope(public.st_snaptogrid(public.st_buffer(public.st_envelope(gemeente.geom), (1000)::double precision), (1)::double precision, (1)::double precision)) AS bbox_gemeente,
    public.st_snaptogrid(public.st_envelope(regio.geom), (1)::double precision, (1)::double precision) AS bbox_regio
   FROM gemeente,
    regio
  WHERE (gemeente.vvr_id = regio.vvr_id);


ALTER TABLE v_gemeente_en_regio_envelopes OWNER TO postgres;

--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 207
-- Name: VIEW v_gemeente_en_regio_envelopes; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_gemeente_en_regio_envelopes IS 'Geeft de MBR van de gemeenten en regio_s';


--
-- TOC entry 208 (class 1259 OID 97011435)
-- Name: v_publieke_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_publieke_terreinen AS
 SELECT t.ibis_id,
    t.rin_nr,
    t.datummutatie,
    t.reden,
    t.workflow_status,
    t.a_bestemming,
    t.a_grootstedeel,
    t.a_haruimtegebruik,
    t.a_kernnaam,
    t.a_ovwkavelgrootte,
    t.a_planfase,
    t.a_plannaam,
    t.a_statusrpb,
    t.a_type,
    t.c_hyperlink,
    t.c_onderhoudemail,
    t.c_onderhoudnaam,
    t.c_onderhoudtelefoon,
    t.c_organisatie,
    t.c_postcodeplaats,
    t.c_verkoopadres,
    t.c_verkoopemail,
    t.c_verkoopnaam,
    t.c_verkooptelefoon,
    t.c_verkoopwebsite,
    t.o_afstandvliegveld,
    t.o_collbeheer,
    t.o_collinkoop,
    t.o_collvoorz,
    t.o_internet,
    t.o_maxhuur,
    t.o_maxverkoop,
    t.o_milieuzone,
    t.o_externebereikbaarheid,
    t.o_minhuur,
    t.o_minverkoop,
    t.o_naamvliegveld,
    t.o_overslag,
    t.o_parkeergelegenheid,
    t.o_spoorontsluiting,
    t.o_waterontsluiting,
    t.o_wegontsluiting,
    t.geom,
    t.gt_pkey,
    t.gemeente_naam,
    t.o_milieuwet_code
   FROM v_actuele_terreinen t
  WHERE (((((t.a_planfase)::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text) OR ((t.a_planfase)::text = 'Ontwerp bestemmingsplan'::text)) OR ((t.a_planfase)::text = 'Vastgesteld bestemmingsplan'::text)) AND ((t.workflow_status)::text = 'definitief'::text));


ALTER TABLE v_publieke_terreinen OWNER TO postgres;

--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 208
-- Name: VIEW v_publieke_terreinen; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_publieke_terreinen IS 'View is uitsluitend tbv het geven van een publieke zoekingang op de (solr) zoekengine op de viewer.';


--
-- TOC entry 209 (class 1259 OID 97011440)
-- Name: v_component_ibis_report; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_component_ibis_report AS
 SELECT t.ibis_id,
    t.rin_nr,
    t.workflow_status,
    t.a_planfase,
    t.a_plannaam,
    t.gemeente_naam,
    t.geom,
    (public.st_envelope(public.st_snaptogrid((public.st_buffer(public.st_envelope(t.geom), (100)::double precision))::public.geometry(Polygon,28992), (1)::double precision, (1)::double precision)))::public.geometry(Polygon,28992) AS bbox_terrein,
    v_gemeente_en_regio_envelopes.naam,
    v_gemeente_en_regio_envelopes.bbox_gemeente,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.bbox_regio
   FROM (v_publieke_terreinen t
     LEFT JOIN v_gemeente_en_regio_envelopes ON (((t.gemeente_naam)::text = (v_gemeente_en_regio_envelopes.naam)::text)))
  ORDER BY v_gemeente_en_regio_envelopes.vvr_naam, v_gemeente_en_regio_envelopes.naam, t.a_plannaam;


ALTER TABLE v_component_ibis_report OWNER TO postgres;

--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 209
-- Name: VIEW v_component_ibis_report; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_component_ibis_report IS 'Uitgifte gegevens voor IbisReport component.';


--
-- TOC entry 210 (class 1259 OID 97011445)
-- Name: v_leegstand; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_leegstand AS
 SELECT t.ibis_id AS terreinid,
    t.gt_pkey,
    count(l.*) AS beschikbare_panden
   FROM v_actuele_terreinen t,
    "Economie"."EcMO_Leegstand" l
  WHERE public.st_within(l.geom, t.geom)
  GROUP BY t.ibis_id, t.gt_pkey;


ALTER TABLE v_leegstand OWNER TO postgres;

--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 210
-- Name: VIEW v_leegstand; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_leegstand IS 'Geeft de het aantal beschikbare panden op een terrein';


--
-- TOC entry 211 (class 1259 OID 97011449)
-- Name: v_terrein_oppervlakte; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_terrein_oppervlakte AS
 SELECT t.gt_pkey,
    t.ibis_id,
    t.rin_nr,
    t.workflow_status,
    COALESCE(NULLIF(round(((public.st_area(t.geom))::numeric / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_geom,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = 'Woonbebouwing'::text) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_woonbebouwing,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = 'Openbare ruimte'::text) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_openbare_ruimte,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN (((a.status)::text = 'Niet terstond uitgeefbaar'::text) AND ((a.eigenaartype)::text = 'particulier'::text)) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_niet_terstond_uitgeefbaar_part,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN (((a.status)::text = 'Niet terstond uitgeefbaar'::text) AND ((a.eigenaartype)::text = 'gemeente'::text)) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_niet_terstond_uitgeefbaar_gem,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = 'Uitgegeven'::text) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_uitgegeven,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN (((a.status)::text = 'Terstond uitgeefbaar'::text) AND ((a.eigenaartype)::text = 'gemeente'::text)) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_uitgeefbaar_gem,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN (((a.status)::text = 'Terstond uitgeefbaar'::text) AND ((a.eigenaartype)::text = 'particulier'::text)) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_uitgeefbaar_part,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = 'Niet bekend'::text) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_niet_bekend,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = 'Optie'::text) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_optie,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN (a.status IS NULL) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_leeg,
    COALESCE(NULLIF(round((sum(
        CASE
            WHEN ((a.status)::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Optie'::text, 'Uitgegeven'::text, 'Niet terstond uitgeefbaar'::text])) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_netto,
    COALESCE(NULLIF(round((sum(a.kaveloppervlak) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_bruto,
    COALESCE(NULLIF(round((max(
        CASE
            WHEN ((a.status)::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Niet terstond uitgeefbaar'::text])) THEN a.kaveloppervlak
            ELSE (0)::numeric
        END) / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_gr_uitgeefbaar_kavel,
    COALESCE(NULLIF((max(
        CASE
            WHEN ((a.status)::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Niet terstond uitgeefbaar'::text])) THEN a.milieuwet_code
            ELSE (0)::bigint
        END))::numeric, (0)::numeric), (0)::numeric) AS max_hindercat_uitgeefbaar_kavel,
    COALESCE(NULLIF((max(a.milieuwet_code))::numeric, (0)::numeric), (0)::numeric) AS max_hindercat_terrein,
    sum(
        CASE
            WHEN ((a.kaveloppervlak < (1000)::numeric) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN 1
            ELSE 0
        END) AS aantal_kavels_onder_1000m2,
    sum(
        CASE
            WHEN (((a.kaveloppervlak >= (1000)::numeric) AND (a.kaveloppervlak <= (2500)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN 1
            ELSE 0
        END) AS aantal_kavels_tussen_1000_2500,
    sum(
        CASE
            WHEN (((a.kaveloppervlak >= (2500)::numeric) AND (a.kaveloppervlak <= (5000)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN 1
            ELSE 0
        END) AS aantal_kavels_tussen_2500_5000,
    sum(
        CASE
            WHEN (((a.kaveloppervlak >= (5000)::numeric) AND (a.kaveloppervlak <= (10000)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN 1
            ELSE 0
        END) AS aantal_kavels_tussen_5000_10k,
    sum(
        CASE
            WHEN ((a.kaveloppervlak > (10000)::numeric) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN 1
            ELSE 0
        END) AS aantal_kavels_groter_10k,
    round(avg(
        CASE
            WHEN ((a.kaveloppervlak < (1000)::numeric) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN a.kaveloppervlak
            ELSE NULL::numeric
        END)) AS avg_opp_kavels_onder_1000m2,
    round(avg(
        CASE
            WHEN (((a.kaveloppervlak >= (1000)::numeric) AND (a.kaveloppervlak <= (2500)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN a.kaveloppervlak
            ELSE NULL::numeric
        END)) AS avg_opp_kavels_tussen_1000_2500,
    round(avg(
        CASE
            WHEN (((a.kaveloppervlak >= (2500)::numeric) AND (a.kaveloppervlak <= (5000)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN a.kaveloppervlak
            ELSE NULL::numeric
        END)) AS avg_opp_kavels_tussen_2500_5000,
    round(avg(
        CASE
            WHEN (((a.kaveloppervlak >= (5000)::numeric) AND (a.kaveloppervlak <= (10000)::numeric)) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN a.kaveloppervlak
            ELSE NULL::numeric
        END)) AS avg_opp_kavels_tussen_5000_10k,
    round(avg(
        CASE
            WHEN ((a.kaveloppervlak > (10000)::numeric) AND ((a.status)::text = ANY (ARRAY[('Niet terstond uitgeefbaar'::character varying)::text, ('Terstond uitgeefbaar'::character varying)::text, ('Optie'::character varying)::text, ('Uitgegeven'::character varying)::text]))) THEN a.kaveloppervlak
            ELSE NULL::numeric
        END)) AS avg_opp_kavels_groter_10k
   FROM v_actuele_terreinen t,
    v_actuele_kavels a
  WHERE (a.terreinid = t.ibis_id)
  GROUP BY t.gt_pkey, t.ibis_id, t.rin_nr, t.workflow_status, t.geom;


ALTER TABLE v_terrein_oppervlakte OWNER TO postgres;

SET default_with_oids = false;

--
-- TOC entry 212 (class 1259 OID 97011454)
-- Name: vest_banen_per_terrein; Type: TABLE; Schema: IBIS4; Owner: ibis
--

CREATE TABLE vest_banen_per_terrein (
    rin_nr bigint,
    bedrijven bigint,
    medewerkers bigint
);


ALTER TABLE vest_banen_per_terrein OWNER TO postgres;

--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE vest_banen_per_terrein; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON TABLE vest_banen_per_terrein IS 'tabel komende van jaarlijkse bedrijven-interview. Is een export die door freerk aangeleverd wordt';


--
-- TOC entry 213 (class 1259 OID 97011457)
-- Name: v_factsheet_terrein_info; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_factsheet_terrein_info AS
 SELECT bedrijventerrein.ibis_id AS terreinid,
    bedrijventerrein.ibis_id,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datummutatie,
    bedrijventerrein.reden,
    bedrijventerrein.workflow_status,
    bedrijventerrein.a_bestemming,
    bedrijventerrein.a_grootstedeel,
    bedrijventerrein.a_haruimtegebruik,
    bedrijventerrein.a_kernnaam,
    bedrijventerrein.a_ovwkavelgrootte,
    bedrijventerrein.a_planfase,
    bedrijventerrein.a_plannaam,
    bedrijventerrein.a_statusrpb,
    bedrijventerrein.a_type,
    bedrijventerrein.c_hyperlink,
    bedrijventerrein.c_onderhoudemail,
    bedrijventerrein.c_onderhoudnaam,
    bedrijventerrein.c_onderhoudtelefoon,
    bedrijventerrein.c_organisatie,
    bedrijventerrein.c_postcodeplaats,
    bedrijventerrein.c_verkoopadres,
    bedrijventerrein.c_verkoopemail,
    bedrijventerrein.c_verkoopnaam,
    bedrijventerrein.c_verkooptelefoon,
    bedrijventerrein.c_verkoopwebsite,
    bedrijventerrein.o_afstandvliegveld,
    bedrijventerrein.o_collbeheer,
    bedrijventerrein.o_collinkoop,
    bedrijventerrein.o_collvoorz,
    bedrijventerrein.o_internet,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
    ( SELECT codes_milieuwet.waarde
           FROM codes_milieuwet
          WHERE (codes_milieuwet.id = bedrijventerrein.o_milieuwet_code)) AS o_milieuwet,
    bedrijventerrein.o_milieuwet_code,
    bedrijventerrein.o_milieuzone,
    bedrijventerrein.o_externebereikbaarheid,
    bedrijventerrein.o_minhuur,
    bedrijventerrein.o_minverkoop,
    bedrijventerrein.o_naamvliegveld,
    bedrijventerrein.o_overslag,
    bedrijventerrein.o_parkeergelegenheid,
    bedrijventerrein.o_spoorontsluiting,
    bedrijventerrein.o_waterontsluiting,
    bedrijventerrein.o_wegontsluiting,
    bedrijventerrein.gemeente_naam,
    bedrijventerrein.geom,
        CASE
            WHEN (v_leegstand.beschikbare_panden IS NULL) THEN (0)::bigint
            ELSE v_leegstand.beschikbare_panden
        END AS beschikbare_panden,
    (round(v_terrein_oppervlakte.opp_geom, 2))::character varying AS opp_geom_ha,
    (round(v_terrein_oppervlakte.opp_woonbebouwing, 2))::character varying AS opp_woonbebouwing_ha,
    (round(v_terrein_oppervlakte.opp_openbare_ruimte, 2))::character varying AS opp_openbare_ruimte_ha,
    (round((v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem), 2))::character varying AS opp_niet_terstond_uitgeefbaar_ha,
    (round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part, 2))::character varying AS opp_niet_terstond_uitgeefbaar_part_ha,
    (round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem, 2))::character varying AS opp_niet_terstond_uitgeefbaar_gem_ha,
    (round(v_terrein_oppervlakte.opp_uitgegeven, 2))::character varying AS opp_uitgegeven_ha,
    (round((v_terrein_oppervlakte.opp_uitgeefbaar_part + v_terrein_oppervlakte.opp_uitgeefbaar_gem), 2))::character varying AS opp_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_bekend, 2) AS opp_niet_bekend_ha,
    (round(v_terrein_oppervlakte.opp_leeg, 2))::character varying AS opp_leeg_ha,
    (round(v_terrein_oppervlakte.opp_optie, 2))::character varying AS opp_optie_ha,
    (round(v_terrein_oppervlakte.opp_netto, 2))::character varying AS opp_netto_ha,
    (round(v_terrein_oppervlakte.opp_bruto, 2))::character varying AS opp_bruto_ha,
    v_gemeente_en_regio_envelopes.cbscode,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.corop,
    v_gemeente_en_regio_envelopes.deelregio,
    v_gemeente_en_regio_envelopes.provincie,
    vest_banen_per_terrein.bedrijven AS aantal_bedrijven,
    vest_banen_per_terrein.medewerkers AS aantal_werkzame_personen,
    v_terrein_oppervlakte.opp_gr_uitgeefbaar_kavel,
    v_terrein_oppervlakte.max_hindercat_uitgeefbaar_kavel,
    v_terrein_oppervlakte.max_hindercat_terrein
   FROM ((((v_actuele_terreinen bedrijventerrein
     LEFT JOIN v_leegstand ON ((bedrijventerrein.gt_pkey = v_leegstand.gt_pkey)))
     LEFT JOIN v_terrein_oppervlakte ON ((v_terrein_oppervlakte.gt_pkey = bedrijventerrein.gt_pkey)))
     LEFT JOIN v_gemeente_en_regio_envelopes ON (((bedrijventerrein.gemeente_naam)::text = (v_gemeente_en_regio_envelopes.naam)::text)))
     LEFT JOIN vest_banen_per_terrein ON ((bedrijventerrein.rin_nr = vest_banen_per_terrein.rin_nr)))
  WHERE (((bedrijventerrein.workflow_status)::text = 'definitief'::text) AND ((v_terrein_oppervlakte.workflow_status)::text = 'definitief'::text));


ALTER TABLE v_factsheet_terrein_info OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 97011462)
-- Name: v_grootste_10_bedrijven_op_terrein; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_grootste_10_bedrijven_op_terrein AS
 SELECT a.gt_pkey,
    a.terreinid,
    a.rin_nr,
    a.naam,
    a.activiteit,
    a.grootte_klasse,
    a.grootte_beschrijving
   FROM ( SELECT t.gt_pkey,
            t.ibis_id AS terreinid,
            t.rin_nr,
            bedr.bedr_nam AS naam,
            bedr.sbi_nam AS activiteit,
            bedr.klasse_omvang AS grootte_klasse,
            g.beschrijving AS grootte_beschrijving,
            row_number() OVER (PARTITION BY t.rin_nr ORDER BY bedr.klasse_omvang DESC) AS row_id
           FROM "EcMo_Prov_werkghd_enquete_copy" bedr,
            v_actuele_terreinen t,
            bedrijven_grootteklasse g
          WHERE ((public.st_within(bedr.geom, t.geom) AND ((g.klasse)::text = (bedr.klasse_omvang)::text)) AND ((t.workflow_status)::text = 'definitief'::text))
          ORDER BY t.rin_nr, row_number() OVER (PARTITION BY t.rin_nr ORDER BY bedr.klasse_omvang DESC)) a
  WHERE (a.row_id <= 10);


ALTER TABLE v_grootste_10_bedrijven_op_terrein OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 97011467)
-- Name: v_publieke_kavels; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_publieke_kavels AS
 SELECT k.gt_key,
    k.ibis_id,
    k.workflow_status,
    k.datummutatie,
    k.terreinid,
    k.status,
    k.uitgegevenaan,
    k.eerstejaaruitgifte,
    k.gemeentenaam,
    k.kaveloppervlak,
    k.eigenaartype,
    k.milieuwet_code,
    t.a_planfase,
    k.geom
   FROM v_actuele_terreinen t,
    v_actuele_kavels k
  WHERE ((((k.terreinid = t.ibis_id) AND ((((t.a_planfase)::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text) OR ((t.a_planfase)::text = 'Ontwerp bestemmingsplan'::text)) OR ((t.a_planfase)::text = 'Vastgesteld bestemmingsplan'::text))) AND ((t.workflow_status)::text = 'definitief'::text)) AND ((k.workflow_status)::text = 'definitief'::text));


ALTER TABLE v_publieke_kavels OWNER TO postgres;

--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 215
-- Name: VIEW v_publieke_kavels; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_publieke_kavels IS 'Deze view geeft alleen de kavels door die bij plannen horen die onherroepelijk en definitief zijn; zachte plannen komen niet in deze view voor.';


--
-- TOC entry 216 (class 1259 OID 97011472)
-- Name: v_report_uitgifte_kavels; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_uitgifte_kavels AS
 SELECT r.vvr_naam,
    g.naam AS gemeentenaam,
    t.a_plannaam AS plannaam,
    kavelrecs_met_statusmutatie.datummutatie AS datum_eerste_uitgifte,
    kavelrecs_met_statusmutatie.ibis_id AS kavel_ibis_id,
    t.a_planfase AS planfase,
    t.rin_nr,
    round((sum(kavelrecs_met_statusmutatie.kaveloppervlak) / (10000)::numeric), 4) AS uitgegeven_oppervlak
   FROM ( SELECT k1.ibis_id,
            k1.gt_key,
            k1.terreinid,
            k1.workflow_status,
            k1.datummutatie,
            k1.status,
            k1.uitgegevenaan,
            k1.eigenaartype,
            k1.eerstejaaruitgifte,
            k1.verouderingsstatus,
            k1.milieuwet_code,
            k1.gemeentenaam,
            k1.geom,
            k1.kaveloppervlak,
            k1.volgnr,
            k2.status AS oude_status
           FROM (( SELECT bedrijvenkavels.ibis_id,
                    bedrijvenkavels.gt_key,
                    bedrijvenkavels.terreinid,
                    bedrijvenkavels.workflow_status,
                    bedrijvenkavels.datummutatie,
                    bedrijvenkavels.status,
                    bedrijvenkavels.uitgegevenaan,
                    bedrijvenkavels.eigenaartype,
                    bedrijvenkavels.eerstejaaruitgifte,
                    bedrijvenkavels.verouderingsstatus,
                    bedrijvenkavels.milieuwet_code,
                    bedrijvenkavels.gemeentenaam,
                    bedrijvenkavels.geom,
                    bedrijvenkavels.kaveloppervlak,
                    bedrijvenkavels.record_created_reason,
                    row_number() OVER (PARTITION BY bedrijvenkavels.ibis_id ORDER BY bedrijvenkavels.datummutatie, bedrijvenkavels.gt_key) AS volgnr
                   FROM bedrijvenkavels) k1
             LEFT JOIN ( SELECT bedrijvenkavels.ibis_id,
                    bedrijvenkavels.gt_key,
                    bedrijvenkavels.terreinid,
                    bedrijvenkavels.workflow_status,
                    bedrijvenkavels.datummutatie,
                    bedrijvenkavels.status,
                    bedrijvenkavels.uitgegevenaan,
                    bedrijvenkavels.eigenaartype,
                    bedrijvenkavels.eerstejaaruitgifte,
                    bedrijvenkavels.verouderingsstatus,
                    bedrijvenkavels.milieuwet_code,
                    bedrijvenkavels.gemeentenaam,
                    bedrijvenkavels.geom,
                    bedrijvenkavels.kaveloppervlak,
                    bedrijvenkavels.record_created_reason,
                    row_number() OVER (PARTITION BY bedrijvenkavels.ibis_id ORDER BY bedrijvenkavels.datummutatie, bedrijvenkavels.gt_key) AS volgnr
                   FROM bedrijvenkavels) k2 ON (((k2.ibis_id = k1.ibis_id) AND (k2.volgnr = (k1.volgnr - 1)))))
          WHERE (((k2.status)::text <> (k1.status)::text) OR ((k2.status IS NULL) AND ((k1.volgnr > 1) OR ((k1.volgnr = 1) AND (k1.record_created_reason IS NULL)))))) kavelrecs_met_statusmutatie,
    bedrijventerrein t,
    gemeente g,
    regio r
  WHERE (((((((kavelrecs_met_statusmutatie.workflow_status)::text = ANY (ARRAY[('definitief'::character varying)::text, ('archief'::character varying)::text])) AND ((t.workflow_status)::text = ('definitief'::character varying)::text)) AND (kavelrecs_met_statusmutatie.terreinid = t.ibis_id)) AND ((t.gemeente_naam)::text = (g.naam)::text)) AND (r.id = g.vvr_id)) AND ((kavelrecs_met_statusmutatie.status)::text = 'Uitgegeven'::text))
  GROUP BY kavelrecs_met_statusmutatie.ibis_id, r.vvr_naam, g.naam, t.a_plannaam, t.a_planfase, t.rin_nr, kavelrecs_met_statusmutatie.datummutatie
  ORDER BY r.vvr_naam, g.naam, t.a_plannaam, kavelrecs_met_statusmutatie.datummutatie, kavelrecs_met_statusmutatie.ibis_id;


ALTER TABLE v_report_uitgifte_kavels OWNER TO postgres;

--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 216
-- Name: VIEW v_report_uitgifte_kavels; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_report_uitgifte_kavels IS 'View levert alle kavelrecords op, waarbij de kavel VOOR HET EERST UITGEGEVEN is.';


--
-- TOC entry 217 (class 1259 OID 97011477)
-- Name: v_report_uitgifte_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_uitgifte_terreinen AS
 SELECT a.vvr_naam,
    a.gemeentenaam,
    a.plannaam,
    a.rin_nr,
    sum(
        CASE
            WHEN (a.jaar = (1980)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1980,
    sum(
        CASE
            WHEN (a.jaar = (1981)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1981,
    sum(
        CASE
            WHEN (a.jaar = (1982)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1982,
    sum(
        CASE
            WHEN (a.jaar = (1983)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1983,
    sum(
        CASE
            WHEN (a.jaar = (1984)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1984,
    sum(
        CASE
            WHEN (a.jaar = (1985)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1985,
    sum(
        CASE
            WHEN (a.jaar = (1986)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1986,
    sum(
        CASE
            WHEN (a.jaar = (1987)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1987,
    sum(
        CASE
            WHEN (a.jaar = (1988)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1988,
    sum(
        CASE
            WHEN (a.jaar = (1989)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1989,
    sum(
        CASE
            WHEN (a.jaar = (1990)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1990,
    sum(
        CASE
            WHEN (a.jaar = (1991)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1991,
    sum(
        CASE
            WHEN (a.jaar = (1992)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1992,
    sum(
        CASE
            WHEN (a.jaar = (1993)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1993,
    sum(
        CASE
            WHEN (a.jaar = (1994)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1994,
    sum(
        CASE
            WHEN (a.jaar = (1995)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1995,
    sum(
        CASE
            WHEN (a.jaar = (1996)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1996,
    sum(
        CASE
            WHEN (a.jaar = (1997)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1997,
    sum(
        CASE
            WHEN (a.jaar = (1998)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1998,
    sum(
        CASE
            WHEN (a.jaar = (1999)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _1999,
    sum(
        CASE
            WHEN (a.jaar = (2000)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2000,
    sum(
        CASE
            WHEN (a.jaar = (2001)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2001,
    sum(
        CASE
            WHEN (a.jaar = (2002)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2002,
    sum(
        CASE
            WHEN (a.jaar = (2003)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2003,
    sum(
        CASE
            WHEN (a.jaar = (2004)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2004,
    sum(
        CASE
            WHEN (a.jaar = (2005)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2005,
    sum(
        CASE
            WHEN (a.jaar = (2006)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2006,
    sum(
        CASE
            WHEN (a.jaar = (2007)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2007,
    sum(
        CASE
            WHEN (a.jaar = (2008)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2008,
    sum(
        CASE
            WHEN (a.jaar = (2009)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2009,
    sum(
        CASE
            WHEN (a.jaar = (2010)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2010,
    sum(
        CASE
            WHEN (a.jaar = (2011)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2011,
    sum(
        CASE
            WHEN (a.jaar = (2012)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2012,
    sum(
        CASE
            WHEN (a.jaar = (2013)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2013,
    sum(
        CASE
            WHEN (a.jaar = (2014)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2014,
    sum(
        CASE
            WHEN (a.jaar = (2015)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2015,
    sum(
        CASE
            WHEN (a.jaar = (2016)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2016,
    sum(
        CASE
            WHEN (a.jaar = (2017)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2017,
    sum(
        CASE
            WHEN (a.jaar = (2018)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2018,
    sum(
        CASE
            WHEN (a.jaar = (2019)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) AS _2019,
    ('now'::text)::date AS datum_gegevens
   FROM ( SELECT v_report_uitgifte_kavels.vvr_naam,
            v_report_uitgifte_kavels.gemeentenaam,
            v_report_uitgifte_kavels.plannaam,
            v_report_uitgifte_kavels.planfase,
            v_report_uitgifte_kavels.rin_nr,
            date_part('year'::text, v_report_uitgifte_kavels.datum_eerste_uitgifte) AS jaar,
            sum(v_report_uitgifte_kavels.uitgegeven_oppervlak) AS oppervlak
           FROM v_report_uitgifte_kavels
          GROUP BY v_report_uitgifte_kavels.vvr_naam, v_report_uitgifte_kavels.gemeentenaam, v_report_uitgifte_kavels.plannaam, v_report_uitgifte_kavels.planfase, v_report_uitgifte_kavels.rin_nr, date_part('year'::text, v_report_uitgifte_kavels.datum_eerste_uitgifte)) a
  GROUP BY a.vvr_naam, a.gemeentenaam, a.plannaam, a.planfase, a.rin_nr
  ORDER BY a.vvr_naam, a.gemeentenaam, a.plannaam;


ALTER TABLE v_report_uitgifte_terreinen OWNER TO postgres;

--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 217
-- Name: VIEW v_report_uitgifte_terreinen; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_report_uitgifte_terreinen IS 'Alle jaaruitgiften van terreinen.';


--
-- TOC entry 218 (class 1259 OID 97011482)
-- Name: v_report_uitgifte_terreinen_group_gem; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_uitgifte_terreinen_group_gem AS
 SELECT v_report_uitgifte_terreinen.vvr_naam,
    v_report_uitgifte_terreinen.gemeentenaam,
    sum(v_report_uitgifte_terreinen._1980) AS _1980,
    sum(v_report_uitgifte_terreinen._1981) AS _1981,
    sum(v_report_uitgifte_terreinen._1982) AS _1982,
    sum(v_report_uitgifte_terreinen._1983) AS _1983,
    sum(v_report_uitgifte_terreinen._1984) AS _1984,
    sum(v_report_uitgifte_terreinen._1985) AS _1985,
    sum(v_report_uitgifte_terreinen._1986) AS _1986,
    sum(v_report_uitgifte_terreinen._1987) AS _1987,
    sum(v_report_uitgifte_terreinen._1988) AS _1988,
    sum(v_report_uitgifte_terreinen._1989) AS _1989,
    sum(v_report_uitgifte_terreinen._1990) AS _1990,
    sum(v_report_uitgifte_terreinen._1991) AS _1991,
    sum(v_report_uitgifte_terreinen._1992) AS _1992,
    sum(v_report_uitgifte_terreinen._1993) AS _1993,
    sum(v_report_uitgifte_terreinen._1994) AS _1994,
    sum(v_report_uitgifte_terreinen._1995) AS _1995,
    sum(v_report_uitgifte_terreinen._1996) AS _1996,
    sum(v_report_uitgifte_terreinen._1997) AS _1997,
    sum(v_report_uitgifte_terreinen._1998) AS _1998,
    sum(v_report_uitgifte_terreinen._1999) AS _1999,
    sum(v_report_uitgifte_terreinen._2000) AS _2000,
    sum(v_report_uitgifte_terreinen._2001) AS _2001,
    sum(v_report_uitgifte_terreinen._2002) AS _2002,
    sum(v_report_uitgifte_terreinen._2003) AS _2003,
    sum(v_report_uitgifte_terreinen._2004) AS _2004,
    sum(v_report_uitgifte_terreinen._2005) AS _2005,
    sum(v_report_uitgifte_terreinen._2006) AS _2006,
    sum(v_report_uitgifte_terreinen._2007) AS _2007,
    sum(v_report_uitgifte_terreinen._2008) AS _2008,
    sum(v_report_uitgifte_terreinen._2009) AS _2009,
    sum(v_report_uitgifte_terreinen._2010) AS _2010,
    sum(v_report_uitgifte_terreinen._2011) AS _2011,
    sum(v_report_uitgifte_terreinen._2012) AS _2012,
    sum(v_report_uitgifte_terreinen._2013) AS _2013,
    sum(v_report_uitgifte_terreinen._2014) AS _2014,
    sum(v_report_uitgifte_terreinen._2015) AS _2015,
    sum(v_report_uitgifte_terreinen._2016) AS _2016,
    sum(v_report_uitgifte_terreinen._2017) AS _2017,
    sum(v_report_uitgifte_terreinen._2018) AS _2018,
    sum(v_report_uitgifte_terreinen._2019) AS _2019,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_uitgifte_terreinen
  GROUP BY v_report_uitgifte_terreinen.vvr_naam, v_report_uitgifte_terreinen.gemeentenaam;


ALTER TABLE v_report_uitgifte_terreinen_group_gem OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 97011487)
-- Name: v_report_uitgifte_terreinen_group_vvr; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_uitgifte_terreinen_group_vvr AS
 SELECT v_report_uitgifte_terreinen.vvr_naam,
    sum(v_report_uitgifte_terreinen._1980) AS _1980,
    sum(v_report_uitgifte_terreinen._1981) AS _1981,
    sum(v_report_uitgifte_terreinen._1982) AS _1982,
    sum(v_report_uitgifte_terreinen._1983) AS _1983,
    sum(v_report_uitgifte_terreinen._1984) AS _1984,
    sum(v_report_uitgifte_terreinen._1985) AS _1985,
    sum(v_report_uitgifte_terreinen._1986) AS _1986,
    sum(v_report_uitgifte_terreinen._1987) AS _1987,
    sum(v_report_uitgifte_terreinen._1988) AS _1988,
    sum(v_report_uitgifte_terreinen._1989) AS _1989,
    sum(v_report_uitgifte_terreinen._1990) AS _1990,
    sum(v_report_uitgifte_terreinen._1991) AS _1991,
    sum(v_report_uitgifte_terreinen._1992) AS _1992,
    sum(v_report_uitgifte_terreinen._1993) AS _1993,
    sum(v_report_uitgifte_terreinen._1994) AS _1994,
    sum(v_report_uitgifte_terreinen._1995) AS _1995,
    sum(v_report_uitgifte_terreinen._1996) AS _1996,
    sum(v_report_uitgifte_terreinen._1997) AS _1997,
    sum(v_report_uitgifte_terreinen._1998) AS _1998,
    sum(v_report_uitgifte_terreinen._1999) AS _1999,
    sum(v_report_uitgifte_terreinen._2000) AS _2000,
    sum(v_report_uitgifte_terreinen._2001) AS _2001,
    sum(v_report_uitgifte_terreinen._2002) AS _2002,
    sum(v_report_uitgifte_terreinen._2003) AS _2003,
    sum(v_report_uitgifte_terreinen._2004) AS _2004,
    sum(v_report_uitgifte_terreinen._2005) AS _2005,
    sum(v_report_uitgifte_terreinen._2006) AS _2006,
    sum(v_report_uitgifte_terreinen._2007) AS _2007,
    sum(v_report_uitgifte_terreinen._2008) AS _2008,
    sum(v_report_uitgifte_terreinen._2009) AS _2009,
    sum(v_report_uitgifte_terreinen._2010) AS _2010,
    sum(v_report_uitgifte_terreinen._2011) AS _2011,
    sum(v_report_uitgifte_terreinen._2012) AS _2012,
    sum(v_report_uitgifte_terreinen._2013) AS _2013,
    sum(v_report_uitgifte_terreinen._2014) AS _2014,
    sum(v_report_uitgifte_terreinen._2015) AS _2015,
    sum(v_report_uitgifte_terreinen._2016) AS _2016,
    sum(v_report_uitgifte_terreinen._2017) AS _2017,
    sum(v_report_uitgifte_terreinen._2018) AS _2018,
    sum(v_report_uitgifte_terreinen._2019) AS _2019,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_uitgifte_terreinen
  GROUP BY v_report_uitgifte_terreinen.vvr_naam;


ALTER TABLE v_report_uitgifte_terreinen_group_vvr OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 97011492)
-- Name: v_report_uitgifte_terreinen_opb_kaveluitgiftes; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_uitgifte_terreinen_opb_kaveluitgiftes AS
 SELECT r.vvr_naam,
    g.naam,
    b.a_plannaam,
    b.rin_nr,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1980)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _onbekend_1980,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1985)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1985,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1986)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1986,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1987)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1987,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1988)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1988,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1989)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1989,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1990)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1990,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1991)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1991,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1992)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1992,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1993)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1993,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1994)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1994,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1995)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1995,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1996)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1996,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1997)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1997,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1998)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1998,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (1999)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _1999,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2000)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2000,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2001)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2001,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2002)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2002,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2003)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2003,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2004)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2004,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2005)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2005,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2006)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2006,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2007)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2007,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2008)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2008,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2009)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2009,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2010)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2010,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2011)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2011,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2012)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2012,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2013)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2013,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2014)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2014,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2015)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2015,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2016)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2016,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2017)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2017,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2018)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2018,
    round((sum(
        CASE
            WHEN ((a.jaar)::double precision = (2019)::double precision) THEN a.oppervlak
            ELSE NULL::numeric
        END) / (10000)::numeric), 4) AS _2019,
    min(a.datumtijd_gegevens) AS datum_gegevens
   FROM kaveluitgiftes a,
    v_actuele_terreinen b,
    gemeente g,
    regio r
  WHERE (((a.terreinid = b.ibis_id) AND ((g.naam)::text = (b.gemeente_naam)::text)) AND (r.id = g.vvr_id))
  GROUP BY r.vvr_naam, g.naam, b.a_plannaam, b.a_planfase, b.rin_nr
  ORDER BY r.vvr_naam, g.naam, b.a_plannaam;


ALTER TABLE v_report_uitgifte_terreinen_opb_kaveluitgiftes OWNER TO postgres;

--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 220
-- Name: VIEW v_report_uitgifte_terreinen_opb_kaveluitgiftes; Type: COMMENT; Schema: IBIS4; Owner: ibis
--

COMMENT ON VIEW v_report_uitgifte_terreinen_opb_kaveluitgiftes IS 'Alle jaaruitgiften van terreinen op basis van nieuw kaveluitgifte algoritme.';


--
-- TOC entry 221 (class 1259 OID 97011497)
-- Name: v_report_voorraad_all_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_all_terreinen AS
 SELECT r.vvr_naam,
    t.gemeente_naam AS gemeentenaam,
    t.a_plannaam AS plannaam,
    t.rin_nr,
    t.a_planfase AS planfase,
    t.a_kernnaam AS kernnaam,
    g.cbscode AS gemnr,
    o.opp_bruto AS bruto,
    o.opp_netto AS netto,
    o.opp_uitgegeven AS uitgegeven,
    (o.opp_uitgeefbaar_gem + o.opp_uitgeefbaar_part) AS direct_uitgeefbaar,
    (o.opp_niet_terstond_uitgeefbaar_gem + o.opp_niet_terstond_uitgeefbaar_part) AS niet_direct_uitgeefbaar,
    o.opp_optie AS optie,
    t.a_type AS type_terrein,
    t.a_bestemming AS bestemming_terrein,
    t.a_grootstedeel AS grootste_kavel,
    t.a_ovwkavelgrootte AS overwegende_kavelgrootte,
    t.o_milieuzone AS is_er_sprake_van_milieuzone,
    t.o_milieuwet_code AS max_toegestane_hindercategorie,
    t.o_minhuur AS huur_minimaal,
    t.o_maxhuur AS huur_maximaal,
    t.o_minverkoop AS verkoop_minimaal,
    t.o_maxverkoop AS verkoop_maximaal,
    (o.opp_gr_uitgeefbaar_kavel / (10000)::numeric) AS opp_grootst_uitgeefbare_kavel,
    o.max_hindercat_uitgeefbaar_kavel AS max_hindercat_uitgeefbare_kavels,
    o.max_hindercat_terrein AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM bedrijventerrein t,
    v_terrein_oppervlakte o,
    gemeente g,
    regio r
  WHERE ((((t.gt_pkey = o.gt_pkey) AND ((g.naam)::text = (t.gemeente_naam)::text)) AND (r.id = g.vvr_id)) AND ((t.workflow_status)::text = 'definitief'::text))
  ORDER BY r.vvr_naam, t.gemeente_naam, t.a_plannaam;


ALTER TABLE v_report_voorraad_all_terreinen OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 97011502)
-- Name: v_report_voorraad_all_terreinen_group_gem; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_all_terreinen_group_gem AS
 SELECT v_report_voorraad_all_terreinen.vvr_naam,
    v_report_voorraad_all_terreinen.gemeentenaam,
    v_report_voorraad_all_terreinen.gemnr,
    sum(v_report_voorraad_all_terreinen.bruto) AS bruto,
    sum(v_report_voorraad_all_terreinen.netto) AS netto,
    sum(v_report_voorraad_all_terreinen.uitgegeven) AS uitgegeven,
    sum(v_report_voorraad_all_terreinen.direct_uitgeefbaar) AS direct_uitgeefbaar,
    sum(v_report_voorraad_all_terreinen.niet_direct_uitgeefbaar) AS niet_direct_uitgeefbaar,
    sum(v_report_voorraad_all_terreinen.optie) AS optie,
    max(v_report_voorraad_all_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
    max(v_report_voorraad_all_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
    max(v_report_voorraad_all_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_voorraad_all_terreinen
  GROUP BY v_report_voorraad_all_terreinen.vvr_naam, v_report_voorraad_all_terreinen.gemeentenaam, v_report_voorraad_all_terreinen.gemnr;


ALTER TABLE v_report_voorraad_all_terreinen_group_gem OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 97011507)
-- Name: v_report_voorraad_all_terreinen_group_vvr; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_all_terreinen_group_vvr AS
 SELECT v_report_voorraad_all_terreinen.vvr_naam,
    sum(v_report_voorraad_all_terreinen.bruto) AS bruto,
    sum(v_report_voorraad_all_terreinen.netto) AS netto,
    sum(v_report_voorraad_all_terreinen.uitgegeven) AS uitgegeven,
    sum(v_report_voorraad_all_terreinen.direct_uitgeefbaar) AS direct_uitgeefbaar,
    sum(v_report_voorraad_all_terreinen.niet_direct_uitgeefbaar) AS niet_direct_uitgeefbaar,
    sum(v_report_voorraad_all_terreinen.optie) AS optie,
    max(v_report_voorraad_all_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
    max(v_report_voorraad_all_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
    max(v_report_voorraad_all_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_voorraad_all_terreinen
  GROUP BY v_report_voorraad_all_terreinen.vvr_naam;


ALTER TABLE v_report_voorraad_all_terreinen_group_vvr OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 97011511)
-- Name: v_report_voorraad_pub_kavels; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_pub_kavels AS
 SELECT r.vvr_naam,
    k.gemeentenaam,
    t.a_plannaam AS plannaam,
    t.rin_nr,
    k.ibis_id AS kavelid,
    k.kaveloppervlak,
    k.status AS kavelstatus,
    k.eigenaartype,
    k.milieuwet_code AS max_hindercat,
    ('now'::text)::date AS datum_gegevens
   FROM v_publieke_kavels k,
    v_publieke_terreinen t,
    gemeente g,
    regio r
  WHERE (((((k.terreinid = t.ibis_id) AND ((g.naam)::text = (k.gemeentenaam)::text)) AND (r.id = g.vvr_id)) AND ((k.workflow_status)::text = 'definitief'::text)) AND ((t.workflow_status)::text = 'definitief'::text))
  ORDER BY r.vvr_naam, k.gemeentenaam, t.a_plannaam, k.status, k.kaveloppervlak;


ALTER TABLE v_report_voorraad_pub_kavels OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 97011516)
-- Name: v_report_voorraad_pub_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_pub_terreinen AS
 SELECT r.vvr_naam,
    t.gemeente_naam AS gemeentenaam,
    t.a_plannaam AS plannaam,
    t.rin_nr,
    t.a_planfase AS planfase,
    t.a_kernnaam AS kernnaam,
    g.cbscode AS gemnr,
    o.opp_bruto AS bruto,
    o.opp_netto AS netto,
    o.opp_uitgegeven AS uitgegeven,
    (o.opp_uitgeefbaar_gem + o.opp_uitgeefbaar_part) AS direct_uitgeefbaar,
    (o.opp_niet_terstond_uitgeefbaar_gem + o.opp_niet_terstond_uitgeefbaar_part) AS niet_direct_uitgeefbaar,
    o.opp_optie AS optie,
    t.a_type AS type_terrein,
    t.a_bestemming AS bestemming_terrein,
    t.a_grootstedeel AS grootste_kavel,
    t.a_ovwkavelgrootte AS overwegende_kavelgrootte,
    t.o_milieuzone AS is_er_sprake_van_milieuzone,
    t.o_milieuwet_code AS max_toegestane_hindercategorie,
    t.o_minhuur AS huur_minimaal,
    t.o_maxhuur AS huur_maximaal,
    t.o_minverkoop AS verkoop_minimaal,
    t.o_maxverkoop AS verkoop_maximaal,
    (o.opp_gr_uitgeefbaar_kavel / (10000)::numeric) AS opp_grootst_uitgeefbare_kavel,
    o.max_hindercat_uitgeefbaar_kavel AS max_hindercat_uitgeefbare_kavels,
    o.max_hindercat_terrein AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_publieke_terreinen t,
    v_terrein_oppervlakte o,
    gemeente g,
    regio r
  WHERE ((((t.gt_pkey = o.gt_pkey) AND ((g.naam)::text = (t.gemeente_naam)::text)) AND (r.id = g.vvr_id)) AND ((t.workflow_status)::text = 'definitief'::text))
  ORDER BY r.vvr_naam, t.gemeente_naam, t.a_plannaam;


ALTER TABLE v_report_voorraad_pub_terreinen OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 97011521)
-- Name: v_report_voorraad_pub_onher_terreinen; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_pub_onher_terreinen AS
 SELECT v_report_voorraad_pub_terreinen.rin_nr,
    v_report_voorraad_pub_terreinen.plannaam,
    v_report_voorraad_pub_terreinen.planfase,
    v_report_voorraad_pub_terreinen.kernnaam,
    v_report_voorraad_pub_terreinen.gemnr,
    v_report_voorraad_pub_terreinen.gemeentenaam,
    v_report_voorraad_pub_terreinen.bruto,
    v_report_voorraad_pub_terreinen.netto,
    v_report_voorraad_pub_terreinen.uitgegeven,
    v_report_voorraad_pub_terreinen.direct_uitgeefbaar,
    v_report_voorraad_pub_terreinen.niet_direct_uitgeefbaar,
    v_report_voorraad_pub_terreinen.optie,
    v_report_voorraad_pub_terreinen.type_terrein,
    v_report_voorraad_pub_terreinen.bestemming_terrein,
    v_report_voorraad_pub_terreinen.grootste_kavel,
    v_report_voorraad_pub_terreinen.overwegende_kavelgrootte,
    v_report_voorraad_pub_terreinen.is_er_sprake_van_milieuzone,
    v_report_voorraad_pub_terreinen.max_toegestane_hindercategorie,
    v_report_voorraad_pub_terreinen.huur_minimaal,
    v_report_voorraad_pub_terreinen.huur_maximaal,
    v_report_voorraad_pub_terreinen.verkoop_minimaal,
    v_report_voorraad_pub_terreinen.verkoop_maximaal,
    v_report_voorraad_pub_terreinen.vvr_naam,
    v_report_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel,
    v_report_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels,
    v_report_voorraad_pub_terreinen.max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_voorraad_pub_terreinen
  WHERE ((v_report_voorraad_pub_terreinen.planfase)::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text);


ALTER TABLE v_report_voorraad_pub_onher_terreinen OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 97011526)
-- Name: v_report_voorraad_pub_terreinen_group_gem; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_pub_terreinen_group_gem AS
 SELECT v_report_voorraad_pub_terreinen.vvr_naam,
    v_report_voorraad_pub_terreinen.gemeentenaam,
    v_report_voorraad_pub_terreinen.gemnr,
    sum(v_report_voorraad_pub_terreinen.bruto) AS bruto,
    sum(v_report_voorraad_pub_terreinen.netto) AS netto,
    sum(v_report_voorraad_pub_terreinen.uitgegeven) AS uitgegeven,
    sum(v_report_voorraad_pub_terreinen.direct_uitgeefbaar) AS direct_uitgeefbaar,
    sum(v_report_voorraad_pub_terreinen.niet_direct_uitgeefbaar) AS niet_direct_uitgeefbaar,
    sum(v_report_voorraad_pub_terreinen.optie) AS optie,
    max(v_report_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
    max(v_report_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
    max(v_report_voorraad_pub_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_voorraad_pub_terreinen
  GROUP BY v_report_voorraad_pub_terreinen.vvr_naam, v_report_voorraad_pub_terreinen.gemeentenaam, v_report_voorraad_pub_terreinen.gemnr
  ORDER BY v_report_voorraad_pub_terreinen.vvr_naam, v_report_voorraad_pub_terreinen.gemeentenaam;


ALTER TABLE v_report_voorraad_pub_terreinen_group_gem OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 97011531)
-- Name: v_report_voorraad_pub_terreinen_group_vvr; Type: VIEW; Schema: IBIS4; Owner: ibis
--

CREATE VIEW v_report_voorraad_pub_terreinen_group_vvr AS
 SELECT v_report_voorraad_pub_terreinen.vvr_naam,
    sum(v_report_voorraad_pub_terreinen.bruto) AS bruto,
    sum(v_report_voorraad_pub_terreinen.netto) AS netto,
    sum(v_report_voorraad_pub_terreinen.uitgegeven) AS uitgegeven,
    sum(v_report_voorraad_pub_terreinen.direct_uitgeefbaar) AS direct_uitgeefbaar,
    sum(v_report_voorraad_pub_terreinen.niet_direct_uitgeefbaar) AS niet_direct_uitgeefbaar,
    sum(v_report_voorraad_pub_terreinen.optie) AS optie,
    max(v_report_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
    max(v_report_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
    max(v_report_voorraad_pub_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
    ('now'::text)::date AS datum_gegevens
   FROM v_report_voorraad_pub_terreinen
  GROUP BY v_report_voorraad_pub_terreinen.vvr_naam
  ORDER BY v_report_voorraad_pub_terreinen.vvr_naam;


ALTER TABLE v_report_voorraad_pub_terreinen_group_vvr OWNER TO postgres;

--
-- TOC entry 3286 (class 2604 OID 97011535)
-- Name: bedrijvenkavels gt_key; Type: DEFAULT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY bedrijvenkavels ALTER COLUMN gt_key SET DEFAULT nextval('bedrijvenkavels_gt_key_seq'::regclass);


--
-- TOC entry 3288 (class 2604 OID 97011536)
-- Name: bedrijventerrein gt_pkey; Type: DEFAULT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY bedrijventerrein ALTER COLUMN gt_pkey SET DEFAULT nextval('bedrijventerrein_gt_pkey_seq'::regclass);


--
-- TOC entry 3290 (class 2604 OID 97011537)
-- Name: code id; Type: DEFAULT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY code ALTER COLUMN id SET DEFAULT nextval('code_id_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 97011538)
-- Name: gemeente id; Type: DEFAULT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY gemeente ALTER COLUMN id SET DEFAULT nextval('gemeente_id_seq'::regclass);


SET search_path = "Economie", pg_catalog;

--
-- TOC entry 3295 (class 2606 OID 97011351)
-- Name: EcMO_Leegstand EcMO_Leegstand_pkey; Type: CONSTRAINT; Schema: Economie; Owner: ibis
--

ALTER TABLE ONLY "EcMO_Leegstand"
    ADD CONSTRAINT "EcMO_Leegstand_pkey" PRIMARY KEY (pkid);


SET search_path = "IBIS4", pg_catalog;

--
-- TOC entry 3298 (class 2606 OID 97088467)
-- Name: bedrijven_grootteklasse bedrijven_grootteklasse_pkey; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY bedrijven_grootteklasse
    ADD CONSTRAINT bedrijven_grootteklasse_pkey PRIMARY KEY (klasse);


--
-- TOC entry 3301 (class 2606 OID 97088469)
-- Name: bedrijvenkavels bedrijvenkavels_pkey; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY bedrijvenkavels
    ADD CONSTRAINT bedrijvenkavels_pkey PRIMARY KEY (gt_key);


--
-- TOC entry 3306 (class 2606 OID 97088471)
-- Name: bedrijventerrein bedrijventerrein_pkey; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY bedrijventerrein
    ADD CONSTRAINT bedrijventerrein_pkey PRIMARY KEY (gt_pkey);


--
-- TOC entry 3313 (class 2606 OID 97088473)
-- Name: gt_pk_metadata gt_pk_metadata_table_schema_table_name_pk_column_key; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY gt_pk_metadata
    ADD CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key UNIQUE (table_schema, table_name, pk_column);


--
-- TOC entry 3316 (class 2606 OID 97088475)
-- Name: kavelhistorie kavelhistorie_pkey; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY kavelhistorie
    ADD CONSTRAINT kavelhistorie_pkey PRIMARY KEY (ibis_id);


--
-- TOC entry 3309 (class 2606 OID 97088477)
-- Name: codes_milieuwet pk_codes_milieuwet; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY codes_milieuwet
    ADD CONSTRAINT pk_codes_milieuwet PRIMARY KEY (id);


--
-- TOC entry 3320 (class 2606 OID 97088479)
-- Name: regio regio_pkey; Type: CONSTRAINT; Schema: IBIS4; Owner: ibis
--

ALTER TABLE ONLY regio
    ADD CONSTRAINT regio_pkey PRIMARY KEY (id);


SET search_path = "Economie", pg_catalog;

--
-- TOC entry 3293 (class 1259 OID 97011352)
-- Name: EcMO_Leegstand_geom_1434453851716; Type: INDEX; Schema: Economie; Owner: ibis
--

CREATE INDEX "EcMO_Leegstand_geom_1434453851716" ON "EcMO_Leegstand" USING gist (geom);


SET search_path = "IBIS4", pg_catalog;

--
-- TOC entry 3299 (class 1259 OID 97088480)
-- Name: bedrijvenkavels_geom_1448372990699; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX bedrijvenkavels_geom_1448372990699 ON bedrijvenkavels USING gist (geom);


--
-- TOC entry 3304 (class 1259 OID 97088481)
-- Name: bedrijventerrein_geom_1448368720658; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX bedrijventerrein_geom_1448368720658 ON bedrijventerrein USING gist (geom);


--
-- TOC entry 3296 (class 1259 OID 97088482)
-- Name: ecmo_prov_werkghd_enquete_copy_geom_1448372990699; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX ecmo_prov_werkghd_enquete_copy_geom_1448372990699 ON "EcMo_Prov_werkghd_enquete_copy" USING gist (geom);


--
-- TOC entry 3310 (class 1259 OID 97088483)
-- Name: gemeente_geom_1448368646168; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX gemeente_geom_1448368646168 ON gemeente USING gist (geom);


--
-- TOC entry 3311 (class 1259 OID 97088484)
-- Name: gt_pk_metadata_idx; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE UNIQUE INDEX gt_pk_metadata_idx ON gt_pk_metadata USING btree (table_schema, table_name, pk_column);


--
-- TOC entry 3314 (class 1259 OID 97088485)
-- Name: kavelhistorie_geom_1476781537934; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX kavelhistorie_geom_1476781537934 ON kavelhistorie USING gist (geom);


--
-- TOC entry 3302 (class 1259 OID 97088486)
-- Name: kavels_terreinen_idx; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX kavels_terreinen_idx ON bedrijvenkavels USING btree (terreinid);


--
-- TOC entry 3317 (class 1259 OID 97088487)
-- Name: kaveluitgiftes_geom; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX kaveluitgiftes_geom ON kaveluitgiftes USING gist (geom);


--
-- TOC entry 3318 (class 1259 OID 97088488)
-- Name: regio_geom_1448368417357; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE INDEX regio_geom_1448368417357 ON regio USING gist (geom);


--
-- TOC entry 3303 (class 1259 OID 97088489)
-- Name: unique_actueel_kavel_idx; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE UNIQUE INDEX unique_actueel_kavel_idx ON bedrijvenkavels USING btree (ibis_id, workflow_status, datummutatie) WHERE (((workflow_status)::text = 'definitief'::text) OR ((workflow_status)::text = 'bewerkt'::text));


--
-- TOC entry 3307 (class 1259 OID 97088490)
-- Name: unique_actueel_terrein_idx; Type: INDEX; Schema: IBIS4; Owner: ibis
--

CREATE UNIQUE INDEX unique_actueel_terrein_idx ON bedrijventerrein USING btree (ibis_id, workflow_status, datummutatie) WHERE (((workflow_status)::text = 'definitief'::text) OR ((workflow_status)::text = 'bewerkt'::text));


--
-- TOC entry 3321 (class 2620 OID 97088491)
-- Name: bedrijvenkavels trig_kavel_oppervlak; Type: TRIGGER; Schema: IBIS4; Owner: ibis
--

CREATE TRIGGER trig_kavel_oppervlak BEFORE INSERT OR UPDATE ON bedrijvenkavels FOR EACH ROW EXECUTE PROCEDURE update_kavel_oppervlak();


-- Completed on 2017-05-11 14:20:42 CEST

--
-- PostgreSQL database dump complete
--

