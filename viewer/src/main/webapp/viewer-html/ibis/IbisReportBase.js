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
 * Shared base for the IbisReport and IbisLocationFinder components.
 *
 * @author Mark Prins
 */
Ext.define("viewer.components.IbisReportBase", {
    extend: 'viewer.components.Component',
    require: ['viewer.components.IbisReportStore'],
//  shared fields

    idColNaam: 'id',
    idVeldId: '',
    idVeldNaam: '',
    //
    terreinColNaam: 'a_plannaam',
    terreinVeldId: '',
    terreinVeldNaam: '',
    //
    terrein_geomColNaam: 'bbox_terrein',
    terrein_geomVeldId: '',
    terrein_geomVeldNaam: '',
    //
    gemeenteColNaam: 'naam',
    gemeenteVeldId: '',
    gemeenteVeldNaam: '',
    //
    gemeente_geomColNaam: 'bbox_gemeente',
    gemeente_geomVeldId: '',
    gemeente_geomVeldNaam: '',
    //
    regioColNaam: 'vvr_naam',
    regioVeldId: '',
    regioVeldNaam: '',
    //
    regio_geomColNaam: 'bbox_regio',
    regio_geomVeldId: '',
    regio_geomVeldNaam: '',
    // TODO would be nice to set this to 0 (== unlimited in Ext world) but the
    // flamingo featureService limits this to 1000
    MAX_ITEMS: 1000,
    /**
     * constructs a ne instance.
     * @param {Object} conf
     * @returns {viewer.components.IbisReportBase}
     */
    constructor: function (conf) {
        viewer.components.IbisReportBase.superclass.constructor.call(this, conf);
        this.initConfig(conf);
        // update custom url, global var contextPath is not available until after page load
        this.config.actionbeanUrl = contextPath + '/action/ibisattributes';

        return this;
    },
});

