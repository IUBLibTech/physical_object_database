function tm_div(format, type, object_id, edit_mode, search_mode) {  
  jQuery.ajax({
    url: "/physical_objects/tm_form/",
    type: "GET",
    data: {"format" : format, "edit_mode" : true, "type" : type, 'edit_mode' : edit_mode, 'search_mode' : search_mode, "id" : object_id},
    dataType: "html",
    success: function(data) {
      jQuery("#technicalMetadatum").html(data);
    }
  });
}

function add_to_picklist(el) {
	if (el == $("#existing_radio")[0]) {
		jQuery.ajax({
    url: "/picklist_specifications/picklist_list/",
    type: "GET",
    data: {},
    dataType: "html",
    success: function(data) {
      jQuery("#picklist_add_div").html(data);
    }});
	} else if (el == $("#new_radio")[0])  {
		jQuery.ajax({
    url: "/picklist_specifications/new_picklist/",
    type: "GET",
    data: {},
    dataType: "html",
    success: function(data) {
      jQuery("#picklist_add_div").html(data);
    }});
        } else if (el == $("#shipment_radio")[0]) {
                jQuery.ajax({
    url: "/shipments/shipments_list/",
    type: "GET",
    data: {},
    dataType: "html",
    success: function(data) {
      jQuery("#picklist_add_div").html(data);
    }});
        } else if (el == $("#shipment_new_radio")[0])  {
                jQuery.ajax({
    url: "/shipments/new_shipment/",
    type: "GET",
    data: {},
    dataType: "html",
    success: function(data) {
      jQuery("#picklist_add_div").html(data);
    }});

	} else {
	  jQuery("#picklist_add_div").html("");
	}
}

