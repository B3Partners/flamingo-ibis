-- View: "IBIS".v_component_ibis_report_uitgifte

-- DROP VIEW "IBIS".v_component_ibis_report_uitgifte;

CREATE OR REPLACE VIEW "IBIS".v_component_ibis_report_uitgifte AS
SELECT bedrijvenkavels.id AS kavelid,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    bedrijvenkavels.datumstart,
    bedrijvenkavels.uitgegevenaan,
    bedrijvenkavels.datumuitgifte,
    v_kavel_oppervlakte.opp_geometrie_ha as opp_geometrie,
    v_gemeente_en_regio_envelopes.naam AS gemeentenaam,
    v_gemeente_en_regio_envelopes.vvr_naam AS regionaam,
    bedrijventerrein.a_plannaam AS terreinnaam
   FROM "IBIS".bedrijvenkavels,
    bedrijventerrein,
    v_kavel_oppervlakte,
    v_gemeente_en_regio_envelopes
  WHERE bedrijvenkavels.id = v_kavel_oppervlakte.id
    AND bedrijventerrein.id = bedrijvenkavels.terreinid
    AND bedrijventerrein.gemeenteid = v_gemeente_en_regio_envelopes.gem_id;

ALTER TABLE "IBIS".v_component_ibis_report_uitgifte
  OWNER TO ibis;

COMMENT ON VIEW "IBIS".v_component_ibis_report
  IS 'Uitgifte gegevens voor IbisReport component.';
