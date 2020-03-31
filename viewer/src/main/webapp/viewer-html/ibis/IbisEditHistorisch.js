/*
 * Copyright (C) 2020 B3Partners B.V.
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
 * Ibis EditHistorisch component. Om historsiche kavels te bewerken.
 * @author mprins
 */
Ext.define("viewer.components.IbisEditHistorisch", {
    extend: "viewer.components.IbisEdit",
    geometryEditable: false,
    config: {
        showVorigeDefintiefVersie: false,
        allowNew : false,
        allowCopy : false,
        showEditLinkInFeatureInfo : false,
        showVorigeDefintiefVersie : false
    },
    /**
     * Create our component.
     * @constructor
     * @param {Object} conf configuration data object
     * @returns {viewer.components.IbisEditHistorisch}
     */
    constructor: function (conf) {
        this.initConfig(conf);
        viewer.components.IbisEditHistorisch.superclass.constructor.call(this, this.config);
        return this;
    },

    initAttributeInputs: function (appLayer) {
        this.callParent(arguments);

        // blokkeer edit van geometrie
        this.geometryEditable = false;
    },
    getFeaturesForCoords: function (coords) {
        var layer = this.layerSelector.getValue();
        var featureInfo = Ext.create("viewer.FeatureInfo", {
            viewerController: this.config.viewerController
        });
        var me = this;
        featureInfo.editFeatureInfo(coords.x, coords.y, this.config.viewerController.mapComponent.getMap().getResolution() * (this.config.clickRadius || 4), layer, function (response) {
            var features = response.features;
            me.featuresReceived(features);
        }, function (msg) {
            me.failed(msg);
        }, {
            historisch:true,
            limit: 20
        });
    },

    handleFeature: function (feature) {
        this.callParent(arguments);
    //
    //     if (this.inputContainer.getForm().findField(this.workflow_fieldname) === undefined) {
    //         // workflow field is missing, add a hidden one to __unprefixed__ accordion of the form panels
    //         // if added to inputContainer it will throw a layout error
    //         this.tabbedFormPanels.__unprefixed__.add({
    //             xtype: 'combo',
    //             hidden: true,
    //             name: this.workflow_fieldname,
    //             id: this.workflow_fieldname,
    //             valueField: 'id',
    //             displayField: 'label',
    //             value: this.workflowStore.getById('bewerkt'),
    //             store: 'IbisWorkflowStore'
    //         });
    //     }
            if (feature[workflowFieldName] === 'archief'){
                // hou bestaande "archief" datum
                var defDate = Ext.Date.parse(feature[mutatiedatumFieldName], 'd-m-Y H:i:s');
                this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(defDate);
            }
    //     if (feature[workflowFieldName] === 'bewerkt'){
    //         // hou bestaande "bewerkt" datum
    //         var defDate = Ext.Date.parse(feature[mutatiedatumFieldName], 'd-m-Y H:i:s');
    //         this.inputContainer.getForm().findField(mutatiedatumFieldName).setMinValue(defDate);
    //         this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(defDate);
    //     } else {
    //         // stel in op vandaag
    //         this.inputContainer.getForm().findField(mutatiedatumFieldName).setMinValue(getMinMutatiedatum(feature[mutatiedatumFieldName]));
    //         this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(new Date());
    //     }
    //     var s = "";
    //     if (this.mode === "copy") {
    //         setNextIbisWorkflowStatus({}, 'bewerkt', Ext.getCmp(this.workflow_fieldname));
    //         s = this.workflowStore.getById('bewerkt').get("label");
    //     } else {
    //         setNextIbisWorkflowStatus(FlamingoAppLoader.get('user').roles, feature[this.workflow_fieldname], Ext.getCmp(this.workflow_fieldname));
    //         var wf = feature[this.workflow_fieldname] || 'bewerkt';
    //         s = this.workflowStore.getById(wf).get("label");
    //     }
    //     if (this.config.showVorigeDefintiefVersie && feature[this.workflow_fieldname] &&
    //             (feature[this.workflow_fieldname] === "bewerkt" || feature[this.workflow_fieldname] === "definitief")) {
    //         // get kavel/terrein voor ibis_id/definitief
    //         this.getDefinitiefFeature(feature);
    //     }
    //     // schakel verwijderen (== saveButton) knop uit als 'definitief' wordt geladen in delete mode
    //     if (this.inputContainer.getForm().findField(this.workflow_fieldname).getValue() === "definitief" && this.mode === "delete") {
    //         this.savebutton.setDisabled(true);
    //         this.savebutton.setText("'Definitief' object mag niet verwijderd worden");
    //     }
    //     // verberg verwijderen knop als iets anders als 'bewerkt' wordt geladen
    //     if (this.inputContainer.getForm().findField(this.workflow_fieldname).getValue() !== "bewerkt") {
    //         // de button wordt hersteld in #showWindow
    //         this.setButtonDisabled("deleteButton", true);
    //         var button = this.maincontainer.down("#deleteButton");
    //         if (button) {
    //             button.hide();
    //         }
    //     }
    },
    // /**
    //  * wrap input element.
    //  *
    //  * @param {Ext.form.field.Field} inputEle
    //  * @returns {Ext.form.field.Field} optionally wrapped in a {Ext.container.Container}
    //  * @private
    //  */
    // _wrapInput: function (inputEle, attributeName) {
    //     var input = inputEle;
    //     if (this.config.showVorigeDefintiefVersie) {
    //         inputEle.setFlex(2);
    //         input = Ext.create('Ext.container.Container', {
    //             layout: {
    //                 type: 'hbox',
    //                 align: 'stretch'
    //             }, items: [
    //                 inputEle,
    //                 {
    //                     xtype: 'box',
    //                     html: '',
    //                     flex: 1,
    //                     id: attributeName + '_def',
    //                     width: 100,
    //                     cls: 'x-form-text-default def_container',
    //                     border: 0,
    //                     style: {
    //                         borderColor: 'red',
    //                         borderStyle: 'dotted'
    //                     }
    //                 }
    //             ]
    //         });
    //         input.setReadOnly = function (readOnly) {
    //             inputEle.setReadOnly(readOnly);
    //             inputEle.addCls("x-item-disabled");
    //         };
    //         input.getName = function () {
    //             return inputEle.getName();
    //         };
    //     }
    //     return input;
    // },
    // _getWasWordtHeader: function() {
    //     var header = [];
    //     if (this.config.showVorigeDefintiefVersie) {
    //         header = Ext.create('Ext.container.Container', {
    //             layout: {
    //                 type: 'hbox',
    //                 align: 'stretch'
    //             },
    //             items: [
    //                 {
    //                     itemId: "headingLabelA",
    //                     margin: '0 0',
    //                     flex: 1,
    //                     html: '',
    //                     xtype: "container"
    //                 },
    //                 {
    //                     itemId: "headingLabelB",
    //                     margin: '0 0',
    //                     flex: 1,
    //                     html: 'Wordt',
    //                     xtype: "container"
    //                 },
    //                 {
    //                     itemId: "headingLabelC",
    //                     margin: '0 0',
    //                     flex: 1,
    //                     html: 'Was',
    //                     xtype: "container"
    //                 }
    //             ]
    //         });
    //     }
    //     return header;
    // },

    createNew: function () {
        // kan/mag niet
    },
    deleteFeature: function () {
        // TODO: kan/mag niet???
        // this.callParent();
        // setNextIbisWorkflowStatus(FlamingoAppLoader.get('user').roles, 'afgevoerd', Ext.getCmp(this.workflow_fieldname));
        // var s = this.workflowStore.getById('afgevoerd').get('label');
        // Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
    },
    /**
     * copied from superclass Edit to override the actionbeanUrl.
     * @returns {undefined}
     * @override
     */
    save: function () {
        if (!this.inputContainer.getForm().findField(mutatiedatumFieldName).isValid()) {
            return;
        }
        // if (this.mode === "delete") {
        //     this.remove();
        //     return;
        // }

        var feature = this.inputContainer.getValues();

        if (this.geometryEditable) {
            if (this.vectorLayer.getActiveFeature()) {
                var wkt = this.vectorLayer.getActiveFeature().config.wktgeom;
                feature[this.appLayer.geometryAttribute] = wkt;
            }
        }
        if (this.mode === "edit") {
            feature.__fid = this.currentFID;
        }

        // geen nieuwe features maken
        // if (this.mode === "copy") {
        //     feature.__fid = null;
        // }
        // if ((this.mode === "new")) {
        //     if (!feature[idFieldName]) {
        //         feature[idFieldName] = this.newID;
        //     }
        // }

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
     * Return the name of the superclass to inherit the css property.
     * @returns {String} base class name
     * @override
     */
    getBaseClass: function () {
        return this.superclass.getBaseClass.call(this.superclass);
    }
});
