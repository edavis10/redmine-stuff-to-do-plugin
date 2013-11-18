namespace :redmine do
  namespace :stuff_to_do do
    desc 'Sends periodic StuffToDo mailer'
    task :send_periodic_mailer => :environment do
      sent = {}
      User.find_each do |user|
        doing_now = StuffToDo.doing_now(user)
        recommended = StuffToDo.recommended(user)
        if doing_now.collect(&:stuff).compact.any? || recommended.collect(&:stuff).compact.any?
          sent[user] = {:doing_now => doing_now, :recommended => recommended}
          StuffToDoMailer.periodic(user, doing_now, recommended).deliver
        end
      end
      StuffToDoMailer.periodic_summary(sent).deliver
    end
  end
end
