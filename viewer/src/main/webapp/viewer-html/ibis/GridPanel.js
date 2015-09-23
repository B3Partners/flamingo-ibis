/*
 Excel.js - convert an ExtJS 5 grid into an Excel spreadsheet using nothing but
 javascript and good intentions.

 By: Steve Drucker
 Dec 26, 2014
 Original Ext 3 Implementation by: Nige "Animal" White?

 Invocation:  grid.downloadExcelXml(includeHiddenColumns,title)

 Upgraded for ExtJS5 on Dec 26, 2014

 see: https://druckit.wordpress.com/2014/12/26/converting-an-ext-5-grid-to-excel-spreadsheet/

 */
Ext.define('viewer.components.GridPanel', {
    override: 'Ext.grid.GridPanel',
    requires: 'Ext.form.action.StandardSubmit',
    /**
     * Kick off download.
     */
    downloadExcelXml: function (includeHidden, title, url, params) {
        if (!title) {
            title = this.title;
        }
        var vExportContent = this.getExcelXml(includeHidden, title);

        // dynamically create and anchor tag to force download with suggested filename
        if (Ext.isChrome || Ext.isGecko /* FF may not work due to CORS see http://caniuse.com/#feat=download but seems to work OK for FF40 */) {
            var gridEl = this.getEl();
            var location = 'data:application/vnd.ms-excel;base64,' + Ext.util.Base64.encode(vExportContent);
            var el = Ext.DomHelper.append(gridEl, {
                tag: "a",
                download: title + "-" + Ext.Date.format(new Date(), 'Y-m-d Hi') + '.xls',
                href: location
            });
            el.click();
            Ext.fly(el).destroy();
        } else {
            var form = this.down('form#uploadForm');
            if (form) {
                form.destroy();
            }
            form = this.add({
                xtype: 'form',
                itemId: 'uploadForm',
                hidden: true,
                standardSubmit: true,
                url: url,
                baseParams: params,
                items: [{
                        xtype: 'hiddenfield',
                        name: 'data',
                        value: vExportContent
                    }]
            });
            form.getForm().submit();
        }
    },
    /**
     * Welcome to XML Hell
     * @see http://msdn.microsoft.com/en-us/library/office/aa140066(v=office.10).aspx
     */
    getExcelXml: function (includeHidden, title) {
        var theTitle = title || this.title;

        var worksheet = this.createWorksheet(includeHidden, theTitle);
        if (this.columnManager.columns) {
            var totalWidth = this.columnManager.columns.length;
        } else {
            var totalWidth = this.columns.length;
        }

        return ''.concat(
                '<?xml version="1.0" encoding="UTF-8"?>',
                '<?mso-application progid="Excel.Sheet"?>',
                '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">',
                '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Title>' + theTitle + '</Title></DocumentProperties>',
                '<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office"><AllowPNG/></OfficeDocumentSettings>',
                //
                '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">',
                '<WindowHeight>' + worksheet.height + '</WindowHeight>',
                '<WindowWidth>' + worksheet.width + '</WindowWidth>',
                '<ProtectStructure>False</ProtectStructure>',
                '<ProtectWindows>False</ProtectWindows>',
                '</ExcelWorkbook>',
                //
                '<Styles>',
                '<Style ss:ID="Default" ss:Name="Default" />',
                // '<Style ss:ID="Default" ss:Name="Normal">',
                // '<Alignment ss:Vertical="Bottom"/>',
                // '<Borders/>',
                // '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>',
                // '<Interior/>',
                // '<NumberFormat/>',
                // '<Protection/>',
                // '</Style>',
                '<Style ss:ID="title" ss:Name="title">',
                '<Borders />',
                '<Font ss:Bold="1" ss:Italic="1" ss:Size="16" />',
                //'<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />',
                //'<NumberFormat ss:Format="@" />',
                '</Style>',
                '<Style ss:ID="headercell"><Font ss:Bold="1" ss:Size="10" /><Alignment ss:Horizontal="Center" ss:WrapText="1" />',
                // '<Interior ss:Color="#A3C9F1" ss:Pattern="Solid" />',
                '<Interior ss:Color="#A3C9F1" ss:Pattern="Solid" />',
                '</Style>',
                '<Style ss:ID="even"><Interior ss:Color="#FFFFFF" ss:Pattern="Solid" /></Style>',
                '<Style ss:ID="evendate" ss:Parent="even"><NumberFormat ss:Format="yyyy-mm-dd" /></Style>',
                '<Style ss:ID="evenint" ss:Parent="even"><Numberformat ss:Format="0" /></Style>',
                '<Style ss:ID="evenfloat" ss:Parent="even"><Numberformat ss:Format="0.00" /></Style>',
                '<Style ss:ID="odd"><Interior ss:Color="#CCCCCC" ss:Pattern="Solid" /></Style>',
                '<Style ss:ID="groupSeparator"><Interior ss:Color="#D3D3D3" ss:Pattern="Solid" /></Style>',
                '<Style ss:ID="odddate" ss:Parent="odd"><NumberFormat ss:Format="yyyy-mm-dd" /></Style>',
                '<Style ss:ID="oddint" ss:Parent="odd"><NumberFormat Format="0" /></Style>',
                '<Style ss:ID="oddfloat" ss:Parent="odd"><NumberFormat Format="0.00" /></Style>',
                '</Styles>',
                worksheet.xml,
                '</Workbook>'
                );
    },
    /**
     * Support function to return field info from store based on fieldname.
     */
    getModelField: function (fieldName) {
        var fields = this.store.model.getFields();
        for (var i = 0; i < fields.length; i++) {
            if (fields[i].name === fieldName) {
                return fields[i];
            }
        }
    },
    /**
     * Convert store into Excel Worksheet.
     */
    generateEmptyGroupRow: function (dataIndex, value, cellTypes, includeHidden) {
        var cm = this.columnManager.columns;
        var colCount = cm.length;
        var rowTpl = '<Row ss:AutoFitHeight="0"><Cell ss:StyleID="groupSeparator" ss:MergeAcross="{0}"><Data ss:Type="String"><html:b>{1}</html:b></Data></Cell></Row>';
        var visibleCols = 0;

        // rowXml += '<Cell ss:StyleID="groupSeparator">'

        for (var j = 0; j < colCount; j++) {
            if (cm[j].xtype != 'actioncolumn' && (cm[j].dataIndex != '') && (includeHidden || !cm[j].hidden)) {
                // rowXml += '<Cell ss:StyleID="groupSeparator"/>';
                visibleCols++;
            }
        }

        // rowXml += "</Row>";

        return Ext.String.format(rowTpl, visibleCols - 1, Ext.String.htmlEncode(value));
    },
    createWorksheet: function (includeHidden, theTitle) {
        // Calculate cell data types and extra class names which affect formatting
        var cellType = [];
        var cellTypeClass = [];
        if (this.columnManager.columns) {
            var cm = this.columnManager.columns;
        } else {
            var cm = this.columns;
        }
        var colCount = cm.length;
        var totalWidthInPixels = 0;
        var colXml = '';
        var headerXml = '';
        var visibleColumnCountReduction = 0;

        for (var i = 0; i < cm.length; i++) {
            if (cm[i].xtype != 'actioncolumn' && (cm[i].dataIndex != '') && (includeHidden || !cm[i].hidden)) {
                var w = cm[i].getEl().getWidth();
                totalWidthInPixels += w;

                if (cm[i].text === "") {
                    cellType.push("None");
                    cellTypeClass.push("");
                    ++visibleColumnCountReduction;
                } else {
                    colXml += '<Column ss:AutoFitWidth="1" ss:Width="' + w + '" />';
                    headerXml += '<Cell ss:StyleID="headercell">' +
                            '<Data ss:Type="String">' + cm[i].text.replace("<br>", " ") + '</Data>' +
                            '<NamedCell ss:Name="Print_Titles"></NamedCell></Cell>';

                    var fld = this.getModelField(cm[i].dataIndex);
                    switch (fld.$className) {
                        case "Ext.data.field.Integer":
                            cellType.push("Number");
                            cellTypeClass.push("int");
                            break;
                        case "Ext.data.field.Number":
                            cellType.push("Number");
                            cellTypeClass.push("float");
                            break;
                        case "Ext.data.field.Boolean":
                            cellType.push("String");
                            cellTypeClass.push("");
                            break;
                        case "Ext.data.field.Date":
                            cellType.push("DateTime");
                            cellTypeClass.push("date");
                            break;
                        default:
                            cellType.push("String");
                            cellTypeClass.push("");
                            break;
                    }
                }
            }
        }
        var visibleColumnCount = cellType.length - visibleColumnCountReduction;

        var result = {
            height: 9000,
            width: Math.floor(totalWidthInPixels * 30) + 50
        };

        // Generate worksheet header details.

        // determine number of rows
        var numGridRows = this.store.getCount() + 2;
        if ((this.store.groupField && !Ext.isEmpty(this.store.groupField)) || (this.store.groupers && this.store.groupers.items.length > 0)) {
            numGridRows = numGridRows + this.store.getGroups().length;
        }

        // create header for worksheet
        var t = ''.concat(
                '<Worksheet ss:Name="' + theTitle + '">',
                '<Names>',
                '<NamedRange ss:Name="Print_Titles" ss:RefersTo="=\'' + theTitle + '\'!R1:R2">',
                '</NamedRange></Names>',
                '<Table ss:ExpandedColumnCount="' + (visibleColumnCount + 2),
                '" ss:ExpandedRowCount="' + numGridRows + '" x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="65" ss:DefaultRowHeight="15">',
                colXml,
                '<Row ss:Height="42">',
                '<Cell ss:MergeAcross="' + (visibleColumnCount - 1) + '" ss:StyleID="title">',
                '<Data ss:Type="String" xmlns:html="http://www.w3.org/TR/REC-html40">',
                '<html:b>' + theTitle + '</html:b></Data><NamedCell ss:Name="Print_Titles">',
                '</NamedCell></Cell>',
                '</Row>',
                '<Row ss:AutoFitHeight="1">',
                headerXml +
                '</Row>'
                );

        // Generate the data rows from the data in the Store
        var groupVal = "";
        var groupField = "";
        if (this.store.groupers && this.store.groupers.keys.length > 0) {
            groupField = this.store.groupers.keys[0];
        } else if (this.store.groupField != '') {
            groupField = this.store.groupField;
        }

        for (var i = 0, it = this.store.data.items, l = it.length; i < l; i++) {

            if (!Ext.isEmpty(groupField)) {
                if (groupVal != this.store.getAt(i).get(groupField)) {
                    groupVal = this.store.getAt(i).get(groupField);
                    t += this.generateEmptyGroupRow(groupField, groupVal, cellType, includeHidden);
                }
            }
            t += '<Row>';
            var cellClass = (i & 1) ? 'odd' : 'even';
            r = it[i].data;
            var k = 0;
            for (var j = 0; j < colCount; j++) {
                if (cm[j].xtype != 'actioncolumn' && (cm[j].dataIndex != '') && (includeHidden || !cm[j].hidden)) {
                    var v = r[cm[j].dataIndex];
                    if (cellType[k] !== "None") {
                        t += '<Cell ss:StyleID="' + cellClass + cellTypeClass[k] + '"><Data ss:Type="' + cellType[k] + '">';
                        if (cellType[k] == 'DateTime') {
                            t += Ext.Date.format(v, 'Y-m-d');
                        } else if (!Ext.isEmpty(v)) {
                            t += Ext.String.htmlEncode(v);
                        }
                        t += '</Data></Cell>';
                    }
                    k++;
                }
            }
            t += '</Row>';
        }

        result.xml = t.concat(
                '</Table>',
                '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">',
                '<PageLayoutZoom>0</PageLayoutZoom>',
                '<Selected/>',
                '<Panes>',
                '<Pane>',
                '<Number>3</Number>',
                '<ActiveRow>2</ActiveRow>',
                '</Pane>',
                '</Panes>',
                '<ProtectObjects>False</ProtectObjects>',
                '<ProtectScenarios>False</ProtectScenarios>',
                '</WorksheetOptions>',
                '</Worksheet>'
                );
        return result;
    }
});