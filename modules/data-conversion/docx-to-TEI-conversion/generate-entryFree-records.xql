xquery version "3.0";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare function local:preprocess-entry($raw-text-content) {
	let $raw-text-content := replace($raw-text-content, "—", "–")
	let $raw-text-content := replace($raw-text-content, " ", " ")
	let $raw-text-content := replace($raw-text-content, "[\S|\s]–[\S|\s]", " – ")
	let $raw-text-content := replace($raw-text-content, "ş", "ș")
	let $raw-text-content := replace($raw-text-content, "", "◊")
	let $raw-text-content := replace($raw-text-content, "", "♦")
	let $raw-text-content := replace($raw-text-content, "", "")
	return $raw-text-content
};

let $paragraphs := collection("/data/dlri-app/raw")//word:body/word:p[data(.) != '']

return
    for $paragraph in $paragraphs
	let $raw-headword := normalize-space($paragraph/word:r[1]/word:t)
	let $headword := if (contains($raw-headword, ",")) then substring-before($raw-headword, ",") else $raw-headword
	let $homonym-number := normalize-space($paragraph//word:r[word:rPr/word:vertAlign[@word:val = 'superscript']][1]/word:t)
	let $uuid := "uuid-" || util:uuid($headword || $homonym-number)
	
    let $entryFree :=
        for $r in $paragraph/word:r
        let $rendition := (
            if ($r/word:rPr/word:b)
            then "bold"
            else ()
            ,
            if ($r/word:rPr/word:i)
            then "italic"
            else ()
            ,
            if ($r/word:rPr/word:vertAlign/@word:val = 'superscript')
            then "superscript"
            else ()
            ,
            if ($r/word:rPr/word:vertAlign/@word:val = 'subscript')
            then "subscript"
            else ()            
        )
        let $rendition :=
            if (empty($rendition))
            then "normal"
            else $rendition
        let $rendition := string-join($rendition," | ")
        
        return <hi xmlns="http://www.tei-c.org/ns/1.0" rend="{$rendition}">{local:preprocess-entry(string-join($r/word:t, ""))}</hi>
    
    let $record :=
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$uuid}">
        	<teiHeader type="text">
        		<fileDesc>
        			<titleStmt>
        				<title />
        				<author />
        				<editor role="reviewer" />
        			</titleStmt>
        			<publicationStmt>
        				<publisher>Linguistic Institute of the Romanian Academy</publisher>
        				<idno type="dictionary-acronym">DEX</idno>
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
        	</teiHeader>
        	<text>
        		<body>
        			<entry>
        				<form type="headword">
        					<orth xml:lang="ro-x-accent-upcase-vowels" n="{$homonym-number}">{$headword}</orth>
        					<syll />
        					<pron />
        				</form>
        			</entry>
        			<entryFree>{$entryFree}</entryFree>
        		</body>
        	</text>
        </TEI>
    
    return xmldb:store("/data/dlri-app/content", $uuid || ".xml", $record)