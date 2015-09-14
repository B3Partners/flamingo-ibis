-- View: "IBIS".v_grootste_10_bedrijven_op_rin_nr

-- DROP VIEW "IBIS".v_grootste_10_bedrijven_op_rin_nr;

CREATE OR REPLACE VIEW "IBIS".v_grootste_10_bedrijven_op_rin_nr AS 
 SELECT a.bedrijvent AS rin_nr,
    a.naam,
    a.sbioms_lan AS activiteit,
    a.grk_huidig AS grootte_klasse
   FROM ( SELECT bedrijven.gid,
            bedrijven.naam,
            bedrijven.sbioms_lan,
            bedrijven.grk_huidig,
            bedrijven.bedrijvent,
            bedrijven.totf,
            row_number() OVER (PARTITION BY bedrijven.bedrijvent ORDER BY bedrijven.totf DESC) AS row_id
           FROM bedrijven
          WHERE bedrijven.datumeinde IS NULL) a
  WHERE a.row_id <= 10
  ORDER BY a.gid, a.totf;

ALTER TABLE "IBIS".v_grootste_10_bedrijven_op_rin_nr
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_grootste_10_bedrijven_op_rin_nr
  IS 'Geeft de 10 grootste actieve bedrijven per bedrijventerrein (rin nr) gesorteerd op aantal medewerkers';
