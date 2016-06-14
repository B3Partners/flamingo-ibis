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
    extend: 'viewer.components.Component',
    form: null,
    container: null,
    config: {
        componentLayer: null,
        actionbeanUrl: "",
        title: 'Ibis Rapporten',
        titlebarIcon: null,
        tooltip: null
    },
    /**
     * constructs a new instance.
     * @param {Object} conf
     * @returns {viewer.components.IbisReports}
     */
    constructor: function (conf) {
        viewer.components.IbisReports.superclass.constructor.call(this, conf);
        this.initConfig(conf);

        // update custom url, global var contextPath is not available until after page load
        this.config.actionbeanUrl = contextPath + '/action/ibisreports';

        var me = this;
        this.container = Ext.create('Ext.container.Container', {
            width: '100%',
            height: '100%',
            renderTo: this.div,
            componentCls: 'IbisReportsContainer',
            items: [{
                    xtype: 'button',
                    text: me.config.title,
                    handler: me.showWindow,
                    scope: me
                }]
        });
        this.createForm();

        return this;
    },
    createForm: function () {
        var me = this;

        this.popup = Ext.create('viewer.components.ScreenPopup', {
            viewerController: me.config.viewerController,
            title: me.config.title,
            details: {
                width: '90%',
                height: '90%',
                useExtLayout: true
            }
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
            url: me.config.actionbeanUrl,
            layout: {
            },
            items: [{
                    name: 'regio',
                    xtype: 'combo',
                    fields: ['regio'],
                    queryMode: 'local',
                    data: [{regio: 'blaa'}]
                },
                {
                    name: 'gemeente',
                    xtype: 'combo',
                    fields: ['gemeente'],
                    queryMode: 'local',
                    data: [{gemeente: 'aap'}]
                },
                {
                    xtype: 'datefield',
                    fieldLabel: 'begin datum',
                    name: 'fromDate'
                },
                {
                    xtype: 'datefield',
                    fieldLabel: 'eind datum',
                    name: 'toDate'
                }
            ]
        });

        for (var i = 0; i < this.config.rapportConfig.length; i++) {
            
            this.form.add({
                xtype: 'button',
                text: me.config.rapportConfig[i].repTitle,
                value: me.config.rapportConfig[i].repTable,
                scope: me,
                handler: function (button, e) {
                    console.debug("btn click", button, e);
                    me.form.submit({
                        params: {
                            report: button.value
                        },
                        success: function (form, action) {
                            Ext.Msg.alert('Success', action.result.msg);
                        },
                        failure: function (form, action) {
                            Ext.Msg.alert('Failed', action.result.msg);
                        }
                    });
                }
            });
        }

        this.popup.getContentContainer().add(this.form);
    },
    showWindow: function () {
        this.popup.show();
    },
    getDiv: function () {
        return this.container;
    },
    getExtComponents: function () {
        return [this.container.getId()];
    }
});
