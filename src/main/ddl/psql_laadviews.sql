-- script om de te maken views specifiek in psql te laden. 
-- uit te voeren door in psql \i psql_laadviews.sql te laden.
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = "IBIS", public, pg_catalog;

-- begin met een index om de oppervlaktes wat vlotter te laten berekenen.
drop index kavels_terreinen_idx;
create index kavels_terreinen_idx on bedrijvenkavels (terreinid);

\i v_kavel_oppervlakte.sql
\i v_terrein_oppervlakte.sql
\i v_gemeente_en_regio_envelopes.sql
\i v_beschikbare_panden_op_terrein.sql
\i v_grootste_10_bedrijven_op_rin_nr.sql
\i v_grootste_10_bedrijven_op_terrein.sql
\i v_grootste_10_kavels_op_terrein.sql
\i v_totaal_bedrijven_en_medewerkers_op_rin_nr.sql
\i v_totaal_bedrijven_en_medewerkers_op_terrein.sql
\i v_factsheet_terrein_info.sql
\i v_component_ibis_report.sql
\i v_component_ibis_report_uitgifte.sql

\i gt_pk_metadata.sql
\i insert_gt_pk_metadata.sql
