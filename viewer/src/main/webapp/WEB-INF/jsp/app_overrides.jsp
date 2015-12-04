<script type="text/javascript">
    <%-- override the featureinfo actionbean url --%>
    actionBeans["featureinfo"]=<js:quote><stripes:url beanclass="nl.b3p.viewer.stripes.IbisFeatureInfoActionBean" /></js:quote>;
    <%--
          The name of the some of the attribute fields in the datamodel;
             TODO ideally these should come from a property fed bean
    --%>
    var workflowFieldName = "workflow_status";
    var mutatiedatumFieldName = "datummutatie";
    var redenFieldName = "reden";
    var idFieldName = "id";
    var planNaamFieldName = "a_plannaam";
    var bboxTerreinFieldName = "bbox_terrein";
    var gemeenteFieldName = "naam";
    var bboxGemeenteFieldName = "bbox_gemeente";
    var regioFieldName = "vvr_naam";
    var bboxRegioFieldName = "bbox_regio";

</script>