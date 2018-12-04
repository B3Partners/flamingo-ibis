<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.1" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="fo">

    <xsl:import href="legend.xsl"/>
	
    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>
	
    <xsl:param name="versionParam" select="'1.0'"/>

    <xsl:variable name="map-width-px" select="'457'"/>
    <xsl:variable name="map-height-px" select="'776'"/>
    
    <!-- See legend.xsl (does not currently affect size of other elements!) -->
    <xsl:variable name="legend-width-cm" select="5.6"/>
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
					<fo:block-container width="20.2cm" height="0.9cm" top="0cm" left="0cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block-border">
					
						<fo:block-container width="7.7cm" height="0.7cm" top="0.1cm" left="0.1cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="title-block"/>
						</fo:block-container>
	
						<fo:block-container width="7.7cm" height="0.7cm" top="0.1cm" left="7.8cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="subtitle-block"/>
						</fo:block-container>
						
						<fo:block-container width="4.6cm" height="0.7cm" top="0.1cm" left="15.4cm" background-color="#d2e9ef" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="logo-block"/>
						</fo:block-container>
                    
                    </fo:block-container>
                    
                    <fo:block-container width="0.25cm" height="6.825cm" top="0.90cm" left="0cm" background-color="#003D5C" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag1-block"/>
                    </fo:block-container>
					
					<fo:block-container width="0.25cm" height="6.875cm" top="7.675cm" left="0cm" background-color="#009900" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag2-block"/>
                    </fo:block-container>
					
					<fo:block-container width="0.25cm" height="6.875cm" top="14.55cm" left="0cm" background-color="#FFED00" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag3-block"/>
                    </fo:block-container>
					
					<fo:block-container width="0.25cm" height="6.9cm" top="21.425cm" left="0cm" background-color="#000000" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="vlag4-block"/>
                    </fo:block-container>
                    
                     <fo:block-container width="16.15cm" height="27.5cm" top="0.9cm" left="0.25cm" xsl:use-attribute-sets="column-block-border">
                        <xsl:call-template name="map-block"/>
                    </fo:block-container>

                   <fo:block-container width="4cm" height="4cm" top="24.3cm" left="13cm" xsl:use-attribute-sets="column-block">
                        <xsl:call-template name="schaal-block"/>
                    </fo:block-container>
                    
                    <fo:block-container width="3.8cm" height="27.5cm" top="0.90cm" left="16.4cm" xsl:use-attribute-sets="column-block-border">
                    
						<fo:block-container width="3.8cm" height="2.5cm" top="0.1cm" left="0.1cm" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="overzicht-block"/>
						</fo:block-container>
	
						<fo:block-container width="3.8cm" height="23.9cm" top="2.5cm" left="0.1cm" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="legenda-block"/>
						</fo:block-container>
						
						<fo:block-container width="3.8cm" height="2.5cm" top="22.1cm" left="0.1cm" xsl:use-attribute-sets="column-block">
							<xsl:call-template name="datum-block"/>
						</fo:block-container>
                    
                    </fo:block-container>

                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>    
    
    <!-- blocks -->
    <xsl:template name="title-block">        
        <fo:block margin-left="0.2cm" margin-top="0.1cm" xsl:use-attribute-sets="title-font" text-align="left">
            <xsl:value-of select="title"/>
        </fo:block>
    </xsl:template>
	
	<xsl:template name="subtitle-block">        
		<fo:block margin-right="0.2cm" margin-top="0.1cm" xsl:use-attribute-sets="title-font" text-align="right">
			<xsl:value-of select="subtitle"/>
		</fo:block>
    </xsl:template>
	
	<xsl:template name="logo-block">
        <fo:block margin-top="0cm" text-align="right">
            <fo:external-graphic src="url('logo_prov_wit_A4L.png')"/>
        </fo:block>
    </xsl:template>
	
	<xsl:template name="vlag1-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
	
	<xsl:template name="vlag2-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
	
	<xsl:template name="vlag3-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
	
	<xsl:template name="vlag4-block">
        <fo:block xsl:use-attribute-sets="default-font">
        </fo:block>
    </xsl:template>
	
	<!-- create map -->
    <xsl:template name="map-block">
		<xsl:variable name="bbox-corrected">
			<xsl:call-template name="correct-bbox">
				<xsl:with-param name="bbox" select="bbox"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="px-ratio" select="format-number($map-height-px div $map-width-px,'0.##','MyFormat')" />
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

		<fo:block-container margin-top="0.5cm" height="19.2cm" xsl:use-attribute-sets="column-block">
			<fo:block margin-left="0.05cm">
				<fo:external-graphic src="{$map}" content-height="scale-to-fit" content-width="scale-to-fit" scaling="uniform" width="{$map-width-px}" height="{$map-height-px}"/>
			</fo:block>
		</fo:block-container>
	</xsl:template>
		
	<xsl:template name="schaal-block">
		
		<xsl:call-template name="windrose">
			<xsl:with-param name="angle" select="angle"/>
			<xsl:with-param name="top" select="'-3cm'"/>
		</xsl:call-template>

		
		<fo:block margin-left="0cm" margin-top="3cm" font-size="9pt">
			schaal
		</fo:block>

		<!-- create scalebar -->
		<fo:block margin-left="0cm" margin-top="0cm">
			<xsl:call-template name="calc-scale">
				<xsl:with-param name="m-width">
					<xsl:call-template name="calc-bbox-width-m-corrected">
						<xsl:with-param name="bbox" select="bbox"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="px-width" select="$map-width-px"/>
			</xsl:call-template>
		</fo:block>
    </xsl:template>
	
	<xsl:template name="overzicht-block">
        <fo:block margin-left="0.2cm" margin-top="0.5cm" color="#000000" xsl:use-attribute-sets="default-font">
			
			<xsl:call-template name="overview-block">
                <xsl:with-param name="width" select="'170px'"/>
                <xsl:with-param name="height" select="'120px'"/>
            </xsl:call-template>
        
        </fo:block>
    </xsl:template>
    
    <xsl:template name="legenda-block">
  		<fo:block margin-left="0.2cm" margin-top="0cm" xsl:use-attribute-sets="default-font">
            <fo:block space-before="0.4cm"/>
            <xsl:call-template name="legend"/>
        </fo:block>
    </xsl:template>

    <xsl:template name="datum-block">
		
        <fo:block margin-left="0.2cm" margin-top="0.1cm" color="#000000" xsl:use-attribute-sets="default-font">
        
			<fo:block margin-left="0.2cm" margin-top="0.1cm" font-size="8pt" font-style="italic">
                <xsl:value-of select="remark"/>
            </fo:block>

            <fo:block margin-left="0.2cm" margin-top="0.3cm" font-size="10pt">
                <xsl:value-of select="date"/>
            </fo:block>
			
			<fo:block margin-left="0.2cm" margin-top="0.5cm" font-size="8pt">
                Aan deze kaart kunnen geen rechten worden ontleend.
            </fo:block>
			
        </fo:block>
    </xsl:template>   
</xsl:stylesheet>