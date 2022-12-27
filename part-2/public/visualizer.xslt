<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
   <html>
      <head>
        <title>XML Visualiser</title>
      </head>
      <body>
        <table>
          <xsl:for-each select="objects/object">
            <tr>
              <td><xsl:value-of select="title"/></td>
              <td><xsl:value-of select="value"/></td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
