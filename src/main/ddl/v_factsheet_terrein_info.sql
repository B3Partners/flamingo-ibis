-- View: "IBIS".v_factsheet_terrein_info

-- DROP VIEW "IBIS".v_factsheet_terrein_info;

CREATE OR REPLACE VIEW "IBIS".v_factsheet_terrein_info AS 
 SELECT bedrijventerrein.id AS terreinid,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datum,
    bedrijventerrein.reden,
    bedrijventerrein.a_bestaatnietmeer,
    bedrijventerrein.a_bestemming,
    bedrijventerrein.a_gecontroleerd,
    bedrijventerrein.a_grootstedeel,
    bedrijventerrein.a_haruimtegebruik,
    bedrijventerrein.a_kernnaam,
    bedrijventerrein.a_ovwkavelgrootte,
    bedrijventerrein.a_planfase,
    bedrijventerrein.a_plannaam,
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
    bedrijventerrein.codeplanfase,
    bedrijventerrein.datum_controle,
    bedrijventerrein.l_foto1,
    bedrijventerrein.l_foto2,
    bedrijventerrein.l_foto3,
    bedrijventerrein.l_foto4,
    bedrijventerrein.o_afstandvliegveld,
    bedrijventerrein.o_collbeheer,
    bedrijventerrein.o_collinkoop,
    bedrijventerrein.o_collvoorz,
    bedrijventerrein.o_externebereikbaarheid,
    bedrijventerrein.o_internet,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
    bedrijventerrein.o_milieuwet,
    bedrijventerrein.o_milieuzone,
    bedrijventerrein.o_minhuur,
    bedrijventerrein.o_minverkoop,
    bedrijventerrein.o_naamvliegveld,
    bedrijventerrein.o_overslag,
    bedrijventerrein.o_parkeergelegenheid,
    bedrijventerrein.o_spoorontsluiting,
    bedrijventerrein.o_waterontsluiting,
    bedrijventerrein.o_wegontsluiting,
    bedrijventerrein.gemeenteid,
    bedrijventerrein.geom,
        CASE
            WHEN v_beschikbare_panden_op_terrein.beschikbare_panden IS NULL THEN 0::bigint
            ELSE v_beschikbare_panden_op_terrein.beschikbare_panden
        END AS beschikbare_panden,
    round(v_terrein_oppervlakte.opp_geom::numeric, 2) AS opp_geom_ha,
    round(v_terrein_oppervlakte.opp_woonbebouwing::numeric, 2) AS opp_woonbebouwing_ha,
    round(v_terrein_oppervlakte.opp_openbare_ruimte::numeric, 2) AS opp_openbare_ruimte_ha,
    round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part::numeric + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem::numeric, 2) AS opp_niet_terstond_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_uitgegeven::numeric, 2) AS opp_uitgegeven_ha,
    round(v_terrein_oppervlakte.opp_uitgeefbaar_part::numeric+v_terrein_oppervlakte.opp_uitgeefbaar_gem::numeric, 2) AS opp_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_bekend::numeric, 2) AS opp_niet_bekend_ha,
    round(v_terrein_oppervlakte.opp_leeg::numeric, 2) AS opp_leeg_ha,
    round(v_terrein_oppervlakte.opp_netto::numeric, 2) AS opp_netto_ha,
    round(v_terrein_oppervlakte.opp_bruto::numeric, 2) AS opp_bruto_ha,
    v_gemeente_en_regio_envelopes.naam AS gemeente_naam,
    v_gemeente_en_regio_envelopes.cbscode,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.corop,
    v_gemeente_en_regio_envelopes.deelregio,
    v_gemeente_en_regio_envelopes.provincie,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.bedrijven AS aantal_bedrijven,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.medewerkers AS aantal_werkzame_personen
   FROM "IBIS".bedrijventerrein
     LEFT JOIN v_beschikbare_panden_op_terrein ON bedrijventerrein.id = v_beschikbare_panden_op_terrein.terreinid
     LEFT JOIN v_terrein_oppervlakte ON v_terrein_oppervlakte.id = bedrijventerrein.id
     LEFT JOIN v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeenteid = v_gemeente_en_regio_envelopes.gem_id
     LEFT JOIN v_totaal_bedrijven_en_medewerkers_op_rin_nr ON bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr;

ALTER TABLE "IBIS".v_factsheet_terrein_info
  OWNER TO ibis;
