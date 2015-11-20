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
Ext.define('viewer.components.IbisReport', {
    extend: 'viewer.components.IbisReportBase',
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
    dataGridPopup: null,
    dataGridColumns: [],
    config: {
        title: null,
        titlebarIcon: null,
        tooltip: null,
        label: ""
    },
    constructor: function (conf) {
        viewer.components.IbisReport.superclass.constructor.call(this, conf);
        this.initConfig(conf);

        Ext.define('reportdataModel', {
            extend: 'Ext.data.Model',
            fields: []
        });

        if (this.config.isPopup) {
            this.renderButton();
        } else {
            // called from getDataModel()
            // this.createForms();
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
    createForms: function () {
        var me = this;

        // to select a bedrijventerrein on the map
        me.toolMapClick = this.config.viewerController.mapComponent.createTool({
            type: viewer.viewercontroller.controller.Tool.MAP_CLICK,
            id: this.name + "toolMapClick",
            handler: {
                fn: me.mapClicked,
                scope: me
            },
            viewerController: this.config.viewerController
        });

        me.setIsLoading("Bezig met ophalen van de lijst met bedrijven terreinen. <br /> Dit duurt even...");
        if (Ext.StoreMgr.lookup('terreinenStore')) {
            me.terreinenStore = Ext.StoreMgr.lookup('terreinenStore');

            if (!me.terreinenStore.isLoaded( )) {
                me.terreinenStore.on({
                    load: {fn: function () {
                            me.setDoneLoading();
                            me.resetStoreFilters(false);
                        }, scope: me}
                });
            } else {
                me.setDoneLoading();
                me.resetStoreFilters(false);
            }
        } else {
            me.terreinenStore = Ext.create('Ext.data.Store', {
                model: 'terreinModel',
                storeId: 'terreinenStore',
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
                            me.setDoneLoading();
                            me.resetStoreFilters(false);
                        }
                    }
                }
            });
        }


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
                    items: [{
                        xtype: 'checkbox',
                        itemId: 'checkAllVariables',
                        boxLabel: 'Alle variabelen aan/uitzetten',
                        listeners: {
                            change: { scope: this, fn: function(field, newval) {
                                var container = this.step3.getComponent('allVariables');
                                if(container.isHidden()) {
                                    container = this.step3.getComponent('aggregationVariables');
                                }
                                var checkboxes = container.query('checkbox');
                                Ext.Array.each(checkboxes, function (checkbox) {
                                    checkbox.setValue(!!newval);
                                });
                            }}
                        }
                    }],
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
                    items: [me.getDownloadExcelButton(), {
                            xtype: 'button',
                            flex: 1,
                            text: 'Open in popup',
                            handler: this.openGridInPopup.bind(this),
                            visible: !this.config.isPopup
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
    getDownloadExcelButton: function(enabled) {
        return {
            xtype: 'button',
            flex: 1,
            text: 'Download data (Excel)',
            disabled: !enabled,
            handler: function (btn, evt) {
                btn.up('grid').downloadExcelXml(
                true,
                this.getReportTitle(),
                this.config.actionbeanUrl, {
                    download: 1,
                    mimetype: 'application/vnd.ms-excel',
                    filename: "ibisrapportage.xls",
                    appLayer: this.config.componentLayer,
                    application: this.config.viewerController.app.id
                });
            }.bind(this)
        };
    },
    getReportTitle: function() {
        return [
            this.step2.getComponent('reportType').getRawValue(),
            'rapportage',
            this.step1.getComponent('terrein').getRawValue(),
            this.step1.getComponent('gemeente').getRawValue(),
            this.step1.getComponent('regio').getRawValue()
        ].join(" ");
    },
    openGridInPopup: function(btn) {
        if(this.dataGridPopup === null) {
            this.dataGridPopup = Ext.create('viewer.components.ScreenPopup', {
                viewerController: this.config.viewerController,
                title: this.getReportTitle(),
                details: {
                    width: '90%',
                    height:'90%',
                    useExtLayout: true
                }
            });
        } else {
            this.dataGridPopup.getContentContainer().removeAll();
        }
        this.setIsLoading("Bezig met laden van popup...");
        var datagrid = Ext.create('Ext.grid.Panel', {
            store: this.step4.getStore(),
            columns: this.dataGridColumns,
            dockedItems: [{
                xtype: 'toolbar',
                docked: 'bottom',
                items: [ this.getDownloadExcelButton(/*enabled=*/true) ]
            }]
        });
        this.dataGridPopup.getContentContainer().add(datagrid);
        this.dataGridPopup.show();
        this.setDoneLoading();
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

        this.setIsLoading("Bezig met ophalen van bedrijventerrein...");
        var featureInfo = Ext.create("viewer.FeatureInfo", {
            viewerController: this.config.viewerController
        });
        featureInfo.editFeatureInfo(
                comp.coord.x,
                comp.coord.y,
                me.config.viewerController.mapComponent.getMap().getResolution() * 4,
                me.viewerController.getAppLayerById(me.config.componentLayer),
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
            this.setDoneLoading();
            var feature = features[0];
            this.resetStoreFilters(false);
            var s = feature.__fid;
            s = s.substr(s.lastIndexOf('.') + 1);
            this.step1.getComponent('terrein').setSelection(this.terreinenStore.getById(s));
        } else {
            this.featuresFailed("Niets gevonden, probeer opnieuw of kies uit de lijst met terreinen.");
        }
    },
    featuresFailed: function (msg) {
        this.resetStoreFilters(false);
        Ext.MessageBox.alert("Foutmelding", msg);
        this.setDoneLoading();
    },
    reportTypeChange: function (combo, val) {
        // uncheck any checkboxes
        var checkboxes = this.step3.getComponent('allVariables').query('[isCheckbox]');
        Ext.Array.each(checkboxes, function (checkbox) {
            checkbox.reset();
        });
        checkboxes = this.step3.getComponent('aggregationVariables').query('[isCheckbox]');
        Ext.Array.each(checkboxes, function (checkbox) {
            checkbox.reset();
        });
        Ext.ComponentQuery.query('#checkAllVariables')[0].setValue(false);
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
        me['step' + step].expand();

        this.setIsLoading("Rapport samenstellen...");

        me.step4.reconfigure(null);
        var formData = me.form.getValues(
                /*asString*/false,
                /*dirtyOnly*/ false,
                /*includeEmptyText*/false,
                /*useDataValues*/false);
        formData.appLayer = me.config.componentLayer;
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
                    // save a copy of the columns array to use when opening grid in popup
                    me.dataGridColumns = [].concat(meta.columns); // [].concat creates a copy of the array
                    // reconfigure grid and update model (up2date model is required for excel download)
                    me.step4.reconfigure(store, meta.columns);
                    me.reportdataStore.model.fields = meta.fields;
                    me.toggleGridButtons(/*disabled=*/false);
                },
                load: function (store, records, successful, eOpts) {
                    if (!successful) {
                        Ext.MessageBox.alert("Fout", "Fout tijdens opvragen van de data: " + eOpts.error);
                        me.toggleGridButtons(/*disabled=*/true);
                    }
                    me.setDoneLoading();
                }
            }
        });
    },
    toggleGridButtons: function(disabled) {
        var btns = this.step4.query('button');
        for(var i = 0; i < btns.length; i++) {
            btns[i].setDisabled(disabled);
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
