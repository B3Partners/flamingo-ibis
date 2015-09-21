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

import com.vividsolutions.jts.geom.Geometry;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
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
import nl.b3p.viewer.config.app.ConfiguredAttribute;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.AttributeDescriptor;
import nl.b3p.viewer.config.services.FeatureTypeRelation;
import nl.b3p.viewer.config.services.Layer;
import nl.b3p.viewer.config.services.SimpleFeatureType;
import nl.b3p.viewer.util.FeatureToJson;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.geotools.filter.text.cql2.CQL;
import org.geotools.filter.text.ecql.ECQL;
import org.json.JSONArray;
import org.json.JSONObject;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.filter.Filter;

/**
 * voor IBIS component IbisReport.
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

    private String gebiedsNaamQuery;
    private QueryArea areaType;

    enum QueryArea {

        REGIO, GEMEENTE, TERREIN
    }

    enum ReportType {

        INDIVIDUAL, AGGREGATED, ISSUE;
    }
    private SimpleFeatureStore store;

    private Layer layer = null;

    private boolean unauthorized;
    /**
     * report reportType
     */
    @Validate(converter = EnumeratedTypeConverter.class)
    private ReportType reportType;

    /**
     * report type
     */
    @Validate(converter = EnumeratedTypeConverter.class)
    private AggregationLevel aggregationLevel;

    enum AggregationLevel {

        ASAREA, MOREDETAIL
    }

    enum AggregationLevelDate {

        NONE, MONTH
    }
    @Validate(converter = EnumeratedTypeConverter.class)
    private AggregationLevelDate aggregationLevelDate;

    @After(stages = LifecycleStage.BindingAndValidation)
    public void loadLayer() {
        this.layer = appLayer.getService().getSingleLayer(appLayer.getLayerName());
    }

    @Before(stages = LifecycleStage.EventHandling)
    public void checkAuthorization() {
        if (application == null
                || appLayer == null
                || !Authorizations.isAppLayerReadAuthorized(application, appLayer, context.getRequest())) {
            unauthorized = true;
        }
    }

    /**
     * Echo back the received base64 encoded form fData. A fallback for IE and
     * browsers that don't support client side downloads.
     *
     * @return excel download of the posted fData (posted fData is not validated
     * for 'excel-ness')
     * @throws Exception if fData is null or something goes wrong during IO
     */
    public Resolution download() throws Exception {
        if (data == null) {
            throw new IllegalArgumentException("Data cannot be null.");
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
                .put("messageProperty", "message");
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
                    gebiedsNaamQuery = "a_plannaam='" + terrein + "'";;
                } else if (gemeente != null) {
                    areaType = QueryArea.GEMEENTE;
                    gebiedsNaamQuery = "naam='" + gemeente + "'";
                } else if (regio != null) {
                    areaType = QueryArea.REGIO;
                    gebiedsNaamQuery = "wgr_naam='" + regio + "'";
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
                log.error("Fout tijdens genereren rapport data.", e);
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

    private void reportIssued(JSONObject json) throws Exception {
// TODO
//        if (fromDate == null || toDate == null) {
//            throw new IllegalArgumentException("Datum vanaf en datum tot zijn verplicht.");
//        }

        SimpleFeatureType ft = layer.getFeatureType();
        SimpleFeatureType relFt = null;
        // TODO assuming there is only one relate, get the foreign type
        for (FeatureTypeRelation rel : ft.getRelations()) {
            if (rel.getType().equals(FeatureTypeRelation.RELATE)) {
                relFt = rel.getForeignFeatureType();
                log.debug("foreign FT: " + relFt.getTypeName());
                break;
            }
        }
        SimpleFeatureIterator foreignIt = null;

        List<AttributeDescriptor> featureTypeAttributes = ft.getAttributes();
        SimpleFeatureSource fs = (SimpleFeatureSource) ft.openGeoToolsFeatureSource();
        Query q = new Query(fs.getName().toString());

        Filter filter;
        // if terrein
        if (areaType == QueryArea.TERREIN) {
            filter = ECQL.toFilter(this.gebiedsNaamQuery);
        } else {
            //else regio or gemeente
            filter = ECQL.toFilter(this.gebiedsNaamQuery);
        }
        List<String> tPropnames = Arrays.asList("id", "a_plannaam", "datum");
        q.setPropertyNames(tPropnames);
        q.setFilter(filter);
        q.setHandle("uitgifte-rapport");
        // TODO
        q.setMaxFeatures(FeatureToJson.MAX_FEATURES);

        try {
            // store terreinen in mem and get a list of the id's
            SimpleFeatureCollection inMem = DataUtilities.collection(fs.getFeatures(q).features());
            StringBuilder in = new StringBuilder();
            SimpleFeatureIterator inMemFeats = inMem.features();
            while (inMemFeats.hasNext()) {
                SimpleFeature f = inMemFeats.next();
                in.append(f.getAttribute("id")).append(",");
            }
            inMemFeats.close();

            // get related features (terreinen)
            SimpleFeatureSource foreignFs = (SimpleFeatureSource) relFt.openGeoToolsFeatureSource();
            Query foreignQ = new Query(foreignFs.getName().toString());
            foreignQ.setHandle("uitgifte-rapport-related");
            List<String> propnames = Arrays.asList("kavelid", "datumuitgifte", "datum", "opp_geometrie", "uitgegevenaan");
            foreignQ.setPropertyNames(propnames);

            String query = "terreinid IN (" + in.substring(0, in.length() - 1) + ")";
            // AND datum BETWEEN " + fromDate + " AND " + toDate;

            log.debug("query: " + query);

            foreignQ.setFilter(ECQL.toFilter(query));
            foreignIt = foreignFs.getFeatures(foreignQ).features();

            // metadata for fData fields
            JSONArray fields = new JSONArray();
            // columns for grid
            JSONArray columns = new JSONArray();
            // fData payload
            JSONArray datas = new JSONArray();

            boolean firstFeature = true;
            while (foreignIt.hasNext()) {
                SimpleFeature feature = foreignIt.next();
                JSONObject fData = new JSONObject();

                for (AttributeDescriptor attr : featureTypeAttributes) {
                    String name = attr.getName();
                    if (firstFeature) {
                        if (propnames.contains(name)) {
                            // only load metadata into json this for first feature
                            fields.put(new JSONObject().put("name", name)/* het model van FLA(wel double) is rijker dan Ext (geen double) .put("type", attr.getType())*/.put("type", "auto"));
                            columns.put(new JSONObject().put("text", (attr.getAlias() != null ? attr.getAlias() : name)).put("dataIndex", name));
                        }
                    }
                    fData.put(attr.getName(), feature.getAttribute(attr.getName()));
                }
                datas.put(fData);
                firstFeature = false;

                log.debug(feature);
            }

            // TODO
//        switch (aggregationLevel) {
//            case ASAREA:
//                // group by
//                break;
//            case MOREDETAIL:
//                break;
//        }
            json.getJSONObject(JSON_METADATA).put("fields", fields);
            json.getJSONObject(JSON_METADATA).put("columns", columns);
            json.put("data", datas);
            json.put("total", datas.length());

        } finally {
            if (foreignIt != null) {
                foreignIt.close();
            }
            fs.getDataStore().dispose();
        }
    }

    private void createJson(SimpleFeatureCollection sfc) {

    }

    private void reportIndividualData(JSONObject json) throws Exception {
        // metadata for fData fields
        JSONArray fields = new JSONArray();
        // columns for grid
        JSONArray columns = new JSONArray();
        // fData payload
        JSONArray datas = new JSONArray();

        fields.put(new JSONObject().put("name", "test").put("type", "int"));
        fields.put(new JSONObject().put("name", "item").put("type", "int"));
        fields.put(new JSONObject().put("name", "naam").put("type", "string"));

        columns.put(new JSONObject().put("text", "Test").put("dataIndex", "test"));
        columns.put(new JSONObject().put("text", "Item").put("dataIndex", "item"));
        columns.put(new JSONObject().put("text", "Naam").put("dataIndex", "naam"));

        json.getJSONObject(JSON_METADATA).put("fields", fields);
        json.getJSONObject(JSON_METADATA).put("columns", columns);

        datas.put(new JSONObject().put("test", 1).put("item", 2).put("naam", "test naam"));
        datas.put(new JSONObject().put("test", 3).put("item", 4).put("naam", "tweede naam"));

        json.put("data", datas);
        json.put("total", datas.length());
    }

    private void reportAggregateData(JSONObject json) throws Exception {
        this.reportIndividualData(json);
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

    public AggregationLevel getAggregationLevel() {
        return aggregationLevel;
    }

    public void setAggregationLevel(AggregationLevel aggregationLevel) {
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

 //</editor-fold>
}
