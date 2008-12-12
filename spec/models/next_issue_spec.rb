require File.dirname(__FILE__) + '/../spec_helper'

describe NextIssue, 'associations' do
  it 'should belong to an Issue' do
    NextIssue.should have_association(:issue, :belongs_to)
  end

  it 'should belong to a user' do
    NextIssue.should have_association(:user, :belongs_to)
  end
end
