window.dex = {};

dex.resultDisplayOptions = {
  valueNames: ["headword", "omonym-number", "grammatical-info", "id"],
  item: "results-item"
};
dex.resetResults = function() {
    $("#results-container .list").show();
    $("#details-container").hide(); 
    dex.resultDisplayContainer.clear();
    $("#details-container").empty();
};
dex.data = {};
dex.actions = {};
dex.data.chars = {'á': 'a','é': 'e','í': 'i', 'ó': 'o', 'ú': 'u', 'ắ': 'ă', 'ấ': 'â', 'ş': 'ș', 'ţ': 'ț'};
dex.data.searchString = "";

$.i18n().load({
    'ro': '/modules/i18n/ro.json',
    'en': '/modules/i18n/en.json'
}).done(function() {
    var locale = localStorage.getItem("locale")  || "ro";
    $("#language-selector").val(locale);
    $.i18n().locale = locale;
    $("body").i18n();
    
    $("#language-selector").selectmenu({
        "change": function(event, ui) {
            var locale = 
            $.i18n().locale = $(this).val();
            $("body").i18n();
            localStorage.setItem("locale", locale);
        }
    });        
});

/*$('#menu').slicknav({
    "label": ""
});
$(".selector").menu( "collapse" );*/
$("#navigation-toolbar").controlgroup();

var values = [];

dex.resultDisplayContainer = new List("results-container", dex.resultDisplayOptions, values);

document.addEventListener('click', event => {
    const target = event.target;
    
	if (target.matches("#results-container ul.list li, #results-container ul.list li span")) {
        let parent = target.parentNode;
        let chidren = Array.from(parent.children);
        let index = chidren.indexOf(target);
        var id = dex.resultDisplayContainer.items[index]._values["id"];

        fetch("/data/2019/html/" + id + ".html")
            .then((response) => response.text())
            .then((data) => {
                var detailsContainer = document.getElementById("details-container");
                detailsContainer.innerHTML = data;
                
                $("#results-container .list").hide();
                $("#details-container").show();
        });        
    }
    
    if (target.matches("#search-button")) {
        dex.actions.searchEntries();
    }    
    
    
    if (target.matches("#scrollToTop-button")) {
        document.getElementById("search-component").scrollIntoView();
    }   
    
    if (target.matches("#view-flip")) {
        $("#results-container .list").show();
        $("#details-container").hide();         
    }     
}, false);

document.addEventListener('keydown', event => {
    const target = event.target;
        
	if (event.keyCode === 13 && target.matches("#search-string")) {
        dex.actions.searchEntries();
    }
}, false);

dex.actions.searchEntries = function(id) {
    dex.resetResults();
    
    var searchString = $("#search-string").val();
    if (searchString != "") {
        searchString = searchString.toLowerCase().replace(/[áéíóúắấşţ]/g, m => dex.data.chars[m]);
        dex.data.searchString = searchString;
        
        fetch("/search/api/dex2019/_search", {
            method: "POST",
            body: '{"size": 1000, "from": 0, "query": {"boost": 1, "query": "' + searchString + '"}, "fields": ["*"]}'
        })
        .then((response) => response.json())
        .then((data) => {
            console.log(data);
            var processedData = [];
            
            data.hits.forEach(element => {
                var item = {
                    "headword": element.fields.s,
                    "omonym-number": element.fields.o,
                    "id": element.id,
                    "l":  element.fields.s.toLowerCase().replace(/[áéíóúắấşţ]/g, m => dex.data.chars[m])                        
                }
                processedData.push(item);
            });
            processedData.sort((a, b) => (a.l > b.l) ? 1 : -1)

            dex.resultDisplayContainer.add(processedData); 
        })
        .catch((error) => {
            console.error('Error:', error);
        });        
    }       
};

//document.getElementById("search-string").value = "cortel";    
