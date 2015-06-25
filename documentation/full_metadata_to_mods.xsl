<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink" version="1.0">
    <!-- <xsl:include href="http://www.loc.gov/standards/marcxml/xslt/MARC21slimUtils.xsl"/> -->
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:if test="object/details/title">
                <titleInfo>
                    <title>
                        <xsl:value-of select="normalize-space(object/details/title)"/>
                    </title>
                </titleInfo>
            </xsl:if>
            <xsl:if test="object/details/author">
                <name type="personal" usage="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(object/details/author)"/>
                    </namePart>
                </name>
            </xsl:if>
            <xsl:if test="object/details/year">
                <originInfo>
                    <dateIssued>
                        <xsl:value-of select="normalize-space(object/details/year)"/>
                    </dateIssued>
                </originInfo>
            </xsl:if>
            <xsl:call-template name="formatTemplate"/>
            <xsl:if test="normalize-space(object/details/collection_name) != ''">
                <note type="general"> Collection Name: <xsl:value-of
                        select="normalize-space(object/details/collection_name)"/>
                </note>
            </xsl:if>
            <xsl:if test="object/assignment/unit">
                <identifier type="local" displayLabel="Unit">
                    <xsl:value-of select="normalize-space(object/assignment/unit)"/>
                </identifier>
            </xsl:if>
            <xsl:if test="object/details/call_number">
                <identifier type="local" displayLabel="Call Number">
                    <xsl:value-of select="normalize-space(object/details/call_number)"/>
                </identifier>
            </xsl:if>
            <xsl:if test="object/details/collection_identifier">
                <identifier type="local" displayLabel="Collection Identifier">
                    <xsl:value-of select="normalize-space(object/details/collection_identifier)"/>
                </identifier>
            </xsl:if>
            <xsl:if test="object/details/mdpi_barcode">
                <identifier type="local" displayLabel="MDPI Barcode">
                    <xsl:value-of select="normalize-space(object/details/mdpi_barcode)"/>
                </identifier>
            </xsl:if>
            <xsl:call-template name="recordInfoTemplate"/>
        </mods>
    </xsl:template>

    <xsl:template name="formatTemplate">
        <typeOfResource>
            <xsl:choose>
                <xsl:when test="normalize-space(object/details/format) = 'CD-R'">sound recording</xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'DAT'">sound recording</xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'Open Reel Audio Tape'">sound recording</xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'LP'">sound recording</xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'Betacam'">moving image</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </typeOfResource>
        <physicalDescription>
            <xsl:choose>
                <xsl:when test="normalize-space(object/details/format) = 'CD-R'">
                    <form authority="marcform">electronic</form>
                    <form authority="gmd">sound recording</form>
                    <form authority="marcsmd">sound disc</form>
                </xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'DAT'">
                    <form authority="gmd">sound recording</form>
                    <form authority="smd">sound cassette</form>
                </xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'Open Reel Audio Tape'">
                    <form authority="gmd">sound recording</form>
                    <form authority="marcsmd">sound tape reel</form>
                </xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'LP'">
                    <form authority="gmd">sound recording</form>
                    <form authority="marcsmd">sound disc</form>
                </xsl:when>
                <xsl:when test="normalize-space(object/details/format) = 'Betacam'">
                    <form authority="gmd">videorecording</form>
                    <form authority="marcsmd">videocassette</form>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </physicalDescription>
        <note displayLabel="system details">
            <xsl:value-of select="normalize-space(object/details/format)"/>
        </note>
    </xsl:template>

    <xsl:template name="recordInfoTemplate">
        <recordInfo>
            <xsl:if test="object/details/created_at">
                <recordCreationDate encoding="iso8601">
                    <xsl:value-of select="normalize-space(object/details/created_at)"/>
                </recordCreationDate>
            </xsl:if>
            <xsl:if test="object/details/updated_at">
                <recordChangeDate encoding="iso8601">
                    <xsl:value-of select="normalize-space(object/details/updated_at)"/>
                </recordChangeDate>
            </xsl:if>
            <xsl:if test="object/details/mdpi_barcode">
                <recordIdentifier source="MDPI">
                    <xsl:value-of select="normalize-space(object/details/mdpi_barcode)"/>
                </recordIdentifier>
            </xsl:if>
        </recordInfo>
    </xsl:template>

</xsl:stylesheet>
