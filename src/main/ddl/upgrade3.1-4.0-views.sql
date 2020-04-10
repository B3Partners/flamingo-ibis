DROP VIEW IF EXISTS v_factsheet_terrein_info;
DROP VIEW IF EXISTS v_component_ibis_report;
DROP VIEW IF EXISTS v_report_uitgifte_terreinen_opb_kaveluitgiftes;
DROP VIEW IF EXISTS v_report_voorraad_pub_kavels;
DROP VIEW IF EXISTS v_publieke_kavels;
DROP VIEW IF EXISTS v_grootste_10_bedrijven_op_terrein;
DROP VIEW IF EXISTS v_vest_banen_per_terrein;
DROP VIEW IF EXISTS v_report2_voorraad_all_terreinen_group_gem;
DROP VIEW IF EXISTS v_report2_voorraad_all_terreinen_group_wgr;
DROP VIEW IF EXISTS v_report2_voorraad_all_terreinen;
DROP VIEW IF EXISTS v_report2_voorraad_pub_terreinen_group_gem;
DROP VIEW IF EXISTS v_report2_voorraad_pub_terreinen_group_wgr;
DROP VIEW IF EXISTS v_report2_voorraad_pub_onher_terreinen;
DROP VIEW IF EXISTS v_report2_voorraad_pub_terreinen;
DROP VIEW IF EXISTS v_publieke_terreinen;
DROP VIEW IF EXISTS v_terrein_oppervlakte;
DROP VIEW IF EXISTS v_actuele_terreinen;

ALTER TABLE bedrijventerrein DROP COLUMN o_internet;

-- internet
ALTER TABLE bedrijventerrein ADD COLUMN i_openbaar_wifi VARCHAR(3) DEFAULT 'nee' CHECK (i_openbaar_wifi IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_3g            VARCHAR(3) DEFAULT 'nee' CHECK (i_3g            IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_4g            VARCHAR(3) DEFAULT 'nee' CHECK (i_4g            IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_5g            VARCHAR(3) DEFAULT 'nee' CHECK (i_5g            IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_kabel         VARCHAR(3) DEFAULT 'nee' CHECK (i_kabel         IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_glasvezel     VARCHAR(3) DEFAULT 'nee' CHECK (i_glasvezel     IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN i_gereserveerd  VARCHAR(3) DEFAULT 'nee' CHECK (i_gereserveerd  IN ('ja','nee')) NOT NULL;

-- Parkmanagement/veiligheid
ALTER TABLE bedrijventerrein ADD COLUMN p_ondernemersvereniging              VARCHAR(3) DEFAULT 'nee' CHECK (p_ondernemersvereniging      IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie          VARCHAR(3) DEFAULT 'nee' CHECK (p_parkmanagementorganisatie  IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_naam     VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_adres    VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_contact  VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_telefoon VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_email    VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_website  VARCHAR(50);
ALTER TABLE bedrijventerrein ADD COLUMN p_parkmanagementorganisatie_taak     VARCHAR(50);

-- hernoemen van deze 3 bestaande zodat ze in de juiste edit tab terecht komen in flamingo
ALTER TABLE bedrijventerrein RENAME COLUMN o_collbeheer TO p_collbeheer;
ALTER TABLE bedrijventerrein RENAME COLUMN o_collinkoop TO p_collinkoop;
ALTER TABLE bedrijventerrein RENAME COLUMN o_collvoorz  TO p_collvoorz;

ALTER TABLE bedrijventerrein ADD COLUMN p_collbeveiliging                    VARCHAR(3) DEFAULT 'nee' CHECK (p_collbeveiliging     IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_cameratoezicht                     VARCHAR(3) DEFAULT 'nee' CHECK (p_cameratoezicht      IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_nachtsluiting                      VARCHAR(3) DEFAULT 'nee' CHECK (p_nachtsluiting       IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_kvob                               VARCHAR(3) DEFAULT 'nee' CHECK (p_kvob                IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_kvobverloopdatum                   DATE;
ALTER TABLE bedrijventerrein ADD COLUMN p_pps                                VARCHAR(3) DEFAULT 'nee' CHECK (p_pps                 IN ('ja','nee')) NOT NULL;
ALTER TABLE bedrijventerrein ADD COLUMN p_preventievecontrole                VARCHAR(3) DEFAULT 'nee' CHECK (p_preventievecontrole IN ('ja','nee')) NOT NULL;

-- duurzaamheid
ALTER TABLE bedrijventerrein ADD COLUMN d_toegevoegdewaarde NUMERIC(5,0);
ALTER TABLE bedrijventerrein ADD COLUMN d_energieverbruik   NUMERIC(5,0);
ALTER TABLE bedrijventerrein ADD COLUMN d_co2uitstoot       NUMERIC(5,0);
ALTER TABLE bedrijventerrein ADD COLUMN d_noxuitstoot       NUMERIC(5,0);
ALTER TABLE bedrijventerrein ADD COLUMN d_score2018         NUMERIC(6,1);

ALTER TABLE bedrijventerrein ADD COLUMN a_maxbouwhoogte     NUMERIC(2,0);


CREATE OR REPLACE VIEW v_actuele_terreinen
AS SELECT bedrijventerrein.ibis_id,
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
    bedrijventerrein.a_statusrpb,
    bedrijventerrein.a_type,
    bedrijventerrein.a_maxbouwhoogte,
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
    bedrijventerrein.p_collbeheer AS p_collbeheer,
    bedrijventerrein.p_collinkoop AS p_collinkoop,
    bedrijventerrein.p_collvoorz AS p_collvoorz,
    bedrijventerrein.i_openbaar_wifi,
    bedrijventerrein.i_3g,
    bedrijventerrein.i_4g,
    bedrijventerrein.i_5g,
    bedrijventerrein.i_kabel,
    bedrijventerrein.i_glasvezel,
    bedrijventerrein.i_gereserveerd,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
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
    bedrijventerrein.gt_pkey,
    bedrijventerrein.gemeente_naam,
    bedrijventerrein.o_milieuwet_code
   FROM bedrijventerrein
  WHERE bedrijventerrein.workflow_status::text = ANY (ARRAY['definitief'::text, 'bewerkt'::text]);

CREATE OR REPLACE VIEW v_terrein_oppervlakte
AS SELECT t.gt_pkey,
          t.ibis_id,
          t.rin_nr,
          t.workflow_status,
          COALESCE(NULLIF(round(st_area(t.geom)::numeric / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_geom,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Woonbebouwing'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_woonbebouwing,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Openbare ruimte'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_openbare_ruimte,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Niet terstond uitgeefbaar'::text AND a.eigenaartype::text = 'particulier'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_niet_terstond_uitgeefbaar_part,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Niet terstond uitgeefbaar'::text AND a.eigenaartype::text = 'gemeente'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_niet_terstond_uitgeefbaar_gem,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Uitgegeven'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_uitgegeven,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Terstond uitgeefbaar'::text AND a.eigenaartype::text = 'gemeente'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_uitgeefbaar_gem,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Terstond uitgeefbaar'::text AND a.eigenaartype::text = 'particulier'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_uitgeefbaar_part,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Niet bekend'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_niet_bekend,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = 'Optie'::text THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_optie,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status IS NULL THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_leeg,
          COALESCE(NULLIF(round(sum(
                                        CASE
                                            WHEN a.status::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Optie'::text, 'Uitgegeven'::text, 'Niet terstond uitgeefbaar'::text]) THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_netto,
          COALESCE(NULLIF(round(sum(a.kaveloppervlak) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_bruto,
          COALESCE(NULLIF(round(max(
                                        CASE
                                            WHEN a.status::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Niet terstond uitgeefbaar'::text]) THEN a.kaveloppervlak
                                            ELSE 0::numeric
                                            END) / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_gr_uitgeefbaar_kavel,
          COALESCE(NULLIF(max(
                                  CASE
                                      WHEN a.status::text = ANY (ARRAY['Terstond uitgeefbaar'::text, 'Niet terstond uitgeefbaar'::text]) THEN a.milieuwet_code
                                      ELSE 0::bigint::numeric
                                      END), 0::numeric), 0::numeric) AS max_hindercat_uitgeefbaar_kavel,
          COALESCE(NULLIF(max(a.milieuwet_code), 0::numeric), 0::numeric) AS max_hindercat_terrein,
          sum(
                  CASE
                      WHEN a.kaveloppervlak < 1000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN 1
                      ELSE 0
                      END) AS aantal_kavels_onder_1000m2,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 1000::numeric AND a.kaveloppervlak <= 2500::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN 1
                      ELSE 0
                      END) AS aantal_kavels_tussen_1000_2500,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 2500::numeric AND a.kaveloppervlak <= 5000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN 1
                      ELSE 0
                      END) AS aantal_kavels_tussen_2500_5000,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 5000::numeric AND a.kaveloppervlak <= 10000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN 1
                      ELSE 0
                      END) AS aantal_kavels_tussen_5000_10k,
          sum(
                  CASE
                      WHEN a.kaveloppervlak > 10000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN 1
                      ELSE 0
                      END) AS aantal_kavels_groter_10k,
          sum(
                  CASE
                      WHEN a.kaveloppervlak < 1000::numeric AND a.status::text = 'Uitgegeven'::character varying::text THEN 1
                      ELSE 0
                      END) AS aantal_uitg_kavels_onder_1000m2,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 1000::numeric AND a.kaveloppervlak <= 2500::numeric AND a.status::text = 'Uitgegeven'::character varying::text THEN 1
                      ELSE 0
                      END) AS aantal_uitg_kavels_tussen_1000_2500,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 2500::numeric AND a.kaveloppervlak <= 5000::numeric AND a.status::text = 'Uitgegeven'::character varying::text THEN 1
                      ELSE 0
                      END) AS aantal_uitg_kavels_tussen_2500_5000,
          sum(
                  CASE
                      WHEN a.kaveloppervlak >= 5000::numeric AND a.kaveloppervlak <= 10000::numeric AND a.status::text = 'Uitgegeven'::character varying::text THEN 1
                      ELSE 0
                      END) AS aantal_uitg_kavels_tussen_5000_10k,
          sum(
                  CASE
                      WHEN a.kaveloppervlak > 10000::numeric AND a.status::text = 'Uitgegeven'::character varying::text THEN 1
                      ELSE 0
                      END) AS aantal_uitg_kavels_groter_10k,
          round(avg(
                  CASE
                      WHEN a.kaveloppervlak < 1000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN a.kaveloppervlak
                      ELSE NULL::numeric
                      END)) AS avg_opp_kavels_onder_1000m2,
          round(avg(
                  CASE
                      WHEN a.kaveloppervlak >= 1000::numeric AND a.kaveloppervlak <= 2500::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN a.kaveloppervlak
                      ELSE NULL::numeric
                      END)) AS avg_opp_kavels_tussen_1000_2500,
          round(avg(
                  CASE
                      WHEN a.kaveloppervlak >= 2500::numeric AND a.kaveloppervlak <= 5000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN a.kaveloppervlak
                      ELSE NULL::numeric
                      END)) AS avg_opp_kavels_tussen_2500_5000,
          round(avg(
                  CASE
                      WHEN a.kaveloppervlak >= 5000::numeric AND a.kaveloppervlak <= 10000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN a.kaveloppervlak
                      ELSE NULL::numeric
                      END)) AS avg_opp_kavels_tussen_5000_10k,
          round(avg(
                  CASE
                      WHEN a.kaveloppervlak > 10000::numeric AND (a.status::text = ANY (ARRAY['Niet terstond uitgeefbaar'::character varying::text, 'Terstond uitgeefbaar'::character varying::text, 'Optie'::character varying::text, 'Uitgegeven'::character varying::text])) THEN a.kaveloppervlak
                      ELSE NULL::numeric
                      END)) AS avg_opp_kavels_groter_10k
   FROM v_actuele_terreinen t,
        v_actuele_kavels a
   WHERE a.terreinid = t.ibis_id AND a.workflow_status::text = 'definitief'::text
   GROUP BY t.gt_pkey, t.ibis_id, t.rin_nr, t.workflow_status, t.geom;

CREATE OR REPLACE VIEW v_publieke_terreinen
AS SELECT t.ibis_id,
          t.rin_nr,
          t.datummutatie,
          t.reden,
          t.workflow_status,
          t.a_bestemming,
          t.a_grootstedeel,
          t.a_haruimtegebruik,
          t.a_kernnaam,
          t.a_ovwkavelgrootte,
          t.a_planfase,
          t.a_plannaam,
          t.a_statusrpb,
          t.a_type,
          t.a_maxbouwhoogte,
          t.c_hyperlink,
          t.c_onderhoudemail,
          t.c_onderhoudnaam,
          t.c_onderhoudtelefoon,
          t.c_organisatie,
          t.c_postcodeplaats,
          t.c_verkoopadres,
          t.c_verkoopemail,
          t.c_verkoopnaam,
          t.c_verkooptelefoon,
          t.c_verkoopwebsite,
          t.o_afstandvliegveld,
          t.p_collbeheer,
          t.p_collinkoop,
          t.p_collvoorz,
          t.i_openbaar_wifi,
          t.i_3g,
          t.i_4g,
          t.i_5g,
          t.i_kabel,
          t.i_glasvezel,
          t.i_glasvezel,
          t.i_gereserveerd,
          t.o_maxhuur,
          t.o_maxverkoop,
          t.o_milieuzone,
          t.o_externebereikbaarheid,
          t.o_minhuur,
          t.o_minverkoop,
          t.o_naamvliegveld,
          t.o_overslag,
          t.o_parkeergelegenheid,
          t.o_spoorontsluiting,
          t.o_waterontsluiting,
          t.o_wegontsluiting,
          t.geom,
          t.gt_pkey,
          t.gemeente_naam,
          t.o_milieuwet_code
   FROM v_actuele_terreinen t
   WHERE (t.a_planfase::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text OR t.a_planfase::text = 'Ontwerp bestemmingsplan'::text OR t.a_planfase::text = 'Vastgesteld bestemmingsplan'::text) AND t.workflow_status::text = 'definitief'::text;

CREATE OR REPLACE VIEW v_report2_voorraad_pub_terreinen
AS SELECT r.vvr_naam AS wgr_naam,
          t.gemeente_naam AS gemeentenaam,
          t.a_plannaam AS plannaam,
          t.rin_nr,
          t.a_planfase AS planfase,
          t.a_kernnaam AS kernnaam,
          g.cbscode AS gemnr,
          o.opp_bruto AS bruto,
          o.opp_netto AS netto,
          o.opp_uitgegeven AS uitgegeven,
          o.opp_uitgeefbaar_gem AS direct_uitgeefbaar_gem,
          o.opp_uitgeefbaar_part AS direct_uitgeefbaar_part,
          o.opp_niet_terstond_uitgeefbaar_gem AS niet_direct_uitgeefbaar_gem,
          o.opp_niet_terstond_uitgeefbaar_part AS niet_direct_uitgeefbaar_part,
          o.opp_optie AS optie,
          t.a_type AS type_terrein,
          t.a_bestemming AS bestemming_terrein,
          t.a_grootstedeel AS grootste_kavel,
          t.a_ovwkavelgrootte AS beoogde_overwegende_kavelgrootte,
          t.o_milieuzone AS is_er_sprake_van_milieuzone,
          t.o_minhuur AS huur_minimaal,
          t.o_maxhuur AS huur_maximaal,
          t.o_minverkoop AS verkoop_minimaal,
          t.o_maxverkoop AS verkoop_maximaal,
          o.opp_gr_uitgeefbaar_kavel AS opp_grootst_uitgeefbare_kavel,
          o.max_hindercat_uitgeefbaar_kavel AS max_hindercat_uitgeefbare_kavels,
          o.max_hindercat_terrein AS max_hindercat_op_terrein,
          t.o_spoorontsluiting AS ontsluiting_spoor,
          t.o_waterontsluiting AS ontsluiting_water,
          t.o_wegontsluiting AS ontsluiting_weg,
          o.aantal_kavels_onder_1000m2,
          o.aantal_kavels_tussen_1000_2500,
          o.aantal_kavels_tussen_2500_5000,
          o.aantal_kavels_tussen_5000_10k,
          o.aantal_kavels_groter_10k,
          o.aantal_uitg_kavels_onder_1000m2,
          o.aantal_uitg_kavels_tussen_1000_2500,
          o.aantal_uitg_kavels_tussen_2500_5000,
          o.aantal_uitg_kavels_tussen_5000_10k,
          o.aantal_uitg_kavels_groter_10k,
          'now'::text::date AS datum_gegevens
   FROM v_publieke_terreinen t,
        v_terrein_oppervlakte o,
        gemeente g,
        regio r
   WHERE t.gt_pkey = o.gt_pkey AND g.naam::text = t.gemeente_naam::text AND r.id = g.vvr_id AND t.workflow_status::text = 'definitief'::text
   ORDER BY r.vvr_naam, t.gemeente_naam, t.a_plannaam;

CREATE OR REPLACE VIEW v_report2_voorraad_pub_onher_terreinen
AS SELECT v_report2_voorraad_pub_terreinen.wgr_naam,
          v_report2_voorraad_pub_terreinen.gemeentenaam,
          v_report2_voorraad_pub_terreinen.plannaam,
          v_report2_voorraad_pub_terreinen.rin_nr,
          v_report2_voorraad_pub_terreinen.planfase,
          v_report2_voorraad_pub_terreinen.kernnaam,
          v_report2_voorraad_pub_terreinen.gemnr,
          v_report2_voorraad_pub_terreinen.bruto,
          v_report2_voorraad_pub_terreinen.netto,
          v_report2_voorraad_pub_terreinen.uitgegeven,
          v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_gem,
          v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_part,
          v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_gem,
          v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_part,
          v_report2_voorraad_pub_terreinen.optie,
          v_report2_voorraad_pub_terreinen.type_terrein,
          v_report2_voorraad_pub_terreinen.bestemming_terrein,
          v_report2_voorraad_pub_terreinen.grootste_kavel,
          v_report2_voorraad_pub_terreinen.beoogde_overwegende_kavelgrootte,
          v_report2_voorraad_pub_terreinen.is_er_sprake_van_milieuzone,
          v_report2_voorraad_pub_terreinen.huur_minimaal,
          v_report2_voorraad_pub_terreinen.huur_maximaal,
          v_report2_voorraad_pub_terreinen.verkoop_minimaal,
          v_report2_voorraad_pub_terreinen.verkoop_maximaal,
          v_report2_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel,
          v_report2_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels,
          v_report2_voorraad_pub_terreinen.max_hindercat_op_terrein,
          v_report2_voorraad_pub_terreinen.ontsluiting_spoor,
          v_report2_voorraad_pub_terreinen.ontsluiting_water,
          v_report2_voorraad_pub_terreinen.ontsluiting_weg,
          v_report2_voorraad_pub_terreinen.aantal_kavels_onder_1000m2,
          v_report2_voorraad_pub_terreinen.aantal_kavels_tussen_1000_2500,
          v_report2_voorraad_pub_terreinen.aantal_kavels_tussen_2500_5000,
          v_report2_voorraad_pub_terreinen.aantal_kavels_tussen_5000_10k,
          v_report2_voorraad_pub_terreinen.aantal_kavels_groter_10k,
          v_report2_voorraad_pub_terreinen.aantal_uitg_kavels_onder_1000m2,
          v_report2_voorraad_pub_terreinen.aantal_uitg_kavels_tussen_1000_2500,
          v_report2_voorraad_pub_terreinen.aantal_uitg_kavels_tussen_2500_5000,
          v_report2_voorraad_pub_terreinen.aantal_uitg_kavels_tussen_5000_10k,
          v_report2_voorraad_pub_terreinen.aantal_uitg_kavels_groter_10k,
          v_report2_voorraad_pub_terreinen.datum_gegevens
   FROM v_report2_voorraad_pub_terreinen
   WHERE v_report2_voorraad_pub_terreinen.planfase::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text;

CREATE OR REPLACE VIEW v_report2_voorraad_pub_terreinen_group_wgr
AS SELECT v_report2_voorraad_pub_terreinen.wgr_naam,
          sum(v_report2_voorraad_pub_terreinen.bruto) AS bruto,
          sum(v_report2_voorraad_pub_terreinen.netto) AS netto,
          sum(v_report2_voorraad_pub_terreinen.uitgegeven) AS uitgegeven,
          sum(v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_gem) AS direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_part) AS direct_uitgeefbaar_part,
          sum(v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_gem) AS niet_direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_part) AS niet_direct_uitgeefbaar_part,
          sum(v_report2_voorraad_pub_terreinen.optie) AS optie,
          max(v_report2_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
          max(v_report2_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
          max(v_report2_voorraad_pub_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
          'now'::text::date AS datum_gegevens
   FROM v_report2_voorraad_pub_terreinen
   GROUP BY v_report2_voorraad_pub_terreinen.wgr_naam;

CREATE OR REPLACE VIEW v_report2_voorraad_pub_terreinen_group_gem
AS SELECT v_report2_voorraad_pub_terreinen.wgr_naam,
          v_report2_voorraad_pub_terreinen.gemeentenaam,
          v_report2_voorraad_pub_terreinen.gemnr,
          sum(v_report2_voorraad_pub_terreinen.bruto) AS bruto,
          sum(v_report2_voorraad_pub_terreinen.netto) AS netto,
          sum(v_report2_voorraad_pub_terreinen.uitgegeven) AS uitgegeven,
          sum(v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_gem) AS direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_pub_terreinen.direct_uitgeefbaar_part) AS direct_uitgeefbaar_part,
          sum(v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_gem) AS niet_direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_pub_terreinen.niet_direct_uitgeefbaar_part) AS niet_direct_uitgeefbaar_part,
          sum(v_report2_voorraad_pub_terreinen.optie) AS optie,
          max(v_report2_voorraad_pub_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
          max(v_report2_voorraad_pub_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
          max(v_report2_voorraad_pub_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
          'now'::text::date AS datum_gegevens
   FROM v_report2_voorraad_pub_terreinen
   GROUP BY v_report2_voorraad_pub_terreinen.wgr_naam, v_report2_voorraad_pub_terreinen.gemeentenaam, v_report2_voorraad_pub_terreinen.gemnr;

CREATE OR REPLACE VIEW v_report2_voorraad_all_terreinen
AS SELECT r.vvr_naam AS wgr_naam,
          t.gemeente_naam AS gemeentenaam,
          t.a_plannaam AS plannaam,
          t.rin_nr,
          t.a_planfase AS planfase,
          t.a_kernnaam AS kernnaam,
          g.cbscode AS gemnr,
          o.opp_bruto AS bruto,
          o.opp_netto AS netto,
          o.opp_uitgegeven AS uitgegeven,
          o.opp_uitgeefbaar_gem AS direct_uitgeefbaar_gem,
          o.opp_uitgeefbaar_part AS direct_uitgeefbaar_part,
          o.opp_niet_terstond_uitgeefbaar_gem AS niet_direct_uitgeefbaar_gem,
          o.opp_niet_terstond_uitgeefbaar_part AS niet_direct_uitgeefbaar_part,
          o.opp_optie AS optie,
          t.a_type AS type_terrein,
          t.a_bestemming AS bestemming_terrein,
          t.a_grootstedeel AS grootste_kavel,
          t.a_ovwkavelgrootte AS beoogde_overwegende_kavelgrootte,
          t.o_milieuzone AS is_er_sprake_van_milieuzone,
          t.o_minhuur AS huur_minimaal,
          t.o_maxhuur AS huur_maximaal,
          t.o_minverkoop AS verkoop_minimaal,
          t.o_maxverkoop AS verkoop_maximaal,
          o.opp_gr_uitgeefbaar_kavel AS opp_grootst_uitgeefbare_kavel,
          o.max_hindercat_uitgeefbaar_kavel AS max_hindercat_uitgeefbare_kavels,
          o.max_hindercat_terrein AS max_hindercat_op_terrein,
          t.o_spoorontsluiting AS ontsluiting_spoor,
          t.o_waterontsluiting AS ontsluiting_water,
          t.o_wegontsluiting AS ontsluiting_weg,
          o.aantal_kavels_onder_1000m2,
          o.aantal_kavels_tussen_1000_2500,
          o.aantal_kavels_tussen_2500_5000,
          o.aantal_kavels_tussen_5000_10k,
          o.aantal_kavels_groter_10k,
          o.aantal_uitg_kavels_onder_1000m2,
          o.aantal_uitg_kavels_tussen_1000_2500,
          o.aantal_uitg_kavels_tussen_2500_5000,
          o.aantal_uitg_kavels_tussen_5000_10k,
          o.aantal_uitg_kavels_groter_10k,
          'now'::text::date AS datum_gegevens
   FROM bedrijventerrein t,
        v_terrein_oppervlakte o,
        gemeente g,
        regio r
   WHERE t.gt_pkey = o.gt_pkey AND g.naam::text = t.gemeente_naam::text AND r.id = g.vvr_id AND t.workflow_status::text = 'definitief'::text
   ORDER BY r.vvr_naam, t.gemeente_naam, t.a_plannaam;

CREATE OR REPLACE VIEW v_report2_voorraad_all_terreinen_group_wgr
AS SELECT v_report2_voorraad_all_terreinen.wgr_naam,
          sum(v_report2_voorraad_all_terreinen.bruto) AS bruto,
          sum(v_report2_voorraad_all_terreinen.netto) AS netto,
          sum(v_report2_voorraad_all_terreinen.uitgegeven) AS uitgegeven,
          sum(v_report2_voorraad_all_terreinen.direct_uitgeefbaar_gem) AS direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_all_terreinen.direct_uitgeefbaar_part) AS direct_uitgeefbaar_part,
          sum(v_report2_voorraad_all_terreinen.niet_direct_uitgeefbaar_gem) AS niet_direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_all_terreinen.niet_direct_uitgeefbaar_part) AS niet_direct_uitgeefbaar_part,
          sum(v_report2_voorraad_all_terreinen.optie) AS optie,
          max(v_report2_voorraad_all_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
          max(v_report2_voorraad_all_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
          max(v_report2_voorraad_all_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
          'now'::text::date AS datum_gegevens
   FROM v_report2_voorraad_all_terreinen
   GROUP BY v_report2_voorraad_all_terreinen.wgr_naam;

CREATE OR REPLACE VIEW v_report2_voorraad_all_terreinen_group_gem
AS SELECT v_report2_voorraad_all_terreinen.wgr_naam,
          v_report2_voorraad_all_terreinen.gemeentenaam,
          v_report2_voorraad_all_terreinen.gemnr,
          sum(v_report2_voorraad_all_terreinen.bruto) AS bruto,
          sum(v_report2_voorraad_all_terreinen.netto) AS netto,
          sum(v_report2_voorraad_all_terreinen.uitgegeven) AS uitgegeven,
          sum(v_report2_voorraad_all_terreinen.direct_uitgeefbaar_gem) AS direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_all_terreinen.direct_uitgeefbaar_part) AS direct_uitgeefbaar_part,
          sum(v_report2_voorraad_all_terreinen.niet_direct_uitgeefbaar_gem) AS niet_direct_uitgeefbaar_gem,
          sum(v_report2_voorraad_all_terreinen.niet_direct_uitgeefbaar_part) AS niet_direct_uitgeefbaar_part,
          sum(v_report2_voorraad_all_terreinen.optie) AS optie,
          max(v_report2_voorraad_all_terreinen.opp_grootst_uitgeefbare_kavel) AS opp_grootst_uitgeefbare_kavel,
          max(v_report2_voorraad_all_terreinen.max_hindercat_uitgeefbare_kavels) AS max_hindercat_uitgeefbare_kavels,
          max(v_report2_voorraad_all_terreinen.max_hindercat_op_terrein) AS max_hindercat_op_terrein,
          'now'::text::date AS datum_gegevens
   FROM v_report2_voorraad_all_terreinen
   GROUP BY v_report2_voorraad_all_terreinen.wgr_naam, v_report2_voorraad_all_terreinen.gemeentenaam, v_report2_voorraad_all_terreinen.gemnr;


CREATE OR REPLACE VIEW v_vest_banen_per_terrein
AS SELECT t.ibis_id,
          t.rin_nr,
          count(k.gem_aantal_mw) AS bedrijven,
          (round((sum(k.gem_aantal_mw) / 10::numeric)::double precision) * 10::double precision)::bigint AS medewerkers
   FROM v_actuele_terreinen t,
        "EcMo_Prov_werkghd_enquete_copy" c,
        bedrijven_grootteklasse k
   WHERE c.terreinid = t.ibis_id AND c.klasse_omvang::text = k.klasse::text
   GROUP BY t.ibis_id, t.rin_nr;


CREATE OR REPLACE VIEW v_grootste_10_bedrijven_op_terrein
AS SELECT a.gt_pkey,
          a.terreinid,
          a.rin_nr,
          a.naam,
          a.activiteit,
          a.grootte_klasse,
          a.grootte_beschrijving
   FROM ( SELECT t.gt_pkey,
                 bedr.terreinid,
                 t.rin_nr,
                 bedr.bedr_nam AS naam,
                 bedr.sbi_nam AS activiteit,
                 bedr.klasse_omvang AS grootte_klasse,
                 g.beschrijving AS grootte_beschrijving,
                 row_number() OVER (PARTITION BY t.rin_nr ORDER BY bedr.klasse_omvang DESC) AS row_id
          FROM "EcMo_Prov_werkghd_enquete_copy" bedr,
               v_actuele_terreinen t,
               bedrijven_grootteklasse g
          WHERE bedr.terreinid = t.ibis_id AND g.klasse::text = bedr.klasse_omvang::text AND t.workflow_status::text = 'definitief'::text
          ORDER BY t.rin_nr, row_number() OVER (PARTITION BY t.rin_nr ORDER BY bedr.klasse_omvang DESC)) a
   WHERE a.row_id <= 10;

CREATE OR REPLACE VIEW v_publieke_kavels
AS SELECT k.gt_key,
          k.ibis_id,
          k.workflow_status,
          k.datummutatie,
          k.terreinid,
          k.status,
          k.uitgegevenaan,
          k.eerstejaaruitgifte,
          k.gemeentenaam,
          k.kaveloppervlak,
          k.eigenaartype,
          k.milieuwet_code,
          round(k.milieuwet_code) AS milieuwet_code_rounded,
          t.a_planfase,
          k.geom
   FROM v_actuele_terreinen t,
        v_actuele_kavels k
   WHERE k.terreinid = t.ibis_id AND (t.a_planfase::text = 'Vastgesteld en Onherroepelijk bestemmingsplan'::text OR t.a_planfase::text = 'Ontwerp bestemmingsplan'::text OR t.a_planfase::text = 'Vastgesteld bestemmingsplan'::text) AND t.workflow_status::text = 'definitief'::text AND k.workflow_status::text = 'definitief'::text;

CREATE OR REPLACE VIEW v_report_voorraad_pub_kavels
AS SELECT r.vvr_naam,
          k.gemeentenaam,
          t.a_plannaam AS plannaam,
          t.rin_nr,
          k.ibis_id AS kavelid,
          k.kaveloppervlak,
          k.status AS kavelstatus,
          k.eigenaartype,
          k.milieuwet_code AS max_hindercat,
          'now'::text::date AS datum_gegevens
   FROM v_publieke_kavels k,
        v_publieke_terreinen t,
        gemeente g,
        regio r
   WHERE k.terreinid = t.ibis_id AND g.naam::text = k.gemeentenaam::text AND r.id = g.vvr_id AND k.workflow_status::text = 'definitief'::text AND t.workflow_status::text = 'definitief'::text
   ORDER BY r.vvr_naam, k.gemeentenaam, t.a_plannaam, k.status, k.kaveloppervlak;




CREATE OR REPLACE VIEW v_report_uitgifte_terreinen_opb_kaveluitgiftes
AS SELECT r.vvr_naam,
    g.naam,
    b.a_plannaam,
    b.rin_nr,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1980::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _onbekend_1980,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1985::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1985,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1986::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1986,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1987::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1987,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1988::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1988,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1989::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1989,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1990::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1990,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1991::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1991,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1992::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1992,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1993::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1993,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1994::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1994,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1995::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1995,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1996::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1996,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1997::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1997,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1998::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1998,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 1999::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _1999,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2000::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2000,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2001::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2001,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2002::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2002,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2003::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2003,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2004::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2004,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2005::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2005,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2006::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2006,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2007::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2007,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2008::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2008,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2009::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2009,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2010::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2010,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2011::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2011,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2012::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2012,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2013::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2013,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2014::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2014,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2015::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2015,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2016::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2016,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2017::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2017,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2018::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2018,
    round(sum(
        CASE
            WHEN a.jaar::double precision = 2019::double precision THEN a.oppervlak
            ELSE NULL::numeric
        END) / 10000::numeric, 4) AS _2019,
    min(a.datumtijd_gegevens) AS datum_gegevens
   FROM kaveluitgiftes a,
    v_actuele_terreinen b,
    gemeente g,
    regio r
  WHERE a.terreinid = b.ibis_id AND g.naam::text = b.gemeente_naam::text AND r.id = g.vvr_id
  GROUP BY r.vvr_naam, g.naam, b.a_plannaam, b.a_planfase, b.rin_nr
  ORDER BY r.vvr_naam, g.naam, b.a_plannaam;














CREATE OR REPLACE VIEW v_component_ibis_report
AS SELECT t.ibis_id,
          t.rin_nr,
          t.workflow_status,
          t.a_planfase,
          t.a_plannaam,
          t.gemeente_naam,
          t.geom,
          st_envelope(st_snaptogrid(st_buffer(st_envelope(t.geom), 100::double precision)::geometry(Polygon,28992), 1::double precision, 1::double precision))::geometry(Polygon,28992) AS bbox_terrein,
          v_gemeente_en_regio_envelopes.naam,
          v_gemeente_en_regio_envelopes.bbox_gemeente,
          v_gemeente_en_regio_envelopes.vvr_naam,
          v_gemeente_en_regio_envelopes.bbox_regio
   FROM v_publieke_terreinen t
            LEFT JOIN v_gemeente_en_regio_envelopes ON t.gemeente_naam::text = v_gemeente_en_regio_envelopes.naam::text
   ORDER BY v_gemeente_en_regio_envelopes.vvr_naam, v_gemeente_en_regio_envelopes.naam, t.a_plannaam;

CREATE OR REPLACE VIEW v_factsheet_terrein_info
AS SELECT bedrijventerrein.ibis_id AS terreinid,
    bedrijventerrein.ibis_id,
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
    bedrijventerrein.a_statusrpb,
    bedrijventerrein.a_type,
    bedrijventerrein.a_maxbouwhoogte,
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
    bedrijventerrein.p_collbeheer,
    bedrijventerrein.p_collinkoop,
    bedrijventerrein.p_collvoorz,
    bedrijventerrein.i_openbaar_wifi,
    bedrijventerrein.i_3g,
    bedrijventerrein.i_4g,
    bedrijventerrein.i_5g,
    bedrijventerrein.i_kabel,
    bedrijventerrein.i_glasvezel,
    bedrijventerrein.i_gereserveerd,
    bedrijventerrein.o_maxhuur,
    bedrijventerrein.o_maxverkoop,
    ( SELECT codes_milieuwet.waarde
           FROM codes_milieuwet
          WHERE codes_milieuwet.id = bedrijventerrein.o_milieuwet_code::numeric) AS o_milieuwet,
    bedrijventerrein.o_milieuwet_code,
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
    'tijdelijk niet beschikbaar'::character varying AS beschikbare_panden,
    round(v_terrein_oppervlakte.opp_geom, 2)::character varying AS opp_geom_ha,
    round(v_terrein_oppervlakte.opp_woonbebouwing, 2)::character varying AS opp_woonbebouwing_ha,
    round(v_terrein_oppervlakte.opp_openbare_ruimte, 2)::character varying AS opp_openbare_ruimte_ha,
    round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part + v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem, 2)::character varying AS opp_niet_terstond_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_part, 2)::character varying AS opp_niet_terstond_uitgeefbaar_part_ha,
    round(v_terrein_oppervlakte.opp_niet_terstond_uitgeefbaar_gem, 2)::character varying AS opp_niet_terstond_uitgeefbaar_gem_ha,
    round(v_terrein_oppervlakte.opp_uitgegeven, 2)::character varying AS opp_uitgegeven_ha,
    round(v_terrein_oppervlakte.opp_uitgeefbaar_part + v_terrein_oppervlakte.opp_uitgeefbaar_gem, 2)::character varying AS opp_uitgeefbaar_ha,
    round(v_terrein_oppervlakte.opp_niet_bekend, 2) AS opp_niet_bekend_ha,
    round(v_terrein_oppervlakte.opp_leeg, 2)::character varying AS opp_leeg_ha,
    round(v_terrein_oppervlakte.opp_optie, 2)::character varying AS opp_optie_ha,
    round(v_terrein_oppervlakte.opp_netto, 2)::character varying AS opp_netto_ha,
    round(v_terrein_oppervlakte.opp_bruto, 2)::character varying AS opp_bruto_ha,
    v_gemeente_en_regio_envelopes.cbscode,
    v_gemeente_en_regio_envelopes.vvr_naam,
    v_gemeente_en_regio_envelopes.corop,
    v_gemeente_en_regio_envelopes.deelregio,
    v_gemeente_en_regio_envelopes.provincie,
    v_vest_banen_per_terrein.bedrijven AS aantal_bedrijven,
    v_vest_banen_per_terrein.medewerkers AS aantal_werkzame_personen,
    v_terrein_oppervlakte.opp_gr_uitgeefbaar_kavel,
    v_terrein_oppervlakte.max_hindercat_uitgeefbaar_kavel,
    v_terrein_oppervlakte.max_hindercat_terrein
   FROM v_actuele_terreinen bedrijventerrein
     LEFT JOIN v_terrein_oppervlakte ON v_terrein_oppervlakte.ibis_id = bedrijventerrein.ibis_id
     LEFT JOIN v_gemeente_en_regio_envelopes ON bedrijventerrein.gemeente_naam::text = v_gemeente_en_regio_envelopes.naam::text
     LEFT JOIN v_vest_banen_per_terrein ON bedrijventerrein.rin_nr = v_vest_banen_per_terrein.rin_nr
  WHERE bedrijventerrein.workflow_status::text = 'definitief'::text AND v_terrein_oppervlakte.workflow_status::text = 'definitief'::text;

GRANT SELECT ON v_actuele_terreinen TO geolees;
GRANT SELECT ON v_terrein_oppervlakte TO geolees;
GRANT SELECT ON v_publieke_terreinen TO geolees;
GRANT SELECT ON v_report2_voorraad_pub_terreinen TO geolees;
GRANT SELECT ON v_report2_voorraad_pub_onher_terreinen TO geolees;
GRANT SELECT ON v_report2_voorraad_pub_terreinen_group_wgr TO geolees;
GRANT SELECT ON v_report2_voorraad_pub_terreinen_group_gem TO geolees;
GRANT SELECT ON v_report2_voorraad_all_terreinen TO geolees;
GRANT SELECT ON v_report2_voorraad_all_terreinen_group_wgr TO geolees;
GRANT SELECT ON v_report2_voorraad_all_terreinen_group_gem TO geolees;
GRANT SELECT ON v_vest_banen_per_terrein TO geolees;
GRANT SELECT ON v_grootste_10_bedrijven_op_terrein TO geolees;
GRANT SELECT ON v_publieke_kavels TO geolees;
GRANT SELECT ON v_report_voorraad_pub_kavels TO geolees;
GRANT SELECT ON v_report_uitgifte_terreinen_opb_kaveluitgiftes TO geolees;
GRANT SELECT ON v_component_ibis_report TO geolees;
GRANT SELECT ON v_factsheet_terrein_info TO geolees;
GRANT SELECT ON v_uitg_kavels_met_bedrijf TO geolees;
GRANT SELECT ON v_report_brk_kaveluitgiftes_per_terrein TO geolees;
GRANT SELECT ON v_report2_uitgifte_terreinen TO geolees;
GRANT SELECT ON v_report2_uitgifte_terreinen_group_gem TO geolees;
GRANT SELECT ON v_bedrijven_groter_50p_niet_op_terrein TO geolees;
GRANT SELECT ON v_report2_uitgifte_terreinen_group_wgr TO geolees;
GRANT SELECT ON v_actuele_kavels TO geolees;
GRANT SELECT ON v_bedrijvenkavels_duiven TO geolees;
GRANT SELECT ON v_gemeente_en_regio_envelopes TO geolees;
GRANT SELECT ON v_kavels_langer_jaar_in_optie TO geolees;
GRANT SELECT ON v_report_uitgifte_kavels TO geolees;

GRANT ALL ON v_actuele_terreinen TO geoedit;
GRANT ALL ON v_terrein_oppervlakte TO geoedit;
GRANT ALL ON v_publieke_terreinen TO geoedit;
GRANT ALL ON v_report2_voorraad_pub_terreinen TO geoedit;
GRANT ALL ON v_report2_voorraad_pub_onher_terreinen TO geoedit;
GRANT ALL ON v_report2_voorraad_pub_terreinen_group_wgr TO geoedit;
GRANT ALL ON v_report2_voorraad_pub_terreinen_group_gem TO geoedit;
GRANT ALL ON v_report2_voorraad_all_terreinen TO geoedit;
GRANT ALL ON v_report2_voorraad_all_terreinen_group_wgr TO geoedit;
GRANT ALL ON v_report2_voorraad_all_terreinen_group_gem TO geoedit;
GRANT ALL ON v_vest_banen_per_terrein TO geoedit;
GRANT ALL ON v_grootste_10_bedrijven_op_terrein TO geoedit;
GRANT ALL ON v_publieke_kavels TO geoedit;
GRANT ALL ON v_report_voorraad_pub_kavels TO geoedit;
GRANT ALL ON v_report_uitgifte_terreinen_opb_kaveluitgiftes TO geoedit;
GRANT ALL ON v_component_ibis_report TO geoedit;
GRANT ALL ON v_factsheet_terrein_info TO geoedit;
GRANT ALL ON v_uitg_kavels_met_bedrijf TO geoedit;
GRANT ALL ON v_report_brk_kaveluitgiftes_per_terrein TO geoedit;
GRANT ALL ON v_report2_uitgifte_terreinen TO geoedit;
GRANT ALL ON v_report2_uitgifte_terreinen_group_gem TO geoedit;
GRANT ALL ON v_bedrijven_groter_50p_niet_op_terrein TO geoedit;
GRANT ALL ON v_report2_uitgifte_terreinen_group_wgr TO geoedit;
GRANT ALL ON v_actuele_kavels TO geoedit;
GRANT ALL ON v_bedrijvenkavels_duiven TO geoedit;
GRANT ALL ON v_gemeente_en_regio_envelopes TO geoedit;
GRANT ALL ON v_kavels_langer_jaar_in_optie TO geoedit;
GRANT ALL ON v_report_uitgifte_kavels TO geoedit;

