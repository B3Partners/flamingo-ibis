-- geotools / geoserver primary key metadata tabel
-- in geoserver op de bron toevoegen als "IBIS".gt_pk_metadata

CREATE TABLE 
  gt_pk_metadata (
    table_schema VARCHAR(32) NOT NULL,
    table_name VARCHAR(32) NOT NULL,
    pk_column VARCHAR(32) NOT NULL,
    pk_column_idx INTEGER,
    pk_policy VARCHAR(32),
    pk_sequence VARCHAR(64),
    unique (table_schema, table_name, pk_column),
    check (pk_policy in ('sequence', 'assigned', 'autoincrement'))
);

CREATE UNIQUE INDEX gt_pk_metadata_idx 
  ON gt_pk_metadata (table_schema, table_name, pk_column);
  
  
