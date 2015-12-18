-- View: "IBIS".v_actuele_kavels

-- DROP VIEW "IBIS".v_actuele_kavels;

CREATE OR REPLACE VIEW "IBIS".v_actuele_kavels AS 
 SELECT bedrijvenkavels.id,
    bedrijvenkavels.workflow_status,
    bedrijvenkavels.datummutatie,
    bedrijvenkavels.terreinid,
    bedrijvenkavels.status,
    bedrijvenkavels.milieuwet,
    bedrijvenkavels.uitgegevenaan,
    bedrijvenkavels.eerstejaaruitgifte,
    bedrijvenkavels.faseveroudering,
    bedrijvenkavels.gemeenteid,
    bedrijvenkavels.gemeentenaam,
    bedrijvenkavels.geom
   FROM bedrijvenkavels
  WHERE bedrijvenkavels.workflow_status::text = 'definitief'::text;

ALTER TABLE "IBIS".v_actuele_kavels
  OWNER TO ibis;
