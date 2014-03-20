function set_format_div(format) {  
  jQuery.ajax({
    url: "/picklist_specification/get_form",
    type: "GET",
    data: {"format" : format},
    dataType: "html",
    success: function(data) {
      jQuery("#formatDiv").html(data);
    }
  });
}

function jsRoar(selected) {
	alert("Selected: "+selected);
}


