/*
 * Copyright (C) 2012-2013 B3Partners B.V.
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
 * global method for modifying the layer ids
 */
// called from the control
function factsheet__layerIdToAppLayerId(config) {
    var factsheetLayer = config.factsheetLayer;

    console.debug("factsheet__layerIdToAppLayerId", config);

    //Ext.Array.each(config.sliders, function (slider) {
//        var newSelectedLayers = [];
//        for (var i = 0; i < slider.selectedLayers.length; i++) {
//            var index = slider.selectedLayers[i];
//            if (index >= 0 && index < layers.length) {
//                newSelectedLayers.push(layers[index]);
//            }
//        }
//        slider.selectedLayers = newSelectedLayers;
    //});
}

function factsheet__appLayerIdToLayerId(config) {
// called frm the config
    // Change app layer id's to indexes in config.layers array

    //config.factsheetLayer = null;
    console.debug("factsheet__appLayerIdToLayerId", config);
    //console.debug("layer id", config.viewerController.getLayer(config.factsheetLayer, false));
//    Ext.Array.each(config.sliders, function (slider) {
//        for (var i = 0; i < slider.selectedLayers.length; i++) {
//            var appLayerId = slider.selectedLayers[i];
//            var index = Ext.Array.indexOf(config.layers, appLayerId);
//            if (index == -1) {
//                config.layers.push(appLayerId);
//                slider.selectedLayers[i] = config.layers.length - 1;
//            } else {
//                slider.selectedLayers[i] = index;
//            }
//        }
//    });

}