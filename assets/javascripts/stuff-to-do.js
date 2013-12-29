// TODO: JSUnit test this
jQuery(function($) {
	
    $("#user_id").change(function() {  $("form#user_switch").submit();  });
    $("#ajax-indicator").ajaxStart(function(){ $(this).show();  });
    $("#ajax-indicator").ajaxStop(function(){ $(this).hide();  });

    $("#filter").change(function() {
	    $.ajax({
	        type: "GET",
	        url: 'stuff_to_do/available_issues.js',
	        dataType: 'html',
	        data: { filter : $('#filter').val(), user_id : $('#user_id').val(), project_id : $('#project_id').val() },
	        success: function(response) {
	            $('#available-pane').html(response);
	            attachSortables();
	        },
	        error: function(response) {
	            $("div.error").html("Error filtering pane.  Please refresh the page.").show();
	            }});
	});
    
    $("#project_id").change(function() {
        $.ajax({
            type: "GET",
            url: 'stuff_to_do/available_issues.js',
            dataType: 'html',
            data: { filter : $('#filter').val(), user_id : $('#user_id').val(), project_id : $('#project_id').val() },
            success: function(response) {
                $('#available-pane').html(response);
                attachSortables();
            },
            error: function(response) {
                $("div.error").html("Error filtering pane.  Please refresh the page.").show();
            }});
	});

  attachSortables = function() {
    $("#available").sortable({
        cancel: 'a',
        connectWith: ["#doing-now", "#recommended"],
        placeholder: 'drop-accepted',
        dropOnEmpty: true,
        update : function (event, ui) {
            if ($('#available li.issue').length > 0) {
                $("#available li.empty-list").hide();
            } else {
                $("#available li.empty-list").show();
            }
        },
    });

    $("#doing-now").sortable({
        cancel: 'a',
        connectWith: ["#available", "#recommended"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); },
    });

    $("#recommended").sortable({
        cancel: 'a',
        connectWith: ["#available", "#doing-now"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); },
    });

  },


  saveOrder = function() {
    data = 'user_id=' + user_id + '&' + $("#doing-now").sortable('serialize') + '&' + $("#recommended").sortable('serialize');
    if (filter != null) {
        data = data + '&filter=' + filter;
    }
    
    if (project_id != null) {
    	data = data + '&project_id=' + project_id;
    }

    data = addAuthenticityToken(data);

    $.ajax({
        type: "POST",
        url: 'stuff_to_do/reorder.js',
        dataType: 'html',
        data: data,
        success: function(response) {
            $('#panes').html(response);
            attachSortables();
        },
        error: function(response) {
            $("div#stuff-to-do-error").html("Error saving lists.  Please refresh the page and try again.").show();
        }});

  },

    isProjectItem = function(element) {
        return element.attr('id').match(/project/);
    },

    getRecordId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_').last();
    },

    parseIssueId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_')[1];
    },

    addAuthenticityToken = function(data) {
      return data + '&authenticity_token=' + encodeURIComponent(window._token);
    },

  attachSortables();

    // Fix the image paths in facebox
    $.extend($.facebox.settings, {
        loadingImage: '../images/loading.gif',
        closeImage: '../plugin_assets/stuff_to_do_plugin/images/closelabel.gif',
        faceboxHtml  : '\
    <div id="facebox" style="display:none;"> \
      <div class="popup"> \
        <table> \
          <tbody> \
            <tr> \
              <td class="tl"/><td class="b"/><td class="tr"/> \
            </tr> \
            <tr> \
              <td class="b"/> \
              <td class="body"> \
                <div class="content"> \
                </div> \
                <div class="footer"> \
                  <a href="#" class="close"> \
                    <img src="../plugin_assets/stuff_to_do_plugin/images/closelabel.gif" title="close" class="close_image" /> \
                  </a> \
                </div> \
              </td> \
              <td class="b"/> \
            </tr> \
            <tr> \
              <td class="bl"/><td class="b"/><td class="br"/> \
            </tr> \
          </tbody> \
        </table> \
      </div> \
    </div>'

    });

});
