--UPDATE attribute_descriptor SET name_alias='Minimale verkoopprijs' WHERE name='b_minverkoop' AND name_alias IS NULL;
--UPDATE attribute_descriptor SET name_alias='Maximale verkoopprijs' WHERE name='b_maxverkoop' AND name_alias IS NULL;
--UPDATE attribute_descriptor SET name_alias='Minimale huurprijs'    WHERE name='b_minhuur' AND name_alias IS NULL;
--UPDATE attribute_descriptor SET name_alias='Maximale huurprijs'    WHERE name='b_maxhuur' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Minimale verkoopprijs' WHERE name='b_minverkoop';
UPDATE attribute_descriptor SET name_alias='Maximale verkoopprijs' WHERE name='b_maxverkoop';
UPDATE attribute_descriptor SET name_alias='Minimale huurprijs'    WHERE name='b_minhuur'   ;
UPDATE attribute_descriptor SET name_alias='Maximale huurprijs'    WHERE name='b_maxhuur'   ;

UPDATE attribute_descriptor SET name_alias=null                    WHERE id IN (
    SELECT a.id FROM attribute_descriptor a
        JOIN feature_type_attributes f ON f.attribute_descriptor = a.id
        JOIN feature_type t            ON t.id = f.feature_type
        WHERE t.type_name = 'v_factsheet_terrein_info'
    )