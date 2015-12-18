-- View: "IBIS".v_kavel_oppervlakte

-- DROP VIEW "IBIS".v_kavel_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_kavel_oppervlakte AS 
 SELECT v_actuele_kavels.id,
    v_actuele_kavels.terreinid,
    v_actuele_kavels.status,
    round(st_area(v_actuele_kavels.geom)::numeric / 10000::numeric, 8) AS opp_geometrie_ha
   FROM v_actuele_kavels;

ALTER TABLE "IBIS".v_kavel_oppervlakte
  OWNER TO ibis;
