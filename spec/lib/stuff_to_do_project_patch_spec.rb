require File.dirname(__FILE__) + '/../spec_helper'

describe Project, 'associations' do
  it 'should have many stuff_to_dos as "stuff"' do
    Project.should have_association(:stuff_to_dos, :has_many)
  end
end
