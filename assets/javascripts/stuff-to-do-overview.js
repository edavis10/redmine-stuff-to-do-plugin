jQuery(function($) {

  $( ".authors-blocks" ).sortable({
      update: function(event, ui){
        var data  = "user_id="+ user_id + '&' + $(".authors-blocks:first").sortable('serialize');
        data = addAuthenticityToken(data);
        console.log(data)
        $.ajax({
             type: "POST",
              url: '/stuff_to_do/reorder_list_user.js',
             data: data,
          success: function(response) {
           },
            error: function(response) {
                 $("div#stuff-to-do-error").html("Error saving lists.  Please refresh the page and try again.").show();
            }
         });

      }
  });
	$( ".one-line" ).draggable({
			helper: "clone",
    	activeClass: "ui-state-default",
			hoverClass: "ui-state-hover"
	})

	$( ".issues" ).droppable({
			activeClass: "ui-state-default",
			hoverClass: "ui-state-hover",
      helper: "clone",
			accept: ".issues > .one-line",
			 drop: function( event, ui ) {
			 	$( '<div class="one-line" data-item_id="'+ ui.draggable.attr("data-item_id") +'" data-owner_id="'+ ui.draggable.attr("data-owner_id") +'"></div>' ).html( ui.draggable.html() ).prependTo( this ).andSelf().draggable({ helper: "clone" });

        var data  = {user_id: $(this).attr("data-user_id"), owner_id: ui.draggable.attr("data-owner_id") }
        var data_issues = jQuery.map(jQuery(this).find(".one-line"),
                             function(item){ return jQuery(item).attr("data-item_id") });
        data["stuff"] = data_issues;
        data = jQuery.param(data);
        data = addAuthenticityToken(data);
				ui.draggable.remove();

        $.ajax({
        type: "POST",
        url: '/stuff_to_do/reorder.js',
        data: data,
        success: function(response) {
            // $('#panes').html(response);
            // attachSortables();
        },
        error: function(response) {
            $("div#stuff-to-do-error").html("Error saving lists.  Please refresh the page and try again.").show();
        }});


			 }
		})

});
