xquery version "3.0";

import module namespace ilir = "http://lingv.ro/ontology/templates/#ilir.xqm" at "ilir.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace console = "java:java.lang.System.out";

declare namespace word = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $grammatical-categories-regex-delimiter := "[\s|,]?\s?|";
declare variable $auxiliary-grammatical-categories := ("și ");
declare variable $pos-grammatical-categories := ("s\.", "pr\.", "adj\.", "vb\.", "adv\.", "conj\.", "interj\.", "prep\.", "art\.", "pron\.", "subst\.", "num\.");
declare variable $genre-grammatical-categories := ("m\.", "f\.", "n\.");
declare variable $genre-grammatical-categories-regex := string-join(($genre-grammatical-categories, $auxiliary-grammatical-categories), $grammatical-categories-regex-delimiter);
declare variable $number-grammatical-categories := ("sg\.", "pl\.", "invar\.");
declare variable $number-grammatical-categories-regex := string-join($number-grammatical-categories, $grammatical-categories-regex-delimiter);
declare variable $verb-voices := ("fact\.", "intranz\.", "tranz\.", "refl\.", "pas\.", "recipr\.");
declare variable $verb-voices-regex := string-join(($verb-voices, $auxiliary-grammatical-categories), $grammatical-categories-regex-delimiter);
declare variable $verb-conjugations := ("I\.", "II\.", "III\.", "IV\.");
declare variable $verb-conjugations-regex := string-join($verb-conjugations, $grammatical-categories-regex-delimiter);



declare variable $common-noun-grammatical-categories := ("art\.");
declare variable $adjective-grammatical-categories := ("dem\.", "interog\.-rel\.", "nehot\.", "pos\.");

declare variable $grammatical-cases := ("acuz\.", "dat\.", "gen\.", "gen\.-dat\.", "nom\.", "voc\.");
declare variable $grammatical-cases-regex := string-join($grammatical-cases, "|");
declare variable $pos-grammatical-categories-regex := string-join($pos-grammatical-categories, "|");
declare variable $grammatical-categories-regex := string-join(distinct-values(($pos-grammatical-categories, $genre-grammatical-categories, $number-grammatical-categories, $common-noun-grammatical-categories, $adjective-grammatical-categories, $verb-conjugations, $verb-voices, $auxiliary-grammatical-categories, $grammatical-cases)), $grammatical-categories-regex-delimiter);
declare variable $element-de-compunere-delimiter := " Element de compunere";

declare function local:reverse($string) {
	codepoints-to-string(reverse(string-to-codepoints($string)))
};

declare function local:generate-lemma-entry($raw-text-content) {
	let $raw-sections := local:generate-raw-sections($raw-text-content)
	
	let $headword := map:get($raw-sections, "headword")
	let $homonym-number := map:get($raw-sections, "homonym")
	let $grammatical-categories := local:generate-grammatical-categories(map:get($raw-sections, "grammatical-categories"))
	let $senses := local:generate-senses(map:get($raw-sections, "senses"), $headword || $homonym-number)
	let $variants := local:generate-variants(map:get($raw-sections, "variants"))
	let $etymology := local:generate-etymology(map:get($raw-sections, "etymology"))
	
	(:
	let $raw-text-content := replace($raw-text-content, "\.([^\s\d;:])", ". $1")
	
	let $raw-headword := normalize-space($paragraph//word:r[1]/word:t)
	let $headword := if (contains($raw-headword, ",")) then substring-before($raw-headword, ",") else $raw-headword
	let $homonym-number := normalize-space($paragraph//word:r[word:rPr/word:vertAlign[@word:val = 'superscript']][1]/word:t)
	:)
	
	return
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="uuid-{util:uuid($headword)}">
        	<teiHeader type="text">
        		<fileDesc>
        			<titleStmt>
        				<title />
        				<author />
        				<editor role="reviewer" />
        			</titleStmt>
        			<publicationStmt>
        				<publisher>Linguistic Institute of the Romanian Academy</publisher>
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
        				{
        				    (
        				        $grammatical-categories
        				        ,
        				        $senses
        				        ,
        				        $variants
        				        ,
        				        $etymology
        				    )
        				}
        			</entry>
        		</body>
        	</text>
        </TEI>	
};

declare function local:generate-variant-entry($raw-text-content) {
	let $raw-sections := local:generate-raw-sections($raw-text-content)
	
	let $headword := map:get($raw-sections, "headword")
	let $homonym-number := map:get($raw-sections, "homonym")
	let $grammatical-categories := local:generate-grammatical-categories(map:get($raw-sections, "grammatical-categories"))
	let $senses := local:generate-senses(map:get($raw-sections, "senses"), $headword || $homonym-number)
	let $variants := local:generate-variants(map:get($raw-sections, "variants"))
    
    return
        <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="uuid-{util:uuid($headword)}">
        	<teiHeader type="text">
        		<fileDesc>
        			<titleStmt>
        				<title />
        				<author />
        				<editor role="reviewer" />
        			</titleStmt>
        			<publicationStmt>
        				<publisher>Linguistic Institute of the Romanian Academy</publisher>
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
        				{
        				    $grammatical-categories
        				}
        				<ptr target="{$senses}"/>
        			</entry>
        		</body>
        	</text>
        </TEI>
};

declare function local:generate-raw-sections($raw-text-content) {
	let $delimiter-1 := "] – "
	let $delimiter-2 := " – "
	
	let $raw-sections := map {}
	
	(: extract the etymology section :)
	let $raw-sections :=
		let $delimiter :=
			if (contains($raw-text-content, $delimiter-1))
			then $delimiter-1
			else $delimiter-2
		let $raw-sections := map:put($raw-sections, "raw-text-content", substring-before($raw-text-content, $delimiter))
		let $raw-sections := map:put($raw-sections, "etymology", substring-after($raw-text-content, $delimiter))
			
		return $raw-sections
	
	(: extract some variant forms :)
	let $raw-sections :=
		if (contains($raw-text-content, $delimiter-1))
		then 
			let $raw-text-content := map:get($raw-sections, "raw-text-content")
			let $raw-sections := map:put($raw-sections, "variants", substring-after($raw-text-content, "["))
			let $raw-sections := map:put($raw-sections, "raw-text-content", substring-before($raw-text-content, "["))
			
			return $raw-sections
		else $raw-sections

	(: extract the headword, the grammatical categories, and the senses sections, respectively :)	
	let $raw-sections :=
		let $raw-text-content := map:get($raw-sections, "raw-text-content")
		
		return
		    if (contains($raw-text-content, $element-de-compunere-delimiter))
		    then
		        let $headword-section := normalize-space(substring-before($raw-text-content, $element-de-compunere-delimiter))
		        let $senses-section := normalize-space($element-de-compunere-delimiter || substring-after($raw-text-content, $element-de-compunere-delimiter))
		        
		        let $raw-sections := map:put($raw-sections, "headword", $headword-section)
		        let $raw-sections := map:put($raw-sections, "senses", $senses-section)
		        
		        return $raw-sections
		    else local:extract-grammatical-categories($raw-sections, $raw-text-content)
	
		    
	(: TODO: extract the remaining variants :)
	(: extract the headword and the homonym number :)
	let $raw-sections :=
		let $headword-regex := "^(.*)(\d{1,2})$"
		let $headword-section := map:get($raw-sections, "headword")
		let $headword-section-components := tokenize($headword-section, ",")[. != '']
		let $headword := normalize-space($headword-section-components[1])
		let $raw-sections :=
			if (matches($headword, $headword-regex))
			then
				let $raw-sections := map:put($raw-sections, "headword", replace($headword, $headword-regex, "$1"))
				let $raw-sections := map:put($raw-sections, "homonym", replace($headword, $headword-regex, "$2"))
				
				return $raw-sections
			else map:put($raw-sections, "headword", $headword) 
		
		return $raw-sections
		
	return $raw-sections
};

declare function local:extract-grammatical-categories($raw-sections, $raw-text-content) {
    let $processed-raw-text-content := analyze-string($raw-text-content, $grammatical-categories-regex, "i")
    let $second-non-match-element := $processed-raw-text-content/fn:non-match[2]
    
    return
	    if (exists($second-non-match-element))
	    then
    		let $end-index := index-of($processed-raw-text-content/*, $second-non-match-element)[1] - 2
    					
    		let $grammatical-categories-section := normalize-space(string-join(subsequence($processed-raw-text-content/*, 2, $end-index)/data(.), ""))
    		let $headword-section := normalize-space(substring-before($raw-text-content, $grammatical-categories-section))
    		let $senses-section := normalize-space(substring-after($raw-text-content, $grammatical-categories-section))
    		
    		let $raw-sections := map:put($raw-sections, "grammatical-categories", $grammatical-categories-section)
    		let $raw-sections := map:put($raw-sections, "headword", $headword-section)
    		let $raw-sections := map:put($raw-sections, "senses", $senses-section)
    		
    		return $raw-sections		
	    else map:put($raw-sections, "error", "Intrarea '" || $raw-text-content || "' nu are categorii gramaticale!")    
};

declare function local:generate-grammatical-categories($raw-text-content) {
	let $grammatical-categories := tokenize($raw-text-content, ",")[. != '']
	
	return
		for $grammatical-category in $grammatical-categories
		let $grammatical-category := normalize-space($grammatical-category)
		
		return
				(: get the part of speech :)
				let $pos := string-join(analyze-string($grammatical-category, $pos-grammatical-categories-regex)/fn:match/data(.), "")
				
				return (
						if ($pos = "s.")
						then
							let $genre := normalize-space(string-join(analyze-string($grammatical-category, $genre-grammatical-categories-regex)//fn:match/data(.), ""))
							let $number := string-join(analyze-string($grammatical-category, $number-grammatical-categories-regex)//fn:match/data(.), "")
							let $case := string-join(analyze-string($grammatical-category, $grammatical-cases-regex)//fn:match/data(.), "")
							let $name := string-join(analyze-string($grammatical-category, string-join(subsequence($common-noun-grammatical-categories, 8, 1), $grammatical-categories-regex-delimiter))//fn:match/data(.), "")
							let $name := if (string-length($name) = 0) then "unknown" else $name
							
							return
                               <gramGrp xmlns="http://www.tei-c.org/ns/1.0">
                                   <pos value="{$pos}" />
                                   <gen xmlns="http://www.tei-c.org/ns/1.0" value="{$genre}" />
                                   <number xmlns="http://www.tei-c.org/ns/1.0" value="{$number}"/>
                                   <case xmlns="http://www.tei-c.org/ns/1.0" value="{$case}"/>
                                   <name xmlns="http://www.tei-c.org/ns/1.0" type="{$name}"/>
                               </gramGrp>						    
						else ()
						,
						if ($pos = "vb.")
						then
							let $iType := string-join(analyze-string($grammatical-category, $verb-conjugations-regex)//fn:match/data(.), "")
							let $subc := string-join(analyze-string($grammatical-category, $verb-voices-regex, "i")//fn:match/data(.), "")
							
							return
                               <gramGrp xmlns="http://www.tei-c.org/ns/1.0">
                                   <pos value="{$pos}" />
                                   <iType xmlns="http://www.tei-c.org/ns/1.0" value="{$iType}" />
                                   <subc xmlns="http://www.tei-c.org/ns/1.0" value="{$subc}"/>
                               </gramGrp>							    
						else ()						
						,
						if ($pos = "adj.")
						then
						    let $subc := string-join(analyze-string($grammatical-category, string-join(subsequence($adjective-grammatical-categories, 1, 4), $grammatical-categories-regex-delimiter))//fn:match/data(.), "")
						    let $subc := if ($subc != '') then $subc else "empty"
							let $genre := normalize-space(string-join(analyze-string($grammatical-category, $genre-grammatical-categories-regex)//fn:match/data(.), ""))
							let $number := string-join(analyze-string($grammatical-category, $number-grammatical-categories-regex)//fn:match/data(.), "")
							let $case := string-join(analyze-string($grammatical-category, $grammatical-cases-regex)//fn:match/data(.), "")
						    
						    return
                				<gramGrp xmlns="http://www.tei-c.org/ns/1.0">
                					<pos value="{$pos}" />
                					<subc value="adj.-{$subc}" />
                					<gen value="{$genre}" />
                					<number value="{$number}" />
                					<case value="{$case}" />
                				</gramGrp>
                		else ()
					)
};

declare function local:generate-senses($raw-senses-section, $headword) {
	let $raw-senses-section :=
		if (contains($raw-senses-section, "1."))
		then tokenize($raw-senses-section, "\d\.")[. != '']
		else $raw-senses-section
	
	return	
		for $sense at $i in $raw-senses-section
			
		return
            (: TODO set better uuid for sense :)
            <sense xmlns="http://www.tei-c.org/ns/1.0" xml:id="uuid-{util:uuid($headword || $i)}">
                <idno n="" type="level-label" />
                <idno n="tip-unitate-semantică-subsumată" type="unknown" />
                <idno n="tip-proces-semantic" type="unknown" />
                <def n="">{normalize-space($sense)}</def>
                <cit>
                    <quote />
                    <bibl type="unknown">
                        <ptr target="unknown" />
                        <date />
                        <citedRange />
                    </bibl>
                </cit>
            </sense>		
};

declare function local:generate-variants($raw-variants-section) {
	let $writing-form-delimiter := "Scris și:"
	let $pronunciation-form-delimiter := "Pr.:"
	
	let $variants := tokenize($raw-variants-section, "–") 
	let $processed-variants :=
		for $variant in $variants
		
		return (
			if (contains($variant, $writing-form-delimiter))
			then
            	<form xmlns="http://www.tei-c.org/ns/1.0" type="writing">
            		<oVar>{replace(normalize-space(substring-after($variant, $writing-form-delimiter)), "\.$", "")}</oVar>
            	</form>			    
			else ()
			,
			if (contains($variant, $pronunciation-form-delimiter))
			then
                <form xmlns="http://www.tei-c.org/ns/1.0" type="pronunciation" value="">
				    <pRef xmlns="http://www.tei-c.org/ns/1.0" xml:lang="ro-x-accent-lowcase-vowels">{replace(normalize-space(substring-after($variant, $pronunciation-form-delimiter)), "\.$", "")}</pRef>                
                </form>
			else ()			
		)
			
	
	return $processed-variants
};

declare function local:generate-etymology($raw-etymology-section) {
	if (starts-with($raw-etymology-section, "Din "))
	then
		<etym xmlns="http://www.tei-c.org/ns/1.0" cert="high">
			<idno type="cuvântul.titlu-element.extern-împrumut-etimon.sigur" />
			<term xml:lang="" type="unknown" />
		</etym>	    
	else $raw-etymology-section
};

let $documents := collection("/data/dlri-app/raw")
let $paragraphs := $documents//word:body/word:p[data(.) != '']

let $entries :=
	for $paragraph in $paragraphs
	let $raw-text-content := data($paragraph/*)
	let $raw-text-content := string-join($raw-text-content, "")
	let $raw-text-content := normalize-space($raw-text-content)
	let $raw-text-content := replace($raw-text-content, "—", "–")
	let $raw-text-content := replace($raw-text-content, " ", " ")
	let $raw-text-content := replace($raw-text-content, "[\S|\s]–[\S|\s]", " – ")
	let $raw-text-content := replace($raw-text-content, "ş", "ș")
	
	
	let $processed-entry-template :=
		if (contains($raw-text-content, " v. "))
		then local:generate-variant-entry($raw-text-content)
		else local:generate-lemma-entry($raw-text-content)
	
	return $processed-entry-template
	

return (
	for $entry in $entries
	
	return xmldb:store("/db/data/dlri-app/content", $entry/@xml:id || ".xml", $entry)
)
