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
            url: contextPath + "/action/componentConfigLayerList",
            params: {
                appId: applicationId,
                filterable: true
            },
            success: function (result, request) {
                var json = Ext.JSON.decode(result.responseText);
                var layers = Ext.create('Ext.data.Store', {fields: ['id', 'alias'], data: json});
                me.form.add([
//                    {
//                        xtype: 'combobox',
//                        fieldLabel: 'Kavels kaartlaag',
//                        labelWidth: me.labelWidth,
//                        emptyText: 'Maak uw keuze',
//                        store: layers,
//                        queryMode: 'local',
//                        itemId: 'bedrijvenKavelsLayer',
//                        name: 'bedrijvenKavelsLayer',
//                        displayField: 'alias',
//                        valueField: 'id',
//                        value: me.configObject.bedrijvenKavelsLayer || null
//                    },
                    {
                        xtype: 'combobox',
                        fieldLabel: 'Bedrijventerreinen kaartlaag (component view)',
                        labelWidth: me.labelWidth,
                        emptyText: 'Maak uw keuze',
                        store: layers,
                        queryMode: 'local',
                        itemId: 'bedrijvenTerreinLayer',
                        name: 'bedrijvenTerreinLayer',
                        displayField: 'alias',
                        valueField: 'id',
                        value: me.configObject.bedrijvenTerreinLayer || null
                    }
                ]);
            },
            failure: function () {
                Ext.MessageBox.alert("Foutmelding", "Er is een onbekende fout opgetreden waardoor de lijst met kaartlagen niet kan worden weergegeven");
            }
        });
    }
});
