/*
 * Copyright (C) 2012-2016 B3Partners B.V.
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
 * change layerindexes.
 * @param {type} config
 */
function factsheet__layersArrayIndexesToAppLayerIds(config) {
    if (config.legendLayers) {
        for (var i = 0; i < config.legendLayers.length; i++) {
            var appLayerIdx = config.legendLayers[i];
            config.legendLayers[i] = config.layers[appLayerIdx];
        }
    }
    if (config.factsheetLayerId !== undefined && config.factsheetLayerId !== null) {
        config.factsheetLayerId = config.layers[config.factsheetLayerId];
    }
}

/**
 * Change app layer id's to indexes in config.layers array.
 * @param {type} config
 * @returns {undefined}
 */
function factsheet__appLayerIdToLayerIndex(config) {
    config.layers = [];
    for (var i = 0; i < config.legendLayers.length; i++) {
        var appLayerId = config.legendLayers[i];
        var index = Ext.Array.indexOf(config.layers, appLayerId);
        if (index === -1) {
            config.layers.push(appLayerId);
            config.legendLayers[i] = config.layers.length - 1;
        } else {
            config.legendLayers[i] = index;
        }
    }
    var appLayerId = config.factsheetLayerId;

    var index = Ext.Array.indexOf(config.layers, appLayerId);
    if (index === -1) {
        config.layers.push(appLayerId);
        config.factsheetLayerId = config.layers.length - 1;
    } else {
        config.factsheetLayerId = index;
    }
}

function reportbase__layersArrayIndexesToAppLayerIds(config) {
    if (config.componentLayer !== undefined && config.componentLayer !== null) {
        config.componentLayer = config.layers[config.componentLayer];
    }
}

function reportbase__appLayerIdToLayerIndex(config) {
    config.layers = [];
    var appLayerId = config.componentLayer;
    var index = Ext.Array.indexOf(config.layers, appLayerId);

    if (index === -1) {
        config.layers.push(appLayerId);
        config.componentLayer = config.layers.length - 1;
    } else {
        config.componentLayer = index;
    }
}
