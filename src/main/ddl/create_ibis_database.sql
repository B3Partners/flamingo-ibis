-- /usr/bin/pg_dump --host ibis.b3p.nl --port 5432 --username "ibis" --role "ibis" --no-password  --format plain --schema-only --create --encoding UTF8 --verbose --file "/home/mark/Desktop/create_ibis_database.sql" --table "\"IBIS\".bedrijven" --table "\"IBIS\".bedrijven_grootteklasse" --table "\"IBIS\".bedrijvenkavels" --table "\"IBIS\".bedrijventerrein" --table "\"IBIS\".code" --table "\"IBIS\".financier" --table "\"IBIS\".gemeente" --table "\"IBIS\".regio" "flamingo-ibis-test"

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.9
-- Dumped by pg_dump version 9.4.5
-- Started on 2015-11-10 15:33:53 CET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = "IBIS", pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 190 (class 1259 OID 5309748)
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
-- TOC entry 189 (class 1259 OID 5309746)
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
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 189
-- Name: bedrijven_gid_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijven_gid_seq OWNED BY bedrijven.gid;


--
-- TOC entry 191 (class 1259 OID 5339667)
-- Name: bedrijven_grootteklasse; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijven_grootteklasse (
    klasse character varying(3) NOT NULL,
    beschrijving character varying(255)
);


ALTER TABLE bedrijven_grootteklasse OWNER TO ibis;

SET default_with_oids = true;

--
-- TOC entry 196 (class 1259 OID 5350020)
-- Name: bedrijvenkavels; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijvenkavels (
    id bigint NOT NULL,
    identificatie character varying(20),
    terreinid integer,
    datumstart date,
    status character varying(70),
    workflow_status character varying(50),
    hindercat character varying(50),
    eigenaartype character varying(50),
    hoeveelheid character varying(8),
    uitgegevenaan character varying(255),
    eerstejaaruitgifte character varying(10),
    datumuitgifte date,
    faseveroudering character varying(20),
    actueel character varying(10),
    datumarchief date,
    geom public.geometry(MultiPolygon,28992)
);


ALTER TABLE bedrijvenkavels OWNER TO ibis;

--
-- TOC entry 195 (class 1259 OID 5347223)
-- Name: bedrijventerrein; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijventerrein (
    id integer NOT NULL,
    rin_nr integer,
    datum date,
    reden character varying(70),
    workflow_status character varying(50),
    a_bestaatnietmeer character varying(20),
    a_bestemming character varying(30),
    a_gecontroleerd character varying(20),
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
    codeplanfase character varying(3),
    datum_controle date,
    l_foto1 character varying(255),
    l_foto2 character varying(255),
    l_foto3 character varying(255),
    l_foto4 character varying(255),
    o_afstandvliegveld integer,
    o_collbeheer character varying(20),
    o_collinkoop character varying(50),
    o_collvoorz character varying(25),
    o_externebereikbaarheid character varying(20),
    o_internet character varying(100),
    o_maxhuur bigint,
    o_maxverkoop bigint,
    o_milieuwet character varying(55),
    o_milieuzone character varying(20),
    o_minhuur bigint,
    o_minverkoop bigint,
    o_naamvliegveld character varying(100),
    o_overslag character varying(100),
    o_parkeergelegenheid character varying(100),
    o_spoorontsluiting character varying(100),
    o_waterontsluiting character varying(100),
    o_wegontsluiting character varying(100),
    gemeenteid integer,
    geom public.geometry(MultiPolygon,28992)
);


ALTER TABLE bedrijventerrein OWNER TO ibis;

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 4984187)
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
-- TOC entry 184 (class 1259 OID 4984185)
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
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 184
-- Name: code_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE code_id_seq OWNED BY code.id;


--
-- TOC entry 187 (class 1259 OID 4984375)
-- Name: financier; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE financier (
    id integer NOT NULL,
    terreinid integer,
    financier character varying(100),
    percentage numeric(15,0)
);


ALTER TABLE financier OWNER TO ibis;

SET default_with_oids = true;

--
-- TOC entry 193 (class 1259 OID 5347088)
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
    geom public.geometry(MultiPolygon,28992)
);


ALTER TABLE gemeente OWNER TO ibis;

--
-- TOC entry 194 (class 1259 OID 5347094)
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
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 194
-- Name: gemeente_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE gemeente_id_seq OWNED BY gemeente.id;


--
-- TOC entry 192 (class 1259 OID 5347058)
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
-- TOC entry 186 (class 1259 OID 4984373)
-- Name: tblfinancier_id_seq; Type: SEQUENCE; Schema: IBIS; Owner: ibis
--

CREATE SEQUENCE tblfinancier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tblfinancier_id_seq OWNER TO ibis;

--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 186
-- Name: tblfinancier_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE tblfinancier_id_seq OWNED BY financier.id;


--
-- TOC entry 3113 (class 2604 OID 5309751)
-- Name: gid; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijven ALTER COLUMN gid SET DEFAULT nextval('bedrijven_gid_seq'::regclass);


--
-- TOC entry 3111 (class 2604 OID 4984190)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY code ALTER COLUMN id SET DEFAULT nextval('code_id_seq'::regclass);


--
-- TOC entry 3112 (class 2604 OID 4984378)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY financier ALTER COLUMN id SET DEFAULT nextval('tblfinancier_id_seq'::regclass);


--
-- TOC entry 3114 (class 2604 OID 5347096)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY gemeente ALTER COLUMN id SET DEFAULT nextval('gemeente_id_seq'::regclass);


--
-- TOC entry 3120 (class 2606 OID 5339671)
-- Name: bedrijven_grootteklasse_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven_grootteklasse
    ADD CONSTRAINT bedrijven_grootteklasse_pkey PRIMARY KEY (klasse);


--
-- TOC entry 3118 (class 2606 OID 5309756)
-- Name: bedrijven_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven
    ADD CONSTRAINT bedrijven_pkey PRIMARY KEY (gid);


--
-- TOC entry 3130 (class 2606 OID 5368113)
-- Name: bedrijvenkavels_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijvenkavels
    ADD CONSTRAINT bedrijvenkavels_pkey PRIMARY KEY (id);


--
-- TOC entry 3127 (class 2606 OID 5350018)
-- Name: bedrijventerrein_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijventerrein
    ADD CONSTRAINT bedrijventerrein_pkey PRIMARY KEY (id);


--
-- TOC entry 3123 (class 2606 OID 5347078)
-- Name: regio_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY regio
    ADD CONSTRAINT regio_pkey PRIMARY KEY (id);


--
-- TOC entry 3116 (class 2606 OID 4984380)
-- Name: tblfinancier_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY financier
    ADD CONSTRAINT tblfinancier_pkey PRIMARY KEY (id);


--
-- TOC entry 3128 (class 1259 OID 5368114)
-- Name: bedrijvenkavels_geom_1443171719128; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijvenkavels_geom_1443171719128 ON bedrijvenkavels USING gist (geom);


--
-- TOC entry 3125 (class 1259 OID 5350019)
-- Name: bedrijventerrein_geom_1443094268178; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijventerrein_geom_1443094268178 ON bedrijventerrein USING gist (geom);


--
-- TOC entry 3124 (class 1259 OID 5347222)
-- Name: gemeente_geom_1443087869706; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX gemeente_geom_1443087869706 ON gemeente USING gist (geom);


--
-- TOC entry 3121 (class 1259 OID 5347079)
-- Name: regio_geom_1443087503427; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX regio_geom_1443087503427 ON regio USING gist (geom);


-- Completed on 2015-11-10 15:33:54 CET

--
-- PostgreSQL database dump complete
--

