window.dglr = {};

dglr.resultDisplayOptions = {
  valueNames: ["l", "id"],
  item: "results-item"
};
dglr.resetResults = function() {
    $("#results-container .list").show();
    $("#details-container").hide(); 
    dglr.resultDisplayContainer.clear();
    $("#details-container").empty();
};
dglr.data = {};
dglr.actions = {};
dglr.data.chars = {'á': 'a','é': 'e','í': 'i', 'ó': 'o', 'ú': 'u', 'ắ': 'ă', 'ấ': 'â', 'ş': 'ș', 'ţ': 'ț'};
dglr.data.searchString = "";

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

dglr.resultDisplayContainer = new List("results-container", dglr.resultDisplayOptions, values);

document.addEventListener('click', event => {
    const target = event.target;
    
	if (target.matches("#results-container ul.list li, #results-container ul.list li span")) {
        let parent = target.parentNode;
        let chidren = Array.from(parent.children);
        let indglr = chidren.indexOf(target);
        var id = dglr.resultDisplayContainer.items[indglr]._values["id"];

        fetch("/data/html/" + id + ".html")
            .then((response) => response.text())
            .then((data) => {
                var detailsContainer = document.getElementById("details-container");
                detailsContainer.innerHTML = data;
                
                $("#results-container .list").hide();
                $("#details-container").show();
        });        
    }
    
    if (target.matches("#search-button")) {
        dglr.actions.searchEntries();
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
        dglr.actions.searchEntries();
    }
}, false);

dglr.actions.searchEntries = function(id) {
    dglr.resetResults();
    
    var searchString = $("#search-string").val();
    if (searchString != "") {
        searchString = searchString.toLowerCase().replace(/[áéíóúắấşţ]/g, m => dglr.data.chars[m]);
        dglr.data.searchString = searchString;
        
        fetch("/search/api/dglr/_search", {
            method: "POST",
            body: '{"size": 1000, "from": 0, "query": {"boost": 1, "query": "' + searchString + '"}, "fields": ["*"]}'
        })
        .then((response) => response.json())
        .then((data) => {
            console.log(data);
            var processedData = [];
            
            data.hits.forEach(element => {
                var l = element.fields.i.toLowerCase().replace(/[áéíóúắấşţ]/g, m => dglr.data.chars[m]);
                l = l.toUpperCase();
                var item = {
                    "id": element.id,
                    "l":  element.fields.i.toLowerCase().replace(/[áéíóúắấşţ]/g, m => dglr.data.chars[m])                        
                }
                processedData.push(item);
            });
            processedData.sort((a, b) => (a.l > b.l) ? 1 : -1)

            dglr.resultDisplayContainer.add(processedData); 
        })
        .catch((error) => {
            console.error('Error:', error);
        });        
    }       
};

//document.getElementById("search-string").value = "cortel";    
