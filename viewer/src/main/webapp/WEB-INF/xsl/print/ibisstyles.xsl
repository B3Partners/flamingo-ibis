<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="fo">
    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

    <xsl:include href="styles.xsl"/>

    <!-- some overrides and extras -->
    <xsl:attribute-set name="title-font">
        <xsl:attribute name="font-size">14pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="default-font">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="color">#000000</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subtitle-font">
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="color">#000066</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="table-border" use-attribute-sets="simple-border">
        <xsl:attribute name="border-color">#A1A1A1</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-width">thin</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="legend-attributes">
        <xsl:attribute name="font-size">9pt</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>
