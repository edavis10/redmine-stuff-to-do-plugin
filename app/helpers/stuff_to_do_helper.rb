module StuffToDoHelper
  def progress_bar_sum(collection, field, opts)
    issues = remove_non_issues(collection)
    
    total = issues.inject(0) {|sum, n| sum + n.read_attribute(field) }
    divisor = issues.length
    return if divisor.nil? || divisor == 0

    progress_bar(total / divisor, opts)
  end
  
  def total_estimates(issues)
    remove_non_issues(issues).collect(&:estimated_hours).compact.sum
  end
  
  def filter_options(filters, selected = nil)
    html = options_for_select([[l(:stuff_to_do_label_filter_by), '']]) # Blank

    filters.each do |filter_group, options|
      next unless [:users, :priorities, :statuses, :projects].include?(filter_group)
      if filter_group == :projects
        # Projects only needs a single item
        html << content_tag(:option,
                            filter_group.to_s.capitalize,
                            :value => 'projects',
                            :style => 'font-weight: bold')
      else
        html << content_tag(:optgroup,
                            options_for_select(options.collect { |item| [item.to_s, filter_group.to_s + '-' + item.id.to_s]}, selected),
                            :label => filter_group.to_s.capitalize )
      end
    end
    
    return html
  end

  # Returns the stuff for a collection of StuffToDo items, removing anything
  # that have been deleted.
  def stuff_for(stuff_to_do_items)
    return stuff_to_do_items.collect(&:stuff).compact
  end

  # Returns the issues for a collection of StuffToDo items, removing anything
  # that have been deleted or isn't an Issue
  def issues_for(stuff_to_do_items)
    return remove_non_issues(stuff_to_do_items.collect(&:stuff).compact)
  end

  def remove_non_issues(stuff_to_do_items)
    stuff_to_do_items.reject {|item| item.class != Issue }
  end

  def total_hours_for_user_on_day(issue, user, date)
    total = issue.time_entries.inject(0.0) {|sum, time_entry|
      if time_entry.user_id == user.id && time_entry.spent_on == date
        sum += time_entry.hours
      end
      sum
    }

    total != 0.0 ? total : nil
  end

  def total_hours_for_issue_for_user(issue, user)
    total = issue.time_entries.inject(0.0) {|sum, time_entry|
      if time_entry.user_id == user.id
        sum += time_entry.hours
      end
      sum
    }
    total
  end

  def total_hours_for_date(issues, user, date)
    issues.collect {|issue| total_hours_for_user_on_day(issue, user, date)}.compact.sum
  end

  def total_hours_for_user(issues, user)
    issues.collect {|issue| total_hours_for_issue_for_user(issue, user)}.compact.sum
  end

  # Redmine 0.8.x compatibility
  def l_hours(hours)
    hours = hours.to_f
    l((hours < 2.0 ? :label_f_hour : :label_f_hour_plural), ("%.2f" % hours.to_f))
  end unless Object.method_defined?('l_hours')
  
  def stuff_to_do_to_csv(doing_now, recommended, available, user, options={})
    decimal_separator = l(:general_csv_decimal_separator)
    encoding = l(:general_csv_encoding)
    
    stuff_to_dos = stuff_for(doing_now + recommended)
    columns = [ l(:field_project), l(:field_tracker), l(:field_status), l(:field_priority), l(:field_subject)]
  
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv title
      csv << [ l(:stuff_to_do_title) ]
      csv << [ l(:field_user) + ": " + user.name ]
      
      subtitles = [l(:stuff_to_do_what_im_doing_now), l(:stuff_to_do_what_is_recommended)]
      
      if options[:available]
        subtitles << l(:stuff_to_do_what_is_available)
      end

      subtitles.each do |subtitle|      
        csv <<  [ '' ]
        csv << [ subtitle ]
        if subtitle == l(:stuff_to_do_what_im_doing_now)
          stuff_to_dos = stuff_for(doing_now)
        elsif subtitle == l(:stuff_to_do_what_is_recommended)
          stuff_to_dos = stuff_for(recommended)
        else
          stuff_to_dos = available
        end
        
        # csv header fields
        csv << [ "#" ] + columns.collect {|c| Redmine::CodesetUtil.from_utf8(c, encoding) }
        # csv lines
        stuff_to_dos.each do |stuff|
          if (stuff.kind_of? Issue)
            col_values = [ stuff.project.name, stuff.tracker, stuff.status.to_s, stuff.priority.to_s, stuff.subject ]
            id = stuff.id.to_s
          else
            col_values = [ stuff.name, '', '', '', '' ]
            id = ''
          end
          csv << [ id ] + col_values.collect {|c| Redmine::CodesetUtil.from_utf8(c.to_s, encoding) }
        end
      end
    end
    export
  end

end
