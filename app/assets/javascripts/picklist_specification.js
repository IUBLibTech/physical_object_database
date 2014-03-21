function set_format_div(format, edit_mode) {  
  jQuery.ajax({
    url: "/picklist_specification/get_form",
    type: "GET",
    data: {"format" : format, "edit_mode" : edit_mode},
    dataType: "html",
    success: function(data) {
      jQuery("#formatDiv").html(data);
    }
  });
}

function jsRoar(selected) {
	alert("Selected: "+selected);
}


