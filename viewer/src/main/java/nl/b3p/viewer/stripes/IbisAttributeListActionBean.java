/*
 * Copyright (C) 2015 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.viewer.stripes;

import static nl.b3p.viewer.ibis.util.DateUtils.addMonth;
import static nl.b3p.viewer.ibis.util.DateUtils.differenceInMonths;

import java.io.StringReader;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.TreeSet;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.After;
import net.sourceforge.stripes.action.Before;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import net.sourceforge.stripes.controller.LifecycleStage;
import net.sourceforge.stripes.validation.DateTypeConverter;
import net.sourceforge.stripes.validation.EnumeratedTypeConverter;
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.viewer.config.app.Application;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.AttributeDescriptor;
import nl.b3p.viewer.config.services.FeatureTypeRelation;
import nl.b3p.viewer.config.services.Layer;
import nl.b3p.viewer.config.services.SimpleFeatureType;
import nl.b3p.viewer.util.FeatureToJson;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.Query;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.feature.simple.SimpleFeatureBuilder;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.filter.text.ecql.ECQL;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.feature.Property;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.filter.Filter;
import org.stripesstuff.stripersist.Stripersist;

/**
 * Attribute list backend for voor IBIS component IbisReport.
 *
 * @author Mark Prins
 */
@UrlBinding("/action/ibisattributes")
@StrictBinding
public class IbisAttributeListActionBean implements ActionBean {

    private static final Log log = LogFactory.getLog(IbisAttributeListActionBean.class);
    private static final String JSON_METADATA = "metaData";
    private ActionBeanContext context;

    /**
     * Base64 form fData to echo back.
     */
    @Validate
    private String data;
    /**
     * filename to echo back.
     */
    @Validate
    private String filename;
    /**
     * mimetype to echo back.
     */
    @Validate
    private String mimetype;

    @Validate
    private Application application;

    @Validate
    private ApplicationLayer appLayer;

    @Validate(converter = DateTypeConverter.class)
    private Date fromDate;
    @Validate(converter = DateTypeConverter.class)
    private Date toDate;
    @Validate
    private String regio;
    @Validate
    private String gemeente;
    @Validate
    private String terrein;
    @Validate
    private List<String> attrNames;
    /**
     * report reportType
     */
    @Validate(converter = EnumeratedTypeConverter.class)
    private ReportType reportType;
    /**
     * report type
     */
    @Validate(converter = EnumeratedTypeConverter.class)
    private QueryArea aggregationLevel;
    @Validate(converter = EnumeratedTypeConverter.class)
    private AggregationLevelDate aggregationLevelDate;

    private Layer layer = null;
    private boolean unauthorized;
    private String gebiedsNaamQuery;
    private QueryArea areaType;

    enum QueryArea {

        REGIO, GEMEENTE, TERREIN
    }

    enum ReportType {

        INDIVIDUAL, AGGREGATED, ISSUE;
    }

    enum AggregationLevelDate {

        NONE, MONTH
    }

    /**
     * Field in the datamodel (base uitgifte view). {@value }
     */
    private static final String TERREINID_FIELDNAME = "id";
    /**
     * Field in the datamodel (base uitgifte view). {@value }
     */
    private static final String GEMEENTE_FIELDNAME = "naam";
    /**
     * Field in the datamodel (base uitgifte view). {@value }
     */
    private static final String REGIO_FIELDNAME = "vvr_naam";
    /**
     * Field in the datamodel (base uitgifte view). {@value }
     */
    private static final String TERREIN_FIELDNAME = "a_plannaam";
    /**
     * Field in the datamodel. {@value }
     */
    private static final String STATUS_FIELDNAME = "status";
    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String KAVELID_RELATED_FIELDNAME = "kavelid";
    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String GEMEENTE_RELATED_FIELDNAME = "gemeentenaam";
    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String REGIO_RELATED_FIELDNAME = "regionaam";
    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String TERREIN_RELATED_FIELDNAME = "terreinnaam";

    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String TERREINID_RELATED_FIELDNAME = "terreinid";

    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String UITGIFTEDATUM_RELATED_FIELDNAME = "datumuitgifte";
    /**
     * Field in the datamodel (related view). {@value }
     */
    private static final String OPPERVLAKTE_GEOM_RELATED_FIELDNAME = "opp_geometrie";

    /**
     * aggregate locality field name. {@value}
     */
    private static final String GEBIED_FIELDNAME = "gebied";

    /**
     * name of the related feature type. {@value}.
     *
     * @todo assuming there is only one relate
     */
    private static final String RELATED_FT_NAME = null;

    @After(stages = LifecycleStage.BindingAndValidation)
    public void loadLayer() {
        this.layer = appLayer.getService().getSingleLayer(appLayer.getLayerName());
    }

    @Before(stages = LifecycleStage.EventHandling)
    public void checkAuthorization() {
        EntityManager em = Stripersist.getEntityManager();
        if (application == null
                || appLayer == null
                || !Authorizations.isAppLayerReadAuthorized(application, appLayer, context.getRequest(), em)) {
            unauthorized = true;
        }
    }

    /**
     * Echo back the received base64 encoded form data. A fallback for IE and
     * browsers that don't support client side downloads.
     *
     * @return excel download of the posted fData (posted data is not validated
     * for 'excel-ness')
     * @throws Exception if data is null or something goes wrong during IO
     */
    public Resolution download() throws Exception {
        if (data == null) {
            throw new IllegalArgumentException("Data cannot be null.");
        } else if (unauthorized) {
            throw new IllegalStateException("Not authorized.");
        }
        if (mimetype == null) {
            mimetype = "application/vnd.ms-excel";
        }
        if (filename == null) {
            filename = "ibisrapportage.xls";
        }
        log.debug("returning excel:" + data);
        return new StreamingResolution(mimetype, new StringReader(data)).setFilename(filename).setAttachment(false);
    }

    @DefaultHandler
    public Resolution query() throws Exception {
        JSONObject json = new JSONObject();
        json.put("success", Boolean.FALSE);
        // initial metadata
        JSONObject metadata = new JSONObject()
                .put("root", "data").put("totalProperty", "total")
                .put("successProperty", "success")
                .put("messageProperty", "message")
                .put("idProperty", "rownum");
        json.put(JSON_METADATA, metadata);

        String error = null;
        if (appLayer == null) {
            error = "Invalid parameters.";
        } else if (unauthorized) {
            error = "Not authorized.";
        } else if (reportType == null) {
            error = "Report type is required.";
        } else {
            try {
                // test either regio / gemeente / terrein must not be null
                if (terrein != null) {
                    areaType = QueryArea.TERREIN;
                    gebiedsNaamQuery = TERREIN_FIELDNAME + "='" + terrein + "'";;
                } else if (gemeente != null) {
                    areaType = QueryArea.GEMEENTE;
                    gebiedsNaamQuery = GEMEENTE_FIELDNAME + "='" + gemeente + "'";
                } else if (regio != null) {
                    areaType = QueryArea.REGIO;
                    gebiedsNaamQuery = REGIO_FIELDNAME + "='" + regio + "'";
                } else {
                    throw new IllegalArgumentException("Geen gebied opgegeven voor rapport.");
                }

                switch (reportType) {
                    case ISSUE:
                        reportIssued(json);
                        break;
                    case INDIVIDUAL:
                        reportIndividualData(json);
                        break;
                    case AGGREGATED:
                        reportAggregateData(json);
                        break;
                }

                json.put("message", "OK");
                json.put("success", Boolean.TRUE);

            } catch (Exception e) {
                log.error("Error generating report data.", e);
                error = e.getLocalizedMessage();
            }
        }

        if (error != null) {
            json.put("success", Boolean.FALSE);
            json.put("message", error);
        }

        log.debug("returning json:" + json);
        return new StreamingResolution("application/json", new StringReader(json.toString()));
    }

    /**
     * Uitgifte report.
     *
     * @param json that get the data added
     * @throws Exception if any
     */
    private void reportIssued(JSONObject json) throws Exception {
        if (fromDate == null || toDate == null) {
            throw new IllegalArgumentException("Datum vanaf en datum tot zijn verplicht voor uitgifte.");
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
        sdf.setTimeZone(TimeZone.getDefault());

        SimpleFeatureType ft = layer.getFeatureType();
        SimpleFeatureType relFt = this.getRelatedSFT(ft, RELATED_FT_NAME);
        SimpleFeatureSource fs = (SimpleFeatureSource) ft.openGeoToolsFeatureSource();
        SimpleFeatureSource foreignFs = (SimpleFeatureSource) relFt.openGeoToolsFeatureSource();

        Filter filter = ECQL.toFilter(this.gebiedsNaamQuery);
        List<String> tPropnames = Arrays.asList(
                TERREINID_FIELDNAME,
                TERREIN_FIELDNAME,
                GEMEENTE_FIELDNAME,
                REGIO_FIELDNAME);
        Query q = new Query(fs.getName().toString());
        q.setPropertyNames(tPropnames);
        q.setFilter(filter);
        q.setHandle("uitgifte-rapport");
        q.setMaxFeatures(FeatureToJson.MAX_FEATURES);

        try {
            // store terreinen in mem and get a list of the id's
            SimpleFeatureCollection inMem = DataUtilities.collection(fs.getFeatures(q).features());
            StringBuilder in = new StringBuilder();
            SimpleFeatureIterator inMemFeats = inMem.features();
            Set<String> terreinNames = new TreeSet<String>(
                    new Comparator<String>() {
                        @Override
                        public int compare(String a, String b) {
                            return a.compareTo(b);
                        }
                    }
            );
            Set<String> regioNames = new TreeSet<String>(new Comparator<String>() {
                @Override
                public int compare(String a, String b) {
                    return a.compareTo(b);
                }
            });
            Set<String> gemeenteNames = new TreeSet<String>(new Comparator<String>() {
                @Override
                public int compare(String a, String b) {
                    return a.compareTo(b);
                }
            });

            while (inMemFeats.hasNext()) {
                SimpleFeature f = inMemFeats.next();
                in.append(f.getAttribute(TERREINID_FIELDNAME)).append(",");
                terreinNames.add((String) f.getAttribute(TERREIN_FIELDNAME));
                regioNames.add((String) f.getAttribute(REGIO_FIELDNAME));
                gemeenteNames.add((String) f.getAttribute(GEMEENTE_FIELDNAME));
            }
            inMemFeats.close();

            // get related features (terreinen)
            Query foreignQ = new Query(foreignFs.getName().toString());
            foreignQ.setHandle("uitgifte-rapport-related");
            List<String> propnames = Arrays.asList(
                    KAVELID_RELATED_FIELDNAME,
                    OPPERVLAKTE_GEOM_RELATED_FIELDNAME,
                    UITGIFTEDATUM_RELATED_FIELDNAME,
                    TERREIN_RELATED_FIELDNAME,
                    REGIO_RELATED_FIELDNAME,
                    GEMEENTE_RELATED_FIELDNAME);
            foreignQ.setPropertyNames(propnames);
            String query = STATUS_FIELDNAME + "= 'uitgegeven' AND "
                    + TERREINID_RELATED_FIELDNAME + " IN (" + in.substring(0, in.length() - 1) + ") AND "
                    + UITGIFTEDATUM_RELATED_FIELDNAME + " DURING " + sdf.format(fromDate) + "/" + sdf.format(toDate);
            log.debug("uitgifte query: " + query);
            foreignQ.setFilter(ECQL.toFilter(query));

            // kavels for selected terrein id's
            SimpleFeatureCollection sfc = DataUtilities.collection(foreignFs.getFeatures(foreignQ).features());

            // create new aggregate featuretype
            org.opengis.feature.simple.SimpleFeatureType type = DataUtilities.createType(
                    "AGGREGATE",
                    "id:String,*geom:MultiPolygon:28992,maand:String,oppervlakte:Double,gebied:String");

            // create flamingo attribute descriptors for AGGREGATE
            List<AttributeDescriptor> relFeatureTypeAttributes = new ArrayList<AttributeDescriptor>();
            AttributeDescriptor maand = new AttributeDescriptor();
            maand.setName("maand");
            maand.setAlias("maand");
            maand.setType(AttributeDescriptor.TYPE_DATE);
            maand.setId(1L);
            relFeatureTypeAttributes.add(maand);

            AttributeDescriptor opp = new AttributeDescriptor();
            opp.setName("oppervlakte");
            opp.setAlias("oppervlakte");
            opp.setType(AttributeDescriptor.TYPE_DOUBLE);
            opp.setId(2L);
            relFeatureTypeAttributes.add(opp);

            AttributeDescriptor plan = new AttributeDescriptor();
            plan.setName(GEBIED_FIELDNAME);
            plan.setAlias("gebiedsnaam");
            plan.setType(AttributeDescriptor.TYPE_STRING);
            plan.setId(3L);
            relFeatureTypeAttributes.add(plan);

            switch (aggregationLevel) {
                case REGIO:
                    switch (aggregationLevelDate) {
                        case MONTH:
                            sfc = aggregateUitgifteByMonthAndArea(sfc, type, "oppervlakte",
                                    regioNames, REGIO_RELATED_FIELDNAME);
                            break;
                        case NONE:
                            sfc = aggregateUitgifteByArea(sfc, type, "oppervlakte",
                                    regioNames, REGIO_RELATED_FIELDNAME);
                            break;
                    }
                    break;
                case GEMEENTE:
                    switch (aggregationLevelDate) {
                        case MONTH:
                            sfc = aggregateUitgifteByMonthAndArea(sfc, type, "oppervlakte",
                                    gemeenteNames, GEMEENTE_RELATED_FIELDNAME);
                            break;
                        case NONE:
                            sfc = aggregateUitgifteByArea(sfc, type, "oppervlakte",
                                    gemeenteNames, GEMEENTE_RELATED_FIELDNAME);
                            break;
                    }
                    break;
                case TERREIN:
                    switch (aggregationLevelDate) {
                        case MONTH:
                            sfc = aggregateUitgifteByMonthAndArea(sfc, type, "oppervlakte",
                                    terreinNames, TERREIN_RELATED_FIELDNAME);
                            break;
                        case NONE:
                            sfc = aggregateUitgifteByArea(sfc, type, "oppervlakte",
                                    terreinNames, TERREIN_RELATED_FIELDNAME);
                            break;
                    }
                    break;
            }
            switch (aggregationLevelDate) {
                case MONTH:
                    propnames = Arrays.asList("maand", "oppervlakte", GEBIED_FIELDNAME);
                    break;
                case NONE:
                    propnames = Arrays.asList("oppervlakte", GEBIED_FIELDNAME);
            }
            featuresToJson(sfc, json, relFeatureTypeAttributes, propnames);
        } finally {
            foreignFs.getDataStore().dispose();
            fs.getDataStore().dispose();
        }
    }

    /**
     * aggregate features by date and area into new collection with named
     * features.
     *
     * @param sfc source of simple features to aggregate
     * @param type aggregate feature type
     * @param featNames names of the new features
     * @param gebiedFieldName field name of the aggregation bucket (eg. gemeente
     * or regio)
     * @return aggregated features
     */
    private SimpleFeatureCollection aggregateUitgifteByMonthAndArea(SimpleFeatureCollection sfc,
            org.opengis.feature.simple.SimpleFeatureType type, final String sfTypeAreaName,
            Set<String> featNames, final String gebiedFieldName) {

        final int months = differenceInMonths(fromDate, toDate);
        final SimpleDateFormat YYYYMM = new SimpleDateFormat("YYYY.MM");
        Map<String, SimpleFeature> newfeats = new TreeMap<String, SimpleFeature>();

        // create a feature for each month for each 'gebiedFieldName' with 0 area and null geom
        for (String fName : featNames) {
            Date newDate = fromDate;
            for (int m = 0; m < months; m++) {
                String key = fName + YYYYMM.format(newDate);
                SimpleFeature month = DataUtilities.
                        createFeature(type, key + "|null|" + YYYYMM.format(newDate) + "|0d|" + fName);
                newfeats.put(key, month);
                newDate = addMonth(newDate);
            }
        }

        // for each month add up opp_geometrie
        SimpleFeatureIterator items = sfc.features();
        while (items.hasNext()) {
            SimpleFeature f = items.next();
            Date d = (Date) f.getAttribute(UITGIFTEDATUM_RELATED_FIELDNAME);
            SimpleFeature newFeat = newfeats.get(f.getAttribute(gebiedFieldName) + YYYYMM.format(d));
            newFeat.setAttribute(sfTypeAreaName,
                    ((Double) newFeat.getAttribute(sfTypeAreaName))
                    + ((BigDecimal) f.getAttribute(OPPERVLAKTE_GEOM_RELATED_FIELDNAME)).doubleValue());

        }
        items.close();

        ArrayList<SimpleFeature> feats = new ArrayList<SimpleFeature>(newfeats.values());
        return DataUtilities.collection(feats);
    }

    /**
     * aggregate features area into new collection with named features.
     *
     * @param sfc source of simple features to aggregate
     * @param type aggregate featuretype
     * @param featNames names of the new features
     * @param gebiedFieldName field name of the aggregation bucket (eg. gemeente
     * or regio)
     * @return aggregated features
     */
    private SimpleFeatureCollection aggregateUitgifteByArea(SimpleFeatureCollection sfc,
            org.opengis.feature.simple.SimpleFeatureType type, String sfTypeAreaName,
            Set<String> featNames, final String gebiedFieldName) {

        // create a feature for each 'gebiedFieldName' with 0 area and null date and null geom
        Map<String, SimpleFeature> newfeats = new TreeMap<String, SimpleFeature>();
        for (String fName : featNames) {
            SimpleFeature newfeat = DataUtilities.
                    createFeature(type, fName + "|null|null|0d|" + fName);
            newfeats.put(fName, newfeat);
        }

        // for each regio add up opp_geometrie
        SimpleFeatureIterator items = sfc.features();
        while (items.hasNext()) {
            SimpleFeature f = items.next();
            SimpleFeature newFeat = newfeats.get((String) f.getAttribute(gebiedFieldName));
            newFeat.setAttribute(sfTypeAreaName,
                    ((Double) newFeat.getAttribute(sfTypeAreaName))
                    + ((BigDecimal) f.getAttribute(OPPERVLAKTE_GEOM_RELATED_FIELDNAME)).doubleValue());

        }
        items.close();
        ArrayList<SimpleFeature> feats = new ArrayList<SimpleFeature>(newfeats.values());
        Collections.reverse(feats);
        return DataUtilities.collection(feats);
    }

    /**
     * Convert a SimpleFeatureCollection to JSON with metadata.
     *
     * @param sfc collections of features
     * @param json output/appendend to json structure
     * @param featureTypeAttributes flamingo attribute descriptors for the
     * features
     * @param outputPropNames fieldnames to put in output
     * @throws JSONException is any
     */
    private void featuresToJson(SimpleFeatureCollection sfc, JSONObject json,
            List<AttributeDescriptor> featureTypeAttributes, List<String> outputPropNames) throws JSONException {

        // metadata for fData fields
        JSONArray fields = new JSONArray();
        // columns for grid
        JSONArray columns = new JSONArray();
        // fData payload
        JSONArray datas = new JSONArray();

        SimpleFeatureIterator sfIter = sfc.features();

        boolean getMetadataFromFirstFeature = true;
        while (sfIter.hasNext()) {
            SimpleFeature feature = sfIter.next();
            JSONObject fData = new JSONObject();

            for (AttributeDescriptor attr : featureTypeAttributes) {
                String name = attr.getName();
                if (getMetadataFromFirstFeature) {
                    if (outputPropNames.contains(name)) {
                        // only load metadata into json this for first feature
                        JSONObject field = new JSONObject().put("name", name).put("type", attr.getExtJSType());
                        if (reportType == ReportType.ISSUE && attr.getType().equals(AttributeDescriptor.TYPE_DATE)) {
                            field.put("dateFormat", "Y-m");
                        }
                        fields.put(field);
                        columns.put(new JSONObject().put("text", (attr.getAlias() != null ? attr.getAlias() : name)).put("dataIndex", name));
                    }
                }
                fData.put(attr.getName(), feature.getAttribute(attr.getName()));
            }
            datas.put(fData);
            getMetadataFromFirstFeature = false;
        }

        json.getJSONObject(JSON_METADATA).put("fields", fields);
        json.getJSONObject(JSON_METADATA).put("columns", columns);
        json.put("data", datas);
        json.put("total", datas.length());

        sfIter.close();
    }

    /**
     * look up the named related featuretype.
     *
     * @param ft main/parent feature type
     * @param typeNameToGet the name of the related feature type or null
     * @return the named feature type or the first feature type in case
     * {@code typeNameToGet} is {
     * @null} or {
     * @null} when the/a related feature type does not exist
     */
    private SimpleFeatureType getRelatedSFT(SimpleFeatureType ft, String typeNameToGet) {
        SimpleFeatureType relFt = null;

        for (FeatureTypeRelation rel : ft.getRelations()) {
            if (rel.getType().equals(FeatureTypeRelation.RELATE)) {
                relFt = rel.getForeignFeatureType();
                if (relFt.getTypeName().equals(typeNameToGet) || typeNameToGet == null) {
                    break;
                }
            }
        }
        return relFt;
    }

    private void reportIndividualData(JSONObject json) throws Exception {
        List<String> tPropnames = new ArrayList(attrNames);

        SimpleFeatureType ft = layer.getFeatureType();
        List<AttributeDescriptor> featureTypeAttributes = ft.getAttributes();
        SimpleFeatureSource fs = (SimpleFeatureSource) ft.openGeoToolsFeatureSource();

        List<String> foreignAttrNames = new ArrayList<String>();
        // find out which attribute names -if any- are from related features
        for (String a : attrNames) {
            if (fs.getSchema().getDescriptor(a) == null) {
                // if not from fs it must be foreign
                foreignAttrNames.add(a);
                tPropnames.remove(a);
            }
        }
        foreignAttrNames.add(TERREINID_RELATED_FIELDNAME);
        tPropnames.add(TERREINID_FIELDNAME);
        Filter filter = ECQL.toFilter(this.gebiedsNaamQuery);
        Query q = new Query(fs.getName().toString());
        q.setPropertyNames(tPropnames);
        q.setFilter(filter);
        q.setHandle("individueel-rapport");
        q.setMaxFeatures(FeatureToJson.MAX_FEATURES);

        SimpleFeatureCollection mainFSinMem;
        try {
            mainFSinMem = DataUtilities.collection(fs.getFeatures(q).features());
        } finally {
            fs.getDataStore().dispose();
        }
        if (!foreignAttrNames.isEmpty()) {
            SimpleFeatureType relFt = this.getRelatedSFT(ft, RELATED_FT_NAME);
            SimpleFeatureSource foreignFs = (SimpleFeatureSource) relFt.openGeoToolsFeatureSource();
            // compose IN query criteria and store parent features in a map so we can easily get them later
            StringBuilder in = new StringBuilder();
            HashMap<Integer, SimpleFeature> parentFeatures = new HashMap<Integer, SimpleFeature>();
            SimpleFeatureIterator inMemFeats = mainFSinMem.features();
            while (inMemFeats.hasNext()) {
                SimpleFeature f = inMemFeats.next();
                in.append(f.getAttribute(TERREINID_FIELDNAME)).append(",");
                parentFeatures.put((Integer) f.getAttribute(TERREINID_FIELDNAME), f);
            }
            inMemFeats.close();

            // get related features (children)
            Query foreignQ = new Query(foreignFs.getName().toString());
            foreignQ.setHandle("individueel-rapport-related");
            foreignQ.setPropertyNames(foreignAttrNames);
            String query = TERREINID_RELATED_FIELDNAME + " IN (" + in.substring(0, in.length() - 1) + ")";
            log.debug("individueel-rapport-related: " + query);
            foreignQ.setFilter(ECQL.toFilter(query));
            try {
                // kavels/children for selected terrein id's
                SimpleFeatureCollection relatedFC = foreignFs.getFeatures(foreignQ);
                // create a new aggregate feature type 'COMPOSITE' that has attributes of both parent and child types
                SimpleFeatureTypeBuilder tb = new SimpleFeatureTypeBuilder();
                tb.setName("COMPOSITE");
                for (String prop : attrNames) {
                    org.opengis.feature.type.AttributeDescriptor attrDescName = fs.getSchema().getDescriptor(prop);
                    if (attrDescName == null) {
                        // if not from the parent it must be from the child
                        attrDescName = foreignFs.getSchema().getDescriptor(prop);
                    }
                    tb.add(attrDescName);
                }
                tb.add(TERREINID_RELATED_FIELDNAME, Integer.class);
                org.opengis.feature.simple.SimpleFeatureType type = tb.buildFeatureType();
                //  merge main & related child flamingo attribute descriptors for COMPOSITE,
                featureTypeAttributes.addAll(relFt.getAttributes());

                SimpleFeatureBuilder sfBuilder = new SimpleFeatureBuilder(type);
                SimpleFeatureIterator sfcIter = relatedFC.features();
                ArrayList<SimpleFeature> newfeats = new ArrayList<SimpleFeature>();
                while (sfcIter.hasNext()) {
                    // create as many new features as children
                    SimpleFeature f = sfcIter.next();
                    SimpleFeature n = SimpleFeatureBuilder.retype(f, sfBuilder);
                    // copy main data to related children(n)
                    SimpleFeature p = parentFeatures.get((Integer) f.getAttribute(TERREINID_RELATED_FIELDNAME));
                    for (Property a : p.getProperties()) {
                        if (attrNames.contains(a.getName().toString())) {
                            n.setAttribute(a.getName(), a.getValue());
                        }
                    }
                    newfeats.add(n);
                }
                sfcIter.close();
                mainFSinMem = DataUtilities.collection(newfeats);
            } finally {
                foreignFs.getDataStore().dispose();
            }
        }
        featuresToJson(mainFSinMem, json, featureTypeAttributes, attrNames);
    }

    private void reportAggregateData(JSONObject json) throws Exception {
        SimpleFeatureType ft = layer.getFeatureType();
        List<AttributeDescriptor> featureTypeAttributes = ft.getAttributes();
        SimpleFeatureSource fs = (SimpleFeatureSource) ft.openGeoToolsFeatureSource();

        List<String> tPropnames = new ArrayList(attrNames);
        List<String> foreignAttrNames = new ArrayList<String>();
        // find out which attribute names -if any- are from related features
        for (String a : attrNames) {
            if (fs.getSchema().getDescriptor(a) == null) {
                // if not from fs it must be foreign
                foreignAttrNames.add(a);
                tPropnames.remove(a);
            }
        }
        foreignAttrNames.add(TERREINID_RELATED_FIELDNAME);
        tPropnames.add(TERREINID_FIELDNAME);
        tPropnames.add(GEMEENTE_FIELDNAME);
        tPropnames.add(REGIO_FIELDNAME);
        tPropnames.add(TERREIN_FIELDNAME);

        Filter filter = ECQL.toFilter(this.gebiedsNaamQuery);
        Query q = new Query(fs.getName().toString());
        q.setPropertyNames(tPropnames);
        q.setFilter(filter);
        q.setHandle("aggregatie-rapport");
        q.setMaxFeatures(FeatureToJson.MAX_FEATURES);
        log.debug("aggregatie query:" + q);

        try {
            // create the new aggregate featuretype
            org.opengis.feature.simple.SimpleFeatureType type;
            SimpleFeatureTypeBuilder tb = new SimpleFeatureTypeBuilder();
            tb.setName("AGGREGATE");
            for (String prop : tPropnames) {
                org.opengis.feature.type.AttributeDescriptor attrDescName = fs.getSchema().getDescriptor(prop);
                if (attrDescName != null) {
                    tb.add(attrDescName);
                }
            }
            tb.add(GEBIED_FIELDNAME, String.class);
            // update flamingo attribute descriptors for AGGREGATE
            AttributeDescriptor g = new AttributeDescriptor();
            g.setName(GEBIED_FIELDNAME);
            g.setAlias("gebiedsnaam");
            g.setType(AttributeDescriptor.TYPE_STRING);
            featureTypeAttributes.add(0, g);
            // get parent features
            SimpleFeatureCollection sfc = DataUtilities.collection(fs.getFeatures(q).features());

            if (!foreignAttrNames.isEmpty()) {
                SimpleFeatureType relFt = this.getRelatedSFT(ft, RELATED_FT_NAME);
                SimpleFeatureSource foreignFs = (SimpleFeatureSource) relFt.openGeoToolsFeatureSource();

                // add related attributes to type
                for (String prop : foreignAttrNames) {
                    org.opengis.feature.type.AttributeDescriptor attrDescName = foreignFs.getSchema().getDescriptor(prop);
                    if (attrDescName != null) {
                        tb.add(attrDescName);
                    }
                }
                tb.add(TERREINID_RELATED_FIELDNAME, Integer.class);
                type = tb.buildFeatureType();

                //  merge main & related child flamingo attribute descriptors for AGGREGATE,
                featureTypeAttributes.addAll(relFt.getAttributes());

                // compose IN query criteria and store parent features in a map so we can easily get them later
                StringBuilder in = new StringBuilder();
                HashMap<Integer, SimpleFeature> parentFeatures = new HashMap<Integer, SimpleFeature>();
                SimpleFeatureIterator inMemFeats = sfc.features();
                while (inMemFeats.hasNext()) {
                    SimpleFeature f = inMemFeats.next();
                    in.append(f.getAttribute(TERREINID_FIELDNAME)).append(",");
                    parentFeatures.put((Integer) f.getAttribute(TERREINID_FIELDNAME), f);
                }
                inMemFeats.close();

                // get related features (children)
                Query foreignQ = new Query(foreignFs.getName().toString());
                foreignQ.setHandle("aggregatie-rapport-related");
                foreignQ.setPropertyNames(foreignAttrNames);
                String query = TERREINID_RELATED_FIELDNAME + " IN (" + in.substring(0, in.length() - 1) + ")";
                log.debug("aggregatie-rapport-related: " + query);
                foreignQ.setFilter(ECQL.toFilter(query));

                try {
                    // kavels/children for selected terrein id's
                    SimpleFeatureCollection relatedFC = foreignFs.getFeatures(foreignQ);
                    SimpleFeatureBuilder sfBuilder = new SimpleFeatureBuilder(type);
                    SimpleFeatureIterator sfcIter = relatedFC.features();
                    ArrayList<SimpleFeature> newfeats = new ArrayList<SimpleFeature>();

                    boolean firsttimeForP = true;
                    Set<SimpleFeature> firsttimeForPSet = new HashSet<SimpleFeature>();
                    while (sfcIter.hasNext()) {
                        // create as many new features as related/children
                        SimpleFeature f = sfcIter.next();
                        SimpleFeature n = SimpleFeatureBuilder.retype(f, sfBuilder);

                        // copy main data to related children
                        //   but payload field only once to prevent aggregating those values later
                        SimpleFeature p = parentFeatures.get((Integer) f.getAttribute(TERREINID_RELATED_FIELDNAME));
                        for (Property a : p.getProperties()) {
                            if (firsttimeForPSet.contains(p)) {
                                if (!attrNames.contains(a.getName().toString())) {
                                    n.setAttribute(a.getName(), a.getValue());
                                }
                            } else {
                                if (tPropnames.contains(a.getName().toString())) {
                                    n.setAttribute(a.getName(), a.getValue());
                                }
                            }
                        }
                        newfeats.add(n);
                        firsttimeForPSet.add(p);
                    }
                    sfcIter.close();
                    sfc = DataUtilities.collection(newfeats);
                } finally {
                    foreignFs.getDataStore().dispose();
                }
            } else {
                type = tb.buildFeatureType();
            }

            // aggregation
            Set<String> regions = new HashSet<String>();
            switch (aggregationLevel) {
                case REGIO:
                    // max number for regio is 1
                    regions.add(regio);
                    sfc = aggregateFields(sfc, type, regions, attrNames, REGIO_FIELDNAME);
                    break;
                case GEMEENTE:
                    if (this.areaType == QueryArea.TERREIN) {
                        regions.add(gemeente);
                    } else {
                        // create set of all gemeente from query result
                        SimpleFeatureIterator iter = sfc.features();
                        try {
                            while (iter.hasNext()) {
                                SimpleFeature f = iter.next();
                                regions.add((String) f.getAttribute(GEMEENTE_FIELDNAME));
                            }
                        } finally {
                            iter.close();
                        }
                    }
                    sfc = aggregateFields(sfc, type, regions, attrNames, GEMEENTE_FIELDNAME);
                    break;
                case TERREIN:
                    if (this.areaType == QueryArea.TERREIN) {
                        regions.add(terrein);
                    } else {
                        // create set of all terrein from query result
                        SimpleFeatureIterator iter = sfc.features();
                        try {
                            while (iter.hasNext()) {
                                SimpleFeature f = iter.next();
                                regions.add((String) f.getAttribute(TERREIN_FIELDNAME));
                            }
                        } finally {
                            iter.close();
                        }
                    }
                    sfc = aggregateFields(sfc, type, regions, attrNames, TERREIN_FIELDNAME);
                    break;
            }

            attrNames.add(GEBIED_FIELDNAME);
            featuresToJson(sfc, json, featureTypeAttributes, attrNames);
        } finally {
            fs.getDataStore().dispose();
        }

    }

    /**
     * Aggregate the values of the given feature collection into new features of
     * {@code type} that are named.
     *
     * @param sfc source of simple features to aggregate
     * @param type aggregate feature type
     * @param featNames names of the new features
     * @param gebiedFieldName field name of the aggregation bucket (eg. gemeente
     * or regio)
     * @param aggregateFieldNames
     * @param gebiedFieldName
     * @return aggregated features
     *
     */
    private SimpleFeatureCollection aggregateFields(
            SimpleFeatureCollection sfc,
            org.opengis.feature.simple.SimpleFeatureType type,
            Set<String> featNames,
            List<String> aggregateFieldNames,
            String gebiedFieldName) {

        // create a feature for each (regio|gemeente|terrein) name with 0 value
        Map<String, SimpleFeature> newfeats = new TreeMap<String, SimpleFeature>();
        for (String fName : featNames) {
            SimpleFeature newfeat = DataUtilities.template(type);
            for (String aggrName : aggregateFieldNames) {
                newfeat.setAttribute(aggrName, 0);
            }
            newfeat.setAttribute(GEBIED_FIELDNAME, fName);
            newfeats.put(fName, newfeat);
        }

        // for each (regio|gemeente|terrein) name in relatedFC get the attribute to aggregate
        //  and add up in new named feature
        SimpleFeatureIterator items = sfc.features();
        while (items.hasNext()) {
            SimpleFeature f = items.next();
            SimpleFeature newFeat = newfeats.get((String) f.getAttribute(gebiedFieldName));

            for (String aggrFieldName : aggregateFieldNames) {
                if (f.getAttribute(aggrFieldName) != null) {
                    // add up if not null
                    newFeat.setAttribute(aggrFieldName,
                            ((Number) newFeat.getAttribute(aggrFieldName)).doubleValue()
                            + ((Number) f.getAttribute(aggrFieldName)).doubleValue()
                    );
                }
            }
        }
        items.close();
        ArrayList<SimpleFeature> feats = new ArrayList<SimpleFeature>(newfeats.values());
        return DataUtilities.collection(feats);
    }

    //<editor-fold defaultstate="collapsed" desc="getters en setters">
    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getMimetype() {
        return mimetype;
    }

    public void setMimetype(String mimetype) {
        this.mimetype = mimetype;
    }

    @Override
    public void setContext(ActionBeanContext context) {
        this.context = context;
    }

    @Override
    public ActionBeanContext getContext() {
        return context;
    }

    public Application getApplication() {
        return application;
    }

    public void setApplication(Application application) {
        this.application = application;
    }

    public ApplicationLayer getAppLayer() {
        return appLayer;
    }

    public void setAppLayer(ApplicationLayer appLayer) {
        this.appLayer = appLayer;
    }

    public String getRegio() {
        return regio;
    }

    public void setRegio(String regio) {
        this.regio = regio;
    }

    public String getGemeente() {
        return gemeente;
    }

    public void setGemeente(String gemeente) {
        this.gemeente = gemeente;
    }

    public String getTerrein() {
        return terrein;
    }

    public void setTerrein(String terrein) {
        this.terrein = terrein;
    }

    public ReportType getReportType() {
        return reportType;
    }

    public void setReportType(ReportType reportType) {
        this.reportType = reportType;
    }

    public QueryArea getAggregationLevel() {
        return aggregationLevel;
    }

    public void setAggregationLevel(QueryArea aggregationLevel) {
        this.aggregationLevel = aggregationLevel;
    }

    public AggregationLevelDate getAggregationLevelDate() {
        return aggregationLevelDate;
    }

    public void setAggregationLevelDate(AggregationLevelDate aggregationLevelDate) {
        this.aggregationLevelDate = aggregationLevelDate;
    }

    public Date getFromDate() {
        return fromDate;
    }

    public void setFromDate(Date fromDate) {
        this.fromDate = fromDate;
    }

    public Date getToDate() {
        return toDate;
    }

    public void setToDate(Date toDate) {
        this.toDate = toDate;
    }

    public List<String> getAttrNames() {
        return attrNames;
    }

    public void setAttrNames(List<String> attrNames) {
        this.attrNames = attrNames;
    }

    //</editor-fold>
}
