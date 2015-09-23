# Order of creating the views and geoserver primary key metadata table

## Views
Some views depende on others, use the following order to create the views:

1. v_kavel_oppervlakte.sql
1. v_terrein_oppervlakte.sql
1. v_gemeente_en_regio_envelopes.sql
1. v_beschikbare_panden_op_terrein.sql
1. v_grootste_10_bedrijven_op_rin_nr.sql
1. v_grootste_10_bedrijven_op_terrein.sql
1. v_grootste_10_kavels_op_terrein.sql
1. v_totaal_bedrijven_en_medewerkers_op_rin_nr.sql
1. v_totaal_bedrijven_en_medewerkers_op_terrein.sql
1. v_factsheet_terrein_info.sql
1. v_component_ibis_report.sql
1. v_component_ibis_report_uitgifte.sql

## Metadata
Last create the geoserver/geotools primary key metadata table (don't forget to add this in the workspace settings of geoserver) and insert the data.

1. gt_pk_metadata.sql
1. insert_gt_pk_metadata.sql
