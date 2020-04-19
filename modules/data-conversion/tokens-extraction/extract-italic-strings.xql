xquery version "3.1";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

let $paragraphs := collection("/data/dlri-app/raw")//word:body/word:p[data(.) != '']
let $italic-strings := 
    for $paragraph in $paragraphs
	let $raw-headword := normalize-space($paragraph/word:r[1]/word:t)
	let $headword := if (contains($raw-headword, ",")) then substring-before($raw-headword, ",") else $raw-headword
	let $homonym-number := normalize-space($paragraph//word:r[word:rPr/word:vertAlign[@word:val = 'superscript']][1]/word:t)
	let $italic-strings :=
        for $r in $paragraph/word:r[.//word:i]
        
        return <italic-string>{$r/word:t/data(.)}</italic-string>
        
	return
	    if (exists($italic-strings))
	    then
    	    <entry>
    	        <headword homonym-number="{$homonym-number}">{$headword}</headword>
    	        <italic-strings>{$italic-strings}</italic-strings>
    	   </entry>
    	else ()

return xmldb:store("/apps/dlri-app/modules/dex-processing/temp", "italic-strings.xml", <italic-strings>{$italic-strings}</italic-strings>)
