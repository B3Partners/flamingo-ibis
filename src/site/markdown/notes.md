# Deployment notes


### IbisEdit component

 This is a subclass of the regular Edit component to support workflow.

 The title of this component is update when attribute data is loaded to reflect
 the object being edited, the fields supported for this are:

  - gemeentenaam
  - a_plannaam
  - terreinid
  - rin_nr

### IbisFactsheet component

This component extends the featureinfo popup with a link to provide extra information on
the kavels layer, the link text is the title of the component (no title - no link).

Configure the component to use the kavels layer as the "Factsheet kaartlaag".
The kavels layer should have the following joins and relates configured:

  - join to the view that provides area information for the kavels `v_kavel_oppervlakte` (`gt_key` = `gt_key`)
  - join to the view that provides factsheet information `v_factsheet_terrein_info` (`terreinid` = `terreinid`)
  - relate to `v_grootste_10_bedrijven_op_terrein` which provide the 10 biggest 
    companies on the terrain that the kavel is part of (`terreinid` = `terreinid`).

In the components "Selecteer de kaartlagen voor de legenda" list 
check the layers to be part of the legend (Bedrijventerrein begrenzing and Bedrijventerrein kavels)

To be able to zoom in to the terrein the geometry field of the `v_factsheet_terrein_info` must 
be checked in the attributes tab.

<!--
### IbisReport component

The IbisReport uses a special layer that is only to be used for the component
and not anything else.

  - Create a layer "ibis report component" based on the `v_component_ibis_report`
    that is created from the same view. Attach a WFS attribue source to this layer.
  - Create a `relate` feature type relation to the view `v_component_ibis_report_uitgifte`
    linking "v_component_ibis_report":ibis_id to "v_component_ibis_report_uitgifte":terreinid
  - Add the layer to the application, but give it a place of it's own in
    "Boomstructuuur met kaart" so it won't show up in the legend. eg.
    `Applicatie > niet in de kaart > ibis report component > ibis report component`,
    turn on __all__ attributes. (Do __not__ add the layer to the "Kaartbeeld")
  - Add the IbisReport component to the application, either as a sidebar component 
    or a popup, configure it to use "ibis report component" as layer, select
    which attributes should be available as aggregate.
-->
### IbisReports component

The IbisReports uses a special layer that is only to be used for the component
and not anything else. Next to that it directly uses an "Attribuutbron" to retrieve
data of the views specified in the control admin.

  - Create a layer "ibis report component" based on the `v_component_ibis_report`
    that is created from the same view. Attach a WFS attribute source to this layer.
  - Add the layer to the application, but give it a place of it's own in
    "Boomstructuuur met kaart" so it won't show up in the legend. eg.
    `Applicatie > niet in de kaart > ibis report component > ibis report component`,
    turn on __all__ attributes. (Do __not__ add the layer to the "Kaartbeeld")
  - Add the IbisReports component to the application, either as a sidebar component 
    or a popup, configure it to use "ibis report component" as layer (IbisRapportages 
    component kaartlaag (component view))
  - choose the IbisReports attribuutbron to use for locating the views (make sure it is up-to-date)
  - add the views to generate reporting buttons using the "Rapport toevoegen" button,
    enter a button label and a table or view name (clear the to remove an entry)

 There are some css classes available for additional styling:

  - `IbisReportBtn` for the sidebar button
  - `IbisReportFormTitel` for the headers in the criteria form
  - `IbisReportFormBtn` for the report buttons


### IbisLocationFinder component

The IbisLocationFinder uses the same layer as the IbisReport component, see above
for configuration. The two components share a common datastore so that the location
data only needs to be downloaded once.

### Other Flamingo joins and relates

  - join `bedrijventerrein` to `gemeente` (`gemeente_naam` = `naam`)
  - join `bedrijventerrein` to `v_terrein_oppervlakte` (`gt_pkey` = `gt_pkey`)

### Workflow

For the possible values list in the viewer-admin edit configuration use the
following for the layers that have workflow enabled (kavels + terreinen):
`bewerkt:Bewerkt,definitief:Definitief,archief:Archief,afgevoerd:Afgevoerd`

_note_ there is no space after the comma.

Next add the following (workflow) user groups in flamingo and add the users to the groups:
 - workflow_gemeente
 - workflow_provincie
 - workflow_admin (can change any status to any other status)

If you need to prevent some users from editing geometry create a usergroup for
that (eg. cannot_edit_geometry) and attach them to this group, next specify the
group on that cannot edit geometry on the layer in the "Service en Kaartlagen"
view of the viewer-admin

