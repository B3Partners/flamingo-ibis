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

import nl.b3p.viewer.ibis.util.IbisConstants;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.io.WKTReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.ibis.util.WorkflowStatus;
import nl.b3p.viewer.ibis.util.WorkflowUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.Transaction;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.feature.simple.SimpleFeatureBuilder;
import org.geotools.filter.identity.FeatureIdImpl;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.type.AttributeDescriptor;
import org.opengis.feature.type.GeometryType;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.stripesstuff.stripersist.Stripersist;

/**
 * edit component met ibis workflow.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
@UrlBinding("/action/feature/ibisedit")
@StrictBinding
public class IbisEditFeatureActionBean extends EditFeatureActionBean implements IbisConstants {

    private static final Log log = LogFactory.getLog(IbisEditFeatureActionBean.class);

//    @DefaultHandler
//    @Override
//    public Resolution edit() throws JSONException {
//        log.debug("hit ibis edit");
//        return super.edit();
//    }
//
//    @Override
//    public Resolution delete() throws JSONException {
//        log.debug("hit ibis delete");
//        return super.delete();
//    }
    protected String addNewFeature() throws Exception {
        String kavelID = super.addNewFeature();
        //update  terrein
        Integer terreinID = Integer.parseInt(this.getJsonFeature().optString(KAVEL_TERREIN_ID_FIELDNAME, null));
        if (terreinID != null) {
            WorkflowUtil.updateTerreinGeometry(terreinID, this.getLayer(), this.getApplication(), Stripersist.getEntityManager());
        }
        return kavelID;
    }

    /**
     * Override to not delete a feature but set workflow status to
     * {@code WorkflowStatus.archief}
     *
     * @param fid
     * @throws IOException
     * @throws Exception
     * @see WorkflowStatus
     */
    @Override
    protected void deleteFeature(String fid) throws IOException, Exception {
        Transaction transaction = new DefaultTransaction("edit");
        this.getStore().setTransaction(transaction);

        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter filter = ff.id(new FeatureIdImpl(fid));

        try {
            //this.getStore().removeFeatures(filter);
            this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.afgevoerd, filter);

            SimpleFeature original = this.getStore().getFeatures(filter).features().next();

            transaction.commit();

            Object terreinID = original.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);
            if (terreinID != null) {
                WorkflowUtil.updateTerreinGeometry((Integer) terreinID, this.getLayer(), this.getApplication(), Stripersist.getEntityManager());
            }

        } catch (Exception e) {
            transaction.rollback();
            throw e;
        } finally {
            transaction.close();
        }
    }

    /**
     * Override the method from the base class to process our workflow.
     *
     * @param fid
     * @throws Exception
     */
    @Override
    protected void editFeature(String fid) throws Exception {

        log.debug("ibis editFeature:" + fid);

        Transaction transaction = new DefaultTransaction("edit");
        this.getStore().setTransaction(transaction);

        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter filter = ff.id(new FeatureIdImpl(fid));

        List<String> attributes = new ArrayList();
        List values = new ArrayList();
        WorkflowStatus workflowStatus = null;
        for (Iterator<String> it = this.getJsonFeature().keys(); it.hasNext();) {
            String attribute = it.next();
            if (!this.getFID().equals(attribute)) {

                AttributeDescriptor ad = this.getStore().getSchema().getDescriptor(attribute);

                if (ad != null) {
                    if (!isAttributeUserEditingDisabled(attribute)) {
                        attributes.add(attribute);

                        if (ad.getType() instanceof GeometryType) {
                            String wkt = this.getJsonFeature().getString(ad.getLocalName());
                            Geometry g = null;
                            if (wkt != null) {
                                g = new WKTReader().read(wkt);
                            }
                            values.add(g);
                        } else {
                            String v = this.getJsonFeature().getString(attribute);
                            values.add(StringUtils.defaultIfBlank(v, null));
                            // remember workflow status
                            if (attribute.equals(WORKFLOW_FIELDNAME)) {
                                workflowStatus = WorkflowStatus.valueOf(v);
                            }
                        }
                    } else {
                        log.info(String.format("Attribute \"%s\" not user editable; ignoring", attribute));
                    }
                } else {
                    log.warn(String.format("Attribute \"%s\" not in feature type; ignoring", attribute));
                }
            }
        }

        log.debug(String.format("Modifying feature source #%d fid=%s, attributes=%s, values=%s",
                this.getLayer().getFeatureType().getId(),
                fid,
                attributes.toString(),
                values.toString()));

        try {

//            if (workflowStatus != null && workflowStatus == WorkflowStatus.definitief) {
            // if the new workflow status === defintief
            // store the original with status archief
            // this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.afgevoerd, filter);
            // make a copy of the original
            SimpleFeature original = this.getStore().getFeatures(filter).features().next();
            SimpleFeatureBuilder builder = new SimpleFeatureBuilder(original.getFeatureType());
            builder.init(original);
            SimpleFeature copy = builder.buildFeature(null);

            // set (new) attribute values
            for (int i = 0; i < attributes.size(); i++) {
                copy.setAttribute(attributes.get(i), values.get(i));
            }

            this.getStore().addFeatures(DataUtilities.collection(copy));
            transaction.commit();

            Object terreinID = original.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);
            if (terreinID != null) {
                WorkflowUtil.updateTerreinGeometry((Integer) terreinID, this.getLayer(), this.getApplication(), Stripersist.getEntityManager());
            }

        } catch (Exception e) {
            transaction.rollback();
            throw e;
        } finally {
            transaction.close();
        }
    }
}
