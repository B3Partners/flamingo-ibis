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
 * IBIS IbisLocationFinder component.
 * 
 * @author Mark Prins
 */
Ext.define('viewer.components.IbisLocationFinder', {
    extend: 'viewer.components.IbisReportBase',
    step1: null,
    terreinenStore: null,
    schema: null,
    /**
     * An array of objects having a name (eg. c0) and a colName (eg. a_bestaatnietmeer) and an optional colAlias;
     * the visible attributes.
     */
    attributeList: [],
    appLayer: null,
    config: {
        title: null,
        titlebarIcon: null,
        tooltip: null,
        label: "",
        componentLayer: null,
        actionbeanUrl: ""
    },
    constructor: function (conf) {
        viewer.components.IbisLocationFinder.superclass.constructor.call(this, conf);
        this.initConfig(conf);
        // update custom url, global var contextPath is not available until after page load
        // this.config.actionbeanUrl = contextPath + '/action/ibisattributes';

        this.schema = new Ext.data.schema.Schema();
        this.getDataModel();

        return this;
    },
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
                        schema: me.schema,
                        idProperty: me.idVeldNaam
                    });

                    me.createForms();
                },
                function (msg) {
                    Ext.MessageBox.alert("Attributen ophalen voor datamodel is mislukt", msg);
                });
    },
    createForms: function () {
        Ext.get(this.getContentDiv()).mask("Bezig met ophalen van de lijst met bedrijventerreinen. <br /> Dit duurt even...");

        var me = this;
        me.terreinenStore = Ext.create('Ext.data.Store', {
            model: 'terreinModel',
            proxy: {
                type: 'ajax',
                timeout: 120000,
                actionMethods: {read: 'POST'},
                url: me.appLayer.featureService.getStoreUrl(),
                extraParams: {
                    attributesToInclude: [
                        me.idVeldId, me.regioVeldId, me.gemeenteVeldId, me.terreinVeldId,
                        me.regio_geomVeldId, me.gemeente_geomVeldId, me.terrein_geomVeldId
                    ],
                    graph: true,
                    arrays: 1
                },
                reader: {
                    type: 'json',
                    rootProperty: 'features',
                    totalProperty: 'total'
                }
            },
            autoLoad: true,
            pageSize: me.MAX_ITEMS,
            listeners: {
                load: {
                    fn: function () {
                        if (me.config.isPopup) {
                            me.popup.popupWin.setLoading(false);
                        } else {
                            Ext.get(me.getContentDiv()).unmask();
                        }
                        // set intial filters on comboboxes
                        me.resetStoreFilters(false);
                    }
                }
            }
        });

        this.step1 = Ext.create('Ext.panel.Panel', {
            title: 'Zoek gebied',
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'container',
                    html: 'Kies een regio, gemeente en/of bedrijventerrein.',
                    margin: '0 0 10 0'
                },
                {
                    xtype: 'combobox',
                    store: this.terreinenStore.collect(this.regioVeldNaam, true/*allowNull*/, true /*bypassFilter*/),
                    itemId: 'regio',
                    name: 'regio',
                    displayField: this.regioVeldNaam,
                    fieldLabel: 'Regio',
                    value: '',
                    queryMode: 'local',
                    listeners: {
                        scope: this,
                        select: this.updateRegio
                    }
                },
                {
                    xtype: 'combobox',
                    store: this.terreinenStore.collect(this.gemeenteVeldNaam, true/*allowNull*/, false /*bypassFilter*/),
                    itemId: 'gemeente',
                    name: 'gemeente',
                    displayField: this.gemeenteVeldNaam,
                    fieldLabel: 'Gemeente',
                    value: '',
                    queryMode: 'local',
                    listeners: {
                        scope: this,
                        select: this.updateGemeente
                    }
                },
                {
                    xtype: 'combobox',
                    store: this.terreinenStore,
                    itemId: 'terrein',
                    name: 'terrein',
                    displayField: this.terreinVeldNaam,
                    fieldLabel: 'Bedrijventerrein',
                    value: '',
                    queryMode: 'local',
                    listeners: {
                        scope: this,
                        select: this.updateTerrein
                    }
                },
                {
                    xtype: 'button',
                    text: 'Reset kaartuitsnede',
                    margin: '10 0',
                    handler: this.resetStoreFilters.bind(this, true)
                }
            ],
            renderTo: this.getContentDiv()
        });
    },
    /*
     * Reset the terreinenStore filters and comboboxes, optionally reset the maps extent.
     *
     * @param {Boolean} resetMapExtend true to rest the map extend to the startExtent
     * @returns void
     */
    resetStoreFilters: function (resetMapExtend) {
        this.terreinenStore.clearFilter(false);
        this.step1.getComponent("terrein").clearValue();
        this.step1.getComponent("gemeente").clearValue();
        this.step1.getComponent("regio").clearValue();

        this.step1.getComponent("regio").setStore(this.terreinenStore.collect(this.regioVeldNaam, false, true));
        this.step1.getComponent("regio").getStore().sort('field1', 'ASC');

        this.step1.getComponent("gemeente").setStore(this.terreinenStore.collect(this.gemeenteVeldNaam, false, false));
        this.step1.getComponent("gemeente").getStore().sort('field1', 'ASC');

        this.step1.getComponent("terrein").getStore().sort(this.terreinVeldNaam, 'ASC');

        if (resetMapExtend) {
            this.config.viewerController.mapComponent.getMap().zoomToExtent(this.config.viewerController.app.startExtent);
        }

    },
    /**
     * update gemeente combobox after choosing regio
     * @param {type} args
     * @returns {undefined}
     */
    updateRegio: function (combo, value, scope) {
        this.terreinenStore.clearFilter(false);

        // zoom to regio
        var data = this.terreinenStore.findRecord(this.regioVeldNaam, value.data.field1);
        var wkt = data.data[this.regio_geomVeldNaam];
        if (wkt) {
            var zoomFeat = Ext.create("viewer.viewercontroller.controller.Feature", {_wktgeom: wkt});
            this.config.viewerController.mapComponent.getMap().zoomToExtent(zoomFeat.getExtent());
        }

        // update gemeente combo
        var myfilter = Ext.create('Ext.util.Filter', {
            scope: this,
            filterFn: function (record) {
                var fieldValue = record.data[this.regioVeldNaam];
                if (fieldValue && fieldValue === value.data.field1) {
                    return true;
                }
                return false;
            }
        });

        this.terreinenStore.addFilter(myfilter);
        this.terreinenStore.sort(this.gemeenteVeldNaam, 'ASC');
        this.step1.getComponent("gemeente").setStore(this.terreinenStore.collect(this.gemeenteVeldNaam, false, false));
        this.step1.getComponent("gemeente").clearValue();
        this.step1.getComponent("terrein").clearValue();
    },
    /**
     * update terrein combobox after choosing gemeente.
     * @param {type} args
     * @returns {undefined}
     */
    updateGemeente: function (combo, value, scope) {
        this.terreinenStore.clearFilter(false);
        this.step1.getComponent("terrein").clearValue();

        // zoom to gemeente
        var data = this.terreinenStore.findRecord(this.gemeenteVeldNaam, value.data.field1);
        var wkt = data.data[this.gemeente_geomVeldNaam];
        if (wkt) {
            var zoomFeat = Ext.create("viewer.viewercontroller.controller.Feature", {_wktgeom: wkt});
            this.config.viewerController.mapComponent.getMap().zoomToExtent(zoomFeat.getExtent());
        }

        // update terrein combo
        var myfilter = Ext.create('Ext.util.Filter', {
            scope: this,
            filterFn: function (record) {
                var fieldValue = record.data[this.gemeenteVeldNaam];
                if (fieldValue && fieldValue === value.data.field1) {
                    return true;
                }
                return false;
            }
        });
        this.terreinenStore.addFilter(myfilter);
        this.terreinenStore.sort(this.terreinVeldNaam, 'ASC');
    },
    /**
     * zoom to terrein.
     * @param {type} args
     * @returns {undefined}
     */
    updateTerrein: function (combo, value, scope) {
        var filters = this.terreinenStore.getFilters().getRange();

        this.terreinenStore.clearFilter(false);

        var wkt;
        if (value.data.field1) {
            var data = this.terreinenStore.findRecord(this.terreinVeldNaam, value.data.field1);
            wkt = data.data[this.terrein_geomVeldNaam];
        } else {
            wkt = value.data[this.terrein_geomVeldNaam];
        }
        if (wkt) {
            var zoomFeat = Ext.create("viewer.viewercontroller.controller.Feature", {_wktgeom: wkt});
            this.config.viewerController.mapComponent.getMap().zoomToExtent(zoomFeat.getExtent());
        }
        this.terreinenStore.setFilters(filters);
    },
    getExtComponents: function () {
        return [this.step1.getId()];
    }
});
