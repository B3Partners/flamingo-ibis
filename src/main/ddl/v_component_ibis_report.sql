-- View: "IBIS".v_component_ibis_report

-- DROP VIEW "IBIS".v_component_ibis_report;

CREATE OR REPLACE VIEW "IBIS".v_component_ibis_report AS 
 SELECT bedrijventerrein.*,
    st_envelope(st_snaptogrid(st_buffer(st_envelope(bedrijventerrein.geom), 100::double precision)::geometry(Polygon,28992), 1::double precision, 1::double precision))::geometry(Polygon,28992) AS bbox_terrein,
    v_gemeente_en_regio_envelopes.naam,
    v_gemeente_en_regio_envelopes.bbox_gemeente,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.bbox_regio,
    v_terrein_oppervlakte.opp_geom,
    v_terrein_oppervlakte.opp_woonbebouwing,
    v_terrein_oppervlakte.opp_openbare_ruimte,
    (v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem+v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part) as opp_niet_terstond_uitgeefbaar,
    v_terrein_oppervlakte.opp_uitgegeven,
    (v_terrein_oppervlakte.opp_uitgeefbaar_gem+v_terrein_oppervlakte.opp_uitgeefbaar_part) as opp_uitgeefbaar,
    v_terrein_oppervlakte.opp_niet_bekend,
    v_terrein_oppervlakte.opp_leeg,
    v_terrein_oppervlakte.opp_netto,
    v_terrein_oppervlakte.opp_bruto
   FROM "IBIS".bedrijventerrein
     LEFT JOIN "IBIS".v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeenteid = v_gemeente_en_regio_envelopes.gem_id
     JOIN "IBIS".v_terrein_oppervlakte ON bedrijventerrein.id = v_terrein_oppervlakte.id
  ORDER BY v_gemeente_en_regio_envelopes.vvr_naam, v_gemeente_en_regio_envelopes.naam, bedrijventerrein.a_plannaam;

ALTER TABLE "IBIS".v_component_ibis_report
  OWNER TO geo;
COMMENT ON VIEW "IBIS".v_component_ibis_report
  IS 'Koppelt de gemeente en regio gegevens en oppervlakte gegevens aan de terreinen voor de IbisReport component';
