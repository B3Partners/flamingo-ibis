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
 * Custom configuration object for HTML configuration
 * @author mprins
 */
Ext.define("viewer.components.CustomConfiguration", {
    extend: "viewer.components.SelectionWindowConfig",
    constructor: function (parentId, configObject) {
        if (configObject === null) {
            configObject = {};
        }
        configObject.showLabelconfig = true;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, configObject);
        this.createCheckBoxes(this.configObject.layers, {editable: true});

        this.form.add([{
                xtype: 'checkbox',
                fieldLabel: 'Verwijderen toestaan',
                name: 'allowDelete',
                value: this.configObject.allowDelete !== undefined ? this.configObject.allowDelete : false,
                labelWidth: this.labelWidth
            },{
                itemId: 'prefixLabels',
                xtype: 'panel',
                collapsible: true,
                collapsed: true,
                height: 200,
                autoScroll: true,
                title: 'Edit velden groeperen',
                dockedItems: {
                    xtype: 'toolbar',
                    dock: 'bottom',
                    border: 0,
                    items: [
                        '->',
                        {
                            xtype: 'button',
                            text: 'Groep toevoegen',
                            handler: this.addPrefixLabel
                        }
                    ]
                },
                listeners: {
                    expand: {
                        fn: function() { this.form.setHeight(this.form.getHeight() + 170); },
                        scope: this
                    },
                    collapse: {
                        fn: function() { this.form.setHeight(this.form.getHeight() - 170); },
                        scope: this
                    }
                }
            }
//            ,{
//                xtype: 'combobox',
//                fieldLabel: 'Workflow status',
//                labelWidth: this.labelWidth,
//                emptyText: 'Maak uw keuze',
//                store: 'IbisWorkflowStore',
//                queryMode: 'local',
//                name: 'workflowstatus',
//                itemId: 'workflowstatus',
//                displayField: 'desc',
//                valueField: 'status',
//                value: this.configObject.workflowstatus || null
//            }
        ]);
        if(configObject.hasOwnProperty('prefixConfig') && configObject.prefixConfig.length !== 0) {
            for(var i = 0; i < configObject.prefixConfig.length; i++) {
                this.addPrefixLabel(configObject.prefixConfig[i]);
            }
            Ext.ComponentQuery.query('#prefixLabels')[0].expand();
        }
        this.form.setAutoScroll(true);
    },
    addPrefixLabel: function(conf) {
        var container = Ext.ComponentQuery.query('#prefixLabels')[0];
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
                name: 'prefix',
                fieldLabel: 'Prefix',
                value: conf ? conf.prefix : '',
                maxLength: 1
            }, {
                xtype: 'textfield',
                name: 'label',
                fieldLabel: 'Label',
                value: conf ? conf.label : '',
                margin: '0 0 0 5'
            }]
        });
    },
    getConfiguration: function(){
        var config = viewer.components.CustomConfiguration.superclass.getConfiguration.call(this);
        var prefixContainer = Ext.ComponentQuery.query('#prefixLabels')[0];
        var prefixes = [];
        prefixContainer.items.each(function(row) {
            var values = row.getValues();
            if(values.prefix !== '' && values.label !== '') {
                prefixes.push(values);
            }
        });
        config.prefixConfig = prefixes;
        return config;
    }
});
