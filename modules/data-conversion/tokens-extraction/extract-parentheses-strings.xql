xquery version "3.1";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

let $regex := "\(([^\d|^\)]+)\)"
let $paragraphs := collection("/data/dlri-app/raw")//word:body/word:p[data(.) != '']

let $tokens := $paragraphs ! analyze-string(., $regex)/fn:match/fn:group ! (let $token := . return if (matches($token, "^[A-Z]")) then $token else ()) ! tokenize(., ";") ! normalize-space(.)
let $tokens := distinct-values($tokens)
let $tokens :=
    for $token in $tokens
    order by $token
    
    return $token

return xmldb:store-as-binary("/apps/dlri-app/modules/dex-processing/temp", "parentheses-strings.txt", string-join($tokens, "&#10;"))
