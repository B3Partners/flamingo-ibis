-- View: "IBIS".v_beschikbare_panden_op_terrein

-- DROP VIEW "IBIS".v_beschikbare_panden_op_terrein;

CREATE OR REPLACE VIEW "IBIS".v_beschikbare_panden_op_terrein AS 
 SELECT bedrijvenkavels.terreinid,
    count(bedrijvenkavels.terreinid) AS beschikbare_panden
   FROM bedrijvenkavels
  WHERE bedrijvenkavels.status::text = ANY (ARRAY['uitgeefbaar'::character varying::text, 'terstond uitgeefbaar'::character varying::text])
  GROUP BY bedrijvenkavels.terreinid;

ALTER TABLE "IBIS".v_beschikbare_panden_op_terrein
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_beschikbare_panden_op_terrein
  IS 'Geeft de het aantal beschikbare panden op een terrein';
