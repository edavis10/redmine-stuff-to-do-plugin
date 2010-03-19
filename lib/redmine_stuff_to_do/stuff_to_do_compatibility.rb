module RedmineStuffToDo
  module StuffToDoCompatibility
    class IssuePriority
      def self.all
        if Object.const_defined?('IssuePriority')
          ::IssuePriority.all
        elsif Enumeration.respond_to?(:priorities)
          return ::Enumeration.priorities
        else
          return ::Enumeration::get_values('IPRI')
        end
      end
    end
  end
end
