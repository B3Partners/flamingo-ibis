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
import org.locationtech.jts.geom.Geometry;
import org.locationtech.jts.io.WKTReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.NoSuchElementException;
import javax.persistence.EntityManager;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.services.Layer;
import nl.b3p.viewer.ibis.util.WorkflowStatus;
import nl.b3p.viewer.ibis.util.WorkflowUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.Transaction;
import org.geotools.data.simple.SimpleFeatureStore;
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
 * @author mprins
 */
@UrlBinding("/action/feature/ibisedit")
@StrictBinding
public class IbisEditFeatureActionBean extends EditFeatureActionBean implements IbisConstants {

    private static final Log log = LogFactory.getLog(IbisEditFeatureActionBean.class);

    @Override
    protected String addNewFeature() throws Exception {
        String kavelID = super.addNewFeature();
        //update  terrein
        Object terreinID = this.getJsonFeature().optString(KAVEL_TERREIN_ID_FIELDNAME, null);
        WorkflowStatus status = WorkflowStatus.valueOf(this.getJsonFeature().optString(WORKFLOW_FIELDNAME, WorkflowStatus.bewerkt.name()));
        if (terreinID != null) {
            WorkflowUtil.updateTerreinGeometry(Integer.parseInt(terreinID.toString()), this.getLayer(), status, this.getApplication(), Stripersist.getEntityManager());
        }
        return kavelID;
    }

    /**
     * Override to not delete a feature but set workflow status to
     * {@code WorkflowStatus.archief}
     *
     * @param fid feature id
     * @throws IOException if any
     * @throws Exception if any
     * @see WorkflowStatus
     */
    @Override
    protected void deleteFeature(String fid) throws IOException, Exception {
        log.debug("ibis deleteFeature: " + fid);

        Transaction transaction = new DefaultTransaction("ibis_delete");
        this.getStore().setTransaction(transaction);

        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter filter = ff.id(new FeatureIdImpl(fid));

        try {
            this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.afgevoerd, filter);
            SimpleFeature original = this.getStore().getFeatures(filter).features().next();
            transaction.commit();
            Object terreinID = original.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);
            if (terreinID != null) {
                WorkflowUtil.updateTerreinGeometry(Integer.parseInt(terreinID.toString()), this.getLayer(), WorkflowStatus.afgevoerd, this.getApplication(), Stripersist.getEntityManager());
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
     * @param fid feature id
     * @throws Exception if any
     */
    @Override
    protected void editFeature(String fid) throws Exception {
        log.debug("ibis editFeature:" + fid);
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        Filter fidFilter = ff.id(new FeatureIdImpl(fid));

        List<String> attributes = new ArrayList();
        List values = new ArrayList();
        WorkflowStatus incomingWorkflowStatus = null;
        // parse json
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
                            // remember the incoming workflow status
                            if (attribute.equals(WORKFLOW_FIELDNAME)) {
                                incomingWorkflowStatus = WorkflowStatus.valueOf(v);
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
                this.getLayer().getFeatureType().getId(), fid, attributes.toString(), values.toString()));

        Transaction editTransaction = new DefaultTransaction("ibis_edit");
        this.getStore().setTransaction(editTransaction);
        try {
            if (incomingWorkflowStatus == null) {
                throw new IllegalArgumentException("Workflow status van edit feature is null, dit wordt niet ondersteund.");
            }
            SimpleFeature original = this.getStore().getFeatures(fidFilter).features().next();
            Object terreinID = original.getAttribute(KAVEL_TERREIN_ID_FIELDNAME);
            WorkflowStatus originalWorkflowStatus = WorkflowStatus.valueOf(original.getAttribute(WORKFLOW_FIELDNAME).toString());

            // make a copy of the original feature and set (new) attribute values on the copy
            SimpleFeature editedNewFeature = createCopy(original);
            for (int i = 0; i < attributes.size(); i++) {
                editedNewFeature.setAttribute(attributes.get(i), values.get(i));
            }

            Filter definitief = ff.and(
                    ff.equals(ff.property(ID_FIELDNAME), ff.literal(original.getAttribute(ID_FIELDNAME))),
                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.name()), false)
            );
            boolean definitiefExists = (this.getStore().getFeatures(definitief).size() > 0);

            Filter bewerkt = ff.and(
                    ff.equals(ff.property(ID_FIELDNAME), ff.literal(original.getAttribute(ID_FIELDNAME))),
                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.bewerkt.name()), false)
            );
            int aantalBewerkt = this.getStore().getFeatures(bewerkt).size();
            boolean bewerktExists = (aantalBewerkt > 0);

            switch (incomingWorkflowStatus) {
                case bewerkt:
                    if (originalWorkflowStatus.equals(WorkflowStatus.definitief)) {
                        // definitief -> bewerkt
                        if (bewerktExists) {
                            // delete existing bewerkt
                            this.getStore().removeFeatures(bewerkt);
                        }
                        // insert new record with original id and workflowstatus "bewerkt", leave original "definitief"
                        this.getStore().addFeatures(DataUtilities.collection(editedNewFeature));
                    } else if (originalWorkflowStatus.equals(WorkflowStatus.bewerkt)) {
                        // bewerkt -> bewerkt, overwrite, only one 'bewerkt' is allowed
                        if (aantalBewerkt > 1) {
                            log.error("Er is meer dan 1 bewerkt kavel/terrein voor " + ID_FIELDNAME + "=" + original.getAttribute(ID_FIELDNAME));
                            // more than 1 bewerkt, move them to archief
                            this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.archief, bewerkt);
                        }
                        this.getStore().modifyFeatures(attributes.toArray(new String[attributes.size()]), values.toArray(), fidFilter);
                    } else {
                        // other behaviour not documented eg. archief -> bewerkt, afgevoerd -> bewerkt
                        //  and not possible to occur in the application as only definitief and bewerkt can be edited
                        throw new IllegalArgumentException(String.format(
                                "Niet ondersteunde workflow stap van %s naar %s",
                                originalWorkflowStatus.label(),
                                incomingWorkflowStatus.label()));
                    }
                    break;
                case definitief:
                    if (definitiefExists) {
                        // check if any "definitief" exists for this id and move that to "archief"
                        this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.archief, definitief);
                    }
                    if (originalWorkflowStatus.equals(WorkflowStatus.definitief)) {
                        // if the original was "definitief" insert a new "definitief"
                        this.getStore().addFeatures(DataUtilities.collection(editedNewFeature));
                    } else if (originalWorkflowStatus.equals(WorkflowStatus.bewerkt)) {
                        // if original was "bewerkt" update this to "definitief" with the edits
                        this.getStore().modifyFeatures(attributes.toArray(new String[attributes.size()]), values.toArray(), fidFilter);
                    } else {
                        // other behaviour not documented eg. archief -> definitief, afgevoerd -> definitief
                        //  and not possible to occur in the application as only definitief and bewerkt can be edited
                        throw new IllegalArgumentException(String.format(
                                "Niet ondersteunde workflow stap van %s naar %s",
                                originalWorkflowStatus.label(),
                                incomingWorkflowStatus.label()));
                    }
                    break;
                case afgevoerd:
                    if (definitiefExists) {
                        // update any "definitief" for this id to "archief"
                        this.getStore().modifyFeatures(WORKFLOW_FIELDNAME, WorkflowStatus.archief, definitief);
                    }
                    // update original with the new/edited data including "afgevoerd"
                    this.getStore().modifyFeatures(attributes.toArray(new String[attributes.size()]), values.toArray(), fidFilter);

                    if (terreinID == null) {
                        // find any kavels related to this terrein and also set them to "afgevoerd"
                        Filter kavelFilter = ff.equals(ff.property(KAVEL_TERREIN_ID_FIELDNAME), ff.literal(original.getAttribute(ID_FIELDNAME)));
                        this.updateKavelWorkflowForTerrein(kavelFilter, WorkflowStatus.afgevoerd);
                    }
                    break;
                case archief: {
                    // not described, for now just edit the feature
                    this.getStore().modifyFeatures(attributes.toArray(new String[attributes.size()]), values.toArray(), fidFilter);
                    break;
                }
                default:
                    throw new IllegalArgumentException("Workflow status van edit feature is null, dit wordt niet ondersteund.");
            }

            editTransaction.commit();
            editTransaction.close();
            // update terrein geometry
            if (terreinID != null) {
                WorkflowUtil.updateTerreinGeometry(Integer.parseInt(terreinID.toString()), this.getLayer(), incomingWorkflowStatus, this.getApplication(), Stripersist.getEntityManager());
            }
        } catch (IllegalArgumentException | IOException | NoSuchElementException e) {
            editTransaction.rollback();
            log.error("Ibis editFeature error", e);
            throw e;
        }
    }

    /**
     * Make a copy of the original, but with a new fid.
     *
     * @param copyFrom original
     * @return copy having same attribute values as original and a new fid
     */
    private SimpleFeature createCopy(SimpleFeature copyFrom) {
        SimpleFeatureBuilder builder = new SimpleFeatureBuilder(copyFrom.getFeatureType());
        builder.init(copyFrom);
        return builder.buildFeature(null);
    }

    /**
     * Update any of the selected kavels to the given workflow.
     *
     * @param kavelFilter filter definitie
     * @param newStatus de nieuwe status
     */
    private void updateKavelWorkflowForTerrein(Filter kavelFilter, WorkflowStatus newStatus) {
        SimpleFeatureStore kavelStore = null;
        try (Transaction kavelTransaction = new DefaultTransaction("get-related-kavel-geom")) {
            EntityManager em = Stripersist.getEntityManager();
            log.debug("updating kavels voor terrein met filter: " + kavelFilter);
            // find kavel appLayer
            ApplicationLayer kavelAppLyr = null;
            List<ApplicationLayer> lyrs = this.getApplication().loadTreeCache(em).getApplicationLayers();
            for (ListIterator<ApplicationLayer> it = lyrs.listIterator(); it.hasNext();) {
                kavelAppLyr = it.next();
                if (kavelAppLyr.getLayerName().equalsIgnoreCase(KAVEL_LAYER_NAME)) {
                    break;
                }
            }
            Layer l = kavelAppLyr.getService().getLayer(KAVEL_LAYER_NAME, em);
            kavelStore = (SimpleFeatureStore) l.getFeatureType().openGeoToolsFeatureSource();
            kavelStore.setTransaction(kavelTransaction);
            // update kavels
            kavelStore.modifyFeatures(WORKFLOW_FIELDNAME, newStatus, kavelFilter);
            kavelTransaction.commit();
            kavelTransaction.close();
        } catch (Exception e) {
            log.error(String.format("Bijwerken van kavel workflow status naar %s voor terrein met %s is mislukt.",
                    newStatus, kavelFilter), e);
        } finally {
            if (kavelStore != null) {
                kavelStore.getDataStore().dispose();
            }
        }
    }

    /**
     * Check that if {@code disableUserEdit} flag is set on the attribute.
     * Override superclass behaviour for the workflow field, so that it's not
     * editable client side, but it can be set programatically in the client.
     *
     * @param attrName attribute to check
     * @return {@code true} when the configured attribute is flagged as
     * "readOnly" except when this is workflow status
     */
    @Override
    protected boolean isAttributeUserEditingDisabled(String attrName) {
        boolean isAttributeUserEditingDisabled = super.isAttributeUserEditingDisabled(attrName);

        if (attrName.equalsIgnoreCase(WORKFLOW_FIELDNAME)) {
            isAttributeUserEditingDisabled = false;
        }

        return isAttributeUserEditingDisabled;
    }

    private boolean isSameMutatiedatum(Object datum1, Object datum2) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-mm-dd");
        return sdf.format(datum1).equals(sdf.format(datum2));
    }
}
