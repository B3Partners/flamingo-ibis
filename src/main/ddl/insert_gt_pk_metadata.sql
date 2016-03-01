

SET statement_timeout = 0;
--SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = "IBIS", pg_catalog;

--
-- insert the primary key metadata for the views
--

INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_component_ibis_report', 'ibis_id', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_component_ibis_report_uitgifte', 'kavelid', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_gemeente_en_regio_envelopes', 'gem_id', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_factsheet_terrein_info', 'terreinid', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_kavel_oppervlakte', 'gt_key', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_actuele_kavels', 'gt_key', NULL, 'assigned', NULL);
INSERT INTO gt_pk_metadata VALUES ('IBIS', 'v_terrein_oppervlakte', 'gt_pkey', NULL, 'assigned', NULL);

