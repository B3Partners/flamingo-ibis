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
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.Query;
import org.geotools.data.Transaction;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureStore;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.feature.collection.AbstractFeatureVisitor;
import org.geotools.geometry.jts.JTSFactoryFinder;
import org.opengis.feature.Feature;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.opengis.filter.sort.SortBy;
import org.opengis.filter.sort.SortOrder;

/**
 * Utility method that come in handy hadling workflow.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
public class WorkflowUtil implements IbisConstants {

    private static final Log log = LogFactory.getLog(WorkflowUtil.class);

    /**
     * private constructor for utility class.
     */
    private WorkflowUtil() {
    }

    /**
     * Update the geometry of the TERREIN. Must be called after the kavels
     * transaction. voor definitief terrein definitief kavels gebruiken, voor
     * bewerkt terrein definitef en bewerkt kavel genbruiken
     *
     * @param terreinID
     * @param layer kavels layer
     * @param kavelStatus
     * @param application
     * @param em
     */
    public static void updateTerreinGeometry(Integer terreinID, Layer layer, WorkflowStatus kavelStatus, Application application, EntityManager em) {
        log.debug("Updating terrein geometry for " + terreinID);
        SimpleFeatureStore terreinStore = null;
        SimpleFeatureStore kavelStore = null;
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Transaction terreinTransaction = new DefaultTransaction("edit-terrein-geom");
        Transaction kavelTransaction = new DefaultTransaction("get-kavel-geom");
        try {
            // determin whichs kavels to use for calcutating new geometry
            Filter kavelFilter = Filter.EXCLUDE;
            switch (kavelStatus) {
                case archief:
                case afgevoerd:
                case definitief:
                    // find all "definitief" kavel for terreinID
                    kavelFilter = ff.and(
                            ff.equals(ff.property(KAVEL_TERREIN_ID_FIELDNAME), ff.literal(terreinID)),
                            ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.toString()), false)
                    );
                    break;
                case bewerkt:
                    // find all "definitief" and "bewerkt" kavel for terreinID
                    kavelFilter = ff.and(
                            ff.equals(ff.property(KAVEL_TERREIN_ID_FIELDNAME), ff.literal(terreinID)),
                            ff.or(
                                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.bewerkt.toString()), false),
                                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.toString()), false)
                            ));
                    break;
                default:
            }
            log.debug("Looking for kavel with filter: " + kavelFilter);

            kavelStore = (SimpleFeatureStore) layer.getFeatureType().openGeoToolsFeatureSource();
            kavelStore.setTransaction(kavelTransaction);
            SimpleFeatureCollection kavels = kavelStore.getFeatures(kavelFilter);

            // dissolve all kavel geometries
            final Collection<Geometry> kavelGeoms = new ArrayList();
            kavels.accepts(new AbstractFeatureVisitor() {
                @Override
                public void visit(Feature feature) {
                    Geometry geom = (Geometry) feature.getDefaultGeometryProperty().getValue();
                    if (geom != null) {
                        kavelGeoms.add(geom);
                    }
                }
            }, null);
            log.debug("Kavels found: " + kavelGeoms.size());
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
            terreinStore = (SimpleFeatureStore) l.getFeatureType().openGeoToolsFeatureSource();
            terreinStore.setTransaction(terreinTransaction);

            // determine which terrein to update
            Filter terreinFilter = Filter.EXCLUDE;
            switch (kavelStatus) {
                case definitief:
                    terreinFilter = ff.and(
                            ff.equals(ff.property(ID_FIELDNAME), ff.literal(terreinID)),
                            ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.name()), false)
                    );
                    break;
                case bewerkt:
                    terreinFilter = ff.and(
                            ff.equals(ff.property(ID_FIELDNAME), ff.literal(terreinID)),
                            ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.bewerkt.name()), false)
                    );
                    break;
                case archief:
                case afgevoerd:
                default:
                // won't do anything
            }
            log.debug("Update terrein geom for kavels filtered by: " + terreinFilter);

            // update terrein with new geom
            String geomAttrName = terreinStore.getSchema().getGeometryDescriptor().getLocalName();
            terreinStore.modifyFeatures(geomAttrName, newTerreinGeom, terreinFilter);
            terreinTransaction.commit();
            terreinTransaction.close();
            kavelTransaction.close();
        } catch (Exception e) {
            log.error(String.format("Update van terrein geometrie %s is mislukt", terreinID), e);
        } finally {
            try {
                kavelTransaction.close();
                terreinTransaction.close();
            } catch (IOException io) {
                // closing transaction failed
            }
            if (terreinStore != null) {
                terreinStore.getDataStore().dispose();
            }
            if (kavelStore != null) {
                kavelStore.getDataStore().dispose();
            }
        }
    }

    /**
     * create a filter that will return the current ("actueel") feature.
     *
     * @param id value for {@link #ID_FIELDNAME}
     * @param typeName the typename eg.
     * {@code Layer layer.getFeatureType().getTypeName()}
     * @param fidOnly if you only want the fid
     * @return
     */
    public static Query actueelQuery(String id, String typeName, boolean fidOnly) {
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter filter = ff.and(
                ff.equals(ff.property(ID_FIELDNAME), ff.literal(id)),
                ff.or(
                        ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.name()), false),
                        ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.bewerkt.name()), false)
                )
        );
        log.debug("update geom for kavels filtered by: " + filter);

        Query q = new Query(typeName, filter);
        if (fidOnly) {
            // just the fid
            q.setProperties(Query.NO_PROPERTIES);
        }
        q.setSortBy(new SortBy[]{
            ff.sort(WORKFLOW_FIELDNAME, SortOrder.ASCENDING),
            ff.sort(MUTATIEDATUM_FIELDNAME, SortOrder.DESCENDING)
        });
        q.setMaxFeatures(1);
        return q;
    }
}
