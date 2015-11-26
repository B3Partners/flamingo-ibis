
create or replace view "IBIS".v_actuele_kavels 
as select * from "IBIS".bedrijvenkavels where workflow_status='definitief';

ALTER TABLE "IBIS".v_actuele_kavels
  OWNER TO geo;