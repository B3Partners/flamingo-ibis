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
package nl.b3p.viewer.util;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.app.ConfiguredAttribute;
import nl.b3p.viewer.config.services.AttributeDescriptor;
import nl.b3p.viewer.config.services.FeatureTypeRelation;
import nl.b3p.viewer.config.services.FeatureTypeRelationKey;
import nl.b3p.viewer.config.services.SimpleFeatureType;
import static nl.b3p.viewer.ibis.util.IbisConstants.ID_FIELDNAME;
import static nl.b3p.viewer.ibis.util.IbisConstants.MUTATIEDATUM_FIELDNAME;
import static nl.b3p.viewer.ibis.util.IbisConstants.WORKFLOW_FIELDNAME;
import nl.b3p.viewer.ibis.util.WorkflowStatus;
import static nl.b3p.viewer.stripes.FeatureInfoActionBean.FID;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.DataUtilities;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.feature.FeatureIterator;
import org.geotools.feature.collection.SortedSimpleFeatureCollection;
import org.geotools.filter.text.cql2.CQL;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.opengis.filter.expression.Function;
import org.opengis.filter.sort.SortBy;
import org.opengis.filter.sort.SortOrder;

/**
 * This is a custom version of {@link FeatureToJson}.
 *
 * @author Mark Prins
 */
public class IbisFeatureToJson {

    private static final Log log = LogFactory.getLog(IbisFeatureToJson.class);

    public static final int MAX_FEATURES = 1000;
    private boolean arrays = false;
    private boolean edit = false;
    private boolean graph = false;
    private List<Long> attributesToInclude = new ArrayList<>();
    private static final int TIMEOUT = 5000;

    public IbisFeatureToJson(boolean arrays, boolean edit, boolean graph, List<Long> attributesToInclude) {
        this.arrays = arrays;
        this.edit = edit;
        this.graph = graph;
        this.attributesToInclude = attributesToInclude;
    }

    /**
     * Get the features as JSONArray with the given params.
     *
     * @param al The application layer(if there is a application layer)
     * @param ft The featuretype that must be used to get the features
     * @param fs The featureSource
     * @param q The query
     * @return JSONArray with features.
     * @throws IOException if any
     * @throws JSONException if any
     * @throws Exception if any
     */
    public JSONArray getWorkflowJSONFeatures(ApplicationLayer al, SimpleFeatureType ft, FeatureSource fs, Query q) throws IOException, JSONException, Exception {
        log.debug("Ophalen workflow json features met: " + q);
        Map<String, String> attributeAliases = new HashMap<>();
        if (!edit) {
            for (AttributeDescriptor ad : ft.getAttributes()) {
                if (ad.getAlias() != null) {
                    attributeAliases.put(ad.getName(), ad.getAlias());
                }
            }
        }
        List<String> propertyNames;
        if (al != null) {
            propertyNames = this.setPropertyNames(al, q, ft, edit);
        } else {
            propertyNames = new ArrayList<>();
            for (AttributeDescriptor ad : ft.getAttributes()) {
                propertyNames.add(ad.getName());
            }
        }
        boolean shouldRemoveID_FIELDbeforeJSONify = false;
        if (!propertyNames.contains(ID_FIELDNAME)) {
            shouldRemoveID_FIELDbeforeJSONify = propertyNames.add(ID_FIELDNAME);
        }
        q.setPropertyNames(propertyNames);

        Integer start = q.getStartIndex();
        if (start == null) {
            start = 0;
        }
        boolean offsetSupported = fs.getQueryCapabilities().isOffsetSupported();
        //if offSet is not supported, get more features (start + the wanted features)
        if (!offsetSupported && q.getMaxFeatures() < MAX_FEATURES) {
            q.setMaxFeatures(q.getMaxFeatures() + start);
        }

        JSONArray features = new JSONArray();
        try {
            // workflow handling
            SimpleFeatureCollection feats = (SimpleFeatureCollection) fs.getFeatures(q);
            // get a list of unique ID_FIELDNAME
            FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
            Function uniq = ff.function("Collection_Unique", ff.property(ID_FIELDNAME));
            Set<Object> idlist = (Set<Object>) uniq.evaluate(feats);

            SimpleFeatureCollection inMem = DataUtilities.collection(feats);
            List<SimpleFeature> actueel = new ArrayList<>();

            // this works as follows:
            //  - filter out all definitief and bewerkt for a certain id
            //  - sort that set ascending by WORKFLOW_FIELDNAME
            //  - sort that set descending by MUTATIEDATUM_FIELDNAME
            //  - get the first feature from the collection
            // which should be the youngest bewerkt or definitief
            SimpleFeature actFeat;
            SortedSimpleFeatureCollection sorted;
            Filter filter;
            SortBy[] sortBy = new SortBy[]{
                ff.sort(WORKFLOW_FIELDNAME, SortOrder.ASCENDING),
                ff.sort(MUTATIEDATUM_FIELDNAME, SortOrder.DESCENDING)
            };
            if (idlist != null && idlist.size() > 0) {
                for (Object id : idlist) {
                    filter = ff.and(
                            ff.equals(ff.property(ID_FIELDNAME), ff.literal(id)),
                            ff.or(
                                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.name()), false),
                                    ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.bewerkt.name()), false)
                            ));
                    sorted = new SortedSimpleFeatureCollection(inMem.subCollection(filter), sortBy);
                    log.debug("aantal gevonden: " + sorted.size());
                    if (log.isDebugEnabled()) {
                        SimpleFeatureIterator sfi = sorted.features();
                        while (sfi.hasNext()) {
                            log.debug("gevonden feature: " + sfi.next());
                        }
                    }
                    actFeat = DataUtilities.first(sorted);
                    log.debug("actuele feature: " + actFeat);
                    if (actFeat != null) {
                        actueel.add(actFeat);
                    }
                }

                int featureIndex = 0;

                if (shouldRemoveID_FIELDbeforeJSONify) {
                    propertyNames.remove(ID_FIELDNAME);
                }

                for (SimpleFeature feature : actueel) {
                    /* if offset not supported and there are more features returned then
                     * only get the features after index >= start*/
                    if (offsetSupported || featureIndex >= start) {
                        JSONObject j = this.toJSONFeature(new JSONObject(), feature, ft, al, propertyNames, attributeAliases, 0);
                        features.put(j);
                    }
                    featureIndex++;
                }
            }
        } finally {
            fs.getDataStore().dispose();
        }
        return features;
    }

    /**
     * Get the features as JSONArray with the given params
     *
     * @param al The application layer(if there is a application layer)
     * @param ft The featuretype that must be used to get the features
     * @param fs The featureSource
     * @param q The query
     * @return JSONArray with features.
     * @throws IOException if any
     * @throws JSONException if any
     * @throws Exception if any
     */
    public JSONArray getDefinitiefJSONFeatures(ApplicationLayer al, SimpleFeatureType ft, FeatureSource fs, Query q)
            throws IOException, JSONException, Exception {
        log.debug("Ophalen definitief json features met: " + q);
        Map<String, String> attributeAliases = new HashMap<>();
        if (!edit) {
            for (AttributeDescriptor ad : ft.getAttributes()) {
                if (ad.getAlias() != null) {
                    attributeAliases.put(ad.getName(), ad.getAlias());
                }
            }
        }
        List<String> propertyNames;
        if (al != null) {
            propertyNames = this.setPropertyNames(al, q, ft, edit);
        } else {
            propertyNames = new ArrayList<>();
            for (AttributeDescriptor ad : ft.getAttributes()) {
                propertyNames.add(ad.getName());
            }
        }

        Integer start = q.getStartIndex();
        if (start == null) {
            start = 0;
        }
        boolean offsetSupported = fs.getQueryCapabilities().isOffsetSupported();
        //if offSet is not supported, get more features (start + the wanted features)
        if (!offsetSupported && q.getMaxFeatures() < MAX_FEATURES) {
            q.setMaxFeatures(q.getMaxFeatures() + start);
        }

        JSONArray features = new JSONArray();
        try {
            // only get 'definitief'
            SimpleFeatureCollection feats = (SimpleFeatureCollection) fs.getFeatures(q);
            FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
            Filter definitief = ff.equal(ff.property(WORKFLOW_FIELDNAME), ff.literal(WorkflowStatus.definitief.name()), false);
            SimpleFeatureCollection defSFC = DataUtilities.collection(feats.subCollection(definitief));

            int featureIndex = 0;
            SimpleFeature feature;
            try (SimpleFeatureIterator defs = defSFC.features()) {
                while (defs.hasNext()) {
                    feature = defs.next();
                    /* if offset not supported and there are more features returned then
                     * only get the features after index >= start*/
                    if (offsetSupported || featureIndex >= start) {
                        JSONObject j = this.toJSONFeature(new JSONObject(), feature, ft, al, propertyNames, attributeAliases, 0);
                        features.put(j);
                    }
                    featureIndex++;
                }
            }
        } finally {
            fs.getDataStore().dispose();
        }
        return features;
    }

    private JSONObject toJSONFeature(JSONObject j, SimpleFeature f, SimpleFeatureType ft, ApplicationLayer al, List<String> propertyNames, Map<String, String> attributeAliases, int index)
            throws JSONException, Exception {
        if (arrays) {
            for (String name : propertyNames) {
                Object value = f.getAttribute(name);
                j.put("c" + index++, formatValue(value));
            }
        } else {
            for (String name : propertyNames) {
                String alias = null;
                if (attributeAliases != null) {
                    alias = attributeAliases.get(name);
                }
                j.put(alias != null ? alias : name, formatValue(f.getAttribute(name)));
            }
        }
        //if edit and not yet set
        // removed check for edit variable here because we need to compare features in edit component and feature info attributes
        // was if(edit && j.optString(FID,null)==null) {
        if (j.optString(FID, null) == null) {
            String id = f.getID();
            j.put(FID, id);
        }
        if (ft.hasRelations()) {
            j = populateWithRelatedFeatures(j, f, ft, al, index);
        }
        return j;
    }

    /**
     * Populate the json object with related featues
     */
    private JSONObject populateWithRelatedFeatures(JSONObject j, SimpleFeature feature, SimpleFeatureType ft, ApplicationLayer al, int index) throws Exception {
        if (ft.hasRelations()) {
            JSONArray related_featuretypes = new JSONArray();
            for (FeatureTypeRelation rel : ft.getRelations()) {
                boolean isJoin = rel.getType().equals(FeatureTypeRelation.JOIN);
                if (isJoin) {
                    FeatureSource foreignFs = rel.getForeignFeatureType().openGeoToolsFeatureSource(TIMEOUT);
                    FeatureIterator<SimpleFeature> foreignIt = null;
                    try {
                        Query foreignQ = new Query(foreignFs.getName().toString());
                        //create filter
                        Filter filter = createFilter(feature, rel);
                        if (filter == null) {
                            continue;
                        }
                        //if join only get 1 feature
                        foreignQ.setMaxFeatures(1);
                        foreignQ.setFilter(filter);
                        //set propertynames
                        List<String> propertyNames;
                        if (al != null) {
                            propertyNames = setPropertyNames(al, foreignQ, rel.getForeignFeatureType(), edit);
                        } else {
                            propertyNames = new ArrayList<>();
                            for (AttributeDescriptor ad : rel.getForeignFeatureType().getAttributes()) {
                                propertyNames.add(ad.getName());
                            }
                        }
                        if (propertyNames.isEmpty()) {
                            // if there are no properties to retrieve just get out
                            continue;
                        }
                        //get aliases
                        Map<String, String> attributeAliases = new HashMap<>();
                        if (!edit) {
                            for (AttributeDescriptor ad : rel.getForeignFeatureType().getAttributes()) {
                                if (ad.getAlias() != null) {
                                    attributeAliases.put(ad.getName(), ad.getAlias());
                                }
                            }
                        }
                        //Get Feature and populate JSON object with the values.
                        foreignIt = foreignFs.getFeatures(foreignQ).features();
                        while (foreignIt.hasNext()) {
                            SimpleFeature foreignFeature = foreignIt.next();
                            //join it in the same json
                            j = toJSONFeature(j, foreignFeature, rel.getForeignFeatureType(), al, propertyNames, attributeAliases, index);
                        }
                    } finally {
                        if (foreignIt != null) {
                            foreignIt.close();
                        }
                        foreignFs.getDataStore().dispose();
                    }
                } else {
                    Filter filter = createFilter(feature, rel);
                    if (filter == null) {
                        continue;
                    }
                    JSONObject related_ft = new JSONObject();
                    related_ft.put("filter", CQL.toCQL(filter));
                    related_ft.put("id", rel.getForeignFeatureType().getId());
                    related_featuretypes.put(related_ft);
                }
            }
            if (related_featuretypes.length() > 0) {
                j.put("related_featuretypes", related_featuretypes);
            }
        }
        return j;
    }

    HashMap<Long, List<String>> propertyNamesQueryCache = new HashMap<>();
    HashMap<Long, Boolean> haveInvisiblePropertiesCache = new HashMap<>();
    HashMap<Long, List<String>> propertyNamesReturnCache = new HashMap<>();

    /**
     * Get the propertynames and add the needed propertynames to the query.
     */
    private List<String> setPropertyNames(ApplicationLayer appLayer, Query q, SimpleFeatureType sft, boolean edit) {
        List<String> propertyNames = new ArrayList<>();
        boolean haveInvisibleProperties = false;
        if (propertyNamesQueryCache.containsKey(sft.getId())) {
            haveInvisibleProperties = haveInvisiblePropertiesCache.get(sft.getId());
            if (haveInvisibleProperties) {
                q.setPropertyNames(propertyNamesQueryCache.get(sft.getId()));
            }
            return propertyNamesReturnCache.get(sft.getId());
        } else {
            for (ConfiguredAttribute ca : appLayer.getAttributes(sft)) {
                if ((!edit && !graph && ca.isVisible()) || (edit && ca.isEditable()) || (graph && attributesToInclude.contains(ca.getId()))) {
                    propertyNames.add(ca.getAttributeName());
                } else {
                    haveInvisibleProperties = true;
                }
            }
            haveInvisiblePropertiesCache.put(sft.getId(), haveInvisibleProperties);
            propertyNamesReturnCache.put(sft.getId(), propertyNames);
            propertyNamesQueryCache.put(sft.getId(), propertyNames);
            if (haveInvisibleProperties) {
                // By default Query retrieves Query.ALL_NAMES
                // Query.NO_NAMES is an empty String array
                q.setPropertyNames(propertyNames);
                // If any related featuretypes are set, add the leftside names in the query
                // don't add them to propertynames, maybe they are not visible
                if (sft.getRelations() != null) {
                    List<String> withRelations = new ArrayList<>();
                    withRelations.addAll(propertyNames);
                    for (FeatureTypeRelation ftr : sft.getRelations()) {
                        if (ftr.getRelationKeys() != null) {
                            for (FeatureTypeRelationKey key : ftr.getRelationKeys()) {
                                if (!withRelations.contains(key.getLeftSide().getName())) {
                                    withRelations.add(key.getLeftSide().getName());
                                }
                            }
                        }
                    }
                    propertyNamesQueryCache.put(sft.getId(), withRelations);
                    q.setPropertyNames(withRelations);
                }
            }
            propertyNamesReturnCache.put(sft.getId(), propertyNames);
            return propertyNames;
        }
    }

    private final DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");

    private Object formatValue(Object value) {
        if (value instanceof Date) {
            // JSON has no date type so format the date as it is used for
            // display, not calculation
            return dateFormat.format((Date) value);
        } else {
            return value;
        }
    }

    private Filter createFilter(SimpleFeature feature, FeatureTypeRelation rel) {
        FilterFactory2 ff = CommonFactoryFinder.getFilterFactory2();
        List<Filter> filters = new ArrayList<>();
        for (FeatureTypeRelationKey key : rel.getRelationKeys()) {
            AttributeDescriptor rightSide = key.getRightSide();
            AttributeDescriptor leftSide = key.getLeftSide();
            Object value = feature.getAttribute(leftSide.getName());
            if (value == null) {
                continue;
            }
            if (AttributeDescriptor.GEOMETRY_TYPES.contains(rightSide.getType())
                    && AttributeDescriptor.GEOMETRY_TYPES.contains(leftSide.getType())) {
                filters.add(ff.not(ff.isNull(ff.property(rightSide.getName()))));
                filters.add(ff.intersects(ff.property(rightSide.getName()), ff.literal(value)));
            } else {
                filters.add(ff.equals(ff.property(rightSide.getName()), ff.literal(value)));
            }
        }
        if (filters.size() > 1) {
            return ff.and(filters);
        } else if (filters.size() == 1) {
            return filters.get(0);
        } else {
            return null;
        }
    }
}
