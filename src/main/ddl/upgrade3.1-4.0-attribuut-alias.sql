UPDATE attribute_descriptor SET name_alias='Openbaar WiFi' WHERE name='i_openbaar_wifi' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='3G' WHERE name='i_3g' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='4G' WHERE name='i_4g' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='5G' WHERE name='i_5g' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Kabel' WHERE name='i_kabel' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Glasvezel' WHERE name='i_glasvezel' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Gereserveerd' WHERE name='i_gereserveerd' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Is er een ondernemersvereniging' WHERE name='p_ondernemersvereniging' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Is er een parkmanagementorganisatie' WHERE name='p_parkmanagementorganisatie' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Naam organisatie' WHERE name='p_parkmanagementorganisatie_naam' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Adres' WHERE name='p_parkmanagementorganisatie_adres' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Contactpersoon' WHERE name='p_parkmanagementorganisatie_contact' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Telefoonnr' WHERE name='p_parkmanagementorganisatie_telefoon' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Emailadres' WHERE name='p_parkmanagementorganisatie_email' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Website' WHERE name='p_parkmanagementorganisatie_website' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Wat is hoofdtaak van deze organisatie' WHERE name='p_parkmanagementorganisatie_taak' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Collectief beheer' WHERE name='p_collbeheer;' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Collectieve inkoop' WHERE name='p_collinkoop;' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Collectieve voorzieningen' WHERE name='p_collvoorz;' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Is er collectieve beveiliging' WHERE name='p_collbeveiliging' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Is er cameratoezicht' WHERE name='p_cameratoezicht' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Wordt het terrein ’s nachts afgesloten' WHERE name='p_nachtsluiting' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Is er een Keurmerk Veilig Ondernemen BT (KVO-B)' WHERE name='p_kvob' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Datum verloop KVO-B' WHERE name='p_kvobverloopdatum' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Is er Publiek Private Samenwerking (PPS)' WHERE name='p_pps' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Worden er preventieve controles uitgevoerd' WHERE name='p_preventievecontrole' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Inschatting toegevoegde waarde in mln €' WHERE name='d_toegevoegdewaarde' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Inschatting energieverbruik (MJ)' WHERE name='d_energieverbruik' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Inschatting CO2 uitstoot (kg)' WHERE name='d_co2uitstoot' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Inschatting NOx uitstoot (kg)' WHERE name='d_noxuitstoot' AND name_alias IS NULL;
UPDATE attribute_descriptor SET name_alias='Score duurzaamheid (2018)' WHERE name='d_score2018' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Maximale bouwhoogte' WHERE name='a_maxbouwhoogte' AND name_alias IS NULL;

UPDATE attribute_descriptor SET name_alias='Naam/omschrijving gebied deelgebied 1' WHERE name='v_deelgebied_1_omschrijving';
UPDATE attribute_descriptor SET name_alias='Specifieke toelichting deelgebied 1' WHERE name='v_deelgebied_1_toelichting';
UPDATE attribute_descriptor SET name_alias='Bruto oppervlak in ha. deelgebied 1' WHERE name='v_deelgebied_1_bruto_opp';
UPDATE attribute_descriptor SET name_alias='Netto oppervlak in ha. deelgebied 1' WHERE name='v_deelgebied_1_netto_opp';
UPDATE attribute_descriptor SET name_alias='Is er sprake van veroudering/herstructurering deelgebied 1' WHERE name='v_deelgebied_1_isverouderd';
UPDATE attribute_descriptor SET name_alias='Wat is de hoofdoorzaak veroudering deelgebied 1' WHERE name='v_deelgebied_1_oorzaak';
UPDATE attribute_descriptor SET name_alias='Is er een herstructureringsplan deelgebied 1' WHERE name='v_deelgebied_1_herstructureringsplan';
UPDATE attribute_descriptor SET name_alias='In welke fase verkeert het plan deelgebied 1' WHERE name='v_deelgebied_1_planfase';
UPDATE attribute_descriptor SET name_alias='(Beoogd) Startjaar van het project deelgebied 1' WHERE name='v_deelgebied_1_start_jaar';
UPDATE attribute_descriptor SET name_alias='(Beoogd) Eindjaar van het project deelgebied 1' WHERE name='v_deelgebied_1_eind_jaar';

UPDATE attribute_descriptor SET name_alias='Naam/omschrijving gebied deelgebied 2' WHERE name='v_deelgebied_2_omschrijving';
UPDATE attribute_descriptor SET name_alias='Specifieke toelichting deelgebied 2' WHERE name='v_deelgebied_2_toelichting';
UPDATE attribute_descriptor SET name_alias='Bruto oppervlak in ha. deelgebied 2' WHERE name='v_deelgebied_2_bruto_opp';
UPDATE attribute_descriptor SET name_alias='Netto oppervlak in ha. deelgebied 2' WHERE name='v_deelgebied_2_netto_opp';
UPDATE attribute_descriptor SET name_alias='Is er sprake van veroudering/herstructurering deelgebied 2' WHERE name='v_deelgebied_2_isverouderd';
UPDATE attribute_descriptor SET name_alias='Wat is de hoofdoorzaak veroudering deelgebied 2' WHERE name='v_deelgebied_2_oorzaak';
UPDATE attribute_descriptor SET name_alias='Is er een herstructureringsplan deelgebied 2' WHERE name='v_deelgebied_2_herstructureringsplan';
UPDATE attribute_descriptor SET name_alias='In welke fase verkeert het plan deelgebied 2' WHERE name='v_deelgebied_2_planfase';
UPDATE attribute_descriptor SET name_alias='(Beoogd) Startjaar van het project deelgebied 2' WHERE name='v_deelgebied_2_start_jaar';
UPDATE attribute_descriptor SET name_alias='(Beoogd) Eindjaar van het project deelgebied 2' WHERE name='v_deelgebied_2_eind_jaar';

UPDATE attribute_descriptor SET name_alias='Aantal ha. terrein (netto) opnieuw uitgeefbaar' WHERE name='v_netto_nieuw_uitgeefbaar';
UPDATE attribute_descriptor SET name_alias='Uitgifte kan plaatsvinden vanaf' WHERE name='v_uitgifte_vanaf';
