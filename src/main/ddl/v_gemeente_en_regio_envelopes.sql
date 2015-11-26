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
    st_envelope(st_snaptogrid(st_buffer(st_envelope(gemeente.geom), 1000::double precision), 1::double precision, 1::double precision)) AS bbox_gemeente,
    st_snaptogrid(st_envelope(regio.geom), 1::double precision, 1::double precision) AS bbox_regio
   FROM "IBIS".gemeente,
    "IBIS".regio
  WHERE gemeente.vvr_id = regio.vvr_id;

ALTER TABLE "IBIS".v_gemeente_en_regio_envelopes
  OWNER TO geo;
COMMENT ON VIEW "IBIS".v_gemeente_en_regio_envelopes
  IS 'Geeft de MBR van de gemeenten en regio_s';
