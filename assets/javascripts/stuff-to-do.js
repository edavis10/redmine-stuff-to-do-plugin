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
        }
    });

    $("#doing-now").sortable({
        cancel: 'a',
        connectWith: ["#available", "#recommended", "#time-grid-table tbody"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); }
    });

    $("#recommended").sortable({
        cancel: 'a',
        connectWith: ["#available", "#doing-now", "#time-grid-table tbody"],
        dropOnEmpty: true,
        placeholder: 'drop-accepted',
        update : function (event, ui) { saveOrder(ui); }
    });

    $("#time-grid-table tbody").sortable({
        connectWith: ["#available", "#doing-now", "#recommended"],
        items: 'th',
        placeholder: 'drop-accepted',
        update : function (event, ui) {
            $(ui.sender).sortable('cancel');
            var std_item = ui.item;
            // Only add issues that are missing.
            if (!isProjectItem(std_item) && !isItemInTimeGrid(std_item)) {
                addItemToTimeGrid(std_item);
            }
        }
    });
  },

  saveOrder = function() {
    data = 'user_id=' + user_id + '&' + $("#doing-now").sortable('serialize') + '&' + $("#recommended").sortable('serialize');
    if (filter != null) {
        data = data + '&filter=' + filter;
    }
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
        var issues = $('#time-grid .issue').map(function(){
            return 'issue_ids[]=' + getRecordId($(this));
        }).get();

        issues.push('issue_ids[]=' + getRecordId(issue));

        $.ajax({
            type: "POST",
            url: 'stuff_to_do/add_to_time_grid.js',
            data: issues.join('&'),
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

    getRecordId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_').last();
    },

    timeLogFacebox = function(issue_id) {
        if (issue_id != undefined) {
            $('#time_entry__issue_id').val(issue_id);
        }
        $.facebox({div: '#logtime'});
        bindTimeEntryForm(); // Rebind since Facebox copies it
    },

    parseIssueId = function(jqueryElement) {
        return jqueryElement.attr('id').split('_')[1];
    },

    updateTimeGridCell = function(hours, date, cell) {
        var current_hours = parseFloat(cell.html());

        if (current_hours == 0) {
            cell.html(hours);
        } else if (isNaN(current_hours)) {
            cell.html(hours);
        } else {
            cell.html( parseFloat(hours) + current_hours);
        }
    },

  $("#time-grid-table tr").contextMenu({ menu: 'time-grid-menu', menuCssName: 'context-menu' },
                             function(action, el, pos) {
                                 // TODO: Needs to get the issue id
                                 timeLogFacebox(parseIssueId(el));
                               });

    bindTimeEntryForm = function() {
        $('#facebox #logtime form').submit(function(){
            // Save to page for the main table
            if ($('#time-grid-table').data('new-time-entry')) {
                jQuery('#time-grid-table').data('new-time-entry',
                                                // flatten() is Prototype
                                                new Array(jQuery('#time-grid-table').data('new-time-entry'),
                                                          jQuery('#facebox #logtime form').serialize()).flatten()
                                               );
            } else {
                jQuery('#time-grid-table').data('new-time-entry',
                                                new Array($('#facebox #logtime form').serialize()));
            }

            // Update the main table's content
            var hours = $('#facebox #logtime form #time_entry__hours').val();
            var issue_id = $('#facebox #logtime form #time_entry__issue_id').val();
            var date = $('#facebox #logtime form #time_entry__spent_on').val();

            var time_grid_cell = $('#issue_' + issue_id + ' .' + date);
            var time_grid_daily_total_cell = $('tr.daily-totals .totals.' + date);
            var time_grid_running_total_cell = $('#issue_' + issue_id + ' .time-grid-running-total');

            updateTimeGridCell(hours, date, time_grid_cell);
            updateTimeGridCell(hours, date, time_grid_daily_total_cell);
            updateTimeGridCell(hours, date, time_grid_running_total_cell);

            // TODO: Add message

            jQuery(document).trigger('close.facebox');
            return false;
        });
    },

    bindTimeEntryForm();

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
