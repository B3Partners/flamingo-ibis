-- View: "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr

-- DROP VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr;

CREATE OR REPLACE VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr AS
 SELECT DISTINCT bedrijven.bedrijvent AS rin_nr,
    count(bedrijven.bedrijvent) AS bedrijven,
    sum(bedrijven.totf)::bigint AS medewerkers
   FROM bedrijven
  GROUP BY bedrijven.bedrijvent;

ALTER TABLE "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_totaal_bedrijven_en_medewerkers_op_rin_nr
  IS 'Geeft het totaal aantal bedrijven en aantal medewerkers per bedrijventerrein';