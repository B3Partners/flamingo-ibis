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

import java.io.StringReader;
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
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.viewer.config.app.Application;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.Layer;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.simple.SimpleFeatureStore;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * voor IBIS component IbisReport.
 *
 * @author Mark Prins
 */
@UrlBinding("/action/ibisattributes")
@StrictBinding
public class IbisAttributeListActionBean implements ActionBean {

    private static final Log log = LogFactory.getLog(IbisAttributeListActionBean.class);
    private ActionBeanContext context;

    @Validate
    private Application application;

    @Validate
    private ApplicationLayer appLayer;

    private SimpleFeatureStore store;

    private Layer layer = null;

    private boolean unauthorized;

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

    @DefaultHandler
    public Resolution attributes() throws Exception {
        // get attributes from view
        return null;
    }

    
    public Resolution query() throws Exception {

        log.debug("appLayer:" + appLayer);
        log.debug("application:" + application);

        JSONObject json = new JSONObject();
        json.put("success", Boolean.FALSE);
        String error = null;
        if (appLayer == null) {
            error = "Invalid parameters";
        } else if (unauthorized) {
            error = "Not authorized";
        } else {
            try {
                // metadata
                JSONObject metadata = new JSONObject();
                metadata.put("root", "data");
                metadata.put("totalProperty", "total");
                metadata.put("successProperty", "ok");
                metadata.put("messageProperty", "msg");

                // data fields
                JSONArray fields = new JSONArray();
                JSONObject field = new JSONObject();
                field.put("name", "test");
                field.put("type", "int");
                fields.put(field);

                field = new JSONObject();
                field.put("name", "item");
                field.put("type", "int");
                fields.put(field);

                field = new JSONObject();
                field.put("name", "naam");
                field.put("type", "string");
                fields.put(field);

                metadata.put("fields", fields);

                // columns for grid
                JSONArray columns = new JSONArray();
                JSONObject col = new JSONObject();
                col.put("text", "Test");
                col.put("dataIndex", "test");
                columns.put(col);

                col = new JSONObject();
                col.put("text", "Item");
                col.put("dataIndex", "item");
                columns.put(col);

                col = new JSONObject();
                col.put("text", "Naam");
                col.put("dataIndex", "naam");
                columns.put(col);
                metadata.put("columns", columns);

                json.put("metaData", metadata);

                // data payload
                JSONArray datas = new JSONArray();

                JSONObject data = new JSONObject();
                data.put("test", 1);
                data.put("item", 2);
                data.put("naam", "test naam");
                datas.put(data);

                data = new JSONObject();
                data.put("test", 3);
                data.put("item", 4);
                data.put("naam", "tweede naam");
                datas.put(data);

                json.put("data", datas);
                json.put("total", 2);

                json.put("msg", "it's OK");
                json.put("ok", Boolean.TRUE);

            } catch (Exception e) {
                error = "er ging iets fout";
            }
        }

        if (error != null) {
            json.put("ok", Boolean.FALSE);
            json.put("msg", error);
        }

        log.debug("returning json:" + json);

        return new StreamingResolution("application/json", new StringReader(json.toString()));
    }

    //<editor-fold defaultstate="collapsed" desc="getters en setters">
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
    //</editor-fold>
}
