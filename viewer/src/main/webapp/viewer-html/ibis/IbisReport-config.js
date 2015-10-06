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
 * Custom configuration object for IBIS Report configuration.
 * @author <a href="mailto:geertplaisier@b3partners.nl">Geert Plaisier</a>
 * @author <a href="mailto:markprins@b3partners.nl">Mark Prins</a>
 */
Ext.define("viewer.components.CustomConfiguration", {
    extend: "viewer.components.SelectionWindowConfig",
    configObject: {},
    /**
     * @constructor
     * @param {type} parentId
     * @param {type} configObject
     * @returns void
     */
    constructor: function (parentId, configObject) {
        this.configObject = configObject || {};
        this.configObject.showLabelconfig = true;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, this.configObject);
        this.addLayerLists();
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
                appId: applicationId,
                filterable: true
            },
            success: function (result, request) {
                var json = Ext.JSON.decode(result.responseText);
                var layers = Ext.create('Ext.data.Store', {fields: ['id', 'alias'], data: json});
                me.form.add([
                    {
                        xtype: 'combobox',
                        fieldLabel: 'IbisRapportage component kaartlaag (component view)',
                        labelWidth: me.labelWidth,
                        emptyText: 'Maak uw keuze',
                        store: layers,
                        queryMode: 'local',
                        itemId: 'bedrijvenTerreinLayer',
                        name: 'bedrijvenTerreinLayer',
                        displayField: 'alias',
                        valueField: 'id',
                        value: me.configObject.bedrijvenTerreinLayer || null,
                        listeners: {
                            scope: me,
                            select: me.addAggregatableAttributes
                        }
                    }
                ]);
                if (me.configObject.bedrijvenTerreinLayer) {
                    me.updateAttributes(me.configObject.bedrijvenTerreinLayer);
                }
            },
            failure: function () {
                Ext.MessageBox.alert("Foutmelding", "Er is een onbekende fout opgetreden waardoor de lijst met kaartlagen niet kan worden weergegeven");
            }
        });
    },
    addAggregatableAttributes: function (combo, record, eOpts) {
        this.updateAttributes(combo.value);
    },
    updateAttributes: function (attrId) {
        if (attrId) {
            if (this.form.getComponent('aggrAttrs') === undefined) {
                // add an empty checkbox group
                this.form.add([
                    {
                        xtype: 'checkboxgroup',
                        fieldLabel: 'Aggregeerbare (numerieke) velden',
                        itemId: 'aggrAttrs',
                        columns: 2,
                        labelWidth: this.labelWidth,
                        vertical: true,
                        items: []
                    }
                ]);
            }

            this.form.getComponent('aggrAttrs').removeAll(true);

            // for each numerical attribute create a checkbox and add it to the
            // form, optianally restoring checked state
            var numberAttributes = [];
            var checked = 0;
            var attr = null;

            var appLayer = appConfig.appLayers[attrId];
            for (var i = 0; i < appLayer.attributes.length; i++) {
                attr = appLayer.attributes[i];
                if (attr.type === "integer" || attr.type === "double") {
                    checked = this.configObject[attr.id] === true;
                    numberAttributes.push({
                        xtype: 'checkbox',
                        boxLabel: (attr.alias !== undefined ? attr.alias : attr.name),
                        name: attr.id,
                        inputValue: attr.id,
                        checked: checked
                    });
                }
            }
            this.form.getComponent('aggrAttrs').add(numberAttributes);
        }
    }
});
