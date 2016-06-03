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
 * Custom configuration object for IBIS factsheet configuration.
 * @author Mark Prins
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
        configObject.title = "Factsheet";
        configObject.showPrintRtf = false;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, configObject, configPage);
        
        factsheet__layersArrayIndexesToAppLayerIds(this.configObject);
        this.createCheckBoxes(this.configObject.legendLayers);
        this.addLayerSelector();
        // in LayerSelector
        this.checkPanel.setTitle("Selecteer de kaartlagen voor de legenda");
    },
    /**
     * Execute an AJAX request to retrieve a list of layers and add some dropdowns
     * to this form so a selection can be made.
     *
     * @returns void
     */
    addLayerSelector: function () {
        var me = this;

        Ext.Ajax.request({
            url: this.getContextpath() + "/action/componentConfigLayerList",
            params: {
                appId: this.getApplicationId(),
                filterable: true
            },
            success: function (result, request) {
                var json = Ext.JSON.decode(result.responseText);
                var layers = Ext.create('Ext.data.Store', {
                    fields: ['id', 'alias'],
                    data: json
                });
                me.form.add([
                    {
                        xtype: 'combobox',
                        fieldLabel: 'Factsheet kaartlaag',
                        labelWidth: me.labelWidth,
                        emptyText: 'Maak uw keuze',
                        store: layers,
                        queryMode: 'local',
                        itemId: 'factsheetLayerId',
                        name: 'factsheetLayerId',
                        displayField: 'alias',
                        valueField: 'id',
                        value: me.configObject.factsheetLayerId || null,
                        listeners: {
                            scope: me,
                            select: function (scope, event, control) {
                                //console.debug(scope, event, control);
                            }
                        }
                    }, {
                        xtype: "checkbox",
                        name: "overview",
                        checked: me.configObject.overview ? me.configObject.overview : true,
                        boxLabel: "Neem de overzichtskaart op als de overzichtskaart aanwezig is"
                    }
                ]);
            },
            failure: function () {
                Ext.MessageBox.alert("Foutmelding",
                        "Er is een onbekende fout opgetreden waardoor de lijst met kaartlagen niet kan worden weergegeven");
            }
        });
    },
    getConfiguration: function () {
        var config = new Object();
        if (this.checkBoxes != null) {
            config.legendLayers = this.checkBoxes.getChecked();
        }
        Ext.apply(config, this.getValuesFromContainer(this.form));
        factsheet__appLayerIdToLayerIndex(config);
        return config;
    }

});
