-- View: "IBIS".v_component_ibis_report

-- DROP VIEW "IBIS".v_component_ibis_report;

CREATE OR REPLACE VIEW "IBIS".v_component_ibis_report AS
 SELECT bedrijventerrein.ibis_id,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datummutatie,
    bedrijventerrein.reden,
    bedrijventerrein.workflow_status,
    bedrijventerrein.a_bestemming,
    bedrijventerrein.a_grootstedeel,
    bedrijventerrein.a_haruimtegebruik,
    bedrijventerrein.a_kernnaam,
    bedrijventerrein.a_ovwkavelgrootte,
    bedrijventerrein.a_planfase,
    bedrijventerrein.a_plannaam,
    bedrijventerrein.a_faseveroudering,
    bedrijventerrein.a_statusrpb,
    bedrijventerrein.a_type,
    bedrijventerrein.c_hyperlink,
    bedrijventerrein.c_onderhoudemail,
    bedrijventerrein.c_onderhoudnaam,
    bedrijventerrein.c_onderhoudtelefoon,
    bedrijventerrein.c_organisatie,
    bedrijventerrein.c_postcodeplaats,
    bedrijventerrein.c_verkoopadres,
    bedrijventerrein.c_verkoopemail,
    bedrijventerrein.c_verkoopnaam,
    bedrijventerrein.c_verkooptelefoon,
    bedrijventerrein.c_verkoopwebsite,
    bedrijventerrein.o_afstandvliegveld,
    bedrijventerrein.o_collbeheer,
    bedrijventerrein.o_collinkoop,
    bedrijventerrein.o_collvoorz,
    bedrijventerrein.o_internet,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
    bedrijventerrein.o_milieuwet,
    bedrijventerrein.o_milieuzone,
    bedrijventerrein.o_externebereikbaarheid,
    bedrijventerrein.o_minhuur,
    bedrijventerrein.o_minverkoop,
    bedrijventerrein.o_naamvliegveld,
    bedrijventerrein.o_overslag,
    bedrijventerrein.o_parkeergelegenheid,
    bedrijventerrein.o_spoorontsluiting,
    bedrijventerrein.o_waterontsluiting,
    bedrijventerrein.o_wegontsluiting,
    bedrijventerrein.gemeente_naam,
    bedrijventerrein.geom,
    st_envelope(st_snaptogrid(st_buffer(st_envelope(bedrijventerrein.geom), 100::double precision)::geometry(Polygon,28992), 1::double precision, 1::double precision))::geometry(Polygon,28992) AS bbox_terrein,
    v_gemeente_en_regio_envelopes.naam,
    v_gemeente_en_regio_envelopes.bbox_gemeente,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.bbox_regio,
    v_terrein_oppervlakte.opp_geom,
    v_terrein_oppervlakte.opp_woonbebouwing,
    v_terrein_oppervlakte.opp_openbare_ruimte,
    v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part AS opp_niet_terstond_uitgeefbaar,
    v_terrein_oppervlakte.opp_uitgegeven,
    v_terrein_oppervlakte.opp_uitgeefbaar_gem + v_terrein_oppervlakte.opp_uitgeefbaar_part AS opp_uitgeefbaar,
    v_terrein_oppervlakte.opp_niet_bekend,
    v_terrein_oppervlakte.opp_leeg,
    v_terrein_oppervlakte.opp_netto,
    v_terrein_oppervlakte.opp_bruto
   FROM bedrijventerrein
     LEFT JOIN v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeente_naam = v_gemeente_en_regio_envelopes.naam
     JOIN v_terrein_oppervlakte ON bedrijventerrein.gt_pkey = v_terrein_oppervlakte.gt_pkey
  ORDER BY v_gemeente_en_regio_envelopes.vvr_naam, v_gemeente_en_regio_envelopes.naam, bedrijventerrein.a_plannaam;

ALTER TABLE "IBIS".v_component_ibis_report
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_component_ibis_report
  IS 'Uitgifte gegevens voor IbisReport component.';
