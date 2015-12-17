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
 * Ibis Split component with support for workflow.
 *
 * @author markprins@b3partners.nl
 */
Ext.define("viewer.components.IbisSplit", {
    extend: "viewer.components.Split",
    config: {
        // custom url
        actionbeanUrl: "/viewer/action/feature/ibissplit",
        // always "definitief" for split
        workflowstatus: "definitief"
    },
    /** (cached) workflow status. */
    status: null,
    constructor: function (conf) {
        viewer.components.IbisSplit.superclass.constructor.call(this, conf);

        var store = Ext.data.StoreManager.lookup('IbisWorkflowStore');
        this.status = store.getById(this.config.workflowstatus);

        // update custom url, global var contextPath is not available until after page load
        this.config.actionbeanUrl = contextPath + "/action/feature/ibissplit";

        this.maincontainer.insert(2, {
            id: this.name + "datumMutatie",
            margin: 5,
            fieldLabel: 'Splitsingsdatum',
            xtype: 'datefield',
            itemId: mutatiedatumFieldName,
            value: new Date()
        });
        return this;
    },
    /**
     * add a workflow_status, reden, datum_mutatie
     * @override
     */
    getExtraData: function () {
        var obj = {};
        obj[workflowFieldName] = this.status.get("id");
        obj[mutatiedatumFieldName] = this.maincontainer.getComponent(mutatiedatumFieldName).getValue();
        // reden veld ontbreekt in datamodel! en terreinen kunnen niet gesplitst worden
        // obj[redenFieldName] = 'splitsing';
        return Ext.util.JSON.encode(obj);
    },
    handleFeature: function (feature) {
        this.superclass.handleFeature.call(this, feature);
        if (feature !== null) {
            this.maincontainer.getComponent(mutatiedatumFieldName).setMinValue(
                    getMinMutatiedatum(feature[mutatiedatumFieldName]));
        }
    },
    save: function () {
        if (this.maincontainer.getComponent(mutatiedatumFieldName).isValid()) {
            this.superclass.save.call(this);
        }
    },
    saveSucces: function (response, me) {
        Ext.Object.eachValue(me.config.viewerController.app.appLayers, function (appLayer) {
            if (appLayer.layerName === terreinenLayerName) {
                me.config.viewerController.getLayer(appLayer).reload();
            }
        });
        me.config.viewerController.getLayer(me.layerSelector.getValue()).reload();
        me.cancel();
    },
    /**
     * Return the name of the superclass to inherit the css property.
     * @returns {String} base class name
     * @override
     */
    getBaseClass: function () {
        return this.superclass.self.getName().replace(/\./g, '');
    }
});

