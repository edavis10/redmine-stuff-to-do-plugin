// TODO: JSUnit test this
jQuery(document).ready(function(){
    attachSortables();

    jQuery("#user_id").change(function() {  jQuery("form#user_switch").submit();  });
    jQuery("#ajax-indicator").ajaxStart(function(){ jQuery(this).show();  });
    jQuery("#ajax-indicator").ajaxStop(function(){ jQuery(this).hide();  });

    jQuery("#filter").change(function() {
        if (jQuery('#filter').val() != '') {
            jQuery.ajax({
                type: "GET",
                url: 'stuff_to_do/available_issues.js',
                data: jQuery('#filter').serialize(),
                success: function(response) {
                    jQuery('#available-pane').html(response);
                    attachSortables();
                },
                error: function(response) {
                    jQuery("div.error").html("Error filtering pane.  Please refresh the page.").show();
                }});
        }
    });

});

function attachSortables() {
    jQuery("#available").sortable({ 
        connectWith: ["#doing-now", "#recommended"], 
        placeholder: 'drop-accepted',
        dropOnEmpty: true,
        update : function (event, ui) {
            if (jQuery('#available li.issue').length > 0) {
                jQuery("#available li.empty-list").hide();
            } else {
                jQuery("#available li.empty-list").show();
            }
        }
    }); 

    jQuery("#doing-now").sortable({ 
        connectWith: ["#available", "#recommended"], 
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); }
    });  

    jQuery("#recommended").sortable({ 
        connectWith: ["#available", "#doing-now"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); }
    });  

}

function saveOrder() {
    data = 'user_id=' + user_id + '&' + jQuery("#doing-now").sortable('serialize') + '&' + jQuery("#recommended").sortable('serialize');
    if (filter != null) {
        data = data + '&filter=' + filter;
    }
    jQuery.ajax({
        type: "POST",
        url: 'stuff_to_do/reorder.js',
        data: data,
        success: function(response) {
            jQuery('#panes').html(response);
            attachSortables();
        },
        error: function(response) {
            jQuery("div.error").html("Error saving lists.  Please refresh the page and try again.").show();
        }});

}

