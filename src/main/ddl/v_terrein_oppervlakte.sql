-- View: "IBIS".v_terrein_oppervlakte

-- DROP VIEW "IBIS".v_terrein_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_terrein_oppervlakte AS
 SELECT
    t.gt_pkey,
    t.ibis_id,
    t.rin_nr,
    COALESCE(NULLIF(round(st_area(t.geom)::numeric / 10000::numeric, 4), 0::numeric), 0::numeric) AS opp_geom,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Woonbebouwing'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_woonbebouwing,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Openbare ruimte'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_openbare_ruimte,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Niet terstond uitgeefbaar particulier'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_niet_terstond_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Niet terstond uitgeefbaar gemeente'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_niet_terstond_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Uitgegeven'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_uitgegeven,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Terstond uitgeefbaar gemeente'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Terstond uitgeefbaar particulier'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Niet bekend'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_niet_bekend,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status::text = 'Optie'::text
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_optie,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND v_kavel_oppervlakte.status IS NULL
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_leeg,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id AND (v_kavel_oppervlakte.status::text = ANY (ARRAY['Terstond uitgeefbaar gemeente'::text, 'Terstond uitgeefbaar particulier'::text, 'Optie'::text, 'Uitgegeven'::text, 'Niet terstond uitgeefbaar gemeente'::text, 'Niet terstond uitgeefbaar particulier'::text]))
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_netto,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha) AS sum
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.ibis_id
          GROUP BY v_kavel_oppervlakte.terreinid), 4), 0::numeric), 0::numeric) AS opp_bruto
   FROM bedrijventerrein t;

ALTER TABLE "IBIS".v_terrein_oppervlakte
  OWNER TO ibis;
