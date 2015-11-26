-- View: "IBIS".v_terrein_oppervlakte

-- DROP VIEW "IBIS".v_terrein_oppervlakte;

CREATE OR REPLACE VIEW "IBIS".v_terrein_oppervlakte AS 
 SELECT t.id,
    t.rin_nr,
    COALESCE(NULLIF(round(st_area(t.geom)::numeric/10000,4),0),'0') AS opp_geom,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Woonbebouwing'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_woonbebouwing,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Openbare ruimte'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_openbare_ruimte,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Niet terstond uitgeefbaar particulier'::text 
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_terstond_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Niet terstond uitgeefbaar gemeente'::text 
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_terstond_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Uitgegeven'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgegeven,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Terstond uitgeefbaar gemeente'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgeefbaar_gem,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Terstond uitgeefbaar particulier'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_uitgeefbaar_part,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Niet bekend'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_niet_bekend,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status::text = 'Optie'::text
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_optie,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id AND "IBIS".v_kavel_oppervlakte.status IS NULL
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_leeg,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id 
		  AND ("IBIS".v_kavel_oppervlakte.status::text 
		      in ('Terstond uitgeefbaar gemeente'::text,
			      'Terstond uitgeefbaar particulier'::text, 
				  'Optie'::text, 
				  'Uitgegeven'::text, 
				  'Niet terstond uitgeefbaar gemeente'::text, 
				  'Niet terstond uitgeefbaar particulier'::text))
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_netto,
    COALESCE(NULLIF(round(( SELECT sum("IBIS".v_kavel_oppervlakte.opp_geometrie_ha)
           FROM "IBIS".v_kavel_oppervlakte
          WHERE "IBIS".v_kavel_oppervlakte.terreinid = t.id
          GROUP BY "IBIS".v_kavel_oppervlakte.terreinid),4),0),'0') AS opp_bruto
   FROM "IBIS".bedrijventerrein t;

ALTER TABLE "IBIS".v_terrein_oppervlakte
  OWNER TO geo;
