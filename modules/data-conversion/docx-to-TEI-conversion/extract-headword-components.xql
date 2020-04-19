xquery version "3.1";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

let $tokens := collection("/data/dex-input-data")//word:body/word:p/string() ! tokenize(., " ")[1]
let $tokens := $tokens ! replace(., "\p{L}", "") ! replace(., "\d{1,2}", "")

let $tokens := $tokens ! replace(., " ", "")

let $tokens := $tokens[. != '']
let $tokens := distinct-values(analyze-string(string-join($tokens), "\S")/*)[. != ' ']

return $tokens

(:
"," comma
" "
"."

"-"
"("
")"

" "
"®"
"´" acute accent
""
"’" apostrophe
:)
