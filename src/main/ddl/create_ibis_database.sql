--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.9
-- using /usr/bin/pg_dump --host ibis.b3p.nl --port 5432 --username "ibis" --no-password  --format plain --schema-only --create --verbose --file "/home/mark/Desktop/create_ibis_database.sql" --schema "\"IBIS\"" "flamingo-ibis-test"
-- Dumped by pg_dump version 9.4.5
-- Started on 2015-12-21 11:37:04 CET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 7 (class 2615 OID 5499631)
-- Name: IBIS; Type: SCHEMA; Schema: -; Owner: ibis
--

CREATE SCHEMA "IBIS";


ALTER SCHEMA "IBIS" OWNER TO ibis;

SET search_path = "IBIS", pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- TOC entry 184 (class 1259 OID 5499632)
-- Name: EcMO_Leegstand; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE "EcMO_Leegstand" (
    pkid bigint NOT NULL,
    datum character varying(20),
    wijziging character varying(255),
    aanbodtype character varying(255),
    soort character varying(255),
    gebouwnaam character varying(255),
    straat character varying(255),
    huisnummer character varying(255),
    naam character varying(255),
    url character varying(255),
    shorturl character varying(255),
    plaats character varying(255),
    opterrein character varying(10),
    geom public.geometry(Point,28992)
);


ALTER TABLE "EcMO_Leegstand" OWNER TO ibis;

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 5499638)
-- Name: bedrijven; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijven (
    gid integer NOT NULL,
    vestnr character varying(9),
    naam character varying(60),
    kvkdosnr character varying(8),
    kvkvestnr character varying(12),
    straatlang character varying(43),
    huisnr integer,
    huisletter character varying(1),
    toev character varying(15),
    postcode character varying(6),
    plaatslang character varying(30),
    gemnr character varying(4),
    gemlang character varying(40),
    sbi_sectie character varying(60),
    sbi_huidig character varying(5),
    sbioms_lan character varying(60),
    grk_huidig character varying(2),
    xcoord double precision,
    ycoord double precision,
    xykwal character varying(2),
    cstraat character varying(43),
    chuisnr integer,
    chuisltr character varying(1),
    ctoev character varying(15),
    cpostcode character varying(6),
    cplaats character varying(30),
    telefoon character varying(15),
    fax character varying(15),
    email character varying(60),
    website character varying(60),
    datumstart date,
    datumeinde date,
    vestsoort character varying(2),
    bedrijvent integer,
    bedrijven2 character varying(60),
    totf double precision
);


ALTER TABLE bedrijven OWNER TO ibis;

--
-- TOC entry 186 (class 1259 OID 5499644)
-- Name: bedrijven_gid_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE bedrijven_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bedrijven_gid_seq OWNER TO ibis;

--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 186
-- Name: bedrijven_gid_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijven_gid_seq OWNED BY bedrijven.gid;


--
-- TOC entry 187 (class 1259 OID 5499646)
-- Name: bedrijven_grootteklasse; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijven_grootteklasse (
    klasse character varying(3) NOT NULL,
    beschrijving character varying(255)
);


ALTER TABLE bedrijven_grootteklasse OWNER TO ibis;

SET default_with_oids = true;

--
-- TOC entry 188 (class 1259 OID 5499649)
-- Name: bedrijvenkavels; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijvenkavels (
    ibis_id bigint NOT NULL,
    workflow_status character varying(50) NOT NULL,
    datummutatie date NOT NULL,
    terreinid integer,
    status character varying(70),
    milieuwet character varying(50),
    uitgegevenaan character varying(255),
    eerstejaaruitgifte integer,
    faseveroudering character varying(100),
    gemeentenaam character varying(100),
    geom public.geometry(Polygon,28992),
    gt_key bigint NOT NULL,
    CONSTRAINT valid_workflow_status CHECK (((workflow_status)::text = ANY (ARRAY[('definitief'::character varying)::text, ('bewerkt'::character varying)::text, ('archief'::character varying)::text, ('afgevoerd'::character varying)::text])))
);


ALTER TABLE bedrijvenkavels OWNER TO ibis;

--
-- TOC entry 200 (class 1259 OID 5522288)
-- Name: bedrijvenkavels_gt_key_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE bedrijvenkavels_gt_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bedrijvenkavels_gt_key_seq OWNER TO ibis;

--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 200
-- Name: bedrijvenkavels_gt_key_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijvenkavels_gt_key_seq OWNED BY bedrijvenkavels.gt_key;


--
-- TOC entry 189 (class 1259 OID 5499655)
-- Name: bedrijventerrein; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
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
    a_faseveroudering character varying(100),
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
    o_milieuwet character varying(55),
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
    CONSTRAINT valid_workflow_status CHECK (((workflow_status)::text = ANY (ARRAY[('definitief'::character varying)::text, ('bewerkt'::character varying)::text, ('archief'::character varying)::text, ('afgevoerd'::character varying)::text])))
);


ALTER TABLE bedrijventerrein OWNER TO ibis;

--
-- TOC entry 201 (class 1259 OID 5522808)
-- Name: bedrijventerrein_gt_pkey_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE bedrijventerrein_gt_pkey_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bedrijventerrein_gt_pkey_seq OWNER TO ibis;

--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 201
-- Name: bedrijventerrein_gt_pkey_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijventerrein_gt_pkey_seq OWNED BY bedrijventerrein.gt_pkey;


SET default_with_oids = false;

--
-- TOC entry 190 (class 1259 OID 5499661)
-- Name: code; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE code (
    id integer NOT NULL,
    soort character varying(20) NOT NULL,
    waarde character varying(100) NOT NULL,
    actueel boolean NOT NULL,
    oudecode character varying(10),
    volgorde integer
);


ALTER TABLE code OWNER TO ibis;

--
-- TOC entry 191 (class 1259 OID 5499664)
-- Name: code_id_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE code_id_seq OWNER TO ibis;

--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 191
-- Name: code_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE code_id_seq OWNED BY code.id;


SET default_with_oids = true;

--
-- TOC entry 192 (class 1259 OID 5499666)
-- Name: gemeente; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
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


ALTER TABLE gemeente OWNER TO ibis;

--
-- TOC entry 193 (class 1259 OID 5499672)
-- Name: gemeente_id_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE gemeente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gemeente_id_seq OWNER TO ibis;

--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 193
-- Name: gemeente_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE gemeente_id_seq OWNED BY gemeente.id;


SET default_with_oids = false;

--
-- TOC entry 194 (class 1259 OID 5499674)
-- Name: gt_pk_metadata; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
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


ALTER TABLE gt_pk_metadata OWNER TO ibis;

--
-- TOC entry 202 (class 1259 OID 5552611)
-- Name: v_actuele_kavels; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_actuele_kavels AS
 SELECT bedrijvenkavels.gt_key,
    bedrijvenkavels.ibis_id,
    bedrijvenkavels.workflow_status,
    bedrijvenkavels.datummutatie,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    bedrijvenkavels.milieuwet,
    bedrijvenkavels.uitgegevenaan,
    bedrijvenkavels.eerstejaaruitgifte,
    bedrijvenkavels.faseveroudering,
    bedrijvenkavels.gemeentenaam,
    bedrijvenkavels.geom
   FROM bedrijvenkavels
  WHERE ((bedrijvenkavels.workflow_status)::text = 'definitief'::text);


ALTER TABLE v_actuele_kavels OWNER TO ibis;

--
-- TOC entry 205 (class 1259 OID 5552624)
-- Name: owner; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW owner AS
 SELECT v_actuele_kavels.terreinid,
    count(v_actuele_kavels.terreinid) AS beschikbare_panden
   FROM v_actuele_kavels
  GROUP BY v_actuele_kavels.terreinid;


ALTER TABLE owner OWNER TO ibis;

--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 205
-- Name: VIEW owner; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW owner IS 'Geeft de het aantal beschikbare panden op een terrein';


SET default_with_oids = true;

--
-- TOC entry 195 (class 1259 OID 5499686)
-- Name: regio; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE regio (
    id integer NOT NULL,
    vvr_id integer,
    vvr_naam character varying(50),
    geom public.geometry(MultiPolygon,28992)
);


ALTER TABLE regio OWNER TO ibis;

--
-- TOC entry 196 (class 1259 OID 5499692)
-- Name: v_gemeente_en_regio_envelopes; Type: VIEW; Schema: IBIS; Owner: ibis
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


ALTER TABLE v_gemeente_en_regio_envelopes OWNER TO ibis;

--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 196
-- Name: VIEW v_gemeente_en_regio_envelopes; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_gemeente_en_regio_envelopes IS 'Geeft de MBR van de gemeenten en regio_s';


--
-- TOC entry 203 (class 1259 OID 5552615)
-- Name: v_kavel_oppervlakte; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_kavel_oppervlakte AS
 SELECT v_actuele_kavels.gt_key,
    v_actuele_kavels.ibis_id,
    v_actuele_kavels.terreinid,
    v_actuele_kavels.status,
    round(((public.st_area(v_actuele_kavels.geom))::numeric / (10000)::numeric), 8) AS opp_geometrie_ha
   FROM v_actuele_kavels;


ALTER TABLE v_kavel_oppervlakte OWNER TO ibis;

--
-- TOC entry 204 (class 1259 OID 5552619)
-- Name: v_terrein_oppervlakte; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_terrein_oppervlakte AS
 SELECT t.gt_pkey,
    t.ibis_id,
    t.rin_nr,
    COALESCE(NULLIF(round(((public.st_area(t.geom))::numeric / (10000)::numeric), 4), (0)::numeric), (0)::numeric) AS opp_geom,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Woonbebouwing'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_woonbebouwing,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Openbare ruimte'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_openbare_ruimte,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Niet terstond uitgeefbaar particulier'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_niet_terstond_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Niet terstond uitgeefbaar gemeente'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_niet_terstond_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Uitgegeven'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_uitgegeven,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Terstond uitgeefbaar gemeente'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Terstond uitgeefbaar particulier'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Niet bekend'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_niet_bekend,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = 'Optie'::text))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_optie,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND (v_kavel_oppervlakte.status IS NULL))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_leeg,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE ((v_kavel_oppervlakte.terreinid = t.ibis_id) AND ((v_kavel_oppervlakte.status)::text = ANY (ARRAY['Terstond uitgeefbaar gemeente'::text, 'Terstond uitgeefbaar particulier'::text, 'Optie'::text, 'Uitgegeven'::text, 'Niet terstond uitgeefbaar gemeente'::text, 'Niet terstond uitgeefbaar particulier'::text])))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_netto,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE (v_kavel_oppervlakte.terreinid = t.ibis_id)
          GROUP BY v_kavel_oppervlakte.terreinid), 4), (0)::numeric), (0)::numeric) AS opp_bruto
   FROM bedrijventerrein t;


ALTER TABLE v_terrein_oppervlakte OWNER TO ibis;

--
-- TOC entry 209 (class 1259 OID 5552643)
-- Name: v_component_ibis_report; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_component_ibis_report AS
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
    bedrijventerrein.a_faseveroudering,
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
    bedrijventerrein.o_milieuwet,
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
    (public.st_envelope(public.st_snaptogrid((public.st_buffer(public.st_envelope(bedrijventerrein.geom), (100)::double precision))::public.geometry(Polygon,28992), (1)::double precision, (1)::double precision)))::public.geometry(Polygon,28992) AS bbox_terrein,
    v_gemeente_en_regio_envelopes.naam,
    v_gemeente_en_regio_envelopes.bbox_gemeente,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.bbox_regio,
    v_terrein_oppervlakte.opp_geom,
    v_terrein_oppervlakte.opp_woonbebouwing,
    v_terrein_oppervlakte.opp_openbare_ruimte,
    (v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part) AS opp_niet_terstond_uitgeefbaar,
    v_terrein_oppervlakte.opp_uitgegeven,
    (v_terrein_oppervlakte.opp_uitgeefbaar_gem + v_terrein_oppervlakte.opp_uitgeefbaar_part) AS opp_uitgeefbaar,
    v_terrein_oppervlakte.opp_niet_bekend,
    v_terrein_oppervlakte.opp_leeg,
    v_terrein_oppervlakte.opp_netto,
    v_terrein_oppervlakte.opp_bruto
   FROM ((bedrijventerrein
     LEFT JOIN v_gemeente_en_regio_envelopes ON (((bedrijventerrein.gemeente_naam)::text = (v_gemeente_en_regio_envelopes.naam)::text)))
     JOIN v_terrein_oppervlakte ON ((bedrijventerrein.gt_pkey = v_terrein_oppervlakte.gt_pkey)))
  ORDER BY v_gemeente_en_regio_envelopes.vvr_naam, v_gemeente_en_regio_envelopes.naam, bedrijventerrein.a_plannaam;


ALTER TABLE v_component_ibis_report OWNER TO ibis;

--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 209
-- Name: VIEW v_component_ibis_report; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_component_ibis_report IS 'Uitgifte gegevens voor IbisReport component.';


--
-- TOC entry 210 (class 1259 OID 5552649)
-- Name: v_component_ibis_report_uitgifte; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_component_ibis_report_uitgifte AS
 SELECT v_actuele_kavels.gt_key,
    v_actuele_kavels.ibis_id AS kavelid,
    v_actuele_kavels.terreinid,
    v_actuele_kavels.status,
    v_actuele_kavels.uitgegevenaan,
    v_actuele_kavels.datummutatie,
    v_kavel_oppervlakte.opp_geometrie_ha AS opp_geometrie,
    v_gemeente_en_regio_envelopes.naam AS gemeentenaam,
    v_gemeente_en_regio_envelopes.vvr_naam AS regionaam,
    bedrijventerrein.a_plannaam AS terreinnaam
   FROM v_actuele_kavels,
    bedrijventerrein,
    v_kavel_oppervlakte,
    v_gemeente_en_regio_envelopes
  WHERE (((v_actuele_kavels.gt_key = v_kavel_oppervlakte.gt_key) AND (bedrijventerrein.ibis_id = v_actuele_kavels.terreinid)) AND ((bedrijventerrein.gemeente_naam)::text = (v_gemeente_en_regio_envelopes.naam)::text));


ALTER TABLE v_component_ibis_report_uitgifte OWNER TO ibis;

--
-- TOC entry 197 (class 1259 OID 5499716)
-- Name: v_totaal_bedrijven_en_medewerkers_op_rin_nr; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_totaal_bedrijven_en_medewerkers_op_rin_nr AS
 SELECT DISTINCT bedrijven.bedrijvent AS rin_nr,
    count(bedrijven.bedrijvent) AS bedrijven,
    (sum(bedrijven.totf))::bigint AS medewerkers
   FROM bedrijven
  GROUP BY bedrijven.bedrijvent;


ALTER TABLE v_totaal_bedrijven_en_medewerkers_op_rin_nr OWNER TO ibis;

--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 197
-- Name: VIEW v_totaal_bedrijven_en_medewerkers_op_rin_nr; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_totaal_bedrijven_en_medewerkers_op_rin_nr IS 'Geeft het totaal aantal bedrijven en aantal medewerkers per bedrijventerrein';


--
-- TOC entry 208 (class 1259 OID 5552638)
-- Name: v_factsheet_terrein_info; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_factsheet_terrein_info AS
 SELECT bedrijventerrein.ibis_id AS terreinid,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datummutatie,
    bedrijventerrein.reden,
    bedrijventerrein.a_bestemming,
    bedrijventerrein.a_grootstedeel,
    bedrijventerrein.a_haruimtegebruik,
    bedrijventerrein.a_kernnaam,
    bedrijventerrein.a_ovwkavelgrootte,
    bedrijventerrein.a_planfase,
    bedrijventerrein.a_plannaam,
    bedrijventerrein.a_faseveroudering,
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
    bedrijventerrein.o_milieuwet,
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
        CASE
            WHEN (owner.beschikbare_panden IS NULL) THEN (0)::bigint
            ELSE owner.beschikbare_panden
        END AS beschikbare_panden,
    round(v_terrein_oppervlakte.opp_geom, 2) AS opp_geom_ha,
    round(v_terrein_oppervlakte.opp_woonbebouwing, 2) AS opp_woonbebouwing_ha,
    round(v_terrein_oppervlakte.opp_openbare_ruimte, 2) AS opp_openbare_ruimte_ha,
    round((v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem), 2) AS opp_niet_terstond_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_uitgegeven, 2) AS opp_uitgegeven_ha,
    round((v_terrein_oppervlakte.opp_uitgeefbaar_part + v_terrein_oppervlakte.opp_uitgeefbaar_gem), 2) AS opp_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_bekend, 2) AS opp_niet_bekend_ha,
    round(v_terrein_oppervlakte.opp_leeg, 2) AS opp_leeg_ha,
    round(v_terrein_oppervlakte.opp_netto, 2) AS opp_netto_ha,
    round(v_terrein_oppervlakte.opp_bruto, 2) AS opp_bruto_ha,
    v_gemeente_en_regio_envelopes.naam AS gemeente_naam,
    v_gemeente_en_regio_envelopes.cbscode,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.corop,
    v_gemeente_en_regio_envelopes.deelregio,
    v_gemeente_en_regio_envelopes.provincie,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.bedrijven AS aantal_bedrijven,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.medewerkers AS aantal_werkzame_personen
   FROM ((((bedrijventerrein
     LEFT JOIN owner ON ((bedrijventerrein.ibis_id = owner.terreinid)))
     LEFT JOIN v_terrein_oppervlakte ON ((v_terrein_oppervlakte.gt_pkey = bedrijventerrein.gt_pkey)))
     LEFT JOIN v_gemeente_en_regio_envelopes ON (((bedrijventerrein.gemeente_naam)::text = (v_gemeente_en_regio_envelopes.naam)::text)))
     LEFT JOIN v_totaal_bedrijven_en_medewerkers_op_rin_nr ON ((bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr)));


ALTER TABLE v_factsheet_terrein_info OWNER TO ibis;

--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 208
-- Name: VIEW v_factsheet_terrein_info; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_factsheet_terrein_info IS 'Geeft de terrein informatie bij een kavel tbv de factsheet. workflow_status is verwijderd vanwege https://github.com/flamingo-geocms/flamingo/issues/497 maar is ook niet nodig voor de factsheet.';


--
-- TOC entry 198 (class 1259 OID 5499725)
-- Name: v_grootste_10_bedrijven_op_rin_nr; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_grootste_10_bedrijven_op_rin_nr AS
 SELECT a.bedrijvent AS rin_nr,
    a.naam,
    a.sbioms_lan AS activiteit,
    a.grk_huidig AS grootte_klasse
   FROM ( SELECT bedrijven.gid,
            bedrijven.naam,
            bedrijven.sbioms_lan,
            bedrijven.grk_huidig,
            bedrijven.bedrijvent,
            bedrijven.totf,
            row_number() OVER (PARTITION BY bedrijven.bedrijvent ORDER BY bedrijven.totf DESC) AS row_id
           FROM bedrijven
          WHERE (bedrijven.datumeinde IS NULL)) a
  WHERE (a.row_id <= 10)
  ORDER BY a.gid, a.totf;


ALTER TABLE v_grootste_10_bedrijven_op_rin_nr OWNER TO ibis;

--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 198
-- Name: VIEW v_grootste_10_bedrijven_op_rin_nr; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_grootste_10_bedrijven_op_rin_nr IS 'Geeft de 10 grootste actieve bedrijven per bedrijventerrein (rin nr) gesorteerd op aantal medewerkers';


--
-- TOC entry 206 (class 1259 OID 5552628)
-- Name: v_grootste_10_bedrijven_op_terrein; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_grootste_10_bedrijven_op_terrein AS
 SELECT bedrijventerrein.ibis_id AS terreinid,
    bedrijventerrein.rin_nr,
    v_grootste_10_bedrijven_op_rin_nr.naam,
    v_grootste_10_bedrijven_op_rin_nr.activiteit,
    v_grootste_10_bedrijven_op_rin_nr.grootte_klasse,
    bedrijven_grootteklasse.beschrijving AS grootte_beschrijving
   FROM ((bedrijventerrein
     LEFT JOIN v_grootste_10_bedrijven_op_rin_nr ON ((bedrijventerrein.rin_nr = v_grootste_10_bedrijven_op_rin_nr.rin_nr)))
     LEFT JOIN bedrijven_grootteklasse ON (((v_grootste_10_bedrijven_op_rin_nr.grootte_klasse)::text = (bedrijven_grootteklasse.klasse)::text)))
  ORDER BY bedrijventerrein.ibis_id, v_grootste_10_bedrijven_op_rin_nr.grootte_klasse DESC;


ALTER TABLE v_grootste_10_bedrijven_op_terrein OWNER TO ibis;

--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 206
-- Name: VIEW v_grootste_10_bedrijven_op_terrein; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_grootste_10_bedrijven_op_terrein IS 'Geeft de 10 grootste bedrijven per terrein';


--
-- TOC entry 207 (class 1259 OID 5552633)
-- Name: v_grootste_10_kavels_op_terrein; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_grootste_10_kavels_op_terrein AS
 SELECT a.terreinid AS id_terrein,
    a.uitgegevenaan,
    a.ibis_id AS id_kavel,
    (public.st_area(a.geom))::numeric AS opp_geometrie
   FROM ( SELECT v_actuele_kavels.ibis_id,
            v_actuele_kavels.workflow_status,
            v_actuele_kavels.datummutatie,
            v_actuele_kavels.terreinid,
            v_actuele_kavels.status,
            v_actuele_kavels.milieuwet,
            v_actuele_kavels.uitgegevenaan,
            v_actuele_kavels.eerstejaaruitgifte,
            v_actuele_kavels.faseveroudering,
            v_actuele_kavels.gemeentenaam,
            v_actuele_kavels.geom,
            row_number() OVER (PARTITION BY v_actuele_kavels.terreinid ORDER BY (public.st_area(v_actuele_kavels.geom))::numeric DESC) AS row_id
           FROM v_actuele_kavels
          WHERE ((v_actuele_kavels.status)::text = 'Uitgegeven'::text)) a
  WHERE (a.row_id <= 10)
  ORDER BY a.terreinid, (public.st_area(a.geom))::numeric;


ALTER TABLE v_grootste_10_kavels_op_terrein OWNER TO ibis;

--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 207
-- Name: VIEW v_grootste_10_kavels_op_terrein; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_grootste_10_kavels_op_terrein IS 'Geeft de 10 grootste kavels met bedrijf per bedrijventerrein gesorteerd op oppervlakte';


--
-- TOC entry 199 (class 1259 OID 5499740)
-- Name: v_totaal_bedrijven_en_medewerkers_op_terrein; Type: VIEW; Schema: IBIS; Owner: ibis
--

CREATE VIEW v_totaal_bedrijven_en_medewerkers_op_terrein AS
 SELECT bedrijventerrein.ibis_id AS terreinid,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.bedrijven,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.medewerkers
   FROM (bedrijventerrein
     LEFT JOIN v_totaal_bedrijven_en_medewerkers_op_rin_nr ON ((bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr)));


ALTER TABLE v_totaal_bedrijven_en_medewerkers_op_terrein OWNER TO ibis;

--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 199
-- Name: VIEW v_totaal_bedrijven_en_medewerkers_op_terrein; Type: COMMENT; Schema: IBIS; Owner: ibis
--

COMMENT ON VIEW v_totaal_bedrijven_en_medewerkers_op_terrein IS 'Geeft de totalen van bedrijven en medewerkers per terrein.';


--
-- TOC entry 3136 (class 2604 OID 5499745)
-- Name: gid; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijven ALTER COLUMN gid SET DEFAULT nextval('bedrijven_gid_seq'::regclass);


--
-- TOC entry 3137 (class 2604 OID 5522290)
-- Name: gt_key; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijvenkavels ALTER COLUMN gt_key SET DEFAULT nextval('bedrijvenkavels_gt_key_seq'::regclass);


--
-- TOC entry 3139 (class 2604 OID 5522810)
-- Name: gt_pkey; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijventerrein ALTER COLUMN gt_pkey SET DEFAULT nextval('bedrijventerrein_gt_pkey_seq'::regclass);


--
-- TOC entry 3141 (class 2604 OID 5499746)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY code ALTER COLUMN id SET DEFAULT nextval('code_id_seq'::regclass);


--
-- TOC entry 3142 (class 2604 OID 5499747)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY gemeente ALTER COLUMN id SET DEFAULT nextval('gemeente_id_seq'::regclass);


--
-- TOC entry 3146 (class 2606 OID 5522261)
-- Name: EcMO_Leegstand_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY "EcMO_Leegstand"
    ADD CONSTRAINT "EcMO_Leegstand_pkey" PRIMARY KEY (pkid);


--
-- TOC entry 3150 (class 2606 OID 5522263)
-- Name: bedrijven_grootteklasse_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven_grootteklasse
    ADD CONSTRAINT bedrijven_grootteklasse_pkey PRIMARY KEY (klasse);


--
-- TOC entry 3148 (class 2606 OID 5522265)
-- Name: bedrijven_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven
    ADD CONSTRAINT bedrijven_pkey PRIMARY KEY (gid);


--
-- TOC entry 3153 (class 2606 OID 5522805)
-- Name: bedrijvenkavels_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijvenkavels
    ADD CONSTRAINT bedrijvenkavels_pkey PRIMARY KEY (gt_key);


--
-- TOC entry 3158 (class 2606 OID 5524980)
-- Name: bedrijventerrein_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijventerrein
    ADD CONSTRAINT bedrijventerrein_pkey PRIMARY KEY (gt_pkey);


--
-- TOC entry 3163 (class 2606 OID 5522271)
-- Name: gt_pk_metadata_table_schema_table_name_pk_column_key; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY gt_pk_metadata
    ADD CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key UNIQUE (table_schema, table_name, pk_column);


--
-- TOC entry 3166 (class 2606 OID 5522273)
-- Name: regio_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY regio
    ADD CONSTRAINT regio_pkey PRIMARY KEY (id);


--
-- TOC entry 3144 (class 1259 OID 5522274)
-- Name: EcMO_Leegstand_geom_144831193933; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX "EcMO_Leegstand_geom_144831193933" ON "EcMO_Leegstand" USING gist (geom);


--
-- TOC entry 3151 (class 1259 OID 5522275)
-- Name: bedrijvenkavels_geom_1448372990699; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijvenkavels_geom_1448372990699 ON bedrijvenkavels USING gist (geom);


--
-- TOC entry 3156 (class 1259 OID 5522276)
-- Name: bedrijventerrein_geom_1448368720658; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijventerrein_geom_1448368720658 ON bedrijventerrein USING gist (geom);


--
-- TOC entry 3160 (class 1259 OID 5522277)
-- Name: gemeente_geom_1448368646168; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX gemeente_geom_1448368646168 ON gemeente USING gist (geom);


--
-- TOC entry 3161 (class 1259 OID 5522278)
-- Name: gt_pk_metadata_idx; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE UNIQUE INDEX gt_pk_metadata_idx ON gt_pk_metadata USING btree (table_schema, table_name, pk_column);


--
-- TOC entry 3154 (class 1259 OID 5522279)
-- Name: kavels_terreinen_idx; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX kavels_terreinen_idx ON bedrijvenkavels USING btree (terreinid);


--
-- TOC entry 3164 (class 1259 OID 5522280)
-- Name: regio_geom_1448368417357; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX regio_geom_1448368417357 ON regio USING gist (geom);


--
-- TOC entry 3155 (class 1259 OID 5536683)
-- Name: unique_actueel_kavel_idx; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE UNIQUE INDEX unique_actueel_kavel_idx ON bedrijvenkavels USING btree (ibis_id, workflow_status, datummutatie) WHERE (((workflow_status)::text = 'definitief'::text) OR ((workflow_status)::text = 'bewerkt'::text));


--
-- TOC entry 3159 (class 1259 OID 5536685)
-- Name: unique_actueel_terrein_idx; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE UNIQUE INDEX unique_actueel_terrein_idx ON bedrijventerrein USING btree (ibis_id, workflow_status, datummutatie) WHERE (((workflow_status)::text = 'definitief'::text) OR ((workflow_status)::text = 'bewerkt'::text));


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 7
-- Name: IBIS; Type: ACL; Schema: -; Owner: ibis
--

REVOKE ALL ON SCHEMA "IBIS" FROM PUBLIC;
REVOKE ALL ON SCHEMA "IBIS" FROM ibis;
GRANT ALL ON SCHEMA "IBIS" TO ibis;


-- Completed on 2015-12-21 11:37:08 CET

--
-- PostgreSQL database dump complete
--

