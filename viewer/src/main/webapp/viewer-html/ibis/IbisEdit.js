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
    workflow_fieldname: null,
    workflowStore: null,
    tabbedFormPanels: {},
    addedTabPanels: [],
    config: {
        prefixConfig: []
    },
    newID: null,
    /**
     * Create our component.
     * @constructor
     * @param {Object} conf configuration data object
     * @returns {viewer.components.IbisEdit}
     */
    constructor: function (conf) {
        if (conf.hasOwnProperty('prefixConfig') && conf.prefixConfig.length !== 0) {
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
        this.maincontainer.add([{
                id: this.name + "workflowLabel",
                margin: 5,
                text: '',
                xtype: "label"}
        ]);

        return this;
    },
    initAttributeInputs: function (appLayer) {
        if (this.config.prefixConfig.length !== 0) {
            this.inputContainer.getLayout().multi = true;
        }
        this.superclass.initAttributeInputs.call(this, appLayer);
        this.groupInputsByPrefix(appLayer);
        if (user !== null && user.roles) {
            setNextIbisWorkflowStatus(user.roles, null, null);
        } else {
            this.cancel();
            Ext.Msg.alert('Workflow Fout', "Uitlezen van gebruikers rollen is mislukt, workflow editing niet mogelijk. <br/>Bent U aangemeld met de juiste rol?");
        }
    },
    groupInputsByPrefix: function () {
        if (this.config.prefixConfig.length === 0) {
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
                align: 'stretch'
            },
            defaults: {
                margin: '0 0 5 0'
            }
        };
        this.tabbedFormPanels = {
            '__unprefixed__': Ext.create('Ext.panel.Panel', Ext.Object.merge({}, defaultConfig, {title: 'Algemeen', collapsed: false, dockedItems: this.getBottomBar('__unprefixed__')}))
        };
        var next;
        var prefix;
        for (var i = 0; i < this.config.prefixConfig.length; i++) {
            next = this.config.prefixConfig[i + 1] || null;
            prefix = this.getPrefix(this.config.prefixConfig[i].prefix);
            this.tabbedFormPanels[prefix] = Ext.create('Ext.panel.Panel',
                    Ext.Object.merge({}, defaultConfig, {
                        title: this.config.prefixConfig[i].label,
                        dockedItems: next !== null ? this.getBottomBar(prefix) : {}
                    })
                    );
        }
        var me = this;
        itemList.each(function (item) {
            var fieldName = item.getName();
            var fieldPrefix = fieldName.substr(0, 2);
            if (!me.tabbedFormPanels.hasOwnProperty(fieldPrefix)) {
                fieldPrefix = '__unprefixed__';
            }
            me.tabbedFormPanels[fieldPrefix].add(item);
            return true;
        });
        this.addedTabPanels = [];
        for (var key in this.tabbedFormPanels) {
            if (this.tabbedFormPanels.hasOwnProperty(key)) {
                if (this.addFieldSet(this.tabbedFormPanels[key])) {
                    this.addedTabPanels.push(key);
                }
            }
        }
        if(this.addedTabPanels.length === 1) {
        	var bottombar = this.tabbedFormPanels[this.addedTabPanels[0]].getDockedItems('toolbar[dock="bottom"]');
        	if(bottombar.length === 1) {
        		this.tabbedFormPanels[this.addedTabPanels[0]].removeDocked(bottombar[0]);
        	}
        }
        this.inputContainer.getLayout().multi = false;
    },
    getPrefix: function (prefix) {
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
        var nextPrefix = null;
        for(var i = 0; i < this.addedTabPanels.length; i++) {
            if(step === this.addedTabPanels[i]) {
                nextPrefix = this.addedTabPanels[i + 1] || null;
            }
        }
        if(nextPrefix === null) {
            return;
        }
        this.tabbedFormPanels[nextPrefix].expand();
    },
    addFieldSet: function (fieldSet) {
        if (fieldSet.items.length === 0) {
            return false;
        }
        this.inputContainer.add(fieldSet);
        return true;
    },
    handleFeature: function (feature) {
        this.superclass.handleFeature.call(this, feature);

        if (Ext.getCmp(this.workflow_fieldname) === undefined) {

            // workflow field is missing, add a hidden one to __unprefixed__ accordion of the form panels
            // if added to inputContainer it will throw a layout error
            this.tabbedFormPanels.__unprefixed__.add({
                xtype: 'combo',
                hidden: true,
                name: this.workflow_fieldname,
                id: this.workflow_fieldname,
                valueField: 'id',
                displayField: 'label',
                value: this.workflowStore.getById('bewerkt'),
                store: 'IbisWorkflowStore'
            });
        }

        this.inputContainer.getForm().findField(mutatiedatumFieldName).setMinValue(
                getMinMutatiedatum(feature[mutatiedatumFieldName]));
        this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(new Date());
        var s = "";
        if (this.mode === "copy") {
            setNextIbisWorkflowStatus({}, 'bewerkt', Ext.getCmp(this.workflow_fieldname));
            s = this.workflowStore.getById('bewerkt').get("label");
        } else {
            setNextIbisWorkflowStatus(user.roles, feature[this.workflow_fieldname], Ext.getCmp(this.workflow_fieldname));
            var wf = feature[this.workflow_fieldname] || 'bewerkt';
            s = this.workflowStore.getById(wf).get("label");
        }
        // label uitgezet mail Ruben 12/6
        // Ext.getCmp(this.name + "workflowLabel").setText("Oude workflow status: " + s);

        // titelgegevens uit het formulier lezen
        var t = '';
        if (this.inputContainer.getForm().findField('gemeentenaam')) {
            t += this.inputContainer.getForm().findField('gemeentenaam').getRawValue() + ', ';
        }
        if (this.inputContainer.getForm().findField(planNaamFieldName)) {
            t += this.inputContainer.getForm().findField(planNaamFieldName).getRawValue() + ', ';
        }
        if (this.inputContainer.getForm().findField(terreinidFieldName)) {
            t += this.inputContainer.getForm().findField(terreinidFieldName).getRawValue() + ' ';
        }
        if (this.inputContainer.getForm().findField(rinnrFieldName)) {
            t += 'RIN:' + this.inputContainer.getForm().findField(rinnrFieldName).getRawValue();
        }
        this.popup.popupWin.setTitle(t);
    },
    resetForm: function () {
        this.superclass.resetForm.call(this);
        this.popup.popupWin.setTitle(this.config.title);
    },
    createNew: function () {
        this.superclass.createNew.call(this);
        setNextIbisWorkflowStatus(user.roles, 'bewerkt', Ext.getCmp(this.workflow_fieldname));
        var s = this.workflowStore.getById('bewerkt').get("label");
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);

        this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(new Date());
        this.inputContainer.getForm().findField('status').setValue('Niet bekend');

        // generate a new, pseudo-unique id for this feature
        // millisecond precision requires database schema update to swith id from integer to bigint
        // alter table bedrijventerrein alter id type bigint;
        // alter table bedrijvenkavels alter id type bigint;
        // var newID = new Date().getTime();
        // for now we'll use second precision
        this.newID = new Date() / 1000 | 0;
        if (this.inputContainer.getForm().findField(idFieldName)) {
            this.inputContainer.getForm().findField(idFieldName).setValue(this.newID);
        }
    },
    deleteFeature: function () {
        this.superclass.deleteFeature.call(this);
        setNextIbisWorkflowStatus(user.roles, 'afgevoerd', Ext.getCmp(this.workflow_fieldname));
        var s = this.workflowStore.getById('afgevoerd').get('label');
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
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

        if (this.geometryEditable) {
            if (this.vectorLayer.getActiveFeature()) {
                var wkt = this.vectorLayer.getActiveFeature().config.wktgeom;
                feature[this.appLayer.geometryAttribute] = wkt;
            }
        }
        if (this.mode === "edit") {
            feature.__fid = this.currentFID;
        }
        if (this.mode === "copy") {
            feature.__fid = null;
        }

        if ((this.mode === "new")) {
            if (!feature[idFieldName]) {
                feature[idFieldName] = this.newID;
            }
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
    /**
     * Set workflow status on the feature before trying to save.
     * @override
     * @return the changed feature
     */
    changeFeatureBeforeSave: function (feature) {
        if (this.mode === "copy") {
            // in copy mode force 'bewerkt' and delete the fid
            feature[this.workflow_fieldname] = this.workflowStore.getById('bewerkt').getId();
            this.currentFID = null;
            delete feature.__fid;
        }

        return feature;
    },
    saveSucces: function (fid) {
        var me = this;
        Ext.Object.eachValue(this.config.viewerController.app.appLayers, function (appLayer) {
            if (appLayer.layerName === terreinenLayerName) {
                me.config.viewerController.getLayer(appLayer).reload();
            }
        });
        this.editingLayer.reload();
        this.currentFID = fid;
        this.cancel();
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