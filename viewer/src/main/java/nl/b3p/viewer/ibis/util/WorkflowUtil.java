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
package nl.b3p.viewer.ibis.util;

import static nl.b3p.viewer.ibis.util.IbisConstants.*;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryCollection;
import com.vividsolutions.jts.geom.GeometryFactory;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.ListIterator;
import javax.persistence.EntityManager;
import nl.b3p.viewer.config.app.Application;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.services.Layer;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.Transaction;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.feature.collection.AbstractFeatureVisitor;
import org.geotools.geometry.jts.JTSFactoryFinder;
import org.opengis.feature.Feature;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;

/**
 * Utility method that come in handy hadling workflow.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
public class WorkflowUtil {

    /**
     * private constructor for utility class.
     */
    private WorkflowUtil() {
    }

    /**
     * Update the geometry of the TERREIN. Must be called after the kavels
     * transaction.
     *
     * @param terreinID
     * @param store
     * @param application
     * @param em
     * @throws IOException if an error reading the geometry of a kavel feature
     * or handling th etransaction occurs
     * @throws Exception if an error opening the GeoToolsFeatureSource occurs
     */
    public static void updateTerreinGeometry(String terreinID, SimpleFeatureStore store, Application application, EntityManager em)
            throws IOException, Exception {
        // find all "current" kavel met terreinID
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter kFilt = ff.and(
                ff.equal(
                        ff.property(KAVEL_TERREIN_ID_FIELDNAME),
                        ff.literal(terreinID)),
                ff.equal(
                        ff.property(WORKFLOW_FIELDNAME),
                        ff.literal(WorkflowStatus.definitief)
                ));
        SimpleFeatureCollection kavels = store.getFeatures(kFilt);

        // dissolve alle kavels
        final Collection<Geometry> kavelGeoms = new ArrayList();
        kavels.accepts(new AbstractFeatureVisitor() {
            @Override
            public void visit(Feature feature) {
                kavelGeoms.add((Geometry) feature.getDefaultGeometryProperty().getValue());
            }
        }, null);
        GeometryFactory factory = JTSFactoryFinder.getGeometryFactory(null);
        GeometryCollection geometryCollection = (GeometryCollection) factory.buildGeometry(kavelGeoms);
        Geometry newTerreinGeom = geometryCollection.union();

        // find terrein appLayer
        ApplicationLayer terreinAppLyr = null;
        List<ApplicationLayer> lyrs = application.loadTreeCache(em).getApplicationLayers();
        for (ListIterator<ApplicationLayer> it = lyrs.listIterator(); it.hasNext();) {
            terreinAppLyr = it.next();
            if (terreinAppLyr.getLayerName().equalsIgnoreCase(TERREIN_LAYER_NAME)) {
                break;
            }
        }
        Layer l = terreinAppLyr.getService().getLayer(TERREIN_LAYER_NAME, em);
        SimpleFeatureStore fs = (SimpleFeatureStore) l.getFeatureType().openGeoToolsFeatureSource();

        // update terrein with new geom
        Transaction transaction = new DefaultTransaction("edit-terrein-geom");
        fs.setTransaction(transaction);
        // TODO get "current"
        Filter tFilt = ff.equal(ff.property(TERREIN_ID_FIELDNAME), ff.literal(terreinID));
        String geomAttrName = fs.getSchema().getGeometryDescriptor().getLocalName();
        fs.modifyFeatures(geomAttrName, newTerreinGeom, tFilt);
        transaction.commit();
        transaction.close();
        fs.getDataStore().dispose();
    }
}
