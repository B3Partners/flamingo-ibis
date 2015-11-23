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
    /** (cached) workflow status. */
    status: null,
    config: {
        // custom url
        actionbeanUrl: "/viewer/action/feature/ibissplit",
        // status altijd definitief
        workflowstatus: "definitief"
    },
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
                itemId: 'datum_mutatie',
                value: new Date()
            }
        );
        return this;
    },
    /**
     * add a workflow_status, reden, datum_mutatie
     * @override
     */
    getExtraData: function () {
        return Ext.util.JSON.encode({
            'workflow_status': this.status.get("id"),
            'reden': 'splitsing',
            'datum_mutatie': this.maincontainer.getComponent('datum_mutatie').getValue()
        });
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

