# Redmine Shams
Sham.mail { Faker::Internet.email }
Sham.name { Faker::Name.name }
Sham.firstname { Faker::Name.first_name }
Sham.lastname { Faker::Name.last_name }
Sham.login { Faker::Internet.user_name }
Sham.project_name { Faker::Company.name[0..29] }
Sham.identifier { Faker::Internet.domain_word.downcase }
Sham.message { Faker::Company.bs }
Sham.position {|index| index }
Sham.single_name { Faker::Internet.domain_word.capitalize }
Sham.integer(:unique => false) { rand(100) }

Sham.permissions(:unique => false) {
  [
   :view_issues
  ]
}

# Redmine specific blueprints
User.blueprint do
  mail
  firstname
  lastname
  login
end

Project.blueprint do
  name { Sham.project_name }
  identifier
  enabled_modules { Sham.enabled_modules }
end

def make_project_with_enabled_modules(attributes = {})
  Project.make(attributes) do |project|
    ['issue_tracking'].each do |name|
      project.enabled_modules.make(:name => name)
    end
  end
end

EnabledModule.blueprint do
  project
  name { 'issue_tracking' }
end

Member.blueprint do
  project
  user
end

Role.blueprint do
  name { Sham.single_name }
  position
  permissions
end

MemberRole.blueprint do
  role { Role.make }
end

# Stupid circular validations
def make_member(attributes, roles)
  member = Member.new(attributes)
  member.roles << roles
  member.save!
end

Enumeration.blueprint do
  name { Sham.single_name }
  opt { 'IPRI' }
end

IssuePriority.blueprint do
  name { Sham.single_name }
end

TimeEntryActivity.blueprint do
  name { Sham.single_name }
end

IssueStatus.blueprint do
  name { Sham.single_name }
  is_closed { false }
end

Tracker.blueprint do
  name { Sham.single_name }
  position { Sham.position }
end

def make_tracker_for_project(project, attributes = {})
  Tracker.make(attributes) do |tracker|
    project.trackers << tracker
    project.save!
  end
end

Issue.blueprint do
  project
  subject { Sham.message }
  tracker { Tracker.make }
  description { Shame.message }
  priority { IssuePriority.make }
  status { IssueStatus.make }
  author { User.make }
end

TimeEntry.blueprint do
  issue
  project { issue.project }
  user
  hours { Sham.integer }
  activity { TimeEntryActivity.make }
  spent_on { Date.today }
end

# Plugin specific
StuffToDo.blueprint do
  user
  stuff
end
