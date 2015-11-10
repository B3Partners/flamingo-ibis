-- View: "IBIS".v_gemeente_en_regio_envelopes

-- DROP VIEW "IBIS".v_gemeente_en_regio_envelopes;

CREATE OR REPLACE VIEW "IBIS".v_gemeente_en_regio_envelopes AS 
 SELECT gemeente.id AS gem_id,
    gemeente.naam,
    gemeente.cbscode,
    gemeente.provincie,
    gemeente.corop,
    gemeente.deelregio,
    regio.vvr_naam,
    regio.vvr_id,
    st_envelope(st_buffer(st_envelope(gemeente.geom), 1000::double precision)) AS bbox_gemeente,
    st_envelope(regio.geom) AS bbox_regio
   FROM "IBIS".gemeente,
    "IBIS".regio
  WHERE gemeente.vvr_id = regio.vvr_id;

ALTER TABLE "IBIS".v_gemeente_en_regio_envelopes
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_gemeente_en_regio_envelopes
  IS 'Geeft de MBR van de gemeenten en regio_s';
