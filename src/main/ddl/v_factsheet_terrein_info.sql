-- View: "IBIS".v_factsheet_terrein_info

-- DROP VIEW "IBIS".v_factsheet_terrein_info;

CREATE OR REPLACE VIEW "IBIS".v_factsheet_terrein_info AS
 SELECT bedrijventerrein.ibis_id AS terreinid,
    bedrijventerrein.rin_nr,
    bedrijventerrein.datummutatie,
    bedrijventerrein.reden,
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
    bedrijventerrein.geom,
        CASE
            WHEN owner.beschikbare_panden IS NULL THEN 0::bigint
            ELSE owner.beschikbare_panden
        END AS beschikbare_panden,
    round(v_terrein_oppervlakte.opp_geom, 2) AS opp_geom_ha,
    round(v_terrein_oppervlakte.opp_woonbebouwing, 2) AS opp_woonbebouwing_ha,
    round(v_terrein_oppervlakte.opp_openbare_ruimte, 2) AS opp_openbare_ruimte_ha,
    round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem, 2) AS opp_niet_terstond_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_uitgegeven, 2) AS opp_uitgegeven_ha,
    round(v_terrein_oppervlakte.opp_uitgeefbaar_part + v_terrein_oppervlakte.opp_uitgeefbaar_gem, 2) AS opp_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_bekend, 2) AS opp_niet_bekend_ha,
    round(v_terrein_oppervlakte.opp_leeg, 2) AS opp_leeg_ha,
    round(v_terrein_oppervlakte.opp_netto, 2) AS opp_netto_ha,
    round(v_terrein_oppervlakte.opp_bruto, 2) AS opp_bruto_ha,
    v_gemeente_en_regio_envelopes.naam AS gemeente_naam,
    v_gemeente_en_regio_envelopes.cbscode,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.corop,
    v_gemeente_en_regio_envelopes.deelregio,
    v_gemeente_en_regio_envelopes.provincie,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.bedrijven AS aantal_bedrijven,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.medewerkers AS aantal_werkzame_personen
   FROM bedrijventerrein
     LEFT JOIN owner ON bedrijventerrein.ibis_id = owner.terreinid
     LEFT JOIN v_terrein_oppervlakte ON v_terrein_oppervlakte.gt_pkey = bedrijventerrein.gt_pkey
     LEFT JOIN v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeente_naam = v_gemeente_en_regio_envelopes.naam
     LEFT JOIN v_totaal_bedrijven_en_medewerkers_op_rin_nr ON bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr;

ALTER TABLE "IBIS".v_factsheet_terrein_info
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_factsheet_terrein_info
  IS 'Geeft de terrein informatie bij een kavel tbv de factsheet. workflow_status is verwijderd vanwege https://github.com/flamingo-geocms/flamingo/issues/497 maar is ook niet nodig voor de factsheet.';
