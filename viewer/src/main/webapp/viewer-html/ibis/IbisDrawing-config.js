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
 * Custom configuration object for IbisDrawing configuration.
 * @author mprins
 */
Ext.define("viewer.components.CustomConfiguration", {
    extend: "viewer.components.SelectionWindowConfig",
    form: null,
    constructor: function (parentId, configObject, configPage) {
        if (configObject === null) {
            configObject = {};
        }
        configObject.showLabelconfig = true;
        viewer.components.CustomConfiguration.superclass.constructor.call(this, parentId, configObject, configPage);
        this.form.add({
            xtype: 'colorfield',
            fieldLabel: 'Kleur',
            name: 'color',
            value: this.configObject.color,
            labelWidth: this.labelWidth
        },
        {
            xtype: 'checkbox',
            fieldLabel: 'Heractiveer de vorige tools',
            name: 'reactivateTools',
            value: this.configObject.reactivateTools !== undefined ? this.configObject.reactivateTools : false,
            labelWidth: this.labelWidth
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Default bericht adres',
            name: 'shareMail',
            value: this.configObject.shareMail !== undefined ? this.configObject.shareMail : "",
            labelWidth: this.labelWidth,
            width: 700
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Default bericht titel',
            name: 'shareTitle',
            value: this.configObject.shareTitle !== undefined ? this.configObject.shareTitle : "schets voorstel",
            labelWidth: this.labelWidth,
            width: 700
        },
        {
            xtype: 'textareafield',
            fieldLabel: 'Default bericht inhoud',
            name: 'shareText',
            grow: true,
            value: this.configObject.shareText !== undefined ? this.configObject.shareText : "Bookmark naar de schets: ",
            labelWidth: this.labelWidth,
            width: 700
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Bookmark doel Flamingo applicatie (mashup), bijv. PROVINCIE',
            name: 'shareTarget',
            value: this.configObject.shareTarget !== undefined ? this.configObject.shareTarget : "",
            labelWidth: this.labelWidth,
            width: 700
        });
    },
    getDefaultValues: function () {
        return {
            details: {
                minWidth: 405,
                minHeight: 215
            }
        };
    }
});

