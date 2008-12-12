require File.dirname(__FILE__) + '/../spec_helper'

describe StuffToDoController, '#index' do
  it 'should be successful' do
    get :index
    response.should be_success
  end
end
