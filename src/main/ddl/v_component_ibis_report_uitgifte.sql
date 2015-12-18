-- View: "IBIS".v_component_ibis_report_uitgifte

-- DROP VIEW "IBIS".v_component_ibis_report_uitgifte;

CREATE OR REPLACE VIEW "IBIS".v_component_ibis_report_uitgifte AS 
 SELECT v_actuele_kavels.id AS kavelid,
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
  WHERE v_actuele_kavels.id = v_kavel_oppervlakte.id AND bedrijventerrein.id = v_actuele_kavels.terreinid AND bedrijventerrein.gemeenteid = v_gemeente_en_regio_envelopes.gem_id;

ALTER TABLE "IBIS".v_component_ibis_report_uitgifte
  OWNER TO ibis;
