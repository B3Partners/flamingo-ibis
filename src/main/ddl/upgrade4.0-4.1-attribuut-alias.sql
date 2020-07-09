UPDATE attribute_descriptor SET name_alias='Minimale verkoopprijs (euro)' WHERE name='b_minverkoop' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Maximale verkoopprijs (euro)' WHERE name='b_maxverkoop' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Minimale huurprijs (euro)'    WHERE name='b_minhuur' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Maximale huurprijs (euro)'    WHERE name='b_maxhuur' AND name_alias IS NULL;
