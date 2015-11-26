-- View: "IBIS".v_grootste_10_kavels_op_terrein

-- DROP VIEW "IBIS".v_grootste_10_kavels_op_terrein;

CREATE OR REPLACE VIEW "IBIS".v_grootste_10_kavels_op_terrein AS 
 SELECT a.terreinid AS id_terrein,
    a.uitgegevenaan,
    a.id AS id_kavel,
    st_area(a.geom)::numeric AS opp_geometrie
   FROM ( SELECT v_actuele_kavels.*,
            row_number() OVER (PARTITION BY v_actuele_kavels.terreinid ORDER BY st_area(v_actuele_kavels.geom)::numeric DESC) AS row_id
           FROM "IBIS".v_actuele_kavels
          WHERE v_actuele_kavels.status::text = 'Uitgegeven'::text) a
  WHERE a.row_id <= 10
  ORDER BY a.terreinid, st_area(a.geom)::numeric;

ALTER TABLE "IBIS".v_grootste_10_kavels_op_terrein
  OWNER TO geo;
COMMENT ON VIEW "IBIS".v_grootste_10_kavels_op_terrein
  IS 'Geeft de 10 grootste kavels met bedrijf per bedrijventerrein gesorteerd op oppervlakte';
