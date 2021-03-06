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
 * Ibis Edit component.
 * @author mprins
 */
Ext.define("viewer.components.IbisEdit", {
    extend: "viewer.components.Edit",
    workflow_fieldname: null,
    workflowStore: null,
    tabbedFormPanels: {},
    addedTabPanels: [],
    rejectButton: null,
    config: {
        prefixConfig: [],
        showVorigeDefintiefVersie: false,
        allowReject: false
    },
    newID: null,
    /**
     * Create our component.
     * @constructor
     * @param {Object} conf configuration data object
     * @returns {viewer.components.IbisEdit}
     */
    constructor: function (conf) {
        this.initConfig(conf);
        if (conf.hasOwnProperty('prefixConfig') && conf.prefixConfig.length !== 0) {
            conf.formLayout = {
                type: 'accordion',
                titleCollapse: true,
                animate: true,
                activeOnTop: false,
                multi: true
            };
        }
        viewer.components.IbisEdit.superclass.constructor.call(this, this.config);
        this.workflow_fieldname = workflowFieldName;
        this.workflowStore = Ext.data.StoreManager.lookup('IbisWorkflowStore');

        return this;
    },
    /** @override */
    loadWindow: function () {
        this.callParent();
        this.geomlabel.up()
            .insert(4,{
            id: this.name + "workflowLabel",
            margin: 5,
            text: '',
            xtype: "label"
        });

        if (this.config.allowReject){
            this.savebutton.up().add(this.createButton("rejectButton","Afkeuren", this.rejectFeature, true));
        }
        this.rejectButton = this.maincontainer.down("#rejectButton");
    },
    initAttributeInputs: function (appLayer) {
        if (this.config.prefixConfig.length !== 0) {
            this.inputContainer.getLayout().multi = true;
        }
        this.callParent(arguments);
        this.groupInputsByPrefix(appLayer);
        var _user = FlamingoAppLoader.get('user');
        if (_user !== null && _user.roles) {
            setNextIbisWorkflowStatus(_user.roles, null, null);
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
            '__unprefixed__': Ext.create('Ext.panel.Panel', Ext.Object.merge({}, defaultConfig, {
                title: 'Algemeen',
                items: this._getWasWordtHeader(),
                collapsed: false,
                dockedItems: this.getBottomBar('__unprefixed__')
            }))
        };
        var next;
        var prefix;
        for (var i = 0; i < this.config.prefixConfig.length; i++) {
            next = this.config.prefixConfig[i + 1] || null;
            prefix = this.getPrefix(this.config.prefixConfig[i].prefix);
            this.tabbedFormPanels[prefix] = Ext.create('Ext.panel.Panel',
                    Ext.Object.merge({}, defaultConfig, {
                        title: this.config.prefixConfig[i].label,
                        items: this._getWasWordtHeader(),
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
        if (this.addedTabPanels.length === 1) {
            var bottombar = this.tabbedFormPanels[this.addedTabPanels[0]].getDockedItems('toolbar[dock="bottom"]');
            if (bottombar.length === 1) {
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
        for (var i = 0; i < this.addedTabPanels.length; i++) {
            if (step === this.addedTabPanels[i]) {
                nextPrefix = this.addedTabPanels[i + 1] || null;
            }
        }
        if (nextPrefix === null) {
            return;
        }
        this.tabbedFormPanels[nextPrefix].expand();
        this.tabbedFormPanels[step].collapse();
    },
    addFieldSet: function (fieldSet) {
        if (fieldSet.items.length === 0) {
            return false;
        }
        this.inputContainer.add(fieldSet);
        return true;
    },
    handleFeature: function (feature) {
        this.callParent(arguments);

        if (this.inputContainer.getForm().findField(this.workflow_fieldname) === undefined) {
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
        if (this.config.allowReject && feature[workflowFieldName] === 'bewerkt' &&
            (this.layerSelector.getSelectedAppLayer().layerName === 'bedrijvenkavels' || this.layerSelector.getSelectedAppLayer().layerName === 'bedrijventerrein')) {
            if (this.rejectButton) this.rejectButton.setDisabled(false);
        } else {
            if (this.rejectButton) this.rejectButton.setDisabled(true);
        }

        if (feature[workflowFieldName] === 'bewerkt'){
            // hou bestaande "bewerkt" datum
            var defDate = Ext.Date.parse(feature[mutatiedatumFieldName], 'd-m-Y H:i:s');
            this.inputContainer.getForm().findField(mutatiedatumFieldName).setMinValue(defDate);
            this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(defDate);
        } else {
            // stel in op vandaag
            this.inputContainer.getForm().findField(mutatiedatumFieldName).setMinValue(getMinMutatiedatum(feature[mutatiedatumFieldName]));
            this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(new Date());
        }
        var s = "";
        if (this.mode === "copy") {
            setNextIbisWorkflowStatus({}, 'bewerkt', this.inputContainer.getForm().findField(this.workflow_fieldname));
            s = this.workflowStore.getById('bewerkt').get("label");
        } else {
            setNextIbisWorkflowStatus(FlamingoAppLoader.get('user').roles, feature[this.workflow_fieldname], this.inputContainer.getForm().findField(this.workflow_fieldname));
            var wf = feature[this.workflow_fieldname] || 'bewerkt';
            s = this.workflowStore.getById(wf).get("label");
        }
        if (this.config.showVorigeDefintiefVersie && feature[this.workflow_fieldname] &&
                (feature[this.workflow_fieldname] === "bewerkt" || feature[this.workflow_fieldname] === "definitief")) {
            // get kavel/terrein voor ibis_id/definitief
            this.getDefinitiefFeature(feature);
        }
        // schakel verwijderen (== saveButton) knop uit als 'definitief' wordt geladen in delete mode
        if (this.inputContainer.getForm().findField(this.workflow_fieldname).getValue() === "definitief" && this.mode === "delete") {
            this.savebutton.setDisabled(true);
            this.savebutton.setText("'Definitief' object mag niet verwijderd worden");
        }
        // verberg verwijderen knop als iets anders als 'bewerkt' wordt geladen
        if (this.inputContainer.getForm().findField(this.workflow_fieldname).getValue() !== "bewerkt") {
            // de button wordt hersteld in #showWindow
            this.setButtonDisabled("deleteButton", true);
            var button = this.maincontainer.down("#deleteButton");
            if (button) {
                button.hide();
            }
        }
        // verberg lege tabbladen, nodig omdat er nu altijd was/wordt kolom in zit
        for (var i = 0; i < this.config.prefixConfig.length; i++) {
            prefix = this.getPrefix(this.config.prefixConfig[i].prefix);
            if (this.tabbedFormPanels[prefix].items.length < 2) {
                this.tabbedFormPanels[prefix].hide();
            }
        }
    },
    /**
     * herstel de delete button, die is mogelijk verborgen door #handleFeature.
     * @returns {undefined}
     * @override
     */
    showWindow: function () {
        this.setButtonDisabled("deleteButton", false);
        var button = this.maincontainer.down("#deleteButton");
        if (button) {
            button.show();
        }
        this.callParent();
    },

    getDefinitiefFeature: function (bewerktFeature) {
        var me = this;
        var options = {
            arrays: 0,
            featureType: me.appLayer.featureType,
            filter: "ibis_id=" + bewerktFeature[idFieldName] + " AND workflow_status='definitief'",
            limit: 1,
            page: 1,
            start: 0,
            aliases: 0,
            includeRelations: 0
        };
        //  ajax for definitief feature
        this.config.viewerController.getAppLayerFeatureService(me.appLayer).loadFeatures(
                me.appLayer,
                function (result) {
                    Ext.each(result, function (ob) {
                        Ext.Object.each(ob, function (property, value) {
                            var lbl = Ext.get(property + '_def');
                            var f = me.inputContainer.getForm().findField(property);
                            if (lbl) {
                                if (f) {
                                    var defVal = f.getValue();
                                    if (property === me.workflow_fieldname) {
                                        value = me.workflowStore.getById(value).get("label");
                                        defVal = me.workflowStore.getById(defVal).get("label");
                                    }
                                    if (f.getXType() === "datefield") {
                                        value = Ext.Date.format(Ext.Date.parse(value, 'd-m-Y H:i:s'), f.format);
                                        defVal = Ext.Date.format(defVal, f.format);
                                    }
                                    if (defVal != value) {
                                        // afwijkende waarde markeren
                                        lbl.setHtml('<span class="def_verschillend">' + value + '</span>');
                                        lbl.setStyle('border-width', '1px');
                                    } else {
                                        lbl.setHtml('<span class="def_identiek">' + value + '</span>');
                                    }
                                    if (property === mutatiedatumFieldName) {
                                        f.setMinValue(value);
                                    }
                                }
                            }
                        });
                        me.geomlabel.setHtml("In de linker kolom staan de voorgestelde aanpassingen");
                    });
                },
                function (result) {
                    Ext.MessageBox.alert("Ajax request failed with status " + result);
                },
                options,
                me);

    },
    /**
     * override createStaticInput welke een input element teruggeeft om die dan te
     * wrappen met een container met een extra box waarin de oude/defintieve waarde geladen kan worden.
     * @see _wrapInput
     */
    createStaticInput: function (attribute, values) {
        //var inputEle = this.superclass.createStaticInput.call(this, attribute, values);
        var inputEle = this.callParent(arguments);
        return this._wrapInput(inputEle, attribute.name);
    },
    /**
     * override createDynamicInput welke een input element teruggeeft om die dan te wrappen
     * met een container met een extra box waarin de oude/defintieve waarde geladen kan worden.
     * @see _wrapInput
     */
    createDynamicInput: function (attribute, values) {
        //var inputEle = this.superclass.createDynamicInput.call(this, attribute, values);
        var inputEle = this.callParent(arguments);
        return this._wrapInput(inputEle, attribute.name);
    },
    /**
     * wrap input element.
     *
     * @param {Ext.form.field.Field} inputEle
     * @returns {Ext.form.field.Field} optionally wrapped in a {Ext.container.Container}
     * @private
     */
    _wrapInput: function (inputEle, attributeName) {
        var input = inputEle;
        if (this.config.showVorigeDefintiefVersie) {
            inputEle.setFlex(2);
            input = Ext.create('Ext.container.Container', {
                layout: {
                    type: 'hbox',
                    align: 'stretch'
                }, items: [
                    inputEle,
                    {
                        xtype: 'box',
                        html: '',
                        flex: 1,
                        id: attributeName + '_def',
                        width: 100,
                        cls: 'x-form-text-default def_container',
                        border: 0,
                        style: {
                            borderColor: 'red',
                            borderStyle: 'dotted'
                        }
                    }
                ]
            });
            input.setReadOnly = function (readOnly) {
                inputEle.setReadOnly(readOnly);
                inputEle.addCls("x-item-disabled");
            };
            input.getName = function () {
                return inputEle.getName();
            };
        }
        return input;
    },
    _getWasWordtHeader: function() {
        var header = [];
        if (this.config.showVorigeDefintiefVersie) {
            header = Ext.create('Ext.container.Container', {
                layout: {
                    type: 'hbox',
                    align: 'stretch'
                },
                items: [
                    {
                        itemId: "headingLabelA",
                        margin: '0 0',
                        flex: 1,
                        html: '',
                        xtype: "container"
                    },
                    {
                        itemId: "headingLabelB",
                        margin: '0 0',
                        flex: 1,
                        html: 'Wordt',
                        xtype: "container"
                    },
                    {
                        itemId: "headingLabelC",
                        margin: '0 0',
                        flex: 1,
                        html: 'Was',
                        xtype: "container"
                    }
                ]
            });
        }
        return header;
    },
    resetForm: function () {
        this.callParent();
        this.popup.popupWin.setTitle(this.config.title);
        this.savebutton.setDisabled(false);
    },
    createNew: function () {
        this.callParent();
        // generate a new, pseudo-unique id for this feature
        // millisecond precision requires database schema update to swith id from integer to bigint
        // alter table bedrijventerrein alter id type bigint;
        // alter table bedrijvenkavels alter id type bigint;
        // var newID = new Date().getTime();
        // for now we'll use second precision
        this.newID = new Date() / 1000 | 0;

        setNextIbisWorkflowStatus(FlamingoAppLoader.get('user').roles, 'bewerkt', this.inputContainer.getForm().findField(this.workflow_fieldname));
        var s = this.workflowStore.getById('bewerkt').get("label");
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);

        this.inputContainer.getForm().findField(mutatiedatumFieldName).setValue(new Date());
        if (this.inputContainer.getForm().findField(idFieldName)) {
            this.inputContainer.getForm().findField(idFieldName).setValue(this.newID);
        }
        if (this.inputContainer.getForm().findField('status')) {
            this.inputContainer.getForm().findField('status').setValue('Niet bekend');
        }
    },
    deleteFeature: function () {
        this.callParent();
        setNextIbisWorkflowStatus(FlamingoAppLoader.get('user').roles, 'afgevoerd', this.inputContainer.getForm().findField(this.workflow_fieldname));
        var s = this.workflowStore.getById('afgevoerd').get('label');
        Ext.getCmp(this.name + "workflowLabel").setText("Huidige workflow status: " + s);
    },
    rejectFeature: function(){
        if (!this.config.allowReject) {
            Ext.Msg.alert('Mislukt', "Afkeuren is niet toegestaan.");
            return;
        }

        var feature = this.inputContainer.getValues();
        feature.__fid = this.currentFID;

        var me = this;
        me.editingLayer = this.config.viewerController.getLayer(this.layerSelector.getValue());
        Ext.create("viewer.EditFeature", {
            viewerController: this.config.viewerController,
            actionbeanUrl: contextPath + '/action/feature/ibisedit?delete'
        }).remove(
            me.editingLayer,
            feature,
            function (fid) {
                me.deleteSucces();
            }, function (error) {
                me.failed(error);
            },{
                reject: true
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
    deleteSucces:function(fid){
        this.currentFID = null;
        this.saveSucces();
    },
    saveSucces: function (fid) {
        var me = this;
        Ext.Object.eachValue(this.config.viewerController.app.appLayers, function (appLayer) {
            // alle aangevinkte lagen verversen
            var layer = me.config.viewerController.getLayer(appLayer);
            if (layer && me.config.viewerController.getLayerChecked(appLayer)) {
                layer.reload();
            }
        });
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
