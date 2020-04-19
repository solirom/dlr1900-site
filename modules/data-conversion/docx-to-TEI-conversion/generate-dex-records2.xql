xquery version "3.1";

declare namespace html = "http://www.w3.org/1999/xhtml";

(:let $entries := doc("/db/DEX2019.htm")//html:body/html:div[1]/html:p[1]:)
let $entries :=
<p class="MsoNormal"
	style="margin-top:.55pt;text-align:justify;text-justify:
inter-ideograph;text-indent:5.65pt;line-height:8.0pt">
	<span class="Normal1">
		<b>
			<span style="font-size:7.0pt;font-family:'Arial Unicode MS',sans-serif">ABAGER&#205;E</span>
		</b>
	</span>
	<span class="Normal1">
		<b>
			<sup>
				<span style="font-size:7.0pt;font-family:'Arial Unicode MS',sans-serif">1</span>
			</sup>
		</b>
	</span>
	<span class="Normal1">
		<b>
			<span style="font-size:7.0pt;font-family:'Arial Unicode MS',sans-serif">,</span>
		</b>
	</span>
	<span class="Normal1">
		<span style="font-size:7.0pt;font-family:'Arial Unicode MS',sans-serif">
			<i>abagerii</i>
			, s.f. Atelier sau industrie de (haine de) aba
			<b>
				<sup>2</sup>
			</b>
			.
			—
			<b>Abagiu</b>
			&#8200;+ suf.
			<i>-&#259;rie</i>
			.
		</span>
	</span>
</p>
    
return 
    for $entry in $entries
    let $headword-span := $entry/html:span[1]/html:b/html:span[1]
    let $headword-string := $entry/html:span[1]/string() ! normalize-space(.)
    let $headword-tokens := analyze-string($headword-string, "(\p{Lu}+)")
    let $headword := string-join($headword-span/text(), "") ! replace(., ",", "") ! normalize-space(.)
    let $omonym-number := $headword-span/* ! normalize-space(.)
    
    return
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="uuid-{util:uuid()}" version="3.3.0" source="0.21">
        	<teiHeader>
        		<fileDesc>
        			<titleStmt>
        				<title />
        				<author />
        				<editor role="reviewer" />
        			</titleStmt>
        			<publicationStmt>
        				<publisher>Romanian Academy, Philology and Literature Section</publisher>
        				<idno type="project">dlr2</idno>
        				<idno type="project">dex2019</idno>
        			</publicationStmt>
        			<sourceDesc>
        				<p>born digital</p>
        			</sourceDesc>
        		</fileDesc>
        		<profileDesc>
        			<creation>
        				<date when-iso="{current-dateTime()}" />
        			</creation>
        		</profileDesc>
        		<revisionDesc />
        	</teiHeader>
        	<text type="editing-mode-dlr">
        		<body>
        			<entry>
        				<form type="headword">
        					<orth n="" />
        					<stress xml:lang="ro-x-accent-upcase-vowels" />
        					<syll />
        					<pron />
        				</form>
        				<gramGrp>
        					<pos value="" />
        				</gramGrp>
        				<dictScrap xml:id="dlr-senses">
        					<sense xml:id="uuid-{util:uuid()}" n="">
        						<def xml:id="uuid-{util:uuid()}" />
        						<cit type="unknown">
        							<quote />
        							<bibl type="unknown">
        								<ptr target="unknown" />
        								<date />
        								<citedRange />
        							</bibl>
        						</cit>
        					</sense>
        				</dictScrap>
        				<dictScrap xml:id="dex-senses">
        					<sense xml:id="uuid-{util:uuid()}" n="">
        						<def xml:id="uuid-{util:uuid()}" />
        						<cit>
        							<quote />
        							<bibl type="unknown">
        								<ptr target="unknown" />
        								<date />
        								<citedRange />
        							</bibl>
        						</cit>
        					</sense>
        				</dictScrap>
        				<etym cert="high">
        					<idno type="unknown" />
        				</etym>
        			</entry>
        		</body>
        	</text>
        </TEI>        
    
