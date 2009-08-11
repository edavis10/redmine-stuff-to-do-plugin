require File.dirname(__FILE__) + '/../spec_helper'

describe User, "associations" do
  it 'should have a habtm time_grid_issues' do
    User.should have_association(:time_grid_issues, :has_and_belongs_to_many)
  end
end

