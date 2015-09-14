-- View: "IBIS".v_terrein_oppervlakte

-- DROP VIEW "IBIS".v_terrein_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_terrein_oppervlakte AS 
 SELECT t.id,
    t.rin_nr,
    ceiling(st_area(t.geom)::numeric) AS opp_geom,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'woonbebouwing'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_woonbebouwing,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'openbare ruimte'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_openbare_ruimte,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'niet terstond uitgeefbaar'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_niet_terstond_uitgeefbaar,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'uitgegeven'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_uitgegeven,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'uitgeefbaar'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_uitgeefbaar,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status::text = 'niet bekend'::text
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_niet_bekend,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND v_kavel_oppervlakte.status IS NULL
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_leeg,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id AND (v_kavel_oppervlakte.status::text = 'uitgeefbaar'::text OR v_kavel_oppervlakte.status::text = 'uitgegeven'::text OR v_kavel_oppervlakte.status::text = 'niet terstond uitgeefbaar'::text)
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_netto,
    ( SELECT ceiling(sum(v_kavel_oppervlakte.opp_geometrie)) AS ceiling
           FROM v_kavel_oppervlakte
          WHERE v_kavel_oppervlakte.terreinid = t.id
          GROUP BY v_kavel_oppervlakte.terreinid) AS opp_bruto
   FROM bedrijventerrein t;

ALTER TABLE "IBIS".v_terrein_oppervlakte
  OWNER TO ibis;
