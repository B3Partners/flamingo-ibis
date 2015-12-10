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

// The name of the some of the attribute fields in the datamodel;
//    TODO ideally these should come from a property fed bean

var terreinenLayerName = "bedrijventerrein";
var workflowFieldName = "workflow_status";
var mutatiedatumFieldName = "datummutatie";
var redenFieldName = "reden";
var idFieldName = "id";
var terreinidFieldName = "terreinid";
var planNaamFieldName = "a_plannaam";
var bboxTerreinFieldName = "bbox_terrein";
var gemeenteFieldName = "naam";
var bboxGemeenteFieldName = "bbox_gemeente";
var regioFieldName = "vvr_naam";
var bboxRegioFieldName = "bbox_regio";
var rinnrFieldName = "rin_nr";

/**
 * @description this file provides some globals regarding workflow status voor Ibis.
 */
if (!Ext.data.StoreManager.lookup('IbisWorkflowStore')) {
    // Check if this store is registered so we only define/create this store once
    Ext.define('IbisWorkflowModel', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            {name: 'id'},
            {name: 'label'}
        ]
    });
    /* mimic WorkflowStatus.java */
    Ext.create(
            'Ext.data.Store', {
                model: 'IbisWorkflowModel',
                storeId: 'IbisWorkflowStore',
                data: [
                    {id: 'bewerkt', label: "Bewerkt"},
                    {id: 'definitief', label: "Definitief"},
                    {id: 'archief', label: "Archief"},
                    {id: 'afgevoerd', label: "Afgevoerd"}
                ]}
    );
}

/**
 * Set the next status in the workflow on the store that is controlling the combo.
 *
 * @param {Object} userRoles The set of roles of the current user
 * @param {Status} statusId the current workflow status
 * @param {Ext.form.ComboBox} comboBox for display
 */
function setNextIbisWorkflowStatus(userRoles, statusId, comboBox) {
    // get the first workflow role
    var workflowRole = "";
    for (var role in userRoles) {
        if (role.indexOf("workflow_", 0) === 0) {
            workflowRole = role;
            break;
        }
    }

    var possibleNextStatus = null;
    switch (workflowRole) {
        case "workflow_gemeente":
            // iedere wijziging van een gemeente medewerker leidt tot workflow_status=bewerkt
            possibleNextStatus = ['bewerkt'];
            break;
        case "workflow_provincie":
            // provincie kan iedere status instellen
            possibleNextStatus = ['bewerkt', 'definitief', 'archief', 'afgevoerd'];
            break;
        case "workflow_admin":
            // kan alles, geen filter
            possibleNextStatus = ['bewerkt', 'definitief', 'archief', 'afgevoerd'];
            break;
        default:
            // onbekende/lege gebruikers rol??
            possibleNextStatus = ['bewerkt'];
            break;
    }

    if (possibleNextStatus) {
        // filter toepassen
        var store = Ext.data.StoreManager.lookup('IbisWorkflowStore');
        var filter = Ext.create('Ext.util.Filter', {
            operator: 'in',
            property: 'id',
            value: possibleNextStatus
        });

        store.clearFilter(/*suppressEvent*/ false);
        store.addFilter(filter, /*suppressEvent*/ false);

        if (comboBox) {
            var cmbStore = comboBox.getStore();
            cmbStore.clearFilter(/*suppressEvent*/ true);
            cmbStore.addFilter(filter, /*suppressEvent*/ false);

            var recNo = cmbStore.find('id', statusId);
            if (recNo > -1) {
                // try to set to current value
                comboBox.select(cmbStore.getAt(recNo));
            } else {
                // set to only or first available option
                comboBox.select(cmbStore.getAt(0));
            }
        }
    }
}

/**
 * return a date  one hour before feature date.
 * @param {String} date
 * @returns {Date} minimum mutatie datum
 */
function getMinMutatiedatum(date) {
    // the format is fixed in Flamingo, see Edit.js and FeatureToJson#formatValue
    if (date) {
        var minMutDate = Ext.Date.parse(date, 'd-m-Y H:i:s');
        minMutDate = Ext.Date.subtract(minMutDate, 1, Ext.Date.HOUR);
    } else {
        minMutDate = new date();
    }
    return minMutDate;
}