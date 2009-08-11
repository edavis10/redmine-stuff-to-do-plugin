# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"

# Allows loading of an environment config based on the environment
redmine_root = ENV["REDMINE_ROOT"] || File.dirname(__FILE__) + "/../../../.."
require File.expand_path(redmine_root + "/config/environment")
require 'spec'
require 'spec/rails'
require 'ruby-debug'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

# require the entire app if we're running under coverage testing,
# so we measure 0% covered files in the report
#
# http://www.pervasivecode.com/blog/2008/05/16/making-rcov-measure-your-whole-rails-app-even-if-tests-miss-entire-source-files/
if defined?(Rcov)
  all_app_files = Dir.glob('{app,lib}/**/*.rb')
  all_app_files.each{|rb| require rb}
end


module AssociationMatcher
  class Association
    def initialize(field, association_type)
      @field = field
      @association_type = association_type
    end
    
    def matches?(model)
      @model=model
      association = @model.reflect_on_association(@field)
      return false if association.nil?

      return association.name == @field && association.macro == @association_type
    end
    
    def failure_message
      "expected <#{@model.name}> to have a #{@association_type} association for #{@field}"
    end

    def negative_failure_message
      "expected <#{@model.name}> to not have a #{@association_type} association for #{@field} but one was found"
    end
  end

  def have_association(field, association_type)
    Association.new(field, association_type)
  end
end

include AssociationMatcher

describe 'get_time_grid_data', :shared => true do
  it 'should set @date for the view' do
    do_request
    assigns[:date].should_not be_nil
  end

  it 'should set @calendar for the view' do
    do_request
    assigns[:calendar].should_not be_nil
  end

  it 'should set @issues for the view' do
    do_request
    assigns[:issues].should_not be_nil
  end

  it 'should set @time_entry for the view' do
    do_request
    assigns[:time_entry].should_not be_nil
  end

  it 'should get the issues and time entries for the user in the date range' do
    # Redmine uses dates based on language settings
    first_workday = (l(:general_first_day_of_week).to_i - 1)%7 + 1
    last_workday = (first_workday + 5)%7 + 1
    date = Date.today
    date_from = date - (date.cwday - first_workday)%7
    date_to = date + (last_workday - date.cwday)%7

    project = mock_model(Project, :name => 'ABC Test')
    issues = [
              mock_model(Issue, :project => project, :subject => 'Testing', :time_entries => []),
              mock_model(Issue, :project => project, :subject => 'Testing', :time_entries => [])
             ]
    User.current.should_receive(:time_grid_issues).and_return(Issue)
    Issue.should_receive(:visible).at_least(:once).and_return(Issue)
    Issue.should_receive(:all).
      with(:order => "#{Issue.table_name}.id ASC").
      and_return(issues)
                                                          
    do_request
  end

end

