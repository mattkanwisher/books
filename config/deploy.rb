require "mt-capistrano"

set :site,         "41895"
set :application,  "book2"
set :webpath,      "bookreadingroom.com"
set :domain,       "s41895.gridserver.com"
set :user,          "serveradmin@#{domain}"

ssh_options[:forward_agent] = true
set :git_shallow_clone, 1
set deploy_via, :remote_cache
set :repository,  "git@github.com:mattcampbell/books.git"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :use_sudo, false

# which environment to work in
set :rails_env,    "production"

# necessary for functioning on the (gs)
default_run_options[:pty] = true

# these shouldn't be changed
role :web, "#{domain}"
role :app, "#{domain}"
role :db,  "#{domain}", :primary => true
set :deploy_to,    "/home/#{site}/containers/rails/#{application}"

# uncomment if desired
#after "deploy:update_code".to_sym do
#  put File.read("deploy/database.yml.mt"), "#{release_path}/config/database.yml", :mode => 0444
#end

# update .htaccess rules after new version is deployed
after "deploy:symlink".to_sym, "mt:generate_htaccess".to_sym

namespace(:deploy) do  
  
  desc "Redefine migrate to work in development mode"
  task :migrate, :roles => :app do
    run "cd #{release_path} && rake db:auto:migrate"
  end

  desc "Long deploy will throw up the maintenance.html page and run migrations 
        then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      #web.disable 
      symlink
      migrate
    end
  
    restart
    #web.enable
  end
end