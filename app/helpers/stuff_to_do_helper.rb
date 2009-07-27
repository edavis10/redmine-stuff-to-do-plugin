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
      else
        sum
      end
    }

    total != 0.0 ? total : nil
  end

  def total_hours_for_user_for_date_range(issue, user, date_from, date_to)
    current_date = date_from
    total = 0.0
    while current_date <= date_to
      hours = total_hours_for_user_on_day(issue, user, current_date)
      total += hours unless hours.nil?
      current_date += 1
    end
    total
  end
end
