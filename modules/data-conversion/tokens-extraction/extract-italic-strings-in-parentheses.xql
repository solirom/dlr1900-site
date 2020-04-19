xquery version "3.1";

let $parentheses-strings := tokenize(util:binary-to-string(util:binary-doc("/exist/apps/dlri-app/modules/dex-processing/temp/parentheses-strings.txt")), "&#10;")
let $italic-strings := doc("/exist/apps/dlri-app/modules/dex-processing/temp/italic-strings.xml")//italic-string

let $italic-strings-in-parentheses :=
    for $parentheses-string in $parentheses-strings
    
    return
        if (ngram:contains($italic-strings, $parentheses-string))
        then $parentheses-string
        else ()
        
return xmldb:store-as-binary("/apps/dlri-app/modules/dex-processing/temp", "italic-strings-in-parentheses.txt", string-join($italic-strings-in-parentheses, "&#10;"))