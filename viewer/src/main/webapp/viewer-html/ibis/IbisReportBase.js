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

/**
 * Shared base for the IbisReport and IbisLocationFinder components.
 *
 * @author Mark Prins
 */
Ext.define("viewer.components.IbisReportBase", {
    extend: 'viewer.components.Component',
    /**
     * An array of objects having a name (eg. c0) and a colName (eg. a_bestaatnietmeer) and an optional colAlias;
     * the visible attributes.
     */
    attributeList: [],
    // TODO would be nice to set this to 0 (== unlimited in Ext world) but the
    // flamingo featureService limits this to 1000
    MAX_ITEMS: 1000,
    //schema: null,
    appLayer: null,
    config: {
        componentLayer: null,
        actionbeanUrl: ""
    },
    // the datamodel based on the componentLayer
    // NB these globals are defined in app_overrides.jsp
    idColNaam: idFieldName,
    idVeldId: '',
    idVeldNaam: '',
    //
    terreinColNaam: planNaamFieldName,
    terreinVeldId: '',
    terreinVeldNaam: '',
    //
    terrein_geomColNaam: bboxTerreinFieldName,
    terrein_geomVeldId: '',
    terrein_geomVeldNaam: '',
    //
    gemeenteColNaam: gemeenteFieldName,
    gemeenteVeldId: '',
    gemeenteVeldNaam: '',
    //
    gemeente_geomColNaam: bboxGemeenteFieldName,
    gemeente_geomVeldId: '',
    gemeente_geomVeldNaam: '',
    //
    regioColNaam: regioFieldName,
    regioVeldId: '',
    regioVeldNaam: '',
    //
    regio_geomColNaam: bboxRegioFieldName,
    regio_geomVeldId: '',
    regio_geomVeldNaam: '',
    /**
     * constructs a ne instance.
     * @param {Object} conf
     * @returns {viewer.components.IbisReportBase}
     */
    constructor: function (conf) {
        viewer.components.IbisReportBase.superclass.constructor.call(this, conf);
        this.initConfig(conf);
        // update custom url, global var contextPath is not available until after page load
        this.config.actionbeanUrl = contextPath + '/action/ibisattributes';
        //this.schema = new Ext.data.schema.Schema();
        this.getDataModel();
        return this;
    },
    /**
     * get and initialize the datamodel.
     * @returns {undefined}
     */
    getDataModel: function () {
        var me = this;

        me.appLayer = this.viewerController.getAppLayerById(this.config.componentLayer);
        var featureService = this.config.viewerController.getAppLayerFeatureService(me.appLayer);
        featureService.loadAttributes(me.appLayer,
                function (attributes) {
                    var index = 0;
                    for (var i = 0; i < attributes.length; i++) {
                        var attribute = attributes[i];
                        if (attribute.visible) {
                            var attIndex = 0;
                            switch (attribute.name) {
                                case me.idColNaam:
                                    attIndex = index++;
                                    me.idVeldNaam = "c" + attIndex;
                                    me.idVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.idVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.regioColNaam:
                                    attIndex = index++;
                                    me.regioVeldNaam = "c" + attIndex;
                                    me.regioVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.regioVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.gemeenteColNaam:
                                    attIndex = index++;
                                    me.gemeenteVeldNaam = "c" + attIndex;
                                    me.gemeenteVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.gemeenteVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.terreinColNaam:
                                    attIndex = index++;
                                    me.terreinVeldNaam = "c" + attIndex;
                                    me.terreinVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.terreinVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.regio_geomColNaam:
                                    attIndex = index++;
                                    me.regio_geomVeldNaam = "c" + attIndex;
                                    me.regio_geomVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.regio_geomVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.gemeente_geomColNaam:
                                    attIndex = index++;
                                    me.gemeente_geomVeldNaam = "c" + attIndex;
                                    me.gemeente_geomVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.gemeente_geomVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                case me.terrein_geomColNaam:
                                    attIndex = index++;
                                    me.terrein_geomVeldNaam = "c" + attIndex;
                                    me.terrein_geomVeldId = attribute.id;
                                    me.attributeList[attIndex] = ({
                                        attrId: attribute.id,
                                        name: me.terrein_geomVeldNaam,
                                        colName: attribute.name,
                                        colAlias: (attribute.alias !== undefined ? attribute.alias : attribute.name)
                                    });
                                    break;
                                default:

                            }
                        }
                    }

                    Ext.define('terreinModel', {
                        extend: 'Ext.data.Model',
                        fields: me.attributeList,
                        //schema: me.schema,
                        schema: new Ext.data.schema.Schema(),
                        idProperty: me.idVeldNaam
                    });

                    if (!me.config.isPopup) {
                        me.createForms();
                    }
                },
                function (msg) {
                    Ext.MessageBox.alert("Attributen ophalen voor datamodel is mislukt", msg);
                });
    },
    /**
     * @returns void
     * @abstract
     */
    createForms: function () {
    },
    /*
     * Reset the terreinenStore filters and comboboxes, optionally reset the maps extent.
     *
     * @param {Boolean} resetMapExtend true to rest the map extend to the startExtent
     * @returns void
     * @abstract
     */
    resetStoreFilters: function (resetMapExtend) {
    },
    /**
     * set loading message.
     * @param {String} msg The loading message to display
     * @returns {void}
     */
    setIsLoading: function (msg) {
        if (this.config.isPopup) {
            this.popup.popupWin.setLoading(msg);
        } else {
            Ext.get(this.getContentDiv()).mask(msg);
        }
    },
    /**
     *  clear loading messages.

     */
    setDoneLoading: function () {
        if (this.config.isPopup) {
            this.popup.popupWin.setLoading(false);
        } else {
            Ext.get(this.getContentDiv()).unmask();
        }
    }
});

