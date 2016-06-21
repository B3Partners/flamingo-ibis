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
 * Custom configuration object for IBIS Reports configuration.
 * 
 * @author <a href="mailto:markprins@b3partners.nl">Mark Prins</a>
 */
Ext.define("viewer.components.CustomConfiguration", {
    extend: "viewer.components.SelectionWindowConfig",
    /**
     * @constructor
     * @param {type} parentId
     * @param {type} configObject
     * @param {type} configPage
     * @returns void
     */
    constructor: function (parentId, configObject, configPage) {
        configObject.showLabelconfig = true;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, configObject, configPage);
        reportbase__layersArrayIndexesToAppLayerIds(this.configObject);
        var me = this;
        me.addForm(configObject);
        me.addLayerLists();
        me.addAttributeSources();
    },
    /**
     * Execute an AJAX request to retrieve a list of layers and add some dropdowns
     * to this form so a selection can be made.
     *
     * @returns void
     */
    addLayerLists: function () {
        var me = this;
        Ext.Ajax.request({
            url: me.requestPath, //contextPath + "/action/componentConfigLayerList",
            params: {
                appId: this.getApplicationId(),
                filterable: true
            },
            success: function (result, request) {
                var json = Ext.JSON.decode(result.responseText);
                var layers = Ext.create('Ext.data.Store', {fields: ['id', 'alias'], data: json});
                me.form.getComponent("componentLayer").setStore(layers);
                me.form.getComponent("componentLayer").setValue(me.configObject.componentLayer);
                me.form.getComponent("componentLayer").validate();

//                me.form.insert(4, {
//                    xtype: 'combobox',
//                    fieldLabel: 'IbisRapportage component kaartlaag (component view)',
//                    labelWidth: me.labelWidth,
//                    emptyText: 'Maak uw keuze',
//                    store: layers,
//                    queryMode: 'local',
//                    itemId: 'componentLayer',
//                    name: 'componentLayer',
//                    displayField: 'alias',
//                    valueField: 'id',
//                    value: me.configObject.componentLayer || null
//                });
            },
            failure: function () {
                Ext.MessageBox.alert("Foutmelding", "Er is een onbekende fout opgetreden waardoor de lijst met kaartlagen niet kan worden weergegeven");
            }
        });
    },
    addAttributeSources: function () {
        var me = this;
        Ext.Ajax.request({
            url: '/viewer-admin/action/attributesource/getGridData',
            params: {
                page: 1,
                start: 0,
                sort: 'name',
                dir: 'ASC',
                limit: 100,
                filter: Ext.util.JSON.encode([{property: "protocol", value: "JDBC", label: "Type"}])
            },
            success: function (result, request) {
                var json = Ext.JSON.decode(result.responseText);
                var sources = Ext.create('Ext.data.Store', {
                    fields: ['protocol', 'name', 'id', 'url', 'status'],
                    data: json.gridrows
                });
                me.form.getComponent("attrSource").setStore(sources);
                me.form.getComponent("attrSource").setValue(me.configObject.attrSource);
                me.form.getComponent("attrSource").validate();

//                me.form.insert(5, {
//                    xtype: 'combobox',
//                    fieldLabel: 'IbisReports attribuutbron',
//                    labelWidth: me.labelWidth,
//                    emptyText: 'Maak uw keuze',
//                    store: sources,
//                    queryMode: 'local',
//                    itemId: 'attrSource',
//                    name: 'attrSource',
//                    displayField: 'name',
//                    valueField: 'id',
//                    value: me.configObject.attrSource || null
//                });
            },
            failure: function () {
                Ext.MessageBox.alert("Foutmelding", "Er is een onbekende fout opgetreden waardoor de lijst met attribuutbronnen niet kan worden weergegeven");
            }
        });
    },
    addForm: function (configObject) {
        var me = this;
        me.form.add([
            {
                xtype: 'combobox',
                fieldLabel: 'IbisRapportage component kaartlaag (component view)',
                labelWidth: me.labelWidth,
                emptyText: 'Maak uw keuze',
                //store: layers,
                queryMode: 'local',
                itemId: 'componentLayer',
                name: 'componentLayer',
                displayField: 'alias',
                valueField: 'id',
                //value: me.configObject.componentLayer || null
            },
            {
                xtype: 'combobox',
                fieldLabel: 'IbisReports attribuutbron',
                labelWidth: me.labelWidth,
                emptyText: 'Maak uw keuze',
                //store: sources,
                queryMode: 'local',
                itemId: 'attrSource',
                name: 'attrSource',
                displayField: 'name',
                valueField: 'id',
                //value: me.configObject.attrSource || null
            },
            {
                itemId: 'rapportLabels',
                xtype: 'panel',
                collapsible: true,
                collapsed: true,
                height: 200,
                autoScroll: true,
                title: 'Rapportages',
                dockedItems: {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    border: 0,
                    items: [
                        '->',
                        {
                            xtype: 'button',
                            text: 'Rapport toevoegen',
                            handler: this.addRapportLabel
                        }
                    ]
                },
                listeners: {
                    expand: {
                        fn: function () {
                            this.form.setHeight(this.form.getHeight() + 170);
                        },
                        scope: this
                    },
                    collapse: {
                        fn: function () {
                            this.form.setHeight(this.form.getHeight() - 170);
                        },
                        scope: this
                    }
                }
            }]);
        if (configObject.hasOwnProperty('rapportConfig') && configObject.rapportConfig.length !== 0) {
            for (var i = 0; i < configObject.rapportConfig.length; i++) {
                this.addRapportLabel(configObject.rapportConfig[i]);
            }
            Ext.ComponentQuery.query('#rapportLabels')[0].expand();
        }
        this.form.setAutoScroll(true);
    },
    /**
     *
     * @param {type} conf
     * @returns {undefined}
     */
    addRapportLabel: function (conf) {
        var container = Ext.ComponentQuery.query('#rapportLabels')[0];
        container.add({
            xtype: 'form',
            labelWidth: 160,
            border: 0,
            padding: '5 5 0 5',
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [{
                    xtype: 'textfield',
                    name: 'repTitle',
                    fieldLabel: 'Knop titel',
                    value: conf ? conf.repTitle : '',
                    maxLength: 1
                }, {
                    // TODO maybe replace with dropdown..
                    xtype: 'textfield',
                    name: 'repTable',
                    fieldLabel: 'view naam',
                    value: conf ? conf.repTable : '',
                    margin: '0 0 0 5'
                }]
        });
    },
    getConfiguration: function () {
        var config = viewer.components.CustomConfiguration.superclass.getConfiguration.call(this);
        reportbase__appLayerIdToLayerIndex(config);

        var lblContainer = Ext.ComponentQuery.query('#rapportLabels')[0];
        var reports = [];
        lblContainer.items.each(function (row) {
            var values = row.getValues();
            if (values.repTitle !== '' && values.repTable !== '') {
                reports.push(values);
            }
        });
        config.rapportConfig = reports;

        return config;
    }
});
