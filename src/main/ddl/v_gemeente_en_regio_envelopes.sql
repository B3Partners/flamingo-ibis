-- View: "IBIS".v_gemeente_en_regio_envelopes

-- DROP VIEW "IBIS".v_gemeente_en_regio_envelopes;

CREATE OR REPLACE VIEW "IBIS".v_gemeente_en_regio_envelopes AS 
 SELECT gemeente.id AS gem_id,
    gemeente.naam,
    gemeente.cbscode,
    gemeente.provincie,
    gemeente.corop,
    gemeente.deelregio,
    regio.wgr_naam,
    regio.wgr_id,
    st_envelope(gemeente.geom) AS bbox_gemeente,
    st_envelope(regio.geom) AS bbox_regio
   FROM gemeente,
    regio
  WHERE gemeente.wgr_id = regio.wgr_id;

ALTER TABLE "IBIS".v_gemeente_en_regio_envelopes
  OWNER TO ibis;
COMMENT ON VIEW "IBIS".v_gemeente_en_regio_envelopes
  IS 'Geeft de MBR van de gemeenten en regio_s';
