<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
                xmlns:svg="http://www.w3.org/2000/svg" exclude-result-prefixes="fo">

    <xsl:import href="legend.xsl"/>

    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

    <xsl:param name="versionParam" select="'1.0'"/>

    <xsl:variable name="map-width-px" select="'671'"/>
    <xsl:variable name="map-height-px" select="'538'"/>

    <!-- laat deze waarde leeg indien geen vaste schaal -->
    <xsl:variable name="global-scale" select="''"/>
    <!-- omrekening van pixels naar mm -->
    <xsl:variable name="ppm" select="'2.8'"/>

    <!-- See legend.xsl (does not currently affect size of other elements!) -->
    <xsl:variable name="legend-width-cm" select="4.2"/>
    <!-- See legend.xsl ('none', 'before', 'right') -->
    <xsl:variable name="legend-labels-pos" select="'before'"/>
    <xsl:variable name="legend-scale-images-same-ratio" select="true()"/>

    <xsl:attribute-set name="legend-attributes">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
    </xsl:attribute-set>

    <!-- formatter -->
    <xsl:decimal-format name="MyFormat" decimal-separator="." grouping-separator=","
                        infinity="INFINITY" minus-sign="-" NaN="Not a Number" percent="%" per-mille="m"
                        zero-digit="0" digit="#" pattern-separator=";" />

    <!-- includes -->
    <xsl:include href="calc.xsl"/>
    <xsl:include href="styles.xsl"/>

    <!-- master set, Pagina grootte en print marges -->
    <xsl:template name="layout-master-set">
        <fo:layout-master-set>
            <fo:simple-page-master master-name="a4-liggend" page-height="210mm" page-width="297mm" margin-top="0.4cm" margin-bottom="0.4cm" margin-left="0.4cm" margin-right="0.4cm">
                <fo:region-body region-name="body"/>
            </fo:simple-page-master>
        </fo:layout-master-set>
    </xsl:template>

    <!-- root -->
    <xsl:template match="info">
        <fo:root>
            <xsl:call-template name="layout-master-set"/>
            <!-- Positionering en grootte van de blocks -->
            <fo:page-sequence master-reference="a4-liggend">
                <fo:flow flow-name="body">
                    <!-- 5 vlag links blauw -->
                    <fo:block-container width="0.25cm" height="4.71cm" top="0.9cm" left="0cm" background-color="#003D5C" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag1-block"/>
                    </fo:block-container>
                    <!-- 1 Blauwe balk boven -->
                    <fo:block-container width="28.6cm" height="0.9cm" top="0cm" left="0cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block-border">
                        <!-- 2 Titel linksboven -->
                        <fo:block-container width="11.9cm" height="0.7cm" top="0.1cm" left="0.1cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="title-block"/>
                        </fo:block-container>
                        <!-- 3 Subtitel rechtsboven -->
                        <fo:block-container width="11.9cm" height="0.7cm" top="0.1cm" left="12cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="subtitle-block"/>
                        </fo:block-container>
                        <!-- 4 Logo rechtsboven -->
                        <fo:block-container width="4.5cm" height="0.7cm" top="0.1cm" left="24cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="logo-block"/>
                        </fo:block-container>
                    </fo:block-container>

                    <!-- 6 vlag links groen -->
                    <fo:block-container width="0.25cm" height="6cm" top="5.2cm" left="0cm" background-color="#009900" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag2-block"/>
                    </fo:block-container>
                    <!-- 7 vlag links geel -->
                    <fo:block-container width="0.25cm" height="4.8cm" top="10.4cm" left="0cm" background-color="#FFED00" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag3-block"/>
                    </fo:block-container>
                    <!-- 8 vlag links zwart -->
                    <fo:block-container width="0.25cm" height="4.84cm" top="15.2cm" left="0cm" background-color="#000000" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag4-block"/>
                    </fo:block-container>

                    <!-- 9 kaart -->
                    <fo:block-container width="23.75cm" height="19.1cm" top="0.925cm" left="0.25cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:call-template name="map-block"/>
                    </fo:block-container>
                    <!-- 10 schaal -->
                    <fo:block-container width="4cm" height="4cm" top="16cm" left="20cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="schaal-block"/>
                    </fo:block-container>

                    <!-- 11 tekenhoofd rechts totaal -->
                    <fo:block-container width="4.55cm" height="19.1cm" top="0.92cm" left="24.01cm" xsl:use-attribute-sets="column-block-border">
                        <!-- 12 tekenhoofd rechts overzichtskaart -->
                        <fo:block-container width="4.45cm" height="3.3cm" top="0cm" left="0.1cm" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="overzicht-block"/>
                        </fo:block-container>
                        <!-- 13 tekenhoofd rechts Legenda -->
                        <fo:block-container width="4.45cm" height="13.3cm" top="3.2cm" left="0cm" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="legenda-block"/>
                        </fo:block-container>
                        <!-- 14 tekenhoofd rechts tekst -->
                        <fo:block-container width="4.45cm" height="2.3cm" top="16.7cm" left="0.01cm" background-color="#FFFFFF" xsl:use-attribute-sets="column-block">
                            <xsl:call-template name="datum-block"/>
                        </fo:block-container>

                    </fo:block-container>

                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <!-- Inhoud van de blocks -->
    <!-- 1 Blauwe balk boven, heeft geen speciale inhoud -->
    <!-- 2 Titel linksboven -->
    <xsl:template name="title-block">
        <fo:block margin-left="0.2cm" margin-top="0.1cm" xsl:use-attribute-sets="title-font" text-align="left">
            <xsl:value-of select="title"/>
        </fo:block>
    </xsl:template>
    <!-- 3 Subtitel rechtsboven -->
    <xsl:template name="subtitle-block">
        <fo:block margin-right="0.2cm" margin-top="0.1cm" xsl:use-attribute-sets="title-font" text-align="right">
            <xsl:value-of select="subtitle"/>
        </fo:block>
    </xsl:template>
    <!-- 4 Logo rechtsboven -->
    <xsl:template name="logo-block">
        <fo:block margin-top="0cm" text-align="right">
            <fo:external-graphic src="url('logo_prov_wit_A4L.png')"/>
        </fo:block>
    </xsl:template>
    <!-- 5 vlag links blauw -->
    <xsl:template name="vlag1-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
    <!-- 6 vlag links groen -->
    <xsl:template name="vlag2-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
    <!-- 7 vlag links geel -->
    <xsl:template name="vlag3-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
    <!-- 8 vlag links zwart -->
    <xsl:template name="vlag4-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>

    <!-- 9 kaart  -->
    <!-- create map -->
    <xsl:template name="map-block">
        <xsl:variable name="local-scale">
            <xsl:call-template name="calc-local-scale">
                <xsl:with-param name="bbox" select="bbox"/>
                <xsl:with-param name="scale" select="scale"/>
                <xsl:with-param name="quality" select="quality"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="bbox-corrected">
            <xsl:call-template name="correct-bbox">
                <xsl:with-param name="bbox" select="bbox"/>
                <xsl:with-param name="scale" select="$local-scale"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="px-ratio" select="format-number($map-height-px div $map-width-px,'0.##','MyFormat')"/>
        <xsl:variable name="map-width-px-corrected" select="quality"/>
        <xsl:variable name="map-height-px-corrected" select="format-number(quality * $px-ratio,'0','MyFormat')"/>

        <xsl:variable name="map">
            <xsl:value-of select="imageUrl"/>
            <xsl:text>&amp;width=</xsl:text>
            <xsl:value-of select="$map-width-px-corrected"/>
            <xsl:text>&amp;height=</xsl:text>
            <xsl:value-of select="$map-height-px-corrected"/>
            <xsl:text>&amp;bbox=</xsl:text>
            <xsl:value-of select="$bbox-corrected"/>
        </xsl:variable>

        <fo:block-container margin-top="0.5cm" height="19.05cm" xsl:use-attribute-sets="column-block">
            <fo:block margin-left="0.05cm">
                <fo:external-graphic src="{$map}" content-height="scale-to-fit" content-width="scale-to-fit" scaling="uniform" width="{$map-width-px}" height="{$map-height-px}"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>
    <!-- 10 schaal -->
    <xsl:template name="schaal-block">
        <!-- 10 schaal windrose -->
        <fo:block margin-left="2cm" margin-top="0cm">
            <xsl:call-template name="windrose">
                <xsl:with-param name="angle" select="angle"/>
                <xsl:with-param name="top" select="'-3cm'"/>
            </xsl:call-template>
        </fo:block>

        <xsl:if test="scale != ''">
            <fo:block margin-left="0cm" margin-top="3cm" font-size="9pt">
                <fo:inline font-weight="bold">
                    <xsl:text>schaal 1: </xsl:text>
                    <xsl:value-of select="scale"/>
                </fo:inline>
            </fo:block>
        </xsl:if>

        <fo:block margin-left="0cm" margin-top="0cm">
            <xsl:variable name="local-scale">
                <xsl:call-template name="calc-local-scale">
                    <xsl:with-param name="bbox" select="bbox"/>
                    <xsl:with-param name="scale" select="scale"/>
                    <xsl:with-param name="quality" select="quality"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="calc-scale">
                <xsl:with-param name="m-width" select="($map-width-px div $ppm) * ($local-scale div 1000)"/>
                <xsl:with-param name="px-width" select="$map-width-px"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!-- 11 tekenhoofd rechts totaal, geen verdere speciale inhoud  -->
    <!-- 12 tekenhoofd rechts overzichtskaart  -->
    <xsl:template name="overzicht-block">
        <fo:block margin-left="0.1cm" margin-top="0cm" color="#000000" xsl:use-attribute-sets="default-font">
            <xsl:call-template name="overview-block">
                <xsl:with-param name="width" select="'4.2cm'"/>
                <xsl:with-param name="height" select="'3.3cm'"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!-- 13 tekenhoofd rechts Legenda  -->
    <xsl:template name="legenda-block">
        <fo:block margin-left="0.1cm" margin-top="0cm" width="4.5cm" height="13.25cm" xsl:use-attribute-sets="default-font">
            <fo:block space-before="0.1cm"/>
            <xsl:call-template name="legend"/>
        </fo:block>
    </xsl:template>
    <!-- 14 tekenhoofd rechts tekst  -->
    <xsl:template name="datum-block">

        <fo:block margin-left="0.1cm" margin-top="0.1cm" color="#000000" xsl:use-attribute-sets="default-font">
            <!-- 14 tekenhoofd rechts tekst, door gebruiker in te vullen opmerking  -->
            <fo:block margin-left="0cm" margin-top="0.1cm" font-size="8pt" font-style="italic">
                <xsl:value-of select="remark"/>
            </fo:block>
            <!-- 14 tekenhoofd rechts tekst, Datum -->
            <fo:block margin-left="0cm" margin-top="0.1cm" font-size="8pt">
                <xsl:value-of select="date"/>
            </fo:block>
            <!-- 14 tekenhoofd rechts tekst, rechten opmerking -->
            <fo:block margin-left="0cm" margin-top="0.1cm" font-size="8pt">
                Aan deze kaart kunnen geen rechten worden ontleend.
            </fo:block>

        </fo:block>
    </xsl:template>

</xsl:stylesheet>
