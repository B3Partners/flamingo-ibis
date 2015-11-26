-- View: "IBIS".  OWNER TO "IBIS";

-- DROP VIEW "IBIS".  OWNER TO "IBIS";;

CREATE OR REPLACE VIEW "IBIS".OWNER AS 
 SELECT v_actuele_kavels.terreinid,
    count(v_actuele_kavels.terreinid) AS beschikbare_panden
   FROM "IBIS".v_actuele_kavels 
  GROUP BY v_actuele_kavels.terreinid;

ALTER TABLE "IBIS".OWNER
  OWNER TO geo;
COMMENT ON VIEW "IBIS".OWNER
  IS 'Geeft de het aantal beschikbare panden op een terrein';
