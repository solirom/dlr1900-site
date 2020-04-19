xquery version "3.1";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare function local:preprocess-entry($raw-text-content) {
	let $raw-text-content := replace($raw-text-content, "—", "–")
	let $raw-text-content := replace($raw-text-content, " ", " ")
	let $raw-text-content := replace($raw-text-content, "[\S|\s]–[\S|\s]", " – ")
	let $raw-text-content := replace($raw-text-content, "Ş", "Ș")
	let $raw-text-content := replace($raw-text-content, "ş", "ș")
	let $raw-text-content := replace($raw-text-content, "Ţ", "Ț")
	let $raw-text-content := replace($raw-text-content, "ţ", "ț")
	let $raw-text-content := replace($raw-text-content, "", "◊")
	let $raw-text-content := replace($raw-text-content, "", "♦")
	let $raw-text-content := replace($raw-text-content, "", "")
	
	return $raw-text-content
};

let $paragraphs := collection("/data/dex-input-data")//word:p

return 
    for $paragraph in $paragraphs
    let $uuid := "uuid-" || util:uuid()
    
    let $runs := $paragraph/word:r
    let $content :=
        <entryFree xmlns="http://www.tei-c.org/ns/1.0" n="content">
            {
                for $run in $runs
                let $runProperties := $run/word:rPr
                let $rendition := (
                    (: check for bold :)
                    if ($runProperties/(word:b[not(@word:val)], word:bCs[not(@word:val)]))
                    then "bold"
                    else ()
                    ,
                    (: check for italic :)
                    if ($runProperties/(word:i[not(@word:val)], word:iCs[not(@word:val)]))
                    then "italic"
                    else ()
                    ,
                    (: check for vertAlign/@superscript :)
                    if ($runProperties/(word:vertAlign[@word:val = 'superscript']))
                    then "superscript"
                    else ()
                    ,
                    (: check for vertAlign/@subscript :)
                    if ($runProperties/(word:vertAlign[@word:val = 'subscript']))
                    then "subscript"
                    else ()            
                )
                let $text := local:preprocess-entry(string-join($run/word:t, ""))
        
                return
                    if (empty($rendition))
                    then $text
                    else <hi xmlns="http://www.tei-c.org/ns/1.0" rend="{string-join($rendition," | |-")}">{$text}</hi>
            }
        </entryFree>
    let $content-as-string := $content/string()

	let $raw-sections := map {
	    "headword": "",
	    "homonym-number": ""
	}
	let $headword-regex := "^(.*)(\d{1,2})$"
	let $headword-section-components := tokenize($content-as-string, ",| |-")[. != '']
	let $headword := normalize-space($headword-section-components[1])
	let $raw-sections :=
		if (matches($headword, $headword-regex))
		then
			let $raw-sections := map:put($raw-sections, "headword", replace($headword, $headword-regex, "$1"))
			let $raw-sections := map:put($raw-sections, "homonym-number", replace($headword, $headword-regex, "$2"))
			
			return $raw-sections
		else map:put($raw-sections, "headword", $headword)    
        
    return 
        xmldb:store("/data/dex", $uuid || ".xml",
            <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$uuid}" version="3.6.0" source="0.1">
            	<teiHeader>
            		<fileDesc>
            			<titleStmt>
            				<title />
            			</titleStmt>
            			<publicationStmt>
            				<publisher />
            			</publicationStmt>
            			<sourceDesc>
            				<p />
            			</sourceDesc>
            		</fileDesc>
            		<profileDesc>
            			<creation>
            				<date when-iso="{current-dateTime()}" />
            			</creation>
            		</profileDesc>
            		<revisionDesc />
            	</teiHeader>
            	<text>
            		<body>
            			<entry>
            				<form type="headword">
            					<orth n="{map:get($raw-sections, "homonym-number")}">{map:get($raw-sections, "headword")}</orth>
            					<stress xml:lang="ro-x-accent-upcase-vowels" />
            					<syll />
            					<pron />
            				</form>
            			</entry>
            			{$content}
            			<entryFree n="content-as-string">{$content-as-string}</entryFree>
            		</body>
            	</text>
            </TEI>  
        )
    
        
