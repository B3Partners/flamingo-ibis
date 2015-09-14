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
 * Ibis Edit component
 * @author mprins
 */
Ext.define("viewer.components.IbisEdit", {
    extend: "viewer.components.Edit",
    //  /** (cached) workflow status. */
    //  status: null,
    workflow_fieldname: null,
    workflowStore: null,
    tabbedFormPanels: {},
    config: {
        prefixConfig: []
    },
    /**
     * Create our component.
     * @constructor
     * @param {Object} conf configuration data object
     * @returns {viewer.components.IbisEdit}
     */
    constructor: function (conf) {
        if(conf.hasOwnProperty('prefixConfig') && conf.prefixConfig.length !== 0) {
            conf.formLayout = {
                type: 'accordion',
                titleCollapse: true,
                animate: true,
                activeOnTop: false,
                multi: true
            };
        }
        viewer.components.IbisEdit.superclass.constructor.call(this, conf);
        this.workflow_fieldname = workflowFieldName;
        this.workflowStore = Ext.data.StoreManager.lookup('IbisWorkflowStore');

// niet meer nodig, we gebruiken het attribuutveld
// add workflow selector, updated in initAttributeInputs
//        this.maincontainer.add([{
//                xtype: 'combobox',
//                fieldLabel: 'Nieuwe workflow status',
//                id: this.name + "workflowStatus",
//                editable: false,
//                store: 'IbisWorkflowStore',
//                queryMode: 'local',
//                name: 'workflowStatus',
//                itemId: 'workflowStatus',
//                displayField: 'label',
//                valueField: 'id',
//                listeners: {
//                    afterrender: function (combo) {
//                        var recordSelected = combo.getStore().getAt(0);
//                        combo.setValue(recordSelected);
//                    }
//                },
//                autoSelect: true
//            }
//        ]);
        this.maincontainer.add([{id: this.name + "workflowLabel",
                margin: 5,
                text: '',
                xtype: "label"}]);

        return this;
    },
    initAttributeInputs: function (appLayer) {
        if(this.config.prefixConfig.length !== 0) {
            this.inputContainer.getLayout().multi = true;
        }
        this.superclass.initAttributeInputs.call(this, appLayer);
        this.groupInputsByPrefix(appLayer);
        getNextIbisWorkflowStatus(user.roles, null, null);
    },
    groupInputsByPrefix: function() {
        if(this.config.prefixConfig.length === 0) {
            return;
        }
        var itemList = this.inputContainer.items;
        var defaultConfig = {
            autoScroll: true,
            collapsible: true,
            collapsed: true,
            width: '100%',
            bodyPadding: 15,
            layout: {
                type: 'vbox',
                align: 'strecth'
            },
            defaults: {
                margin: '0 0 5 0'
            }
        };
        this.tabbedFormPanels = {
            '__unprefixed__': Ext.create('Ext.panel.Panel', Ext.Object.merge({}, defaultConfig, { title: 'Algemeen', collapsed: false, dockedItems: this.getBottomBar(this.getPrefix(this.config.prefixConfig[0].prefix)) }))
        };
        var next, nextPrefix;
        for(var i = 0; i < this.config.prefixConfig.length; i++) {
            next = this.config.prefixConfig[i + 1] || {};
            nextPrefix = this.getPrefix(next.prefix);
            this.tabbedFormPanels[this.getPrefix(this.config.prefixConfig[i].prefix)] = Ext.create('Ext.panel.Panel',
                Ext.Object.merge({}, defaultConfig, {
                    title: this.config.prefixConfig[i].label,
                    dockedItems: nextPrefix ? this.getBottomBar(nextPrefix) : {}
                })
            );
        }
        var me = this;
        itemList.each(function(item) {
            var fieldName = item.getName();
            var fieldPrefix = fieldName.substr(0, 2);
            if(!me.tabbedFormPanels.hasOwnProperty(fieldPrefix)) {
                fieldPrefix = '__unprefixed__';
            }
            me.tabbedFormPanels[fieldPrefix].add(item);
            return true;
        });
        for(var key in this.tabbedFormPanels) if(this.tabbedFormPanels.hasOwnProperty(key)) {
            this.addFieldSet(this.tabbedFormPanels[key]);
        }
        this.inputContainer.getLayout().multi = false;
    },
    getPrefix: function(prefix) {
        return prefix + '_';
    },
    getBottomBar: function (step) {
        return [{
            xtype: 'toolbar',
            dock: 'bottom',
            border: 0,
            items: [
                '->',
                {
                    xtype: 'button',
                    text: 'Volgende',
                    handler: this.nextStep.bind(this, step)
                }
            ]
        }];
    },
    nextStep: function (step) {
        this.tabbedFormPanels[step].expand();
    },
    addFieldSet: function(fieldSet) {
        if(fieldSet.items.length === 0) {
            return;
        }
        this.inputContainer.add(fieldSet);
    },
    handleFeature: function (feature) {
        this.superclass.handleFeature.call(this, feature);
        getNextIbisWorkflowStatus(user.roles, feature.workflow_status, Ext.getCmp(this.workflow_fieldname));
        var s = this.workflowStore.getById(feature[this.workflow_fieldname]).get("label");
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
    },
    createNew: function () {
        this.superclass.createNew.call(this);
        getNextIbisWorkflowStatus(user.roles, 'nieuw', Ext.getCmp(this.workflow_fieldname));
        var s = this.workflowStore.getById('nieuw').get("label");
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
    },
    deleteFeature: function () {
        this.superclass.deleteFeature.call(this);
        getNextIbisWorkflowStatus(user.roles, 'archief', Ext.getCmp(this.workflow_fieldname));
        var s = this.workflowStore.getById('archief').get('label');
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
    },

    /**
     * copied from superclass Edit to override the actionbeanUrl.
     * @returns {undefined}
     * @override
     */
    save: function () {
        if (this.mode === "delete") {
            this.remove();
            return;
        }

        var feature = this.inputContainer.getValues();

        if (this.geometryEditable) {
            if (this.vectorLayer.getActiveFeature()) {
                var wkt = this.vectorLayer.getActiveFeature().config.wktgeom;
                feature[this.appLayer.geometryAttribute] = wkt;
            }
        }
        if (this.mode == "edit") {
            feature.__fid = this.currentFID;
        }
        var me = this;
        try {
            feature = this.changeFeatureBeforeSave(feature);
        } catch (e) {
            me.failed(e);
            return;
        }

        me.editingLayer = this.config.viewerController.getLayer(this.layerSelector.getValue());
        Ext.create("viewer.EditFeature", {
            viewerController: this.config.viewerController,
            actionbeanUrl: contextPath + '/action/feature/ibisedit'
        }).edit(
                me.editingLayer,
                feature,
                function (fid) {
                    me.saveSucces(fid);
                }, function (error) {
            me.failed(error);
        });
    },
    /**
     * copied from superclass Edit to override the actionbeanUrl.
     * @override
     * @returns {undefined}
     */
    remove: function () {
        if (!this.config.allowDelete || !this.geometryEditable) {
            Ext.Msg.alert('Mislukt', "Verwijderen is niet toegestaan.");
            return;
        }

        var feature = this.inputContainer.getValues();
        feature.__fid = this.currentFID;

        var me = this;
        try {
            feature = this.changeFeatureBeforeSave(feature);
        } catch (e) {
            me.failed(e);
            return;
        }
        me.editingLayer = this.config.viewerController.getLayer(this.layerSelector.getValue());
        Ext.create("viewer.EditFeature", {
            viewerController: this.config.viewerController,
            actionbeanUrl: contextPath + '/action/feature/ibisedit'
        }).remove(
                me.editingLayer,
                feature,
                function (fid) {
                    me.deleteSucces();
                }, function (error) {
            me.failed(error);
        });
    },
// niet meer nodig, we gebruiken het attribuut veld
//    /**
//     * Set workflow status on the feature before trying to save.
//     * @override
//     * @return the changed feature
//     */
//    changeFeatureBeforeSave: function (feature) {
//        feature.workflow_status = Ext.getCmp(this.name + "workflowStatus").getValue();
//        return feature;
//    },
    /**
     * Return the name of the superclass to inherit the css property.
     * @returns {String} base class name
     * @override
     */
    getBaseClass: function () {
        return this.superclass.self.getName().replace(/\./g, '');
    }
});