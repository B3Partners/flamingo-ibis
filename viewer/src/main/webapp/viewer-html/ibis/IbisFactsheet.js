/*
 * Copyright (C) 2015-2016 B3Partners B.V.
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
/**
 * IBIS factsheet component.
 * @author Mark Prins
 */
Ext.define("viewer.components.IbisFactsheet", {
    extend: "viewer.components.Print",
    config: {
        title: "Factsheet",
        legendLayers: null
    },
    factsheetLayer: null,
    /** a reference to the selected feature.*/
    factsheetFeature: null,
    appLayerList: null,
    featureInfoEvent: {},
    /**
     * @constructor
     */
    constructor: function (conf) {
        viewer.components.IbisFactsheet.superclass.constructor.call(this, conf);
        factsheet__layersArrayIndexesToAppLayerIds(this.config);
        var me = this;
        var requestParams = {};
        requestParams[this.config.restriction] = true;
        requestParams["appId"] = appId;
        requestParams["layers"] = me.config.legendLayers;
        requestParams["hasConfiguredLayers"] = true;
        Ext.Ajax.request({
            url: actionBeans["layerlist"],
            params: requestParams,
            success: function (result, request) {
                me.appLayerList = Ext.JSON.decode(result.responseText);
                // register with featureinfo components
                var infoComponents = me.viewerController.getComponentsByClassName("viewer.components.FeatureInfo");
                for (var i = 0; i < infoComponents.length; i++) {
                    infoComponents[i].registerExtraLink(
                            me,
                            function (feature, appLayer) {
                                me.handleAction(feature, appLayer);
                            },
                            me.config.title,
                            [me.viewerController.getAppLayerById(me.config.factsheetLayerId)]
                            );
                }
            },
            failure: function (a, b, c) {
                Ext.MessageBox.alert("Foutmelding",
                        "Er is een onbekende fout opgetreden waardoor de lijst met kaartlagen niet kan worden weergegeven");
            }
        });

        me.createForm();
        me.registerExtraInfo(me, me.kenmerkenTerrein);
        me.registerExtraInfo(me, me.gegevensKavelPand);
        me.registerExtraInfo(me, me.ontsluitingTerrein);
        me.registerExtraInfo(me, me.beschikbarePanden);
        me.registerExtraInfo(me, me.gegevensGevestigd);
        me.registerExtraInfo(me, me.gegevensGevestigdLijst);
        me.registerExtraInfo(me, me.gegevensVerkoopOverheid);
        me.registerExtraInfo(me, me.gegevensVerkoopOntwikkelaar);

        this.config.viewerController.mapComponent.getMap().addListener(viewer.viewercontroller.controller.Event.ON_GET_FEATURE_INFO, this.onFeatureInfoStart, this);

        return this;
    },
    /**
     * track the click location.
     * @param {type} a ignored
     * @param {type} click
     */
    onFeatureInfoStart: function (a, click) {
        this.featureInfoClick = click;
    },
    /**
     * Create the print form.
     * @override
     */
    createForm: function () {
        this.printForm = Ext.create('Ext.form.Panel', {
            url: actionBeans["print"],
            visible: false,
            standardSubmit: true,
            items: [{
                    xtype: "hidden",
                    name: "params",
                    id: this.name + 'formParams'
                }]
        });
    },
    /**
     * totaal gegevens gevestigde bedrijven en personen
     */
    gegevensGevestigd: function (factsheetFeature) {
        var result = {}, key;

        for (key in factsheetFeature) {
            if (key.indexOf("aantal_bedrijven") > -1 ||
                    key.indexOf("aantal_werkzame_personen") > -1) {
                result[key] = factsheetFeature[key];
            }
        }

        if (Ext.Object.isEmpty(result)) {
            result['aantal_bedrijven_en_werkzame_personen '] = 'onbekend';
        }
        return result;
    },
    /**
     * gegevens gevestigde bedrijvigheid en grootste gevestigde bedrijven
     */
    gegevensGevestigdLijst: function (factsheetFeature) {
        var result = [];
        var DELIM = ';';
        var lijst = factsheetFeature.related_features.bedrijven;

        if (lijst.length < 1) {
            result.push('geen gevestigde bedrijven gevonden' + DELIM + '' + DELIM + '');
        } else {
            result.push('Naam' + DELIM + 'Hoofdactiviteit' + DELIM + 'Grootteklasse');
            // reverse sort lijst on grootte_klasse
            lijst = lijst.sort(function (a, b) {
                if (a.grootte_klasse < b.grootte_klasse)
                    return 1;
                if (a.grootte_klasse > b.grootte_klasse)
                    return -1;
                return 0;
            });
            for (var k = 0; k < lijst.length; k++) {
                result.push(lijst[k]['naam'] + DELIM + lijst[k]['activiteit'] + DELIM + lijst[k]['grootte_beschrijving']);
            }
        }
        return {'item': result};
    },
    gegevensKavelPand: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.indexOf("opp_geometrie") > -1 ||
                    key.indexOf("Kaveloppervlakte") > -1 ||
                    (key.lastIndexOf("status", 0) === 0) ||
                    key.indexOf("milieuzone") > -1) {
                result[key] = factsheetFeature[key];
            }
        }
        if (Ext.Object.isEmpty(result)) {
            result.gegevens = 'onbekend';
        }
        if (result['Kaveloppervlakte']) {
            result['Kaveloppervlakte'] = result['Kaveloppervlakte'] + ' ha';
        }
        return result;
    },
    beschikbarePanden: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.indexOf("panden") > -1) {
                result[key] = factsheetFeature[key];
            }
        }
        if (Ext.Object.isEmpty(result)) {
            result.panden = 'onbekend';
        }
        return result;
    },
    kenmerkenTerrein: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.indexOf("opp_bruto") > -1 ||
                    key.indexOf("opp_netto") > -1 ||
                    key.indexOf("opp_uitgeefbaar") > -1 ||
                    key.indexOf("o_milieuwet") > -1 ||
                    key.indexOf("o_milieuzone") > -1) {
                result[key] = factsheetFeature[key];
            }
        }
        if (Ext.Object.isEmpty(result)) {
            result.terrein_kenmerken = 'onbekend';
        }
        // rename o_milieuwet o_milieuwetcode
        if (result['o_milieuwet_code']) {
            result['maximaal_toegestane_hindercategorie'] = result['o_milieuwet_code'];
            delete result['o_milieuwet_code'];
        }

        return result;
    },
    /** verzamel verkoop contact gegevens van kavel. */
    gegevensVerkoopOntwikkelaar: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.lastIndexOf("c_verkoopnaam", 0) === 0) {
                result['a_'] = factsheetFeature[key];
            }
            if (key.lastIndexOf("c_verkooptelefoon", 0) === 0) {
                result['b_'] = 'T: ' + factsheetFeature[key];
            }
            if (key.lastIndexOf("c_verkoopemail", 0) === 0) {
                result['c_'] = 'e: ' + factsheetFeature[key];
            }
            if (key.lastIndexOf("c_verkoopwebsite", 0) === 0) {
                result['d_'] = 'W: ' + factsheetFeature[key];
            }
        }
        if (Ext.Object.isEmpty(result)) {
            result.contact_gegevens = 'onbekend';
        }
        return result;
    },
    /** verzamel verkoop contact gegevens van kavel. */
    gegevensVerkoopOverheid: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.lastIndexOf("c_onderhoudnaam", 0) === 0) {
                result['a_'] = factsheetFeature[key];
            }
            if (key.lastIndexOf("c_organisatie", 0) === 0) {
                result['b_'] = factsheetFeature[key];
            }
            if (key.lastIndexOf("c_onderhoudtelefoon", 0) === 0) {
                result['c_'] = 'T: ' + factsheetFeature[key];
            }
            if (key.lastIndexOf("c_onderhoudemail", 0) === 0) {
                result['d_'] = 'e: ' + factsheetFeature[key];
            }
            if (key.lastIndexOf("c_hyperlink", 0) === 0) {
                result['e_'] = 'W: ' + factsheetFeature[key];
            }
        }
        if (Ext.Object.isEmpty(result)) {
            result.contact_gegevens = 'onbekend';
        }

        return result;
    },
    /**
     * gegevens mbt. ontsluiting terrein
     */
    ontsluitingTerrein: function (factsheetFeature) {
        var result = {}, key;
        for (key in factsheetFeature) {
            if (key.indexOf("ontsluiting") > -1 ||
                    key.indexOf("internet") > -1 ||
                    key.indexOf("afstand") > -1) {
                result[key] = factsheetFeature[key];
            }

        }
        if (Ext.Object.isEmpty(result)) {
            result.ontsluiting_gegevens = 'onbekend';
        }
        return result;
    },
    /**
     *
     * @returns {Array} of legend urls to send to the backend
     */
    getLegendsToPrint: function () {
        var legendsToPrint = [];
        var me = this;
        for (var l = 0; l < me.appLayerList.length; l++) {
            this.config.viewerController.getLayerLegendInfo(
                    me.appLayerList[l],
                    function (a, b) {
                        legendsToPrint.push(b);
                    }),
                    function () {
                        Ext.MessageBox.alert("Foutmelding",
                                "Er is een onbekende fout opgetreden");
                    };
        }
        return legendsToPrint;
    },
    /**
     * @override
     * @param {type} action
     * @returns {IbisFactsheetAnonym$0.getAllProperties.properties}
     */
    getAllProperties: function (action) {
        var properties = {
            action: action,
            title: this.config.title + ' kerngegevens bedrijventerrein: ' +
                    this.factsheetFeature.a_plannaam + ', ' +
                    this.factsheetFeature.a_kernnaam,
            mailTo: "",
            xsltemplate: "ibisfactsheet.xsl",
            includeLegend: true,
            legendUrl: this.getLegendsToPrint(),
            quality: this.getMapQuality()
        };
        // Process registered extra info callbacks
        var extraInfos = new Array();
        for (var i = 0; i < this.extraInfoCallbacks.length; i++) {
            var entry = this.extraInfoCallbacks[i];
            var extraInfo = {
                className: Ext.getClass(entry.component).getName() + '.' + entry.callback.$name,
                componentName: entry.component.name,
                info: entry.callback(this.factsheetFeature)
            };
            extraInfos.push(extraInfo);
        }
        properties.extra = extraInfos;

        if (this.shouldAddOverview()) {
            var overviews = this.getOverviews();
            if (overviews.length > 0) {
                var overview = overviews[0];
                var url = overview.config.url;
                properties.overview = new Object();
                properties.overview.overviewUrl = url;
                properties.overview.extent = overview.config.lox + "," + overview.config.loy + "," + overview.config.rbx + "," + overview.config.rby;
                properties.overview.protocol = url.toLowerCase().indexOf("getmap") > 0 ? 'WMS' : 'IMAGE';
            }
        }

        return properties;
    },
    /**
     * Called from the featureinfo popup that we registered with.
     *
     * @param {type} feature selected feature
     * @param {type} appLayer
     * @returns void
     */
    handleAction: function (feature, appLayer) {
        var me = this;
        me.factsheetFeature = me.remapFeatureInfo(feature, appLayer);

        var options = {
            arrays: 1,
            featureType: feature.related_featuretypes[0].id,
            filter: feature.related_featuretypes[0].filter,
            limit: 10,
            page: 1,
            start: 0
        };

        // get related features
        this.config.viewerController.getAppLayerFeatureService(appLayer).loadFeatures(
                appLayer,
                function (result) {
                    // get related attribute names
                    var relatedAttr = Ext.Array.filter(appLayer.attributes, function (item, index, array) {
                        return (item.featureType === feature.related_featuretypes[0].id &&
                                item.visible);
                    });

                    var relatedGeom = null;

                    me.factsheetFeature.related_features = {};
                    me.factsheetFeature.related_features.bedrijven = [];

                    if (result[0]) {
                        for (var f = 0; f < result.length; f++) {
                            // copy attributes and add them to the feature
                            var relatedFactsheetFeature = {};
                            for (var i = 0; i < relatedAttr.length; i++) {
                                if (relatedAttr[i].visible && (result[f]["c" + i])) {
                                    relatedFactsheetFeature[relatedAttr[i].name] = result[f]["c" + i];
                                }
                            }
                            if (!Ext.Object.isEmpty(relatedFactsheetFeature)) {
                                me.factsheetFeature.related_features.bedrijven.push(relatedFactsheetFeature);
                            }
                        }
                    }

                    var naam = me.factsheetFeature.a_plannaam;
                    var mapvalues = me.getMapValues();
                    var properties = me.getAllProperties("savePDF");

                    // properties.subtitle = (naam) ? "Voor terrein: " + naam : "";
                    // properties.extraTekst = "Daahng dawg ipsum nizzle away ass, tellivizzle adipiscing brizzle. ";

                    if (me.factsheetFeature[appLayer.geometryAttribute]) {
                        // if we have a feature geometry use that
                        var feat = Ext.create("viewer.viewercontroller.controller.Feature",
                                {_wktgeom: me.factsheetFeature[appLayer.geometryAttribute], color: '0000FF', label: naam, strokeWidth: 4});
                        properties.bbox = feat.getExtent().toString();
                        mapvalues.geometries = [{_wktgeom: me.factsheetFeature[appLayer.geometryAttribute], color: '0000FF', label: naam, strokeWidth: 4}];
                    } else if (relatedGeom) {
                        // if we have a geometry on the related feature use that
                        var feat = Ext.create("viewer.viewercontroller.controller.Feature",
                                {_wktgeom: relatedGeom, color: 'FF00FF', label: naam});
                        properties.bbox = feat.getExtent().toString();
                        mapvalues.geometries = [{_wktgeom: relatedGeom, color: '0000FF', label: naam, strokeWidth: 4}];
                    } else {
                        // TODO geometrie of bbox ophalen voor feature?
                    }
                    // click-ed location
                    mapvalues.geometries.push({_wktgeom: 'POINT(' + this.featureInfoClick.coord.x +
                                ' ' + this.featureInfoClick.coord.y + ')',
                        color: 'FF00FF', label: 'Geselecteerde kavel', strokeWidth: 8}
                    );

                    Ext.merge(mapvalues, properties);
                    me.submitSettings(mapvalues);


                }, function (result) {
            Ext.MessageBox.alert("Ajax request failed with status " + result);
        },
                options,
                me);
    },
    /**
     * Remap attribute aliases to fields.
     * @param {Feature} feature
     * @param {AppLayer} appLayer
     * @returns {Feature}
     */
    remapFeatureInfo: function (feature, appLayer) {
        var attributes = appLayer.attributes;
        var f = Ext.clone(feature);

        for (var alias in feature) {
            // except related_features or related_featuretypes
            if (!feature.hasOwnProperty(alias) || alias === 'related_features' ||
                    alias === 'related_featuretypes' || alias === '__fid') {
                continue;
            }
            // find alias in attributes
            var attr = Ext.Array.findBy(attributes, function (attribute) {
                return (attribute.alias && attribute.alias === alias);
            });
            // add attribute with value
            if (attr) {
                f[attr.name] = feature[alias];
            }
        }
        return f;
    },
    /**
     * Called when the PDF request can be submitted.
     * @param {Object} mapvalues an object containg data for the form to be posted to the printservice
     * @override
     */
    submitSettings: function (mapvalues) {
        // console.debug("submitting mapvalues: ", mapvalues);
        Ext.getCmp(this.name + 'formParams').setValue(Ext.JSON.encode(mapvalues));
        this.printForm.submit({
            target: '_blank'
        });
    }
});
