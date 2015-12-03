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
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.ibis.util.IbisConstants;
import static nl.b3p.viewer.ibis.util.IbisConstants.KAVEL_TERREIN_ID_FIELDNAME;
import static nl.b3p.viewer.ibis.util.IbisConstants.WORKFLOW_FIELDNAME;
import nl.b3p.viewer.ibis.util.WorkflowStatus;
import nl.b3p.viewer.ibis.util.WorkflowUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.util.Converter;
import org.geotools.util.GeometryTypeConverterFactory;
import org.json.JSONException;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.type.AttributeDescriptor;
import org.opengis.feature.type.GeometryType;
import org.opengis.filter.Filter;
import org.opengis.filter.identity.FeatureId;
import org.json.JSONObject;
import org.stripesstuff.stripersist.Stripersist;

/**
 * A workflow-supporting split action bean for ibis.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
@UrlBinding("/action/feature/ibissplit")
@StrictBinding
public class IbisSplitFeatureActionBean extends SplitFeatureActionBean implements IbisConstants {
    
    private static final Log log = LogFactory.getLog(IbisSplitFeatureActionBean.class);
    
    private Object terreinID = null;
    private WorkflowStatus newWorkflowStatus = WorkflowStatus.definitief;

    /**
     * force the workflow status attribute on the feature. This will handle the
     * case where the {@code extraData} attribute is a piece of json with the
     * workflow, eg
     * {@code {workflow_status:'afgevoerd',datum_mutatie:'2015-12-01Z00:00'}}.
     *
     * @param features A list of features to be modified
     * @return the list of modified features that are about to be committed to
     * the datastore
     *
     * @throws JSONException if json parsing failed
     */
    @Override
    protected List<SimpleFeature> handleExtraData(List<SimpleFeature> features) throws JSONException {
        JSONObject json = new JSONObject(this.getExtraData());
        Iterator items = json.keys();
        while (items.hasNext()) {
            String key = (String) items.next();
            for (SimpleFeature f : features) {
                log.debug(String.format("Setting value: %s for attribute: %s on feature %s", json.get(key), key, f.getID()));
                f.setAttribute(key, json.get(key));
                if (key.equalsIgnoreCase(WORKFLOW_FIELDNAME)) {
                    newWorkflowStatus = WorkflowStatus.valueOf(json.getString(key));
                }
            }
        }
        return features;
    }

    /**
     * Overrides deleting features by archiving them instead. {@inheritDoc}
     */
    @Override
    protected List<FeatureId> handleStrategy(SimpleFeature feature, List<? extends Geometry> geoms,
            Filter filter, SimpleFeatureStore localStore, String localStrategy) throws Exception {
        
        List<SimpleFeature> newFeats = new ArrayList();
        GeometryTypeConverterFactory cf = new GeometryTypeConverterFactory();
        Converter c = cf.createConverter(Geometry.class, localStore.getSchema().getGeometryDescriptor().getType().getBinding(), null);
        GeometryType type = localStore.getSchema().getGeometryDescriptor().getType();
        String geomAttribute = localStore.getSchema().getGeometryDescriptor().getLocalName();
        
        boolean firstFeature = true;
        int newID = (int) (new Date().getTime() / 1000);
        for (Geometry newGeom : geoms) {
            log.debug("Creating feature with geom: " + newGeom.getLength());
            if (firstFeature) {
//                if (localStrategy.equalsIgnoreCase("replace")) {
//                    // IBIS MUST USE add STRATEGY
//                    // use first/largest geom to update existing feature geom
//                    feature.setAttribute(geomAttribute, c.convert(newGeom, type.getBinding()));
//                    feature = this.handleExtraData(feature);
//                    Object[] attributevalues = feature.getAttributes().toArray(new Object[feature.getAttributeCount()]);
//                    AttributeDescriptor[] attributes = feature.getFeatureType().getAttributeDescriptors()
//                            .toArray(new AttributeDescriptor[feature.getAttributeCount()]);
//                    localStore.modifyFeatures(attributes, attributevalues, filter);
//                    firstFeature = false;
//                    continue;
//                } else
                if (localStrategy.equalsIgnoreCase("add")) {
                    // existing feature to "archief"
                    feature.setAttribute(WORKFLOW_FIELDNAME, WorkflowStatus.archief);
                    Object[] attributevalues = feature.getAttributes().toArray(new Object[feature.getAttributeCount()]);
                    AttributeDescriptor[] attributes = feature.getFeatureType().getAttributeDescriptors()
                            .toArray(new AttributeDescriptor[feature.getAttributeCount()]);
                    localStore.modifyFeatures(attributes, attributevalues, filter);
                    // remember terreinID
                    this.terreinID = feature.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);

                    // create the first new feature
                    SimpleFeature newFeat = DataUtilities.createFeature(feature.getType(),
                            DataUtilities.encodeFeature(feature, false));
                    newFeat.setAttribute(geomAttribute, c.convert(newGeom, type.getBinding()));
                    newFeats.add(newFeat);
                    
                    firstFeature = false;
                    continue;
                } else {
                    throw new IllegalArgumentException("Unknown or unsupported strategy '" + localStrategy + "', cannot split.");
                }
            }
            // create + add new features using the rest of the geometries
            SimpleFeature newFeat = DataUtilities.createFeature(feature.getType(),
                    DataUtilities.encodeFeature(feature, false));
            newFeat.setAttribute(geomAttribute, c.convert(newGeom, type.getBinding()));
            newFeat.setAttribute(ID_FIELDNAME, newID++);
            log.debug("created new feature with id: " + newID);
            newFeats.add(newFeat);
        }
        // update specified fields on the new features
        newFeats = this.handleExtraData(newFeats);
        return localStore.addFeatures(DataUtilities.collection(newFeats));
    }

    /**
     * Called after the split is completed and commit was performed. update
     * terrein geometry
     */
    @Override
    protected void afterSplit() {
        if (this.terreinID != null) {
            WorkflowUtil.updateTerreinGeometry((Integer) this.terreinID, this.getLayer(),
                    this.newWorkflowStatus, this.getApplication(), Stripersist.getEntityManager());
        }
    }
}
