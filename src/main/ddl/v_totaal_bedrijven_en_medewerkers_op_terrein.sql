-- View: "IBIS".v_totaal_bedrijven_en_medewerkers_op_terrein

-- DROP VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_terrein;

CREATE OR REPLACE VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_terrein AS 
 SELECT bedrijventerrein.id AS terreinid,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.bedrijven,
    v_totaal_bedrijven_en_medewerkers_op_rin_nr.medewerkers
   FROM "IBIS".bedrijventerrein
     LEFT JOIN "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr ON "IBIS".bedrijventerrein.rin_nr = v_totaal_bedrijven_en_medewerkers_op_rin_nr.rin_nr;

ALTER TABLE "IBIS".v_totaal_bedrijven_en_medewerkers_op_terrein
  OWNER TO geo;
COMMENT ON VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_terrein
  IS 'Geeft de totalen van bedrijven en medewerkers per terrein.';
