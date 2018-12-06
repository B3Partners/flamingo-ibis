/*
 * Copyright (C) 2016 B3Partners B.V.
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
 * Ibis Drawing component.
 * @author mprins
 */
Ext.define("viewer.components.IbisDrawing", {
    extend: "viewer.components.Drawing",
    url: "",
    baseUrl: "",
    shareUrls: null,
    shareSource: null,
    config: {
        details: {
            minWidth: 405,
            minHeight: 215
        },
        shareMail: null,
        shareTitle: null,
        shareText: null,
        shareTarget: null
    },
    /**
     * Create our component.
     * @constructor
     * @param {Object} conf configuration data object
     * @returns {viewer.components.IbisDrawing}
     */
    constructor: function (conf) {
        this.initConfig(conf);
        if (!Ext.isDefined(conf.showLabels)) {
            conf.showLabels = true;
        }
        viewer.components.IbisDrawing.superclass.constructor.call(this, this.config);
        this.shareUrls = {
            email: "mailto:[mail]?subject=[title]&body=[text]%20[url]"
        };
    },
    /**
     * Create the GUI
     * @override
     */
    loadWindow: function () {
        this.superclass.loadWindow.call(this);
        // remove some panels we don't need from our superclass
        var cPanel = this.mainContainer.getComponent(this.name + 'ContentPanel');
        cPanel.remove(this.formopen);
        cPanel.remove(this.formsave);
        // redefine formsave panel to creat a bookmark
        this.formsave = new Ext.form.FormPanel({
            border: 0,
            standardSubmit: true,
            url: actionBeans["bookmark"] + "?create",
            style: {
                marginBottom: '25px'
            },
            items: [
                {
                    xtype: 'button',
                    text: 'Schets link maken en bericht opstellen',
                    listeners: {
                        click: {
                            scope: this,
                            fn: this.bookmark
                        }
                    }
                }
            ]
        });
        cPanel.add(this.formsave);
    },
    bookmark: function () {
        var paramJSON = this.config.viewerController.getBookmarkUrl();
        var parameters = "";
        var params = [];
        for (var i = 0; i < paramJSON["params"].length; i++) {
            var param = paramJSON["params"][i];
            if (param.name === 'url') {
                params.push(param);
                this.url = param.value;
                this.baseUrl = param.value;
                this.shareSource = this.baseUrl.substring(
                        this.baseUrl.lastIndexOf('app/') + 4,
                        this.baseUrl.lastIndexOf('?'));
            } else if (param.name === 'extent') {
                params.push(param);
                parameters += param.name + "=";
                var extent = param.value;
                parameters += extent.minx + "," + extent.miny + "," + extent.maxx + "," + extent.maxy + "&";
            } else if (param.name === 'layers') {
              //  params.push(param);
                parameters += param.name + "=";
                var layers = param.value;
                for (var x = 0; x < layers.length; x++) {
                    parameters += layers[x];
                    if (x !== (layers.length - 1)) {
                        parameters += ",";
                    }
                }
                parameters += "&";
            } else if (param.name === 'levelOrder' && param.value.length > 0) {
               // params.push(param);
                parameters += param.name + "=";
                parameters += param.value.join(",");
                parameters += "&";
            } else if (param.name !== 'selectedContent' && param.name !== 'services' && param.name !== 'levels'
                    && param.name !== 'appLayers' && param.name !== "" && param.value !== "") {
                parameters += param.name + "=" + param.value + "&";
            }
        }
        params.push({
            name: "forceLoadLayers",
            value: true
        });
        paramJSON["params"] = params;
        

        var componentParams = "";
        //get all the params from components that need to be added to the bookmark
        var components = this.config.viewerController.getComponents();
        for (var i = 0; i < components.length; i++) {
            var state = components[i].getBookmarkState(false);
            if (!Ext.isEmpty(state)) {
                componentParams += encodeURIComponent(components[i].getName());
                componentParams += "=";
                componentParams += encodeURIComponent(Ext.encode(state));
                componentParams += "&";
            }
        }
        this.url += parameters;
        if (componentParams.length != 0) {
            this.url += componentParams;
        }
        //get all the states of the components for the short url
        for (var i = 0; i < components.length; i++) {
            var state = components[i].getBookmarkState(true);
            if (!Ext.isEmpty(state)) {
                var param = {
                    name: components[i].getName(),
                    value: Ext.JSON.encode(state)
                };
                paramJSON.params.push(param);
            }
        }

        var me = this;
        Ext.create("viewer.Bookmark").createBookmark(
                Ext.JSON.encode(paramJSON),
                function (code) {
                    me.succesCompactUrl(code);
                },
                function (code) {
                    me.failureCompactUrl(code);
                }
        );
    },
    succesCompactUrl: function (code) {
        var bookmarkUrl = this.baseUrl + "bookmark=" + code;
        // search/replace with other mashup target
        if (this.config.shareTarget && this.config.shareTarget !== '') {
            bookmarkUrl = bookmarkUrl.replace(this.shareSource, encodeURIComponent(this.config.shareTarget));
        }
        // copied/modified from bookmark control share function.
        var url = this.shareUrls["email"];
        if (!bookmarkUrl || bookmarkUrl === "") {
            bookmarkUrl = this.url;
        }
        if (this.config.shareTarget && this.config.shareTarget !== '') {
            url = url.replace(this.shareSource, encodeURIComponent(this.config.shareTarget));
        }
        if (url.indexOf("[url]") !== -1) {
            url = url.replace("[url]", encodeURIComponent(bookmarkUrl));
        }
        if (url.indexOf("[text]") !== -1) {
            url = url.replace("[text]", encodeURIComponent(this.config.shareText));
        }
        if (url.indexOf("[title]") !== -1) {
            url = url.replace("[title]", encodeURIComponent(this.config.shareTitle));
        }
        if (url.indexOf("[mail]") !== -1) {
            url = url.replace("[mail]", encodeURIComponent(this.config.shareMail));
        }
        window.open(url, '_self');
        this.popup.hide();
    },
    failureCompactUrl: function (code) {
        this.config.viewerController.logger.error(code);
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
