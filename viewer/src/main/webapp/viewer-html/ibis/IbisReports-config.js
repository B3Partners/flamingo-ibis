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
    configObject: {},
    /**
     * @constructor
     * @param {type} parentId
     * @param {type} configObject
     * @param {type} configPage
     * @returns void
     */
    constructor: function (parentId, configObject, configPage) {
        this.configObject.showLabelconfig = true;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, configObject, configPage);

        this.form.add([{
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
    addRapportLabel: function (conf) {
        console.log('addRapportLabel', conf);
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
                    fieldLabel: 'Titel',
                    value: conf ? conf.repTitle : '',
                    maxLength: 1
                }, {
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
        var prefixContainer = Ext.ComponentQuery.query('#rapportLabels')[0];
        var prefixes = [];
        prefixContainer.items.each(function (row) {
            var values = row.getValues();
            if (values.repTitle !== '' && values.repTable !== '') {
                prefixes.push(values);
            }
        });
        config.rapportConfig = prefixes;
        return config;
    }
});
