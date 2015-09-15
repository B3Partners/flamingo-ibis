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
 * @description this file provides some globals
 */
/**
 * the name of the workflow attribute field in the datamodel.
 * @type String
 */
var workflowFieldName = "workflow_status";

/**
 * workflow status voor Ibis.
 */
if (!Ext.data.StoreManager.lookup('IbisWorkflowStore')) {
    // only define/create this store once
    Ext.define('IbisWorkflowModel', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            {name: 'id'},
            {name: 'label'}
        ]
    });
// mimic WorkflowStatus.java
    Ext.create(
            'Ext.data.Store', {
                model: 'IbisWorkflowModel',
                storeId: 'IbisWorkflowStore',
                data: [
                    {id: 'nieuw', label: "Nieuw"},
                    {id: 'beoordeling_gemeente', label: "Beoordeling gemeente"},
                    {id: 'goedkeuring_gemeente', label: "Goedkeuring gemeente"},
                    {id: 'goedkeuring_provincie', label: "Goedkeuring provincie"},
                    {id: 'definitief', label: "Definitief"},
                    {id: 'archief', label: "Archief"}
                ]}
    );
}

/**
 * return the next status in the workflow.
 *
 * @param {Object} userRoles
 * @param {Status} statusId
 * @param {Ext.form.ComboBox} comboBox
 * @returns {Array} of possible next statusIds
 */
function getNextIbisWorkflowStatus(userRoles, statusId, comboBox) {
    // get the first workflow role
    var workflowRole = "";
    for (var role in userRoles) {
        // TODO hardcoded
        if (role.indexOf("workflow_", 0) === 0) {
            workflowRole = role;
            break;
        }
    }

    var possibleNextStatus = null;

    //TODO  workflow logica; wat volgt op wat, wie (rol) kan wat
    switch (workflowRole) {
        case "workflow_gemeente":
            switch (statusId) {
                case "nieuw":
                    possibleNextStatus = ['nieuw', 'beoordeling_gemeente'];
                    break;
                case "beoordeling_gemeente":
                    possibleNextStatus = ['beoordeling_gemeente', 'goedkeuring_gemeente'];
                    break;
                case "goedkeuring_gemeente":
                    possibleNextStatus = ['goedkeuring_gemeente', 'beoordeling_gemeente'];
                    break;
                case "goedkeuring_provincie":
                    possibleNextStatus = ['goedkeuring_gemeente'];
                    break;
                case "definitief":
                    possibleNextStatus = ['definitief'];
                    break;
                case "archief":
                    break;
            }
            break;
        case "workflow_provincie":
            switch (statusId) {
                case "nieuw":
                    possibleNextStatus = ['nieuw', 'beoordeling_gemeente'];
                    break;
                case "beoordeling_gemeente":
                    possibleNextStatus = ['beoordeling_gemeente'];
                    break;
                case "goedkeuring_gemeente":
                    possibleNextStatus = ['goedkeuring_gemeente', 'beoordeling_gemeente', 'goedkeuring_provincie'];
                    break;
                case "goedkeuring_provincie":
                    possibleNextStatus = ['definitief'];
                    break;
                case "definitief":
                    possibleNextStatus = ['definitief'];
                    break;
                case "archief":
                    break;
            }
            break;
        case "workflow_admin":
            // kan alles, geen filter
            possibleNextStatus = ['nieuw', 'beoordeling_gemeente', 'goedkeuring_gemeente', 'goedkeuring_provincie', 'definitief', 'archief'];
            break;
        default:
            // onbekende/lege gebruikers rol??
            possibleNextStatus = ['nieuw'];
            break;
    }

    //console.debug("lookup up workflows for ", workflowRole, statusId, comboBox);
    // console.debug("possibleNextStatus", possibleNextStatus);

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

