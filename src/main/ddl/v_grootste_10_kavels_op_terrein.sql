-- View: "IBIS".v_grootste_10_kavels_op_terrein

-- DROP VIEW "IBIS".v_grootste_10_kavels_op_terrein;

CREATE OR REPLACE VIEW "IBIS".v_grootste_10_kavels_op_terrein AS 
 SELECT a.terreinid AS id_terrein,
    a.uitgegevenaan,
    a.id AS id_kavel,
    st_area(a.geom)::numeric AS opp_geometrie
   FROM ( SELECT bedrijvenkavels.id,
            bedrijvenkavels.terreinid,
            bedrijvenkavels.datum,
            bedrijvenkavels.status,
            bedrijvenkavels.workflow_status,
            bedrijvenkavels.geom,
            bedrijvenkavels.hindercat,
            bedrijvenkavels.eigenaartype,
            bedrijvenkavels.hoeveelheid,
            bedrijvenkavels.uitgegevenaan,
            bedrijvenkavels.eerstejaaruitgifte,
            bedrijvenkavels.identificatie,
            row_number() OVER (PARTITION BY bedrijvenkavels.terreinid ORDER BY st_area(bedrijvenkavels.geom)::numeric DESC) AS row_id
           FROM bedrijvenkavels
          WHERE bedrijvenkavels.status::text = 'uitgegeven'::text) a
  WHERE a.row_id <= 10
  ORDER BY a.terreinid, st_area(a.geom)::numeric;

ALTER TABLE "IBIS".v_grootste_10_kavels_op_terrein
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_grootste_10_kavels_op_terrein
  IS 'Geeft de 10 grootste kavels met bedrijf per bedrijventerrein gesorteerd op oppervlakte';
