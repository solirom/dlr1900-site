<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <xsl:output method="json" encoding="UTF-8" />   
    <xsl:variable name="uuid" select="/*/@xml:id"/>
    <xsl:template match="/">
        <xsl:result-document href="{concat($uuid, '.json')}">
              <xsl:variable name="content-as-string" select="/tei:TEI/tei:text/tei:body/tei:entryFree[@n = 'content-as-string']/string()"/>
              <xsl:variable name="headword-tokens" as="xs:string+">
                  <xsl:analyze-string select="$content-as-string" regex="(^[\p{{Lu}}\s,-]+)(\d*)">
                      <xsl:matching-substring>
                          <xsl:sequence select="normalize-space(regex-group(1))"/>
                          <xsl:sequence select="normalize-space(regex-group(2))"/>
                      </xsl:matching-substring>                      
                  </xsl:analyze-string>   
              </xsl:variable>             
            <xsl:variable name="i" select="translate($headword-tokens[1], 'ÁÉÍÓÚẮẤ', 'AEIOUĂÂ')" />
                        
            <xsl:sequence select="map {'s': $headword-tokens[1], 'o': $headword-tokens[2], 'i': $i}" />
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
