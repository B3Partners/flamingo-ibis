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
        allowNew: false,
        allowCopy: false,
        allowReject: false,
        showEditLinkInFeatureInfo: false,
        showVorigeDefintiefVersie: false
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
    /**
     * @Override om extra parameters mee te geven
     * @param coords
     */
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
            historisch: true,
            limit: 20
        });
    },
    updateMinMaxDate: function (dateField, fid, ibisId) {
        Ext.Ajax.request({
            url: actionBeans["ibisfeatureinfoutil"],
            params: {
                minmaxDate: true,
                appLayer: this.appLayer.id,
                application: this.config.viewerController.app.id,
                fid: fid,
                ibisId: ibisId
            },
            success: function (result) {
                var response = Ext.JSON.decode(result.responseText);
                if (response.success) {
                    if (response.mindate === response.featdate) {
                        dateField.setMinValue(parseDate(response.mindate));
                    } else {
                        // 1 uur meer dan min
                        dateField.setMinValue(getMaxMutatiedatum(response.mindate));
                    }
                    if (response.maxdate === response.featdate) {
                        dateField.setMaxValue(parseDate(response.maxdate));
                    } else {
                        // 1 uur minder dan max
                        dateField.setMaxValue(getMinMutatiedatum(response.maxdate));
                    }
                    dateField.setValue(parseDate(response.featdate));
                } else {
                    Ext.MessageBox.alert("Let Op", "De minimum en maximum mutatie datum zijn niet ingesteld.\nFout: " + response.error);
                    dateField.setReadOnly(true);
                }
            },
            failure: function (result) {
                Ext.MessageBox.alert("De minimum en maximum mutatie datum konden niet worden opgehaald.\nFout: " + result.status + " " + result.statusText);
                dateField.setReadOnly(true);
            }
        });
    },

    handleFeature: function (feature) {
        this.callParent(arguments);
        // hou bestaande datum
        var defDate = Ext.Date.parse(feature[mutatiedatumFieldName], 'd-m-Y H:i:s');
        this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(defDate);
        this.updateMinMaxDate(this.inputContainer.getForm().findField(mutatiedatumFieldName), feature.__fid, feature[idFieldName]);

        // herstel delete button (wordt weggehaald in super class
        if (this.config.allowDelete) {
            this.setButtonDisabled("deleteButton", false);
            var button = this.maincontainer.down("#deleteButton");
            if (button) {
                button.show();
            }
        }
    },
    createNew: function () {
        // kan/mag niet
    },
    /** @override */
    deleteFeature: function () {
        // werkt niet, roept toch IbisEdit#deleteFeature aan
        // this.callSuper();
        // dan maar zo
        this.superclass.superclass.deleteFeature.call(this);
    },
    /** @override */
    remove: function () {
        var feature = this.inputContainer.getValues();
        feature.__fid = this.currentFID;
        var me = this;
        me.editingLayer = this.config.viewerController.getLayer(this.layerSelector.getValue());
        Ext.create("viewer.EditFeature", {
            viewerController: this.config.viewerController,
            actionbeanUrl: FlamingoAppLoader.get('contextPath') + '/action/feature/ibisedit' + "?delete"
        }).remove(
            me.editingLayer,
            feature,
            function (fid) {
                me.deleteSucces();
            }, function (error) {
                me.failed(error);
            }, {
                historisch: true
            }
        );
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
        if (this.mode === "delete") {
            this.remove();
            return;
        }

        var feature = this.inputContainer.getValues();
        if (this.mode === "edit") {
            feature.__fid = this.currentFID;
        }
        var me = this;
        me.editingLayer = this.config.viewerController.getLayer(this.layerSelector.getValue());
        Ext.create("viewer.EditFeature", {
            viewerController: this.config.viewerController,
            actionbeanUrl: FlamingoAppLoader.get('contextPath') + '/action/feature/ibisedit'
        }).edit(
            me.editingLayer,
            feature,
            function (fid) {
                me.saveSucces(fid);
            }, function (error) {
                me.failed(error);
            }, {
                historisch: true
            }
        );
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
