class SortUser < ActiveRecord::Base
  unloadable
  belongs_to :user
  belongs_to :item
  default_scope :order => 'sort_users.position'
  class << self
    def reorder(user_id,item_id, position)
      @sort_user = first(:conditions => {:user_id => user_id, :item_id => item_id}) ||
        new(:user_id => user_id, :item_id => item_id)
      @sort_user.position = position
      @sort_user.save!
    end
    def sort_users( user, users )
      @stuff_to_do_position = all(:conditions => {:user_id => user.id})
      @stuff_to_do_max_position = maximum(:position, :conditions => {:user_id => user.id})
      users.map {|x|
        if @user_position = @stuff_to_do_position.find{|v| v.item_id == x.id }
          x.stuff_to_do_position = @user_position.position
        else
          x.stuff_to_do_position = @stuff_to_do_max_position.to_i + 1
        end
      }
      users.sort{|v1,v2| v1.stuff_to_do_position <=> v2.stuff_to_do_position}
    end
  end
end
