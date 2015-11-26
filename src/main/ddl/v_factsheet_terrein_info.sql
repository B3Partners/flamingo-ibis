-- View: "IBIS".v_factsheet_terrein_info

-- DROP VIEW "IBIS".v_factsheet_terrein_info;

CREATE OR REPLACE VIEW "IBIS".v_factsheet_terrein_info AS 
 SELECT bedrijventerrein.id AS terreinid,
    bedrijventerrein.*,
        CASE
            WHEN   OWNER.beschikbare_panden IS NULL THEN 0::bigint
            ELSE   OWNER.beschikbare_panden
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
     LEFT JOIN   OWNER ON bedrijventerrein.id =   OWNER.terreinid
     LEFT JOIN "IBIS".v_terrein_oppervlakte ON v_terrein_oppervlakte.id = bedrijventerrein.id
     LEFT JOIN "IBIS".v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeenteid = v_gemeente_en_regio_envelopes.gem_id
     LEFT JOIN "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr ON bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr;

ALTER TABLE "IBIS".v_factsheet_terrein_info
  OWNER TO geo;
