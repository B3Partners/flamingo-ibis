-- View: "IBIS".owner

-- DROP VIEW "IBIS".owner;

CREATE OR REPLACE VIEW "IBIS".owner AS 
 SELECT v_actuele_kavels.terreinid,
    count(v_actuele_kavels.terreinid) AS beschikbare_panden
   FROM v_actuele_kavels
  GROUP BY v_actuele_kavels.terreinid;

ALTER TABLE "IBIS".owner
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".owner
  IS 'Geeft de het aantal beschikbare panden op een terrein';
