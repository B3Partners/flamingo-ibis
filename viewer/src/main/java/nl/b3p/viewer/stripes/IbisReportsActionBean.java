/*
 * Copyright (C) 2016 B3Partners B.V.
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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.activation.MimetypesFileTypeMap;
import javax.persistence.EntityManager;
import javax.servlet.http.HttpServletResponse;
import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.Before;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import net.sourceforge.stripes.controller.LifecycleStage;
import net.sourceforge.stripes.validation.DateTypeConverter;
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.viewer.config.app.Application;
import nl.b3p.viewer.config.app.ConfiguredAttribute;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.AttributeDescriptor;
import nl.b3p.viewer.config.services.JDBCFeatureSource;
import nl.b3p.viewer.config.services.SimpleFeatureType;
import nl.b3p.viewer.features.CSVDownloader;
import nl.b3p.viewer.features.ExcelDownloader;
import nl.b3p.viewer.features.FeatureDownloader;
import nl.b3p.viewer.features.ShapeDownloader;
import nl.b3p.viewer.ibis.util.IbisConstants;
import nl.b3p.web.stripes.ErrorMessageResolution;
import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.data.simple.SimpleFeatureSource;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.util.factory.GeoTools;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.stripesstuff.stripersist.Stripersist;

/**
 *
 * @author mprins
 */
@UrlBinding("/action/ibisreports")
@StrictBinding
public class IbisReportsActionBean implements ActionBean, IbisConstants {

    private static final Log log = LogFactory.getLog(IbisReportsActionBean.class);

    private static final String JSON_METADATA = "metaData";

    private ActionBeanContext context;
    @Validate(converter = DateTypeConverter.class)
    private Date fromDate;
    @Validate(converter = DateTypeConverter.class)
    private Date toDate;
    @Validate
    private String regio;
    @Validate
    private String gemeente;
    /**
     * download type.
     */
    @Validate
    private String type;

    @Validate
    private String report;

    @Validate
    private Application application;
    @Validate
    private JDBCFeatureSource attrSource;

    @Validate
    private String params;

    private boolean unauthorized;

    @Before(stages = LifecycleStage.EventHandling)
    public void checkAuthorization() {
        EntityManager em = Stripersist.getEntityManager();
        if (application == null || !Authorizations.isApplicationReadAuthorized(application, context.getRequest(), em)) {
            unauthorized = true;
        }
    }

    public Resolution download() throws Exception {
        JSONObject json = new JSONObject();
        if (unauthorized) {
            json.put("success", Boolean.FALSE);
            json.put("message", "Not authorized");
            return new StreamingResolution("application/json", new StringReader(json.toString(4)));
        }

        File output = null;
        try {
            SimpleFeatureType sft = attrSource.getFeatureType(report);
            Filter f = this.createFilters(sft);
            List<AttributeDescriptor> attrs = sft.getAttributes();

            SimpleFeatureSource fs = (SimpleFeatureSource) sft.openGeoToolsFeatureSource();

            final Query q = new Query(fs.getName().toString());
            q.setFilter(createFilters(sft));
            log.debug(q);

            // cannot forward to download action bean as that uses layers/appLayers
            //  while we use an attributesource
            Map<String, AttributeDescriptor> featureTypeAttributes = new HashMap();
            List<ConfiguredAttribute> attributes = new ArrayList();
            ConfiguredAttribute ca;
            for (AttributeDescriptor ad : attrs) {
                featureTypeAttributes.put(ad.getName(), ad);
                ca = new ConfiguredAttribute();
                ca.setVisible(true);
                ca.setAttributeName(ad.getName());
                attributes.add(ca);
            }

            output = convert(sft, fs, q, attributes, featureTypeAttributes);
            json.put("success", true);
        } catch (Exception e) {
            log.error("Error loading features", e);
            json.put("success", false);

            String message = "Fout bij ophalen features: " + e.toString();
            Throwable cause = e.getCause();
            while (cause != null) {
                message += "; " + cause.toString();
                cause = cause.getCause();
            }
            json.put("message", message);
        }

        if (json.getBoolean("success")) {
            final FileInputStream fis = new FileInputStream(output);
            try {
                StreamingResolution res = new StreamingResolution(MimetypesFileTypeMap.getDefaultFileTypeMap().getContentType(output)) {
                    @Override
                    public void stream(HttpServletResponse response) throws Exception {
                        OutputStream out = response.getOutputStream();
                        IOUtils.copy(fis, out);
                        fis.close();
                    }
                };
                String name = output.getName();
                String extension = name.substring(name.lastIndexOf("."));
                SimpleDateFormat today = new SimpleDateFormat("yyyy_MM_dd");
                String newName = "download-" + report + "-" + today.format(new Date()) + extension;
                res.setFilename(newName);
                res.setAttachment(true);
                return res;
            } finally {
                output.delete();
            }
        } else {
            return new ErrorMessageResolution(json.getString("message"));
        }
    }

    @DefaultHandler
    public Resolution execute() throws Exception {
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
        if (attrSource == null) {
            error = "Invalid parameters.";
        } else if (unauthorized) {
            error = "Not authorized.";
        } else if (report == null) {
            error = "Report type is required.";
        }
        SimpleFeatureType sft = attrSource.getFeatureType(report);
        List<AttributeDescriptor> attrs = sft.getAttributes();

        SimpleFeatureSource fs = null;
        try {
            fs = (SimpleFeatureSource) sft.openGeoToolsFeatureSource();

            final Query q = new Query(fs.getName().toString());
            q.setFilter(createFilters(sft));
            log.debug(q);

            SimpleFeatureCollection sfc = fs.getFeatures(q);

            featuresToJson(sfc, json, attrs/*attribuutnamen*/);

            json.put("message", "OK");
            json.put("success", Boolean.TRUE);
        } catch (Exception e) {
            log.error("Error generating report data.", e);
            error = e.getLocalizedMessage();
        } finally {
            if (fs != null) {
                fs.getDataStore().dispose();
            }
        }
        if (error != null) {
            json.put("success", Boolean.FALSE);
            json.put("message", error);
        }

        log.debug("returning json:" + json);
        return new StreamingResolution("application/json", new StringReader(json.toString()));
    }

    private Filter createFilters(SimpleFeatureType sft) {
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2(GeoTools.getDefaultHints());
        List<Filter> filters = new ArrayList<>();
        // regio
        if (this.regio != null && sft.getAttribute("vvr_naam") != null) {
            filters.add(ff.equals(ff.property("vvr_naam"), ff.literal(regio)));
        }
        // regio
        if (this.regio != null && sft.getAttribute("wgr_naam") != null) {
            filters.add(ff.equals(ff.property("wgr_naam"), ff.literal(regio)));
        }
        if (this.gemeente != null && sft.getAttribute("gemeentenaam") != null) {
            filters.add(ff.equals(ff.property("gemeentenaam"), ff.literal(gemeente)));
        }
        if (this.toDate != null && sft.getAttribute("datum") != null) {
            filters.add(ff.before(ff.property("datum"), ff.literal(toDate)));
        }
        if (this.fromDate != null && sft.getAttribute("datum") != null) {
            filters.add(ff.after(ff.property("datum"), ff.literal(fromDate)));
        }

        if (filters.size() > 1) {
            return ff.and(filters);
        } else if (filters.size() == 1) {
            return filters.get(0);
        } else {
            return Filter.INCLUDE;
        }
    }

    /**
     * Convert a SimpleFeatureCollection to JSON with metadata.
     *
     * @param sfc collections of features
     * @param json output/appendend to json structure
     * @param featureTypeAttributes flamingo attribute descriptors for the
     * features
     * @throws JSONException if any
     */
    private void featuresToJson(SimpleFeatureCollection sfc, JSONObject json,
            List<AttributeDescriptor> featureTypeAttributes) throws JSONException {

        // metadata for fData fields
        JSONArray fields = new JSONArray();
        // columns for grid
        JSONArray columns = new JSONArray();
        // fData payload
        JSONArray datas = new JSONArray();

        boolean getMetadataFromFirstFeature = true;
        try (SimpleFeatureIterator sfIter = sfc.features()) {
            while (sfIter.hasNext()) {
                SimpleFeature feature = sfIter.next();
                JSONObject fData = new JSONObject();

                for (AttributeDescriptor attr : featureTypeAttributes) {
                    String name = attr.getName();
                    if (getMetadataFromFirstFeature) {
                        // only load metadata into json this for first feature
                        JSONObject field = new JSONObject().put("name", name).put("type", attr.getExtJSType());
                        if (attr.getType().equals(AttributeDescriptor.TYPE_DATE)) {
                            field.put("dateFormat", "Y-m");
                        }
                        fields.put(field);
                        columns.put(new JSONObject().put("text", (attr.getAlias() != null ? attr.getAlias() : name)).put("dataIndex", name));
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
        }
    }

    private File convert(SimpleFeatureType ft, FeatureSource fs, Query q, List<ConfiguredAttribute> attributes,
            Map<String, AttributeDescriptor> featureTypeAttributes) throws IOException {

        Map<String, String> attributeAliases = new HashMap<>();
        for (AttributeDescriptor ad : ft.getAttributes()) {
            if (ad.getAlias() != null) {
                attributeAliases.put(ad.getName(), ad.getAlias());
            } else {
                attributeAliases.put(ad.getName(), ad.getName());
            }
        }

        SimpleFeatureCollection fc = (SimpleFeatureCollection) fs.getFeatures(q);
        File f = null;
        // alle kolommen autosizen op inhoud
        StringBuilder autosizeAttr = new StringBuilder(",autoSize=");
        for (ConfiguredAttribute configuredAttribute : attributes) {
            autosizeAttr.append(configuredAttribute.getAttributeName()).append("|");
        }
        params = params + autosizeAttr;

        FeatureDownloader downloader = null;
        if (type.equalsIgnoreCase("SHP")) {
            downloader = new ShapeDownloader(attributes, (SimpleFeatureSource) fs, featureTypeAttributes, attributeAliases, params);
        } else if (type.equalsIgnoreCase("XLS")) {
            downloader = new ExcelDownloader(attributes, (SimpleFeatureSource) fs, featureTypeAttributes, attributeAliases, params);
        } else if (type.equals("CSV")) {
            downloader = new CSVDownloader(attributes, (SimpleFeatureSource) fs, featureTypeAttributes, attributeAliases, params);
        } else {
            throw new IllegalArgumentException("No suitable type given: " + type);
        }

        try {
            downloader.init();
            try (SimpleFeatureIterator it = fc.features()) {
                while (it.hasNext()) {
                    SimpleFeature feature = it.next();
                    downloader.processFeature(feature);
                }
            }
            f = downloader.write();
        } catch (IOException ex) {
            log.error("Cannot create outputfile: ", ex);
            throw ex;
        } finally {
            fs.getDataStore().dispose();
        }
        log.debug("returning file " + f);
        return f;
    }

    //<editor-fold defaultstate="collapsed" desc="getters en setters">
    @Override
    public ActionBeanContext getContext() {
        return context;
    }

    @Override
    public void setContext(ActionBeanContext context) {
        this.context = context;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReport() {
        return report;
    }

    public void setReport(String report) {
        this.report = report;
    }

    public Application getApplication() {
        return application;
    }

    public void setApplication(Application application) {
        this.application = application;
    }

    public JDBCFeatureSource getAttrSource() {
        return attrSource;
    }

    public void setAttrSource(JDBCFeatureSource attrSource) {
        this.attrSource = attrSource;
    }

    
    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }
    //</editor-fold>
}
