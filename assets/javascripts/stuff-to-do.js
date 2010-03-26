// TODO: JSUnit test this
jQuery(function($) {
    $("#user_id").change(function() {  $("form#user_switch").submit();  });
    $("#ajax-indicator").ajaxStart(function(){ $(this).show();  });
    $("#ajax-indicator").ajaxStop(function(){ $(this).hide();  });

    $("#filter").change(function() {
        if ($('#filter').val() != '') {
            $.ajax({
                type: "GET",
                url: 'stuff_to_do/available_issues.js',
                data: $('#filter').serialize(),
                success: function(response) {
                    $('#available-pane').html(response);
                    attachSortables();
                },
                error: function(response) {
                    $("div.error").html("Error filtering pane.  Please refresh the page.").show();
                }});
        }
    });

  attachSortables = function() {
    $("#available").sortable({
        cancel: 'a',
        connectWith: ["#doing-now", "#recommended", "#time-grid-table tbody"],
        placeholder: 'drop-accepted',
        dropOnEmpty: true,
        update : function (event, ui) {
            if ($('#available li.issue').length > 0) {
                $("#available li.empty-list").hide();
            } else {
                $("#available li.empty-list").show();
            }
        },
      receive : function (event, ui) { removeItemFromTimeGridIfNeeded(event,ui);}
    });

    $("#doing-now").sortable({
        cancel: 'a',
        connectWith: ["#available", "#recommended", "#time-grid-table tbody"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); },
        receive : function (event, ui) { removeItemFromTimeGridIfNeeded(event,ui);}
    });

    $("#recommended").sortable({
        cancel: 'a',
        connectWith: ["#available", "#doing-now", "#time-grid-table tbody"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); },
        receive : function (event, ui) { removeItemFromTimeGridIfNeeded(event,ui);}
    });

    $("#time-grid-table tbody").sortable({
        connectWith: ["#available", "#doing-now", "#recommended"],
        items: 'tr',
        placeholder: 'drop-accepted',
        // Cancel the drag and drop if it's reordering itself
        update: function (event, ui) {
          if (ui.sender == null && isDraggingToTimeGrid($(event.target))) {
            $(this).sortable('cancel');
          }
        },
        receive : function (event, ui) {
          $(ui.sender).sortable('cancel');
          if (isAddingAnIssueToTimeGrid($(event.target))) {
            var std_item = ui.item;
            // Only add issues that are missing.
            if (!isProjectItem(std_item) && !isItemInTimeGrid(std_item)) {
                addItemToTimeGrid(std_item);
            }
          }
        }
    });
  },

  saveOrder = function() {
    data = 'user_id=' + user_id + '&' + $("#doing-now").sortable('serialize') + '&' + $("#recommended").sortable('serialize');
    if (filter != null) {
        data = data + '&filter=' + filter;
    }

    data = addAuthenticityToken(data);

    $.ajax({
        type: "POST",
        url: 'stuff_to_do/reorder.js',
        data: data,
        success: function(response) {
            $('#panes').html(response);
            attachSortables();
        },
        error: function(response) {
            $("div#stuff-to-do-error").html("Error saving lists.  Please refresh the page and try again.").show();
        }});

  },

    addItemToTimeGrid = function(issue) {
        $.ajax({
            type: "POST",
            url: 'stuff_to_do/add_to_time_grid.js',
            data: addAuthenticityToken('issue_id=' + getRecordId(issue) + '&' + $('#query_form').serialize()),
            success: function(response) {
                $('#time-grid').html(response);
                attachSortables();
            },
        error: function(response) {
            $("div#time-grid-error").html("Error saving Time Grid.  Please refresh the page and try again.").show();
        }});
    },

    removeItemFromTimeGrid = function(issue) {
        $.ajax({
            type: "POST",
            url: 'stuff_to_do/remove_from_time_grid.js',
            data: addAuthenticityToken('issue_id=' + getRecordId(issue) + '&' + $('#query_form').serialize()),
            success: function(response) {
                $('#time-grid').html(response);
                attachSortables();
            },
        error: function(response) {
            $("div#time-grid-error").html("Error saving Time Grid.  Please refresh the page and try again.").show();
        }});
    },

    isProjectItem = function(element) {
        return element.attr('id').match(/project/);
    },

    isItemInTimeGrid = function(element) {
        var record_id = getRecordId(element);
        return $('td.time-grid-issue issue_' + record_id).size() > 0;
    },

    isAddingAnIssueToTimeGrid = function(jqueryElement) {
      return (jqueryElement.parents('#time-grid-table').length == 0);
    },

    isDraggingToTimeGrid = function(jqueryElement) {
      return !isAddingAnIssueToTimeGrid(jqueryElement);
    },

    getRecordId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_').last();
    },

    removeItemFromTimeGridIfNeeded = function (event, ui) {
      if (!isAddingAnIssueToTimeGrid($(event.target)) ||  !isAddingAnIssueToTimeGrid(ui.sender)) {
        $(ui.sender).sortable('cancel');
        removeItemFromTimeGrid(ui.item);
      }
    },

    timeLogFacebox = function(issue_id, date) {
        if (issue_id != undefined) {
            $('#time_entry__issue_id').val(issue_id);
        }

        if (date != undefined) {
            $('#time_entry__core').val(date); // Renamed below
        }

        $.facebox({div: '#logtime'});
        bindTimeEntryForm(); // Rebind since Facebox copies it
        // Need to rebind the calendar by renaming the time_entry
        // fields and running setup.
        $('#facebox #time_entry__core').attr("id", "time_entry__spent_on");
        $('#facebox #time_entry__core_trigger').attr("id", "time_entry__spent_on_trigger");
        Calendar.setup({inputField : 'time_entry__spent_on', ifFormat : '%Y-%m-%d', button : 'time_entry__spent_on_trigger' });
    },

    parseIssueId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_')[1];
    },

    parseDateFromGrid = function(jqueryElement) {
        return jqueryElement.attr('class').split(' ')[1];
    },

    saveTimeEntriesRemotely = function(form) {
        $.ajax({
            type: "POST",
            url: 'stuff_to_do/save_time_entry.js',
            data: addAuthenticityToken($(form).serialize()),
            success: function(response) {
                $('#time-grid').before(response).remove();
                $('.time-grid-flash').not(':empty').show();
              jQuery(document).trigger('close.facebox');
            },
            error: function(response) {
              alert(response.responseText);
            }
        });
    },

    bindContextMenuToTimeGrid = function() {
        $("#time-grid-table tr td.time-grid-date").
            contextMenu({ menu: 'time-grid-menu', menuCssName: 'context-menu' },
                        function(action, el, pos) {
                            timeLogFacebox(parseIssueId(el.parent()),
                                           parseDateFromGrid(el));
                        });
    },

    bindTimeEntryForm = function() {
        $('#facebox #logtime form').submit(function(){
            saveTimeEntriesRemotely(this);
            return false;
        });
    },

    bindSaveTimeGridButtons = function() {
        $('.save-time-grid').click(function(){
            saveTimeEntriesRemotely();
            return false;
        });
    },

    initTimeGrid = function() {
        bindContextMenuToTimeGrid();
        bindTimeEntryForm();
        bindSaveTimeGridButtons();
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
