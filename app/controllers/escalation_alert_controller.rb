class EscalationAlertController < ApplicationController
  unloadable

  def check_for_escalations
    subscribed = CustomField.find_by_name_and_type 'Wiedervorlage', 'UserCustomField'
    users = User.where('type = "User"')
    intervals = expand_intervals Setting.plugin_escalation_alert['intervals']

    users.each do |user|
      if user.custom_field_value(subscribed) == '1'
        escalations = Array.new
        issues = Issue.where('due_date IS NOT NULL AND assigned_to_id = ?', user.id)
        issues += Issue.where('due_date IS NOT NULL AND author_id = ? AND assigned_to_id IS NULL', user.id)

        issues.each do |issue|
          message_dates = intervals.map{|i| issue.due_date - i}

          if issue.due_date < Date.today or message_dates.include? Date.today
            escalations << issue
          end
        end

        if escalations.size > 0
          EscalationMailer.escalation(escalations, user).deliver
        end
      end
    end

    redirect_to :home
  end

  private

  def expand_intervals(intervals)
    expanded = Array.new

    intervals.split(',').each do |interval|
      if m = interval.match(/\[(\d+)\-(\d+)\]/)
        expanded += Array.new(m[2].to_i - m[1].to_i + 1).fill{|i| m[1].to_i + i}
      elsif m = interval.match(/\d+/)
        expanded << m[0].to_i
      end
    end

    return expanded.uniq
  end

end
