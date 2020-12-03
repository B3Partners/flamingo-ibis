package nl.b3p.viewer.stripes;

import net.sourceforge.stripes.action.*;
import net.sourceforge.stripes.controller.LifecycleStage;
import net.sourceforge.stripes.validation.Validate;
import nl.b3p.viewer.config.app.Application;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.Layer;
import nl.b3p.viewer.ibis.util.DateUtils;
import nl.b3p.viewer.ibis.util.IbisConstants;
import nl.b3p.viewer.util.IbisFeatureToJson;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.feature.collection.AbstractFeatureVisitor;
import org.geotools.filter.text.cql2.CQLException;
import org.geotools.filter.text.ecql.ECQL;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.feature.Feature;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.opengis.filter.sort.SortBy;
import org.opengis.filter.sort.SortOrder;
import org.stripesstuff.stripersist.Stripersist;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@UrlBinding("/action/ibisfeatureinfoutil")
@StrictBinding
public class IbisFeatureInfoUtilsActionBean extends LocalizableApplicationActionBean implements IbisConstants {
    private static final Log LOG = LogFactory.getLog(IbisEditFeatureActionBean.class);

    private static final String FID = FeatureInfoActionBean.FID;

    @Validate
    private Application application;

    /**
     * the application layer to get the features from.
     */
    @Validate
    private ApplicationLayer appLayer;
    /**
     * feature id to get.
     */
    @Validate
    private String fid;

    /**
     * ibis id to get.
     */
    @Validate
    private String ibisId;

    private Layer layer;

    private ActionBeanContext context;

    private boolean unauthorized;

    @After(stages = LifecycleStage.BindingAndValidation)
    public void loadLayer() {
        this.layer = appLayer.getService().getSingleLayer(appLayer.getLayerName(), Stripersist.getEntityManager());
    }

    @Before(stages = LifecycleStage.EventHandling)
    public void checkAuthorization() {
        if (appLayer == null
                || !Authorizations.isLayerReadAuthorized(layer, context.getRequest(), Stripersist.getEntityManager())) {
            unauthorized = true;
        }
    }

    /**
     * @return json object with min, max and current mutatiedatum
     * @throws JSONException
     */
    public Resolution minmaxDate() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("success", Boolean.FALSE);
        String error = null;

        if (appLayer == null) {
            error = "appLayer parameter ontbreekt";
        } else if (unauthorized) {
            error = "actie niet toegestaan";
        } else {
            FeatureSource fs = null;
            try {
                fs = this.layer.getFeatureType().openGeoToolsFeatureSource();
                FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
                executeQuery(fs, ff, json);
                json.put("success", Boolean.TRUE);
            } catch (IOException ex) {
                error = ex.getLocalizedMessage();
                LOG.error(error, ex);
            } catch (Exception ex) {
                error = ex.getLocalizedMessage();
                LOG.error(error, ex);
            } finally {
                if (fs != null) {
                    fs.getDataStore().dispose();
                }
            }
        }
        if (error != null) {
            json.put("error", error);
        }
        return new StreamingResolution("application/json", new StringReader(json.toString()));
    }

    private void executeQuery(FeatureSource fs, FilterFactory2 ff, JSONObject json) throws IOException, CQLException {
        // werkt niet: Filter f = ff.equal(ff.property(ID_FIELDNAME), ff.literal(new BigInteger(ibisId)));
        Filter f = ECQL.toFilter(ID_FIELDNAME + "=" + ibisId, ff);
        Query q = new Query(
                fs.getName().toString(),
                f,
                new String[]{ID_FIELDNAME, MUTATIEDATUM_FIELDNAME}
        );
        q.setSortBy(new SortBy[]{ff.sort(MUTATIEDATUM_FIELDNAME, SortOrder.ASCENDING)});
        q.setHandle("date-query");
        LOG.debug(q);
        SimpleFeatureCollection sfc = (SimpleFeatureCollection) fs.getFeatures(q);

        List<Date> dateList = new ArrayList<>();
        final Date[] perceelDate = new Date[1];
        sfc.accepts(new AbstractFeatureVisitor() {
            private Date d;
            private String _fid;

            @Override
            public void visit(Feature feature) {
                d = (Date) ((SimpleFeature) feature).getAttribute(MUTATIEDATUM_FIELDNAME);
                _fid = ((SimpleFeature) feature).getID();
                if (_fid.equalsIgnoreCase(getFid())) {
                    perceelDate[0] = d;
                }
                LOG.info("feature: " + _fid + ", " + d);
                dateList.add(d);
            }
        }, null);

        json.put("featdate", IbisFeatureToJson.dateFormat.format(perceelDate[0]));
        json.put("mindate", IbisFeatureToJson.dateFormat.format(DateUtils.getBeforeDate(dateList, perceelDate[0])));
        json.put("maxdate", IbisFeatureToJson.dateFormat.format(DateUtils.getAfterDate(dateList, perceelDate[0])));

        LOG.debug(json);
    }

    //<editor-fold defaultstate="collapsed" desc="getters and setters">
    @Override
    public Application getApplication() {
        return this.application;
    }

    public void setApplication(Application application) {
        this.application = application;
    }

    /**
     * Called by the Stripes dispatcher to provide context to the ActionBean before invoking the
     * handler method.  Implementations should store a reference to the context for use during
     * event handling.
     *
     * @param context ActionBeanContext associated with the current request
     */
    @Override
    public void setContext(ActionBeanContext context) {
        this.context = context;
    }

    /**
     * Implementations must implement this method to return a reference to the context object
     * provided to the ActionBean during the call to setContext(ActionBeanContext).
     *
     * @return ActionBeanContext associated with the current request
     */
    @Override
    public ActionBeanContext getContext() {
        return this.context;
    }

    public ApplicationLayer getAppLayer() {
        return appLayer;
    }

    public void setAppLayer(ApplicationLayer appLayer) {
        this.appLayer = appLayer;
    }

    public String getFid() {
        return fid;
    }

    public void setFid(String fid) {
        this.fid = fid;
    }

    public String getIbisId() {
        return ibisId;
    }

    public void setIbisId(String ibisId) {
        this.ibisId = ibisId;
    }
//</editor-fold>
}
