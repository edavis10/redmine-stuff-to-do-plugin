module StuffToDoHelper
  def progress_bar_sum(collection, field, opts)
    total = collection.inject(0) {|sum, n| sum + n.read_attribute(field) }
    divisor = collection.length
    return if divisor.nil? || divisor == 0

    progress_bar(total / divisor, opts)
  end
  
  def total_estimates(issues)
    issues.collect(&:estimated_hours).compact.sum
  end
  
  def filter_options(filters)
    html = ''
    filters.each_pair do |filter_group, options|
      next unless [:users, :priorities, :statuses].include?(filter_group)
      
      html << content_tag(:optgroup,
                          options_from_collection_for_select(options, :id, :to_s),
                          :label => filter_group.to_s.capitalize )
    end
    
    return html
  end
end
