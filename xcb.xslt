<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

	<xsl:template match="/">
		<xsl:text>(c-system-include "xcb/xcb.h")&#xA;</xsl:text>
		<xsl:apply-templates select="element()"/>
	</xsl:template>

	<xsl:template match="text()" />

	<xsl:template match="Typedef">
		<xsl:if test="matches(@name, '^xcb_')">

			<xsl:variable name="type" select="@type"/>
			<xsl:variable name="enum" select="//Enumeration[@id = $type]"/>

			<xsl:choose>

				<xsl:when test="$enum">
					<xsl:text>(define-c-enum (</xsl:text>
					<xsl:call-template name="scheme-name">
						<xsl:with-param name="c-name">
							<xsl:value-of select="$enum/@name"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$enum/@name"/>
					<xsl:text>)</xsl:text>
					<xsl:for-each select="$enum/EnumValue">
						<xsl:text> </xsl:text>
						<xsl:value-of select="@name"/>
					</xsl:for-each>
					<xsl:text>)&#xA;</xsl:text>
				</xsl:when>

				<xsl:otherwise>
					<xsl:text>(define-c-type </xsl:text>
					<xsl:value-of select="@name"/>
					<xsl:text> predicate: </xsl:text>
					<xsl:call-template name="scheme-name">
						<xsl:with-param name="c-name">
							<xsl:value-of select="@name"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text>?</xsl:text>
					<xsl:text>)&#xA;</xsl:text>
				</xsl:otherwise>

			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="scheme-name">
		<xsl:param name="c-name"/>
		<xsl:value-of select="replace(replace($c-name, '_t$', ''), '_', '-')"/>
	</xsl:template>

</xsl:stylesheet>
