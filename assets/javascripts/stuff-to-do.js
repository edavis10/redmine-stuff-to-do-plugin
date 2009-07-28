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

        var issue_id = getRecordId(issue);

        $.ajax({
            type: "POST",
            url: 'stuff_to_do/add_to_time_grid.js',
            data: 'issue_id=' + issue_id,
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
    };

  attachSortables();

});
