<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
                xmlns:svg="http://www.w3.org/2000/svg" exclude-result-prefixes="fo">
    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

    <!-- berekent de breedte van de kaart in meters na correctie vanwege verschil
    in verhouding hoogte/breedte kaart op scherm en van kaart in template -->
    <xsl:template name="calc-bbox-width-m-corrected">
        <xsl:param name="bbox"/>

        <xsl:variable name="xmin" select="substring-before($bbox, ',')"/>
        <xsl:variable name="bbox1" select="substring-after($bbox, ',')"/>
        <xsl:variable name="ymin" select="substring-before($bbox1, ',')"/>
        <xsl:variable name="bbox2" select="substring-after($bbox1, ',')"/>
        <xsl:variable name="xmax" select="substring-before($bbox2, ',')"/>
        <xsl:variable name="ymax" select="substring-after($bbox2, ',')"/>
        <xsl:variable name="bbox-width-m" select="$xmax - $xmin"/>
        <xsl:variable name="bbox-height-m" select="$ymax - $ymin"/>
        <xsl:variable name="bbox-ratio" select="($map-width-px * $bbox-height-m) div ($map-height-px * $bbox-width-m)"/>
        <xsl:choose>
            <xsl:when test="$bbox-ratio &gt; 1">
                <xsl:value-of select="$bbox-width-m * $bbox-ratio"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$bbox-width-m"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- berekent nieuwe bbox indien verhouding hoogte/breedte van kaart op scherm
    anders is dan verhouding van kaart in template, kaart in template bevat minimaal
    dekking van kaart op scherm, maar mogelijk meer -->
    <xsl:template name="correct-bbox">
        <xsl:param name="bbox"/>

        <xsl:variable name="xmin" select="substring-before($bbox, ',')"/>
        <xsl:variable name="bbox1" select="substring-after($bbox, ',')"/>
        <xsl:variable name="ymin" select="substring-before($bbox1, ',')"/>
        <xsl:variable name="bbox2" select="substring-after($bbox1, ',')"/>
        <xsl:variable name="xmax" select="substring-before($bbox2, ',')"/>
        <xsl:variable name="ymax" select="substring-after($bbox2, ',')"/>
        <xsl:variable name="xmid" select="($xmin + $xmax) div 2"/>
        <xsl:variable name="ymid" select="($ymin + $ymax) div 2"/>
        <xsl:variable name="bbox-width-m" select="$xmax - $xmin"/>
        <xsl:variable name="bbox-height-m" select="$ymax - $ymin"/>
        <xsl:variable name="bbox-ratio" select="($map-width-px * $bbox-height-m) div ($map-height-px * $bbox-width-m)"/>
        <xsl:choose>
            <xsl:when test="$bbox-ratio = 1">
                <xsl:value-of select="$bbox"/>
            </xsl:when>
            <xsl:when test="$bbox-ratio &gt; 1">
                <xsl:variable name="bbox-width-m-corrected" select="$bbox-width-m * $bbox-ratio"/>
                <xsl:value-of select="$xmid - ($bbox-width-m-corrected div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$ymin"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$xmid + ($bbox-width-m-corrected div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$ymax"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="bbox-height-m-corrected" select="$bbox-height-m div $bbox-ratio"/>
                <xsl:value-of select="$xmin"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$ymid - ($bbox-height-m-corrected div 2)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$xmax"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$ymid + ($bbox-height-m-corrected div 2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="overview-block">
        <xsl:param name="width" select="'4cm'"/>
        <xsl:param name="height" select="'4cm'"/>
        <xsl:variable name="bbox-corrected">
            <xsl:call-template name="correct-bbox">
                <xsl:with-param name="bbox" select="bbox"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="overviewUrl">
            <fo:block margin-left="0cm" margin-right="0cm">
                <xsl:variable name="overviewSrc">
                    <xsl:value-of select="overviewUrl"/>
                    <xsl:text>&amp;geom=</xsl:text>
                    <xsl:value-of select="$bbox-corrected"/>
                    <xsl:text>&amp;width=</xsl:text>
                    <xsl:value-of select="translate($width,'px', '')"/>
                    <xsl:text>&amp;height=</xsl:text>
                    <xsl:value-of select="translate($height,'px', '')"/>
                </xsl:variable>
                <fo:external-graphic src="url({$overviewSrc})" content-height="scale-to-fit" content-width="scale-to-fit" scaling="uniform" width="{$width}" height="{$height}"/>
            </fo:block>
        </xsl:if>

    </xsl:template>
</xsl:stylesheet>
