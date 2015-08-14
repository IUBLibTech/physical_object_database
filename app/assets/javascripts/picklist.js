$(document).ready(function() 
{
    $("#pack_form > *").keypress(function(event) 
    { 
        if (event.keyCode == 13)
        {
            event.preventDefault();
            $(this).trigger("change");
        }
    });
});
var $pl_tooltip = $('#pl_tooltip'), offset = {x: 20, y: 20};

  
