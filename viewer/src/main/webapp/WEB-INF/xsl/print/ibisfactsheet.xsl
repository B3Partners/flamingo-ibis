<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : ibisfactsheet.xsl
    Created on : July 6, 2015, 2:39 PM
    Author     : mark
    Description:
        factsheet voor ibis  (A4_Portrait)
-->

<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="fo">

    <xsl:import href="legend.xsl"/>
    <xsl:include href="calc.xsl"/>
    <xsl:include href="ibisstyles.xsl"/>

    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

    <xsl:comment>
        XSLT Version = <xsl:copy-of select="system-property('xsl:version')"/>
        XSLT Vendor = <xsl:copy-of select="system-property('xsl:vendor')"/>
        XSLT Vendor URL = <xsl:copy-of select="system-property('xsl:vendor-url')"/>
    </xsl:comment>

    <xsl:param name="versionParam" select="'1.0'"/>

    <!-- map variables --> 
    <xsl:variable name="map-width-px" select="'368'"/>
    <xsl:variable name="map-height-px" select="'220'"/>

    <!-- legend variables -->
    <!-- See legend.xsl (does not currently affect size of other elements!) -->
    <xsl:variable name="legend-width-cm" select="3.1"/>
    <!-- See legend.xsl ('none', 'before', 'right') -->
    <xsl:variable name="legend-labels-pos" select="'before'"/>
    <xsl:variable name="legend-scale-images-same-ratio" select="true()"/>
    
    <!-- formatter -->
    <xsl:decimal-format name="MyFormat" decimal-separator="." grouping-separator=","
                        infinity="INFINITY" minus-sign="-" NaN="Not a Number" percent="%" per-mille="m"
                        zero-digit="0" digit="#" pattern-separator=";" />

    <!-- master set -->
    <xsl:template name="layout-master-set">
        <fo:layout-master-set>
            <fo:simple-page-master master-name="a4-staand" page-height="297mm" page-width="210mm" margin-top="0.4cm" margin-bottom="0.4cm" margin-left="0.4cm" margin-right="0.4cm">
                <fo:region-body region-name="body"/>
            </fo:simple-page-master>
        </fo:layout-master-set>
    </xsl:template>

    <!-- root -->
    <xsl:template match="info">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:call-template name="layout-master-set"/>

            <fo:page-sequence master-reference="a4-staand">
                <fo:flow flow-name="body">

                    <fo:block-container width="20.45cm" height="1.5cm" top="0cm" left="0cm" background-color="#FFFFFF" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="title-block"/>
                    </fo:block-container>

                    <!--
                    <fo:block-container width="6.0cm" height="0.75cm" top="1.6cm" left="0cm" background-color="#FFFFFF" xsl:use-attribute-sets="column-block">
                        <fo:block margin-left="0.2cm" margin-top="0.2cm" xsl:use-attribute-sets="default-font">
                            <xsl:value-of select="subtitle"/>
                        </fo:block>
                    </fo:block-container>
                    -->

                    <fo:block-container width="13.1cm" height="7.9cm" top="1.6cm" margin-top="0cm" margin-left="0cm" left="0cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:call-template name="map-block"/>
                    </fo:block-container>

                    <fo:block-container width="4.0cm" height="2.9cm" top="1.6cm" left="13.2cm" margin-left="0cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="overview-block">
                            <xsl:with-param name="width" select="'112'" />
                            <xsl:with-param name="height" select="'80'" />
                        </xsl:call-template>
                    </fo:block-container>

                    <fo:block-container width="2.5cm" top="1.6cm" margin-top="0cm" margin-left="0cm" left="17.1cm" height="1cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="PG-logo-block"/>
                    </fo:block-container>

                    <fo:block-container overflow="hidden" width="6.5cm" height="4.9cm" top="4.6cm" left="13.2cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:call-template name="legend"/>
                        <!-- evt. statische afbeelding(en) voor legenda -->
                        <!-- xsl:call-template name="static-legend-block"/ -->
                    </fo:block-container>

                    <!-- tabellen -->                   
                    <fo:block-container width="6.5cm" height="4.0cm" top="9.6cm" left="0cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.kenmerkenTerrein']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Kenmerken Terrein</fo:block>
                            <xsl:call-template name="ibis-tabel-2column"/>
                        </xsl:for-each>
                    </fo:block-container>

                    <fo:block-container width="6.5cm" height="4.0cm" top="9.6cm" left="6.6cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.beschikbarePanden']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Beschikbare panden</fo:block>
                            <xsl:call-template name="ibis-tabel-2column"/>
                        </xsl:for-each>
                    </fo:block-container>

                    <fo:block-container width="6.5cm" height="4.0cm" top="9.6cm" left="13.2cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.gegevensKavelPand']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Gegevens geselecteerde kavel</fo:block>
                            <xsl:call-template name="ibis-tabel-2column"/>
                        </xsl:for-each>
                    </fo:block-container>

                    <fo:block-container width="13.1cm" height="4.0cm" top="13.7cm" left="0cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.ontsluitingTerrein']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Ontsluiting Terrein</fo:block>
                            <xsl:call-template name="ibis-tabel-2column">
                                <xsl:with-param name="tWidthLeft" select="50" />
                                <xsl:with-param name="tWidthRight" select="80" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </fo:block-container>

                    <!-- bedrijvigheid -->
                    <fo:block-container overflow="hidden" width="19.7cm" height="7.3cm" top="17.8cm" left="0cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <fo:block xsl:use-attribute-sets="subtitle-font">Aantal gevestigde bedrijven en bijbehorend aantal banen</fo:block>
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.gegevensGevestigd']/root">
                            <xsl:call-template name="ibis-tabel-2column">
                                <xsl:with-param name="tWidthLeft" select="80" />
                                <xsl:with-param name="tWidthRight" select="40" />
                            </xsl:call-template>
                        </xsl:for-each>
                        <fo:block xsl:use-attribute-sets="default-font"> 
                            <!-- witregel -->
                            <fo:leader />
                        </fo:block>
                        <fo:block xsl:use-attribute-sets="subtitle-font">Grootste bedrijven</fo:block>
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.gegevensGevestigdLijst']/root">
                            <xsl:call-template name="ibis-tabel-3column"/>
                        </xsl:for-each>
                    </fo:block-container>

                    <!-- contact gegevens -->
                    <fo:block-container width="9.8cm" height="3.0cm" top="25.2cm" left="0cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.gegevensVerkoopOntwikkelaar']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Contactgegevens verkoper/ontwikkelaar</fo:block>
                            <xsl:call-template name="ibis-tabel-2column">
                                <xsl:with-param name="tWidthLeft" select="2" />
                                <xsl:with-param name="tWidthRight" select="100" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </fo:block-container>
                        
                    <fo:block-container width="9.8cm" height="3.0cm" top="25.2cm" left="9.9cm" margin-left="0.1cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet.gegevensVerkoopOverheid']/root">
                            <fo:block xsl:use-attribute-sets="subtitle-font">Contactgegevens overheid</fo:block>
                            <xsl:call-template name="ibis-tabel-2column">
                                <xsl:with-param name="tWidthLeft" select="2" />
                                <xsl:with-param name="tWidthRight" select="100" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </fo:block-container>

                    
                    <!--
                    <fo:block-container width="5.8cm" height="24.0cm" top="15cm" left="0cm" xsl:use-attribute-sets="column-block">
                        <xsl:for-each select="extra/info[@classname='viewer.components.IbisFactsheet']/root">
                            <xsl:call-template name="ibis-tabel"/>
                        </xsl:for-each>
                    </fo:block-container>
                    -->

                    <!--
                    <fo:block-container width="12.0cm" height="2.3cm" top="26.5cm" left="0cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="disclaimer-block"/>
                    </fo:block-container>
                    -->
                    <!--
                    <fo:block-container width="7.6cm" height="2.3cm" top="26.5cm" left="12.0cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="logo-block"/>
                    </fo:block-container>
                    -->
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <!-- blocks -->
    <xsl:template name="title-block">
        <fo:block margin-left="0.2cm" margin-top="0.5cm" xsl:use-attribute-sets="title-font">
            <xsl:value-of select="title"/>
        </fo:block>
    </xsl:template>

    <xsl:template name="ibis-tabel-2column">
        <!-- maak een eenvoudige tabel met de extra info, de breedte van de tabel kolommen kan in mm opgegeven worden als parameter, default is 30 -->
        <xsl:param name="tWidthLeft">30</xsl:param>
        <xsl:param name="tWidthRight">30</xsl:param>
        <fo:block font-size="8pt">
            <fo:table table-layout="fixed" width="{$tWidthLeft + $tWidthRight}mm">
                <fo:table-column column-width="{$tWidthLeft}mm"/>
                <fo:table-column column-width="{$tWidthRight}mm"/>
                <fo:table-body>
                    <xsl:for-each select="*">
                        <xsl:sort select="local-name()" data-type="text"/>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block>
                                    <xsl:call-template name="string-remove-underscore-prefix">
                                        <xsl:with-param name="text" select="local-name()" />
                                    </xsl:call-template>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <xsl:choose>
                                    <xsl:when test="starts-with(normalize-space(.),'W: ')">
                                        <!-- voor contact info blok -->
                                        <fo:block>
                                            <xsl:text>W: </xsl:text>
                                            <fo:inline color="#0000FF">
                                                <xsl:value-of select="substring(normalize-space(.), 4)" />
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <!-- getallen rechts uitlijnen -->
                                            <xsl:when test="number(.) = .">
                                                <fo:block text-align="right">
                                                    <xsl:value-of select="normalize-space(.)" />
                                                </fo:block>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <fo:block>
                                                    <xsl:value-of select="normalize-space(.)" />
                                                </fo:block>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:for-each>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <!-- strip a prefix like o_ from o_internet and remove any understcores from result -->
    <xsl:template name="string-remove-underscore-prefix">
        <xsl:param name="text" />
        <xsl:choose>
            <xsl:when test="contains(substring($text, 2,1), '_')" >
                <xsl:value-of select="translate(substring($text, 3),'_', ' ')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate($text,'_', ' ')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- splits een string met ';' in delen die elk een tabel cel vullen -->
    <xsl:template name="split" match="text()">
        <xsl:param name="pText" select="."/>
        <xsl:if test="string-length($pText)">
            <fo:table-cell>
                <fo:block>
                    <xsl:value-of select="substring-before(concat($pText,';'),';')"/>
                </fo:block>
            </fo:table-cell>
            <xsl:call-template name="split">
                <xsl:with-param name="pText" select="substring-after($pText, ';')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="ibis-tabel-3column">
        <!--
        maak een eenvoudige tabel met de extra info,
        de breedte van de tabel kan in mm opgegeven worden als parameter,
        data moet het scheidingsteken ';' hebben, bijvoorbeeld:
        < a2>TODO dummy bedrijf 2;Dummy hoofdactiviteit 2;dummy grootteklasse 2< /a2>
        zie ook: template "split"
        De eerste regel wordt vet gemaakt
        -->
        <xsl:param name="tWidth">204</xsl:param>
        <fo:block font-size="8pt">
            <fo:table table-layout="fixed" width="{$tWidth}mm">
                <fo:table-column column-width="{$tWidth div 3}mm"/>
                <fo:table-column column-width="{$tWidth div 3}mm"/>
                <fo:table-column column-width="{$tWidth div 3}mm"/>
                <fo:table-body>
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="position()=1">
                                <fo:table-row font-weight="bold">
                                    <xsl:call-template name="split">
                                        <xsl:with-param name="pText" select="." />
                                    </xsl:call-template>
                                </fo:table-row>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:table-row>
                                    <xsl:call-template name="split">
                                        <xsl:with-param name="pText" select="." />
                                    </xsl:call-template>
                                </fo:table-row>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template name="info-block">
        <!--
        <xsl:call-template name="windrose">
            <xsl:with-param name="angle" select="angle"/>
            <xsl:with-param name="top" select="'0cm'"/>
        </xsl:call-template>
        -->
        <fo:block margin-left="0.2cm" margin-top="0cm" xsl:use-attribute-sets="default-font">
            <!--
            <fo:block margin-left="0.2cm" margin-top="0.5cm" font-size="9pt">
                schaal
            </fo:block>
            -->
            <!-- create scalebar -->
            <!--
            <fo:block margin-left="0.2cm" margin-top="0.2cm">
                <xsl:call-template name="calc-scale">
                    <xsl:with-param name="m-width">
                        <xsl:call-template name="calc-bbox-width-m-corrected">
                            <xsl:with-param name="bbox" select="bbox"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="px-width" select="$map-width-px"/>
                </xsl:call-template>
            </fo:block>
            -->
            <!--
            <fo:block margin-left="0.2cm" margin-top="0.5cm" font-size="10pt">
                <xsl:value-of select="date"/>
            </fo:block>
            -->

            <fo:block space-before="0.4cm" />

            <xsl:call-template name="legend" />
            <!--
            <fo:block margin-left="0.2cm" margin-top="0.3cm" font-size="8pt" font-style="italic">
                <xsl:value-of select="remark" />
            </fo:block>
            -->
        </fo:block>
    </xsl:template>

    <!-- create map -->
    <xsl:template name="map-block">
        <xsl:variable name="bbox-corrected">
            <xsl:call-template name="correct-bbox">
                <xsl:with-param name="bbox" select="bbox" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="px-ratio" select="format-number($map-height-px div $map-width-px,'0.##','MyFormat')" />
        <xsl:variable name="map-height-px-corrected" select="quality"/>
        <xsl:variable name="map-width-px-corrected" select="format-number(quality div $px-ratio,'0','MyFormat')"/>
        <xsl:variable name="map">
            <xsl:value-of select="imageUrl"/>
            <xsl:text>&amp;width=</xsl:text>
            <xsl:value-of select="$map-width-px-corrected"/>
            <xsl:text>&amp;height=</xsl:text>
            <xsl:value-of select="$map-height-px-corrected"/>
            <xsl:text>&amp;bbox=</xsl:text>
            <xsl:value-of select="$bbox-corrected"/>
        </xsl:variable>

        <fo:block-container margin-top="0cm" height="7cm" width="13cm" xsl:use-attribute-sets="column-block">
            <fo:block margin-left="0.05cm" margin-right="0.05cm">
                <fo:external-graphic src="{$map}" content-height="scale-to-fit" content-width="scale-to-fit" scaling="uniform" width="{$map-width-px}" height="{$map-height-px}"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="disclaimer-block">
        <fo:block margin-left="0.2cm" margin-top="0.5cm" color="#000000" xsl:use-attribute-sets="default-font">
            Aan deze kaart kunnen geen rechten worden ontleend.
        </fo:block>
    </xsl:template>

    <xsl:template name="PG-logo-block">
        <fo:block>
            <!-- fo:external-graphic src="url('PG-logo-zw-200x71-px.png')" width="3cm" scaling="uniform" content-height="scale-to-fit" content-width="scale-to-fit" /-->
            <fo:external-graphic src="url('PG-logo-zw-200x72px.jpg')" width="3cm" scaling="uniform" content-height="scale-to-fit" content-width="scale-to-fit" />
        </fo:block>
    </xsl:template>

    <xsl:template name="static-legend-block">
        <fo:block>
            <!--  -->
            <fo:external-graphic src="url('TODO.png')" width="231px" height="56px" scaling="uniform" content-height="scale-to-fit" content-width="scale-to-fit"/>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>
