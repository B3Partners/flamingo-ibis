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
 * IBIS Report component.
 * 
 * @author <a href="mailto:geertplaisier@b3partners.nl">Geert Plaisier</a>
 * @author <a href="mailto:markprins@b3partners.nl">Mark Prins</a>
 */
Ext.define("viewer.components.IbisReport", {
    extend: "viewer.components.Component",
    requires: ['viewer.components.GridPanel'],
    deActivatedTools: [],
    toolMapClick: null,
    step1: null,
    step2: null,
    step3: null,
    step4: null,
    form: null,
    terreinenStore: null,
    reportdataStore: null,
    idColNaam: 'id',
    idVeldId: '',
    idVeldNaam: '',
    //
    terreinColNaam: 'a_plannaam',
    terreinVeldId: '',
    terreinVeldNaam: '',
    //
    terrein_geomColNaam: 'bbox_terrein',
    terrein_geomVeldId: '',
    terrein_geomVeldNaam: '',
    //
    gemeenteColNaam: 'naam',
    gemeenteVeldId: '',
    gemeenteVeldNaam: '',
    //
    gemeente_geomColNaam: 'bbox_gemeente',
    gemeente_geomVeldId: '',
    gemeente_geomVeldNaam: '',
    //
    regioColNaam: 'vvr_naam',
    regioVeldId: '',
    regioVeldNaam: '',
    //
    regio_geomColNaam: 'bbox_regio',
    regio_geomVeldId: '',
    regio_geomVeldNaam: '',
    // TODO would be nice to set this to 0 (== unlimited in Ext world) but the
    // flamingo featureService limits this to 1000
    MAX_ITEMS: 1000,
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
        bedrijvenTerreinLayer: null,
        bedrijvenKavelsLayer: null,
        actionbeanUrl: ""
    },
    constructor: function (conf) {
        viewer.components.IbisReport.superclass.constructor.call(this, conf);
        this.initConfig(conf);
        // update custom url, global var contextPath is not available until after page load
        this.config.actionbeanUrl = contextPath + "/action/ibisattributes";

        Ext.define('reportdataModel', {
            extend: 'Ext.data.Model',
            fields: []
        });


        this.schema = new Ext.data.schema.Schema();
        this.getDataModel();
        if (this.config.isPopup) {
            this.renderButton();
        } else {
            //this.createForms();
        }
        return this;
    },
    renderButton: function () {
        var me = this;
        this.superclass.renderButton.call(this, {
            text: me.config.title,
            icon: me.config.titlebarIcon,
            tooltip: me.config.tooltip,
            label: me.config.label,
            handler: function () {
                if (!me.form) {
                    me.createForms();
                }
                me.showWindow();
            }
        });
    },
    getDataModel: function () {
        var me = this;
        me.appLayer = this.viewerController.getAppLayerById(this.config.bedrijvenTerreinLayer);
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

                    if (!me.config.isPopup) {
                        me.createForms();
                    }
                },
                function (msg) {
                    Ext.MessageBox.alert("Attributen ophalen voor datamodel is mislukt", msg);
                });
    },
    createForms: function () {
        // to select a bedrijventerrein on the map
        this.toolMapClick = this.config.viewerController.mapComponent.createTool({
            type: viewer.viewercontroller.controller.Tool.MAP_CLICK,
            id: this.name + "toolMapClick",
            handler: {
                fn: this.mapClicked,
                scope: this
            },
            viewerController: this.config.viewerController
        });

        //var appLayer = this.viewerController.getAppLayerById(this.config.bedrijvenTerreinLayer);

        if (this.config.isPopup) {
            this.popup.popupWin.setLoading("Bezig met ophalen van de lijst met bedrijven terreinen. <br /> Dit duurt even...");
        } else {
            Ext.get(this.getContentDiv()).mask("Bezig met ophalen van de lijst met bedrijventerreinen. <br /> Dit duurt even...");
        }

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
            title: 'Stap 1. Kies gebied',
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
                    text: 'Reset selectie en kaartuitsnede',
                    margin: '10 0',
                    handler: this.resetStoreFilters.bind(this, true)
                },
                {
                    xtype: 'container',
                    html: 'Of kies een terrein in de kaart (klik op kaart).',
                    margin: '5 0 0 0'
                },
                {
                    xtype: 'button',
                    text: 'Activeer klik op kaart',
                    handler: this.activateMapClick.bind(this),
                    margin: '5 0'
                }
            ],
            dockedItems: this.getBottomBar(1)
        });
        this.step2 = Ext.create('Ext.panel.Panel', {
            title: 'Stap 2. Type rapport kiezen',
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            defaults: {
                labelWidth: 160,
                labelStyle: 'color: #000000;'
            },
            items: [
                {
                    xtype: 'container',
                    html: 'Selecteer het type rapport en eventuele opties',
                    margin: '0 0 10 0'
                },
                {
                    xtype: "combobox",
                    itemId: 'reportType',
                    name: 'reportType',
                    fieldLabel: 'Type rapport',
                    store: [
                        ['INDIVIDUAL', 'Individuele gegevens'],
                        ['AGGREGATED', 'Geaggregeerde gegevens'],
                        ['ISSUE', 'Uitgifte']
                    ],
                    value: 'INDIVIDUAL',
                    listeners: {
                        change: this.reportTypeChange.bind(this)
                    }
                },
                {
                    xtype: "combobox",
                    itemId: 'aggregationLevel',
                    name: 'aggregationLevel',
                    fieldLabel: 'Aggregatie niveau',
                    store: [
//                        ['ASAREA', 'Gelijk aan gebied'],
//                        ['MOREDETAIL', 'Meer detail']
                        ['REGIO', 'Regio'],
                        ['GEMEENTE', 'Gemeente'],
                        ['TERREIN', 'Terrein']
                    ],
                    value: 'REGIO',
                    hidden: true
                },
                {
                    xtype: 'datefield',
                    itemId: 'fromDate',
                    fieldLabel: 'Tijdvak datum van',
                    name: 'fromDate',
                    anchor: '100%',
                    hidden: true
                },
                {
                    xtype: 'datefield',
                    itemId: 'toDate',
                    fieldLabel: 'Tijdvak datum tot',
                    name: 'toDate',
                    hidden: true
                },
                {
                    xtype: "combobox",
                    itemId: 'aggregationLevelDate',
                    name: 'aggregationLevelDate',
                    fieldLabel: 'Aggregatie niveau tijdvak',
                    store: [
                        ['NONE', 'Geen'],
                        ['MONTH', 'Maand']
                    ],
                    value: 'NONE',
                    hidden: true
                }
            ],
            dockedItems: this.getBottomBar(2)
        });

        var allVariables = [];
        for (var i = 0; i < this.appLayer.attributes.length; i++) {
            var attr = this.appLayer.attributes[i];
            // skip geometry fields
            if (attr.type !== "geometry"
                    && attr.type !== "multipolygon" && attr.type !== "polygon"
                    && attr.type !== "point" && attr.type !== "multipoint"
                    && attr.type !== "linestring" && attr.type !== "multilinestring") {

                allVariables.push({
                    xtype: 'checkbox',
                    aggregationType: (this.config[attr.id] === true),
                    boxLabel: (attr.alias !== undefined ? attr.alias : attr.name),
                    name: 'attrNames',
                    inputValue: attr.name
                });
            }
        }

        var aggregationVariables = [];
        for (var i = 0; i < allVariables.length; i++) {
            if (allVariables[i].aggregationType) {
                aggregationVariables.push(allVariables[i]);
            }
        }

        this.step3 = Ext.create('Ext.panel.Panel', {
            title: 'Stap 3. Kies variabelen',
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            autoScroll: true,
            items: [
                {
                    xtype: 'container',
                    html: 'Kies de variabelen die u in het rapport wilt hebben.',
                    margin: '0 0 10 0'
                },
                {
                    xtype: 'container',
                    itemId: 'allVariables',
                    items: allVariables
                },
                {
                    xtype: 'container',
                    itemId: 'aggregationVariables',
                    items: aggregationVariables,
                    hidden: true
                },
                {
                    xtype: 'container',
                    itemId: 'issueVariables',
                    html: 'Voor het uitgifte rapport kunt u geen variabelen kiezen',
                    hidden: true
                }
            ],
            dockedItems: this.getBottomBar(3)
        });

        this.step4 = Ext.create('Ext.grid.Panel', {
            title: 'Resultaat',
            store: null,
            forceFit: true,
            dockedItems: [{
                    xtype: 'toolbar',
                    docked: 'bottom',
                    items: [{
                            xtype: 'button',
                            flex: 1,
                            text: 'Download data (Excel)',
                            id: this.name + "downloadBtn",
                            disabled: true,
                            handler: function (btn, evt) {
                                btn.up('grid').downloadExcelXml(
                                        true,
                                        me.step2.getComponent('reportType').getRawValue() + ' rapportage '
                                        + me.step1.getComponent('terrein').getRawValue()
                                        + ' ' + me.step1.getComponent('gemeente').getRawValue()
                                        + ' ' + me.step1.getComponent('regio').getRawValue(),
                                        me.config.actionbeanUrl, {
                                            download: 1,
                                            mimetype: 'application/vnd.ms-excel',
                                            filename: "ibisrapportage.xls",
                                            appLayer: me.config.bedrijvenTerreinLayer,
                                            application: me.config.viewerController.app.id
                                        });
                            }
                        }]
                }]
        });

        this.form = new Ext.form.FormPanel({
            frame: false,
            border: 0,
            width: '100%',
            height: '100%',
            defaults: {
                // applied to each contained panel
                bodyPadding: 15
            },
            layout: {
                type: 'accordion',
                titleCollapse: true,
                animate: true,
                activeOnTop: false
            },
            items: [this.step1, this.step2, this.step3, this.step4],
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

        this.step2.getComponent('aggregationLevel').store.clearFilter();
        this.step2.getComponent("aggregationLevel").setValue('REGIO');
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

        // update aggregation levels
        this.step2.getComponent("aggregationLevel").setValue('REGIO');
        this.step2.getComponent('aggregationLevel').store.clearFilter();
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

        // update aggregation levels
        var myfilter = Ext.create('Ext.util.Filter', {
            scope: this,
            filterFn: function (record) {
                // filter out REGIO
                if (record.data.field1 !== 'REGIO') {
                    return true;
                }
                return false;
            }
        });
        this.step2.getComponent('aggregationLevel').store.clearFilter();
        this.step2.getComponent('aggregationLevel').store.addFilter(myfilter);
        this.step2.getComponent("aggregationLevel").setValue('GEMEENTE');

    },
    /**
     * zoom to terrein.
     * @param {type} args
     * @returns {undefined}
     */
    updateTerrein: function (combo, value, scope) {
        var filters = this.terreinenStore.getFilters().clone();
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
        try {
            this.terreinenStore.setFilters(filters);
            //Uncaught Error: Cannot override method statics on Ext.util.FilterCollection instance.
        } catch (e) {
            // ignore
        }

        // update aggregation levels
        var myfilter = Ext.create('Ext.util.Filter', {
            scope: this,
            filterFn: function (record) {
                // filter in TERREIN
                if (record.data.field1 === 'TERREIN') {
                    return true;
                }
                return false;
            }
        });
        this.step2.getComponent('aggregationLevel').store.clearFilter();
        this.step2.getComponent('aggregationLevel').store.addFilter(myfilter);
        this.step2.getComponent("aggregationLevel").setValue('TERREIN');
    },
    getBottomBar: function (step) {
        var nextStep = (step === 1 || step === 2);
        return [{
                xtype: 'toolbar',
                dock: 'bottom',
                border: 0,
                items: [
                    '->',
                    {
                        xtype: 'button',
                        text: nextStep ? 'Volgende' : 'Rapport maken',
                        handler: (nextStep ? this.nextStep.bind(this, step + 1) : this.createReport.bind(this, step + 1))
                    }
                ]
            }];
    },
    nextStep: function (step) {
        if ([2, 3, 4].indexOf(step) === -1) {
            return;
        }
        this['step' + step].expand();
    },
    activateMapClick: function () {
        this.deActivatedTools = this.config.viewerController.mapComponent.deactivateTools();
        this.toolMapClick.activateTool();
        if (this.config.isPopup) {
            this.popup.hide();
        }
    },
    deactivateMapClick: function () {
        for (var i = 0; i < this.deActivatedTools.length; i++) {
            this.deActivatedTools[i].activate();
        }
        this.deActivatedTools = [];
        this.toolMapClick.deactivateTool();
        if (this.config.isPopup) {
            this.popup.show();
        }
    },
    mapClicked: function (toolMapClick, comp) {
        var me = this;
        this.deactivateMapClick();

        if (this.config.isPopup) {
            this.popup.popupWin.setLoading("Bezig met ophalen van bedrijventerrein...");
        } else {
            Ext.get(this.getContentDiv()).mask("Bezig met ophalen van bedrijventerrein...");
        }

        var featureInfo = Ext.create("viewer.FeatureInfo", {
            viewerController: this.config.viewerController
        });
        featureInfo.editFeatureInfo(
                comp.coord.x,
                comp.coord.y,
                me.config.viewerController.mapComponent.getMap().getResolution() * 4,
                me.viewerController.getAppLayerById(me.config.bedrijvenTerreinLayer),
                function (features) {
                    me.featuresReceived(features);
                },
                function (msg) {
                    me.featuresFailed(msg);
                });
    },
    featuresReceived: function (features) {
        // select in dropdown
        if (features && features.length > 0) {
            if (this.config.isPopup) {
                this.popup.popupWin.setLoading(false);
            } else {
                Ext.get(this.getContentDiv()).unmask();
            }
            var feature = features[0];
            this.resetStoreFilters(false);
            var s = feature.__fid;
            s = s.substr(s.lastIndexOf('.') + 1);

            this.step1.getComponent('terrein').setSelection(this.terreinenStore.getById(s));
            //this.step1.getComponent('terrein').select(this.terreinenStore.getById(s));
//            try {
//                // try to zoom in
//                var appLayer = this.viewerController.getAppLayerById(this.config.bedrijvenTerreinLayer);
//                // XXX re-index for editable fields (geom must be editable...)
//                var geomIdx = 0;
//                for (var i = 0; i < appLayer.attributes.length; i++) {
//                    var attribute = appLayer.attributes[i];
//                    if (attribute.editable) {
//                        if (attribute.name === appLayer.geometryAttribute) {
//                            geomIdx = 'c' + geomIdx;
//                            break;
//                        }
//                        geomIdx++;
//                    }
//                }
//                var zoomFeat = Ext.create("viewer.viewercontroller.controller.Feature", {_wktgeom: feature[geomIdx]});
//                this.config.viewerController.mapComponent.getMap().zoomToExtent(zoomFeat.getExtent());
//            } finally {
//                   if (this.config.isPopup) {
//                            this.popup.popupWin.setLoading(false);
//                        } else {
//                            Ext.get(this.getContentDiv()).unmask();
//                        }
//            }
        } else {
            this.featuresFailed("Niets gevonden, probeer opnieuw of kies uit de lijst met terreinen.");
        }
    },
    featuresFailed: function (msg) {
        this.resetStoreFilters(false);
        Ext.MessageBox.alert("Foutmelding", msg);
        if (this.config.isPopup) {
            this.popup.popupWin.setLoading(false);
        } else {
            Ext.get(this.getContentDiv()).unmask();
        }
    },
    reportTypeChange: function (combo, val) {
        var showAggregation = val === 'AGGREGATED' || val === 'ISSUE';
        var showTimeslot = val === 'ISSUE';
        // Step 2 details
        this.step2.getComponent('aggregationLevel').setVisible(showAggregation);
        this.step2.getComponent('fromDate').setVisible(showTimeslot);
        this.step2.getComponent('toDate').setVisible(showTimeslot);
        this.step2.getComponent('aggregationLevelDate').setVisible(showTimeslot);
        // Step 3 variables
        this.step3.getComponent('allVariables').setVisible(!showAggregation && !showTimeslot);
        this.step3.getComponent('aggregationVariables').setVisible(showAggregation && !showTimeslot);
        this.step3.getComponent('issueVariables').setVisible(showTimeslot);
    },
    createReport: function (step) {
        var me = this;
        me.step4.reconfigure(null);

        this['step' + step].expand();

        if (this.config.isPopup) {
            this.popup.popupWin.setLoading("Rapport samenstellen...");
        } else {
            Ext.get(this.getContentDiv()).mask("Rapport samenstellen...");
        }

        var formData = me.form.getValues(
                /*asString*/false,
                /*dirtyOnly*/ true,
                /*includeEmptyText*/false,
                /*useDataValues*/false);
        formData.appLayer = me.config.bedrijvenTerreinLayer;
        formData.application = me.config.viewerController.app.id;

        // get data from backend
        me.reportdataStore = Ext.create('Ext.data.Store', {
            model: reportdataModel,
            proxy: {
                type: 'ajax',
                timeout: 120000,
                url: me.config.actionbeanUrl,
                actionMethods: {read: 'POST'},
                reader: {
                    type: 'json'
                },
                listeners: {
//                    exception: function (store, request, operation, eOpts) {
//                        console.error("FOUT:", operation.error);
//                    }
                }
            },
            autoLoad: {
                params: formData
            },
            pageSize: 0,
            listeners: {
                metachange: function (store, meta) {
                    // reconfigure grid and update model (up2date model is required for excel download)
                    me.step4.reconfigure(store, meta.columns);
                    me.reportdataStore.model.fields = meta.fields;
                    Ext.getCmp(me.name + "downloadBtn").setDisabled(false);
                },
                load: function (store, records, successful, eOpts) {
                    if (!successful) {
                        Ext.MessageBox.alert("Fout", "Fout tijdens opvragen van de data: " + eOpts.error);
                        Ext.getCmp(me.name + "downloadBtn").setDisabled(true);
                        if (me.config.isPopup) {
                            me.popup.popupWin.setLoading(false);
                        } else {
                            Ext.get(me.getContentDiv()).unmask();
                        }
                    }
                }
            }
        });
        if (this.config.isPopup) {
            this.popup.popupWin.setLoading(false);
        } else {
            Ext.get(this.getContentDiv()).unmask();
        }
    },
    showWindow: function () {
        this.popup.show();
    },
    getExtComponents: function () {
        return [this.form.getId()];
    },
    /**
     * Return the name of the AttributeList control to inherit the css property.
     * @returns {String} viewercomponentsAttributeList
     * @override
     */
    getBaseClass: function () {
        return 'viewercomponentsAttributeList';
    }
});
