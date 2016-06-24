/*
 * Copyright (C) 2016 B3Partners B.V.
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
 * IBIS Reports component.
 *
 * @author mprins
 */
Ext.define('viewer.components.IbisReports', {
    extend: 'viewer.components.IbisReportBase',
    form: null,
    /** side bar paneel */
    container: null,
    terreinenStore: null,
    reportdataStore: null,
    dataGridColumns: [],
    resultsgrid: null,
    report: "",
    config: {
        componentLayer: null,
        attrSource: null,
        title: null,
        titlebarIcon: null,
        tooltip: null,
        reportactionbeanUrl: ''
    },
    /**
     * constructs a new instance.
     * @param {Object} conf
     * @returns {viewer.components.IbisReports}
     */
    constructor: function (conf) {
        viewer.components.IbisReports.superclass.constructor.call(this, conf);
        this.initConfig(conf);

        Ext.define('reportdataModel', {
            extend: 'Ext.data.Model',
            fields: []
        });

        var me = this;
        // update custom url, global var contextPath is not available until after page load
        me.config.reportactionbeanUrl = contextPath + '/action/ibisreports';

        // sidebar panel
        me.container = Ext.create('Ext.container.Container', {
            width: '100%',
            height: '100%',
            renderTo: this.div,
            componentCls: 'IbisReportsContainer',
            items: [{
                    xtype: 'button',
                    text: me.config.title,
                    cls: 'IbisReportBtn',
                    handler: me.showWindow,
                    margin: '10 0 0 10',
                    scope: me
                }]
        });

        this.popup = Ext.create('viewer.components.ScreenPopup', {
            viewerController: me.config.viewerController,
            title: me.config.title,
            details: {
                width: '99%',
                height: '99%',
                changeablePosition: false,
                useExtLayout: true,
                changeableSize: false
            },
            modal: true
        });
        return this;
    },
    createForms: function () {
        var me = this;
        me.setIsLoading("Bezig met ophalen van de lijst met gebieden. <br /> Dit duurt even...");
        if (Ext.StoreMgr.lookup('terreinenStore')) {
            me.terreinenStore = Ext.StoreMgr.lookup('terreinenStore');
            if (!me.terreinenStore.isLoaded()) {
                me.terreinenStore.on({
                    load: {
                        fn: function () {
                            me.setDoneLoading();
                            me.resetStoreFilters();
                        },
                        scope: me
                    }
                });
            } else {
                me.setDoneLoading();
                me.resetStoreFilters();
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
                            // hier niet echt nodig, maar terreinenStore is een globale store dus toch ophalen
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
                            me.resetStoreFilters();
                        }
                    }
                }
            });
        }

        // resultaten grid
        me.resultsgrid = Ext.create('Ext.grid.Panel', {
            title: 'Rapportage',
            store: me.reportdataStore,
            allowDeselect: true,
            flex: 0.7,
            dockedItems: [{
                    xtype: 'toolbar',
                    docked: 'bottom',
                    items: [{
                            xtype: 'button',
                            flex: 1,
                            text: 'Download data (Excel)',
                            disabled: true,
                            handler: me.downloadExcel,
                            scope: me
                        }]
                }]
        });

        // formulier maken
        me.form = Ext.create('Ext.form.FormPanel', {
            flex: 0.25,
            layout: 'vbox',
            title: 'Criteria',
            defaults: {
                // applied to each contained panel
                bodyPadding: 15
            },
            items: [{
                    xtype: 'container',
                    html: 'Kies een regio en/of gemeente',
                    margin: '10 0 10 5',
                    cls: 'IbisReportFormTitel x-panel-header-title-default'
                }, {
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
                }, {
                    xtype: 'combobox',
                    store: this.terreinenStore.collect(this.gemeenteVeldNaam, true/*allowNull*/, false /*bypassFilter*/),
                    itemId: 'gemeente',
                    name: 'gemeente',
                    displayField: this.gemeenteVeldNaam,
                    value: '',
                    queryMode: 'local',
                    fieldLabel: 'Gemeente'
                }, {
                    xtype: 'container',
                    html: 'Kies eventueel een periode (voor uitgifte)',
                    margin: '10 0 10 5',
                    cls: 'IbisReportFormTitel x-panel-header-title-default'
                }, {
                    xtype: 'datefield',
                    fieldLabel: 'Begindatum',
                    name: 'fromDate'
                }, {
                    xtype: 'datefield',
                    fieldLabel: 'Einddatum',
                    name: 'toDate'
                }, {
                    xtype: 'button',
                    text: 'Reset selecties',
                    scope: me,
                    handler: function (button, e) {
                        me.form.reset();
                        me.resetStoreFilters();
                        me.toggleGridButtons(true);
                        me.resultsgrid.reconfigure(null, null);
                        me.resultsgrid.getView().refresh();
                    }
                }, {
                    xtype: 'container',
                    html: 'Beschikbare rapporten',
                    margin: '10 0 10 5',
                    cls: 'IbisReportFormTitel x-panel-header-title-default'
                }]
        });

        // knoppen voor de rapporten toevoegen
        for (var i = 0; i < this.config.rapportConfig.length; i++) {
            this.form.add({
                xtype: 'button',
                text: me.config.rapportConfig[i].repTitle,
                value: me.config.rapportConfig[i].repTable,
                scope: me,
                margin: '5 0 5 10',
                cls: 'IbisReportFormBtn',
                handler: function (button, e) {
                    me.report = button.value;
                    me.createReport();
                }
            });
        }

        var layoutcontainer = Ext.create('Ext.container.Container', {
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                me.form,
                me.resultsgrid
            ]
        });
        this.popup.getContentContainer().add(layoutcontainer);
    },
    getFormData: function () {
        var formData = this.form.getValues(
                /*asString*/false,
                /*dirtyOnly*/ false,
                /*includeEmptyText*/false,
                /*useDataValues*/false);

        formData.application = this.config.viewerController.app.id;
        formData.attrSource = this.attrSource;
        formData.report = this.report;
        return formData;
    },
    /**
     * gebruik verborgen formulier voor download van spreadsheet.
     * @returns 
     */
    downloadExcel: function () {
        var me = this;
        me.setIsLoading("Rapport downloaden...");

        var formData = me.getFormData();
        formData.download = 1;
        formData.type = 'xls';

        Ext.create('Ext.form.Panel', {
            standardSubmit: true,
            method: 'POST',
            url: me.config.reportactionbeanUrl,
            hidden: true
        }).submit({
            params: formData
        });
        me.setDoneLoading();
    },
    createReport: function () {
        var me = this;

        this.setIsLoading("Rapport samenstellen...");

        me.resultsgrid.reconfigure(null);
        var formData = me.getFormData();

        // get data from backend
        me.reportdataStore = Ext.create('Ext.data.Store', {
            model: reportdataModel,
            proxy: {
                type: 'ajax',
                timeout: 120000,
                url: me.config.reportactionbeanUrl,
                actionMethods: {
                    read: 'POST'
                },
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
                    me.dataGridColumns = [].concat(meta.columns);
                    // reconfigure grid and update model
                    me.resultsgrid.reconfigure(store, meta.columns);
                    me.reportdataStore.model.fields = meta.fields;
                    me.toggleGridButtons(/*disabled=*/false);
                },
                load: function (store, records, successful, eOpts) {
                    if (!successful) {
                        Ext.MessageBox.alert("Fout", "Fout tijdens opvragen van de data: " + eOpts.error);
                        me.toggleGridButtons(/*disabled=*/true);
                    }
                    if (records.length < 1) {
                        Ext.MessageBox.alert("Informatie", "Er zijn geen gegevens gevonden bij de gebruikte criteria.");
                    }
                    me.setDoneLoading();
                }
            }
        });
    },
    toggleGridButtons: function (disabled) {
        var btns = this.resultsgrid.query('button');
        for (var i = 0; i < btns.length; i++) {
            btns[i].setDisabled(disabled);
        }
    },
    /**
     * Reset the terreinenStore filters and comboboxes
     *
     * @returns void
     */
    resetStoreFilters: function () {
        this.terreinenStore.clearFilter(false);
        this.form.getComponent("gemeente").clearValue();
        this.form.getComponent("regio").clearValue();

        this.form.getComponent("regio").setStore(this.terreinenStore.collect(this.regioVeldNaam, false, true));
        this.form.getComponent("regio").getStore().sort('field1', 'ASC');

        this.form.getComponent("gemeente").setStore(this.terreinenStore.collect(this.gemeenteVeldNaam, false, false));
        this.form.getComponent("gemeente").getStore().sort('field1', 'ASC');
    },
    /**
     * update gemeente combobox after choosing regio
     * @param {type} args
     * @returns {undefined}
     */
    updateRegio: function (combo, value, scope) {
        this.terreinenStore.clearFilter(false);

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
        this.form.getComponent("gemeente").setStore(this.terreinenStore.collect(this.gemeenteVeldNaam, false, false));
        this.form.getComponent("gemeente").clearValue();
    },
    showWindow: function () {
        this.popup.show();
    },
    getDiv: function () {
        return this.container;
    },
    getExtComponents: function () {
        return [this.container.getId()];
    },
    /**
     * set loading message.
     * @param {String} msg The loading message to display
     * @returns {void}
     * @override
     */
    setIsLoading: function (msg) {
        this.popup.popupWin.setLoading(msg);
    },
    /**
     *  clear loading messages.
     * @override
     */
    setDoneLoading: function () {
        this.popup.popupWin.setLoading(false);
    }
});
