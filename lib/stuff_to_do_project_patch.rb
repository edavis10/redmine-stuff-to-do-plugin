module StuffToDoProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      after_save :update_stuff_to_do
      has_many :stuff_to_dos, :as => :stuff
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    # This will update all StuffToDos assigned to the Project
    #
    # * When a project is archived, StuffToDo#closing_issue will be called to
    #   update the set of StuffToDos
    def update_stuff_to_do
      StuffToDo.closing_issue(self) unless self.active?
      return true
    end

  end    
end

