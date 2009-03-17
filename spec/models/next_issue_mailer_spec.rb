require File.dirname(__FILE__) + '/../spec_helper'

describe NextIssueMailer, 'recommended_below_threshold' do

  before(:each) do
    @settings = {'email_to' => 'user1@example.com,user2@example.com', 'threshold' => '5'}
    Setting.stub!(:plugin_stuff_to_do_plugin).and_return(@settings)
    Setting.stub!(:host_name).and_return('example.com')
    Setting.stub!(:protocol).and_return('https')
    @user = mock_model(User, :name => "Example User", :id => 100)
    @next_item_count = 2

    @mail = NextIssueMailer.create_recommended_below_threshold(@user, @next_item_count)
  end
  
  it 'should send to the users specified in the Settings' do
    @mail.bcc.should have(2).things
    @mail.bcc.should include("user1@example.com")
    @mail.bcc.should include("user2@example.com")
  end

  it 'should use the subject of "Whats Recommended is below the threshold"' do
    @mail.subject.should match(/What's Recommended is below the threshold/i)
  end
  
  it 'should have the user name in the body' do
    @mail.encoded.should match(/#{ @user.name }/)
  end

  it 'should say the threshold amount in the body' do
    @mail.encoded.should match(/threshold of 5/)
  end

  it 'should say the number of NextIssues for the user in the body' do
    @mail.encoded.should match(/only 2 recommended items left/)
  end
  
  it 'should have a link to the users stuff_to_do page in the body' do
    # '=3D' is the encoded version of '='
    @mail.encoded.should include("https://example.com/stuff_to_do?user_id=3D#{@user.id}")
  end
end
