-- View: "IBIS".v_terrein_oppervlakte

-- DROP VIEW "IBIS".v_terrein_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_terrein_oppervlakte AS 
 SELECT t.id,
    t.rin_nr,
    COALESCE(NULLIF(round(st_area(t.geom)::numeric/10000,4),0),'0') AS opp_geom,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'woonbebouwing'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_woonbebouwing,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'openbare ruimte'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_openbare_ruimte,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'niet terstond uitgeefbaar'::text AND v_kavel_oppervlakte.eigenaartype::text = 'particulier'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_terstond_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'niet terstond uitgeefbaar'::text AND v_kavel_oppervlakte.eigenaartype::text = 'gemeente'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_terstond_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'uitgegeven'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgegeven,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'uitgeefbaar'::text  AND v_kavel_oppervlakte.eigenaartype::text = 'gemeente'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'uitgeefbaar'::text  AND v_kavel_oppervlakte.eigenaartype::text = 'particulier'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'niet bekend'::text
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_bekend,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status IS NULL
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_leeg,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND (v_kavel_oppervlakte.status::text = 'uitgeefbaar'::text OR v_kavel_oppervlakte.status::text = 'uitgegeven'::text OR v_kavel_oppervlakte.status::text = 'niet terstond uitgeefbaar'::text)
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_netto,
    COALESCE(NULLIF(round(( SELECT sum(v_kavel_oppervlakte.opp_geometrie_ha)
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id
          GROUP BY v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_bruto
   FROM "IBIS".bedrijventerrein t;

ALTER TABLE "IBIS".v_terrein_oppervlakte
  OWNER TO ibis;
