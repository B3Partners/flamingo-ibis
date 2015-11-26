-- View: "IBIS".v_grootste_10_bedrijven_op_terrein

-- DROP VIEW "IBIS".v_grootste_10_bedrijven_op_terrein;

CREATE OR REPLACE VIEW "IBIS".v_grootste_10_bedrijven_op_terrein AS 
 SELECT bedrijventerrein.id AS terreinid,
    bedrijventerrein.rin_nr,
    v_grootste_10_bedrijven_op_rin_nr.naam,
    v_grootste_10_bedrijven_op_rin_nr.activiteit,
    v_grootste_10_bedrijven_op_rin_nr.grootte_klasse,
    bedrijven_grootteklasse.beschrijving AS grootte_beschrijving
   FROM "IBIS".bedrijventerrein
     LEFT JOIN v_grootste_10_bedrijven_op_rin_nr ON bedrijventerrein.rin_nr = v_grootste_10_bedrijven_op_rin_nr.rin_nr
     LEFT JOIN bedrijven_grootteklasse ON v_grootste_10_bedrijven_op_rin_nr.grootte_klasse::text = bedrijven_grootteklasse.klasse::text
  ORDER BY bedrijventerrein.id, v_grootste_10_bedrijven_op_rin_nr.grootte_klasse DESC;

ALTER TABLE "IBIS".v_grootste_10_bedrijven_op_terrein
  OWNER TO geo;
COMMENT ON VIEW "IBIS".v_grootste_10_bedrijven_op_terrein
  IS 'Geeft de 10 grootste bedrijven per terrein';
