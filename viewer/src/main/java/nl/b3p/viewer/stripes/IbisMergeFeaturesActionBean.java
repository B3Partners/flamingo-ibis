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

import org.locationtech.jts.geom.Geometry;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.ibis.util.IbisConstants;
import nl.b3p.viewer.ibis.util.WorkflowStatus;
import nl.b3p.viewer.ibis.util.WorkflowUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.util.Converter;
import org.geotools.data.util.GeometryTypeConverterFactory;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.type.GeometryType;
import org.opengis.filter.Filter;
import org.opengis.filter.identity.FeatureId;
import org.stripesstuff.stripersist.Stripersist;

/**
 * A workflow-supporting merge action bean for ibis.
 *
 * @author mprins
 */
@UrlBinding("/action/feature/ibismerge")
@StrictBinding
public class IbisMergeFeaturesActionBean extends MergeFeaturesActionBean implements IbisConstants {

    private static final Log log = LogFactory.getLog(IbisMergeFeaturesActionBean.class);
    private Object terreinID = null;
    private WorkflowStatus newWorkflowStatus = WorkflowStatus.definitief;

    /**
     * Force the workflow status attribute on the feature. This will handle the
     * case where the {@code extraData} attribute is a piecs of json with the
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
    protected List<FeatureId> handleStrategy(SimpleFeature featureA, SimpleFeature featureB,
            Geometry newGeom, Filter filterA, Filter filterB, SimpleFeatureStore localStore, String localStrategy) throws Exception {
        List<FeatureId> ids = new ArrayList();

        if (!this.getLayer().getName().equalsIgnoreCase(KAVEL_LAYER_NAME)) {
            throw new IllegalArgumentException("Aborting as merge layer is not " + KAVEL_LAYER_NAME);
        }

        String geomAttrName = localStore.getSchema().getGeometryDescriptor().getLocalName();
        GeometryType type = localStore.getSchema().getGeometryDescriptor().getType();
        GeometryTypeConverterFactory cf = new GeometryTypeConverterFactory();
        Converter c = cf.createConverter(Geometry.class,
                localStore.getSchema().getGeometryDescriptor().getType().getBinding(),
                null);

        if (this.getStrategy().equalsIgnoreCase("new")) {
            // archive the source feature (A)
            localStore.modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.archief, filterA);

            // update B with status afgevoerd, and a null terreinid
            String[] fields = new String[]{WORKFLOW_FIELDNAME, KAVEL_TERREIN_ID_FIELDNAME};
            Object[] values = new Object[]{WorkflowStatus.afgevoerd, null};
            localStore.modifyFeatures(fields, values, filterB);

            // create a new feature with the attributes of A but a new geom
            SimpleFeature newAfeat = DataUtilities.createFeature(featureA.getType(),
                    DataUtilities.encodeFeature(featureA, false));
            newAfeat.setAttribute(geomAttrName, c.convert(newGeom, type.getBinding()));

            // remember terreinID
            this.terreinID = newAfeat.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);

            List<SimpleFeature> newFeats = new ArrayList();
            newFeats.add(newAfeat);
            // update new feature set mut. date, workflow status etc.
            newFeats = this.handleExtraData(newFeats);
            ids = localStore.addFeatures(DataUtilities.collection(newFeats));
        } else {
            throw new IllegalArgumentException("Unknown merge strategy '" + this.getStrategy() + "', cannot merge.");
        }
        return ids;
    }

    @Override
    protected void afterMerge(List<FeatureId> ids) {
        if (this.terreinID != null) {
            WorkflowUtil.updateTerreinGeometry(Integer.parseInt(this.terreinID.toString()), this.getLayer(),
                    this.newWorkflowStatus, this.getApplication(), Stripersist.getEntityManager());
        }
    }
}
