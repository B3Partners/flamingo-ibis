-- /usr/bin/pg_dump --host ibis.b3p.nl --port 5432 --username "ibis" --role "ibis" --no-password  --format plain --schema-only --create --encoding UTF8 --verbose --file "/home/mark/Desktop/create_ibis_database.sql" --table "\"IBIS\".EcMO_Leegstand" --table "\"IBIS\".bedrijven" --table "\"IBIS\".bedrijven_grootteklasse" --table "\"IBIS\".bedrijvenkavels" --table "\"IBIS\".bedrijventerrein" --table "\"IBIS\".code" --table "\"IBIS\".gemeente" --table "\"IBIS\".regio" "flamingo-ibis-test"

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.9
-- Dumped by pg_dump version 9.4.5
-- Started on 2015-12-01 08:32:15 CET

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
-- TOC entry 211 (class 1259 OID 5499638)
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
-- TOC entry 212 (class 1259 OID 5499644)
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
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 212
-- Name: bedrijven_gid_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijven_gid_seq OWNED BY bedrijven.gid;


--
-- TOC entry 213 (class 1259 OID 5499646)
-- Name: bedrijven_grootteklasse; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijven_grootteklasse (
    klasse character varying(3) NOT NULL,
    beschrijving character varying(255)
);


ALTER TABLE bedrijven_grootteklasse OWNER TO ibis;

SET default_with_oids = true;

--
-- TOC entry 214 (class 1259 OID 5499649)
-- Name: bedrijvenkavels; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijvenkavels (
    id bigint NOT NULL,
    workflow_status character varying(50) NOT NULL,
    datummutatie date NOT NULL,
    terreinid integer,
    status character varying(70),
    milieuwet character varying(50),
    uitgegevenaan character varying(255),
    eerstejaaruitgifte integer,
    faseveroudering character varying(100),
    gemeenteid bigint,
    gemeentenaam character varying(100),
    geom public.geometry(Polygon,28992),
    gt_key bigint NOT NULL
);


ALTER TABLE bedrijvenkavels OWNER TO ibis;

--
-- TOC entry 235 (class 1259 OID 5522288)
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
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 235
-- Name: bedrijvenkavels_gt_key_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijvenkavels_gt_key_seq OWNED BY bedrijvenkavels.gt_key;


--
-- TOC entry 215 (class 1259 OID 5499655)
-- Name: bedrijventerrein; Type: TABLE; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE TABLE bedrijventerrein (
    id integer NOT NULL,
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
    gemeenteid integer,
    geom public.geometry(MultiPolygon,28992),
    gt_pkey bigint NOT NULL
);


ALTER TABLE bedrijventerrein OWNER TO ibis;

--
-- TOC entry 236 (class 1259 OID 5522808)
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
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 236
-- Name: bedrijventerrein_gt_pkey_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE bedrijventerrein_gt_pkey_seq OWNED BY bedrijventerrein.gt_pkey;


SET default_with_oids = false;

--
-- TOC entry 216 (class 1259 OID 5499661)
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
-- TOC entry 217 (class 1259 OID 5499664)
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
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 217
-- Name: code_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE code_id_seq OWNED BY code.id;


SET default_with_oids = true;

--
-- TOC entry 218 (class 1259 OID 5499666)
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
-- TOC entry 219 (class 1259 OID 5499672)
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
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 219
-- Name: gemeente_id_seq; Type: SEQUENCE OWNED BY; Schema: IBIS; Owner: ibis
--

ALTER SEQUENCE gemeente_id_seq OWNED BY gemeente.id;


--
-- TOC entry 223 (class 1259 OID 5499686)
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
-- TOC entry 3191 (class 2604 OID 5499745)
-- Name: gid; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijven ALTER COLUMN gid SET DEFAULT nextval('bedrijven_gid_seq'::regclass);


--
-- TOC entry 3192 (class 2604 OID 5522290)
-- Name: gt_key; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijvenkavels ALTER COLUMN gt_key SET DEFAULT nextval('bedrijvenkavels_gt_key_seq'::regclass);


--
-- TOC entry 3193 (class 2604 OID 5522810)
-- Name: gt_pkey; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY bedrijventerrein ALTER COLUMN gt_pkey SET DEFAULT nextval('bedrijventerrein_gt_pkey_seq'::regclass);


--
-- TOC entry 3194 (class 2604 OID 5499746)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY code ALTER COLUMN id SET DEFAULT nextval('code_id_seq'::regclass);


--
-- TOC entry 3195 (class 2604 OID 5499747)
-- Name: id; Type: DEFAULT; Schema: IBIS; Owner: ibis
--

ALTER TABLE ONLY gemeente ALTER COLUMN id SET DEFAULT nextval('gemeente_id_seq'::regclass);


--
-- TOC entry 3199 (class 2606 OID 5522263)
-- Name: bedrijven_grootteklasse_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven_grootteklasse
    ADD CONSTRAINT bedrijven_grootteklasse_pkey PRIMARY KEY (klasse);


--
-- TOC entry 3197 (class 2606 OID 5522265)
-- Name: bedrijven_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijven
    ADD CONSTRAINT bedrijven_pkey PRIMARY KEY (gid);


--
-- TOC entry 3202 (class 2606 OID 5522807)
-- Name: bedrijvenkavels_id_workflow_status_datummutatie_key; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijvenkavels
    ADD CONSTRAINT bedrijvenkavels_id_workflow_status_datummutatie_key UNIQUE (id, workflow_status, datummutatie);


--
-- TOC entry 3204 (class 2606 OID 5522805)
-- Name: bedrijvenkavels_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijvenkavels
    ADD CONSTRAINT bedrijvenkavels_pkey PRIMARY KEY (gt_key);


--
-- TOC entry 3208 (class 2606 OID 5524982)
-- Name: bedrijventerrein_id_datummutatie_workflow_status_key; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijventerrein
    ADD CONSTRAINT bedrijventerrein_id_datummutatie_workflow_status_key UNIQUE (id, datummutatie, workflow_status);


--
-- TOC entry 3210 (class 2606 OID 5524980)
-- Name: bedrijventerrein_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY bedrijventerrein
    ADD CONSTRAINT bedrijventerrein_pkey PRIMARY KEY (gt_pkey);


--
-- TOC entry 3214 (class 2606 OID 5522273)
-- Name: regio_pkey; Type: CONSTRAINT; Schema: IBIS; Owner: ibis; Tablespace: 
--

ALTER TABLE ONLY regio
    ADD CONSTRAINT regio_pkey PRIMARY KEY (id);


--
-- TOC entry 3200 (class 1259 OID 5522275)
-- Name: bedrijvenkavels_geom_1448372990699; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijvenkavels_geom_1448372990699 ON bedrijvenkavels USING gist (geom);


--
-- TOC entry 3206 (class 1259 OID 5522276)
-- Name: bedrijventerrein_geom_1448368720658; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX bedrijventerrein_geom_1448368720658 ON bedrijventerrein USING gist (geom);


--
-- TOC entry 3211 (class 1259 OID 5522277)
-- Name: gemeente_geom_1448368646168; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX gemeente_geom_1448368646168 ON gemeente USING gist (geom);


--
-- TOC entry 3205 (class 1259 OID 5522279)
-- Name: kavels_terreinen_idx; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX kavels_terreinen_idx ON bedrijvenkavels USING btree (terreinid);


--
-- TOC entry 3212 (class 1259 OID 5522280)
-- Name: regio_geom_1448368417357; Type: INDEX; Schema: IBIS; Owner: ibis; Tablespace: 
--

CREATE INDEX regio_geom_1448368417357 ON regio USING gist (geom);


-- Completed on 2015-12-01 08:32:16 CET

--
-- PostgreSQL database dump complete
--

