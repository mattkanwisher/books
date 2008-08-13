task :get_mail => :environment do |args|
  delete_if = lambda {|email| MyMailer.deleteif(email) }
  MailFetcher.fetch(:delete_if => delete_if, :mailer_methods => [:receive])
end

task :send_mail => :environment do |args|
  MyMailer.sendallnotifications
end