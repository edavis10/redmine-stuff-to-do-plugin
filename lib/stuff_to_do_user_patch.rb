# Patches Redmine's Users dynamically.
module StuffToDoUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable
    end
  end
end

