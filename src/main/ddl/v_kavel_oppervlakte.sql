-- View: "IBIS".v_kavel_oppervlakte

-- DROP VIEW "IBIS".v_kavel_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_kavel_oppervlakte AS 
 SELECT bedrijvenkavels.id,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    bedrijvenkavels.eigenaartype,
    round(st_area(bedrijvenkavels.geom)::numeric/10000,8) AS opp_geometrie_ha
   FROM "IBIS".bedrijvenkavels;

ALTER TABLE "IBIS".v_kavel_oppervlakte
  OWNER TO ibis;
