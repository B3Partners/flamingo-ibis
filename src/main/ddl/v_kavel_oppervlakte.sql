-- View: "IBIS".v_kavel_oppervlakte

-- DROP VIEW "IBIS".v_kavel_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_kavel_oppervlakte AS 
 SELECT bedrijvenkavels.id,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    st_area(bedrijvenkavels.geom)::numeric AS opp_geometrie
   FROM bedrijvenkavels;

ALTER TABLE "IBIS".v_kavel_oppervlakte
  OWNER TO ibis;
