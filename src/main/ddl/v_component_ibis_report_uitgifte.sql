-- View: "IBIS".v_component_ibis_report_uitgifte

-- DROP VIEW "IBIS".v_component_ibis_report_uitgifte;

CREATE OR REPLACE VIEW "IBIS".v_component_ibis_report_uitgifte AS 
 SELECT bedrijvenkavels.id AS kavelid,
    bedrijvenkavels.terreinid,
    v_kavel_oppervlakte.opp_geometrie,
    bedrijvenkavels.datum,
    bedrijvenkavels.uitgegevenaan,
    bedrijvenkavels.datumuitgifte
   FROM v_kavel_oppervlakte,
    bedrijvenkavels
  WHERE bedrijvenkavels.status::text = 'uitgegeven'::text AND bedrijvenkavels.id = v_kavel_oppervlakte.id;

ALTER TABLE "IBIS".v_component_ibis_report_uitgifte
  OWNER TO ibis;
