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

import java.io.IOException;
import net.sourceforge.stripes.action.StrictBinding;
import net.sourceforge.stripes.action.UrlBinding;
import nl.b3p.viewer.config.app.ApplicationLayer;
import nl.b3p.viewer.config.security.Authorizations;
import nl.b3p.viewer.config.services.SimpleFeatureType;
import nl.b3p.viewer.ibis.util.IbisConstants;
import nl.b3p.viewer.util.FeatureToJson;
import nl.b3p.viewer.util.IbisFeatureToJson;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.json.JSONArray;
import org.json.JSONException;
import org.stripesstuff.stripersist.Stripersist;

/**
 * Override feature info for {@link KAVEL_LAYER_NAME} and
 * {@link TERREIN_LAYER_NAME} to make sure we only get to see the current
 * feature in the client.
 *
 * @author mprins
 */
@UrlBinding("/action/ibisfeatureinfo")
@StrictBinding
public class IbisFeatureInfoActionBean extends FeatureInfoActionBean implements IbisConstants {

    private static final Log log = LogFactory.getLog(IbisFeatureInfoActionBean.class);

    /**
     * execute the query, can be overridden in subclasses to modify behaviour
     * such as workflow. {@inheritDoc }
     */
    @Override
    protected JSONArray executeQuery(ApplicationLayer al, SimpleFeatureType ft, FeatureSource fs, Query q)
            throws IOException, JSONException, Exception {

        JSONArray features;
        if (this.getLayer().getName().equalsIgnoreCase(KAVEL_LAYER_NAME)
                || this.getLayer().getName().equalsIgnoreCase(TERREIN_LAYER_NAME)) {

            IbisFeatureToJson ftjson = new IbisFeatureToJson(
                    this.isArrays(),
                    this.isEdit(),
                    this.isGraph(),
                    this.getAttributesToInclude());

            if (Authorizations.isAppLayerWriteAuthorized(this.getApplication(), al,
                    this.getContext().getRequest(), Stripersist.getEntityManager())) {
                // workflow/edit behaviour
                log.debug("Executing custom IBIS featureinfo for write-authorized user on layer " + this.getLayer().getName());
                features = ftjson.getWorkflowJSONFeatures(al, this.getLayer().getFeatureType(), fs, q);
            } else {
                log.debug("Executing custom IBIS featureinfo for non-write-authorized user on layer " + this.getLayer().getName());
                features = ftjson.getDefinitiefJSONFeatures(al, this.getLayer().getFeatureType(), fs, q);
            }

        } else /* not a special layer in this application */ {
            log.debug("Executing default IBIS featureinfo for 'any' user on layer " + this.getLayer().getName());
            // default behaviour for any other layers
            FeatureToJson ftjson = new FeatureToJson(this.isArrays(), this.isEdit(), this.isGraph(), this.getAttributesToInclude());
            features = ftjson.getJSONFeatures(al, this.getLayer().getFeatureType(), fs, q, null, null);
        }

        return features;
    }

}
