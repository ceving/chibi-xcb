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

	<xsl:template match="Function">
		<xsl:if test="starts-with(@name, 'xcb_')">
			<xsl:text>(define-c</xsl:text>
			<xsl:call-template name="type">
				<xsl:with-param name="type-id" select="@returns"/>
				<xsl:with-param name="return" select="true()"/>
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:call-template name="scheme-name">
				<xsl:with-param name="c-name" select="@name"/>
			</xsl:call-template>
			<xsl:text> (</xsl:text>
			<xsl:for-each select="Argument">
				<xsl:call-template name="type">
					<xsl:with-param name="type-id" select="@type"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:text> ))&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="type">

		<xsl:param name="type-id"/>
		<xsl:param name="pointer"/>
		<xsl:param name="const"/>
		<xsl:param name="return"/>

		<xsl:variable name="type" select="//*[@id = $type-id]"/>

		<xsl:choose>

			<xsl:when test="$type/name() = 'PointerType'">
				<xsl:call-template name="type">
					<xsl:with-param name="type-id" select="$type/@type"/>
					<xsl:with-param name="pointer" select="true()"/>
					<xsl:with-param name="const" select="$const"/>
					<xsl:with-param name="return" select="$return"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$type/name() = 'CvQualifiedType'">
				<xsl:choose>

					<xsl:when test="$type/@const">
						<xsl:call-template name="type">
							<xsl:with-param name="type-id" select="$type/@type"/>
							<xsl:with-param name="pointer" select="$pointer"/>
							<xsl:with-param name="const" select="true()"/>
							<xsl:with-param name="return" select="$return"/>
						</xsl:call-template>
					</xsl:when>

					<xsl:otherwise>
						<xsl:text>?</xsl:text>
					</xsl:otherwise>

				</xsl:choose>
			</xsl:when>

			<xsl:when test="$type/name() = 'FundamentalType'">

				<xsl:text> </xsl:text>

				<xsl:variable name="modifier">
					<xsl:if test="$const">
						<xsl:text>const </xsl:text>
					</xsl:if>
					<xsl:if test="$pointer and $type/@name != 'char'">
						<xsl:text>pointer </xsl:text>
					</xsl:if>
				</xsl:variable>

				<xsl:if test="string-length($modifier) > 0">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$modifier"/>
				</xsl:if>

				<xsl:choose>

					<xsl:when test="$type/@name = 'char'">
						<xsl:choose>
							<xsl:when test="$pointer">
								<xsl:text>string</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>char</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:when test="$type/@name = 'int'">
						<xsl:text>int</xsl:text>
					</xsl:when>

					<xsl:when test="$type/@name = 'void'">
						<xsl:text>void</xsl:text>
					</xsl:when>

					<xsl:otherwise>
						<xsl:text>[</xsl:text>
							<xsl:value-of select="$type/@name"/>
						<xsl:text>]</xsl:text>
					</xsl:otherwise>

				</xsl:choose>

				<xsl:if test="string-length($modifier) > 0">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>

			<xsl:otherwise>

				<xsl:text> </xsl:text>

				<xsl:variable name="modifier">
					<xsl:if test="$const">
						<xsl:text>const </xsl:text>
					</xsl:if>
					<xsl:if test="$return and not($pointer)">
						<xsl:text>struct </xsl:text>
					</xsl:if>
				</xsl:variable>

				<xsl:if test="string-length($modifier) > 0">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$modifier"/>
				</xsl:if>

				<xsl:value-of select="$type/@name"/>

				<xsl:if test="string-length($modifier) > 0">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<xsl:template name="scheme-name">
		<xsl:param name="c-name"/>
		<xsl:value-of select="replace(replace($c-name, '_t$', ''), '_', '-')"/>
	</xsl:template>

</xsl:stylesheet>
