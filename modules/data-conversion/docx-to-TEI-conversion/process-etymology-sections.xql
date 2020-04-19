xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function local:reverse($string) {
	codepoints-to-string(reverse(string-to-codepoints($string)))
};

let $entries := collection("/data/dlri-app/content")//tei:entryFree/data(.)

let $delimiter-1 := "] – "
let $delimiter-2 := " – "

let $tokens :=
    for $entry in $entries

    return
        if (contains($entry, $delimiter-1))
        then normalize-space(substring-after($entry, $delimiter-1))
        else
            let $entry := local:reverse($entry)
            return normalize-space(local:reverse(substring-before($entry, $delimiter-2)))
            
let $tokens := distinct-values($tokens)
let $tokens :=
    for $token in $tokens
    order by $token
    
    return $token    
    
 return xmldb:store-as-binary("/apps/dlri-app/modules/dex-processing/temp", "etymology-sections.txt", string-join($tokens, "&#10;"))