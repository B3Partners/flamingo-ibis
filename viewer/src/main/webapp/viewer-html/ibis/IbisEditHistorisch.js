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
    renderButton: function () {
        var me = this;
        this.superclass.renderButton.call(this, {
            text: me.config.title,
            icon: 'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICBpZD0ic3ZnNiIKICAgc3R5bGU9ImZpbGwtcnVsZTpldmVub2RkO2NsaXAtcnVsZTpldmVub2RkO3N0cm9rZS1taXRlcmxpbWl0OjEuNDE0MjE7ZmlsbDojOTZCRkQyIgogICB4bWw6c3BhY2U9InByZXNlcnZlIgogICB2ZXJzaW9uPSIxLjEiCiAgIHZpZXdCb3g9IjAgMCAzMiAzMiIKICAgaGVpZ2h0PSIxMDAlIgogICB3aWR0aD0iMTAwJSI+CiAgICA8cGF0aAogICBpZD0icGF0aDIiCiAgIHN0eWxlPSJmaWxsLXJ1bGU6bm9uemVybztzdHJva2Utb3BhY2l0eTowO2ZpbGwtb3BhY2l0eToxIgogICBkPSJNOS4yMywyNi44MDRsMS41NjIsLTEuNTYybC00LjAzMywtNC4wMzNsLTEuNTYyLDEuNTYybDAsMS44MzZsMi4xOTYsMGwwLDIuMTk4bDEuODM4LDBsLTAuMDAxLC0wLjAwMWwwLDBaTTE4LjIwNSwxMC44NzhjMCwtMC4yNTMgLTAuMTI2LC0wLjM3OCAtMC4zNzgsLTAuMzc4Yy0wLjExNCwwIC0wLjIxMiwwLjAzOSAtMC4yOTIsMC4xMmwtOS4zMDIsOS4zMDFjLTAuMDgsMC4wOCAtMC4xMiwwLjE3OCAtMC4xMiwwLjI5M2MwLDAuMjUxIDAuMTI2LDAuMzc4IDAuMzc3LDAuMzc4YzAuMTE2LDAgMC4yMTMsLTAuMDQxIDAuMjkzLC0wLjEyMWw5LjMwMiwtOS4zMDFjMC4wOCwtMC4wODEgMC4xMiwtMC4xNzggMC4xMiwtMC4yOTJsMCwwWk0xNy4yNzgsNy41ODNsNy4xNCw3LjEzOWwtMTQuMjc4LDE0LjI3OGwtNy4xNCwwbDAsLTcuMTM5bDE0LjI3OCwtMTQuMjc4bDAsMFpNMjksOS4yM2MwLDAuNjA2IC0wLjIxMSwxLjEyMSAtMC42MzQsMS41NDRsLTIuODQ5LDIuODQ5bC03LjE0LC03LjEzOWwyLjg0OSwtMi44MzJjMC40MTEsLTAuNDM0IDAuOTI2LC0wLjY1MiAxLjU0NCwtMC42NTJjMC42MDYsMCAxLjEyNywwLjIxOCAxLjU2MiwwLjY1Mmw0LjAzMyw0LjAxN2MwLjQyMywwLjQ0NSAwLjYzNCwwLjk2NiAwLjYzNCwxLjU2MWwwLjAwMSwwWiIgLz4KICAgIDxwYXRoCiAgIGlkPSJwYXRoNCIKICAgc3R5bGU9ImZpbGwtcnVsZTpub256ZXJvO3N0cm9rZS13aWR0aDoxcHg7IgogICBkPSJNMTcsMjIuMzA1bDMuMzA1LDBsMCwtMy4zMDVsMy4zOSwwbDAsMy4zMDVsMy4zMDUsMGwwLDMuMzlsLTMuMzA1LDBsMCwzLjMwNWwtMy4zOSwwbDAsLTMuMzA1bC0zLjMwNSwwbDAsLTMuMzlaIiAvPgo8cGF0aAogICBzdHlsZT0ic3Ryb2tlLXdpZHRoOjAuMDEzNTkzOSIKICAgZD0ibSA4LjEyOTkzNzcsMi4yNTUyNzg5IGMgLTMuMTUzNzg4MywwIC01LjcwOTQ0NDQsMi41NTU2NTYyIC01LjcwOTQ0NDQsNS43MDk0NDQ0IEggMC41MTczNDYyOSBMIDMuMDU1MzI5NywxMC41MDI3MDcgNS41OTMzMTMxLDcuOTY0NzIzMyBIIDMuNjg4ODA1NSBjIDAsLTIuNDU1MDYwNCAxLjk4NjA3MTcsLTQuNDQxMTMwNCA0LjQ0MTEzMjIsLTQuNDQxMTMwNCAyLjQ1NTA2MDMsMCA0LjQ0MTEzMDMsMS45ODYwNyA0LjQ0MTEzMDMsNC40NDExMzA0IDAsMi40NTUwNTg3IC0xLjk4NjA3LDQuNDQxMTMxNyAtNC40NDExMzAzLDQuNDQxMTMxNyAtMC45NTcwMTI3LDAgLTEuODQ2MDUzNywtMC4zMTEzMDMgLTIuNTc0Njg3OSwtMC44MjUxNTEgTCA0LjY1NTMzNCwxMi40OTI4NTMgYyAwLjk2MjQ0ODIsMC43MzY3OTIgMi4xNjgyMjgsMS4xODEzMTMgMy40NzQ2MDM3LDEuMTgxMzEzIDMuMTUzNzg2MywwIDUuNzA5NDQzMywtMi41NTcwMTUgNS43MDk0NDMzLC01LjcwOTQ0MjcgMCwtMy4xNTM3ODgyIC0yLjU1NzAxNiwtNS43MDk0NDQ0IC01LjcwOTQ0MzMsLTUuNzA5NDQ0NCB6IG0gMC4zMTY3MzcsMi41Mzc5ODUyIEggNy40OTUxMDEyIFYgOC41OTk1NTggTCAxMC41MDg4NzIsMTAuNDA3NTUgMTAuOTg0NjU4LDkuNjI3MjU4MiA4LjQ0NjY3NDcsOC4xMjM3NzEyIFoiCiAgIGlkPSJwYXRoNDU0MyIgLz48cGF0aAogICBpZD0icGF0aDUxMzQiCiAgIGQ9Ik0gNy4yMTQwNjA1LDEzLjUyMTkgQyA2LjQ3NzY2NTUsMTMuMzk3MTUzIDUuNTAzMjg3MywxMy4wMTQyMDYgNS4wNTc2MjcxLDEyLjY3NDM4NSA0Ljc4OTc2MiwxMi40NzAxMzQgNC43OTEwNTMzLDEyLjQ2Mjc3MyA1LjE2MzA1NTksMTIuMDczMzMxIGwgMC4zNzY2MTUzLC0wLjM5NDI3IDAuNzA3ODI3NCwwLjM1MDMgYyAwLjYwMzY2NjEsMC4yOTg3NTEgMC44ODc0NTI3LDAuMzUwMTE2IDEuOTI4NDY5NSwwLjM0OTA1MSAxLjA3MDM2NTEsLTAuMDAxMSAxLjMwODg1NTQsLTAuMDQ3NTcgMS45MzcxNjQ5LC0wLjM3NzUyNSAwLjg4MzIyOCwtMC40NjM4MjMgMS42NjMwNTksLTEuMjUwNDUyIDIuMDc5NTM5LC0yLjA5NzY3MDMgMC4yNjIyMDgsLTAuNTMzMzkxNSAwLjMxNjI4LC0wLjg2MDQ0OTQgMC4zMTkxNCwtMS45MzAzMzUzIDAuMDA0LC0xLjUwNjcwODkgLTAuMjgxOTgxLC0yLjI1ODY2MDkgLTEuMjEzMzI4LC0zLjE5MDAwOSBDIDEwLjM2ODk4MywzLjg1MzM3MjIgOS42MTUxNTI0LDMuNTY1OTkxMiA4LjEwODQ3NDYsMy41NjY3NTMyIDYuOTc0NjQ0NSwzLjU2NzMyNjggNi43MzkxMjU2LDMuNjEwNjI2NyA2LjE0MjM3MjksMy45MjgyMTk1IDQuODE2OTUyMSw0LjYzMzYxMDggMy44NzU1MDQ1LDUuOTQxMjQzNyAzLjY4MzI1ODcsNy4zNDM4MyBMIDMuNTk4ODQ1NCw3Ljk1OTY5MTggNC41MDE0Nzk3LDguMDAwMTg0OSA1LjQwNDExNDIsOC4wNDA2NzggNC4yMTExNjY0LDkuMjI3MTkwOSAzLjAxODIxODcsMTAuNDEzNzA0IDEuODAzNDYxOCw5LjE5MzI5MjYgMC41ODg3MDQ4OSw3Ljk3Mjg4MTQgSCAxLjU1MDA5NjQgMi41MTE0ODc5IEwgMi41ODMxNTE3LDcuMTgyNTU4OSBDIDIuNjgzNTA4Miw2LjA3NTgwOTQgMy4yNTkwODk0LDQuOTQwMDIzNiA0LjE5NDkwODEsNC4wMDIxMDM1IDUuNDk1NjU2NCwyLjY5ODQzNDMgNy4yNjM5MDY3LDIuMTAwMjIyMyA4Ljk0MjYxMjEsMi4zOTU5MjA0IDExLjQwMjM3LDIuODI5MTk4MiAxMy4yMzU5MjcsNC42Mzg3NDkgMTMuNjg1MDU5LDcuMDc2Mjc0OCAxNC4xNzU4OTgsOS43NDAxNTY3IDEyLjI3NDI1LDEyLjcyMDI4NiA5LjY2Nzc5NjYsMTMuMzcxODQ1IDguNzc0NTMzMiwxMy41OTUxNDIgNy45NDU2NDc3LDEzLjY0NTgzMSA3LjIxNDA2MDUsMTMuNTIxOSBaIgogICBzdHlsZT0iZmlsbDojODAwMDAwO2ZpbGwtb3BhY2l0eTowLjAzMTM3MjU1O3N0cm9rZS13aWR0aDowLjEzNTU5MzIyIiAvPjxwYXRoCiAgIGlkPSJwYXRoNTEzNiIKICAgZD0iTSA3LjIxNDA2MDUsMTMuNTIxOSBDIDYuNDc3NjY1NSwxMy4zOTcxNTMgNS41MDMyODczLDEzLjAxNDIwNiA1LjA1NzYyNzEsMTIuNjc0Mzg1IDQuNzg5NzYyLDEyLjQ3MDEzNCA0Ljc5MTA1MzMsMTIuNDYyNzczIDUuMTYzMDU1OSwxMi4wNzMzMzEgbCAwLjM3NjYxNTMsLTAuMzk0MjcgMC43MDc4Mjc0LDAuMzUwMyBjIDAuNjAzNjY2MSwwLjI5ODc1MSAwLjg4NzQ1MjcsMC4zNTAxMTYgMS45Mjg0Njk1LDAuMzQ5MDUxIDEuMDcwMzY1MSwtMC4wMDExIDEuMzA4ODU1NCwtMC4wNDc1NyAxLjkzNzE2NDksLTAuMzc3NTI1IDAuODgzMjI4LC0wLjQ2MzgyMyAxLjY2MzA1OSwtMS4yNTA0NTIgMi4wNzk1MzksLTIuMDk3NjcwMyAwLjI2MjIwOCwtMC41MzMzOTE1IDAuMzE2MjgsLTAuODYwNDQ5NCAwLjMxOTE0LC0xLjkzMDMzNTMgMC4wMDQsLTEuNTA2NzA4OSAtMC4yODE5ODEsLTIuMjU4NjYwOSAtMS4yMTMzMjgsLTMuMTkwMDA5IEMgMTAuMzY4OTgzLDMuODUzMzcyMiA5LjYxNTE1MjQsMy41NjU5OTEyIDguMTA4NDc0NiwzLjU2Njc1MzIgNi45NzQ2NDQ1LDMuNTY3MzI2OCA2LjczOTEyNTYsMy42MTA2MjY3IDYuMTQyMzcyOSwzLjkyODIxOTUgNC44MTY5NTIxLDQuNjMzNjEwOCAzLjg3NTUwNDUsNS45NDEyNDM3IDMuNjgzMjU4Nyw3LjM0MzgzIEwgMy41OTg4NDU0LDcuOTU5NjkxOCA0LjUwMTQ3OTcsOC4wMDAxODQ5IDUuNDA0MTE0Miw4LjA0MDY3OCA0LjIxMTE2NjQsOS4yMjcxOTA5IDMuMDE4MjE4NywxMC40MTM3MDQgMS44MDM0NjE4LDkuMTkzMjkyNiAwLjU4ODcwNDg5LDcuOTcyODgxNCBIIDEuNTUwMDk2NCAyLjUxMTQ4NzkgTCAyLjU4MzE1MTcsNy4xODI1NTg5IEMgMi44NDg1MjE1LDQuMjU2MDE1MSA2LjAwNjg1ODgsMS44Nzg3OTc3IDguOTQyNjEyMSwyLjM5NTkyMDQgMTEuNDAyMzcsMi44MjkxOTgyIDEzLjIzNTkyNyw0LjYzODc0OSAxMy42ODUwNTksNy4wNzYyNzQ4IDE0LjE3NTg5OCw5Ljc0MDE1NjcgMTIuMjc0MjUsMTIuNzIwMjg2IDkuNjY3Nzk2NiwxMy4zNzE4NDUgOC43NzQ1MzMyLDEzLjU5NTE0MiA3Ljk0NTY0NzcsMTMuNjQ1ODMxIDcuMjE0MDYwNSwxMy41MjE5IFoiCiAgIHN0eWxlPSJmaWxsOiM4MDAwMDA7ZmlsbC1vcGFjaXR5OjAuMDMxMzcyNTU7c3Ryb2tlLXdpZHRoOjAuMTM1NTkzMjIiIC8+PC9zdmc+',
            tooltip: me.config.tooltip,
            label: me.config.label,
            handler: function () {
                me.showWindow();
            }
        });
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
    // /**
    //  * Return the name of the superclass to inherit the css property.
    //  * @returns {String} base class name
    //  * @override
    //  */
    // getBaseClass: function () {
    //     return this.superclass.getBaseClass.call(this.superclass);
    // }
});
