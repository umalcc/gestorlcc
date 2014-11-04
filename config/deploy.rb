require 'mongrel_cluster/recipes'

    # Your Applications “Name”
    set :application, "gestorlcc"

    # The URL to your applications repository
    set :repository,  "."
    set :scm, :none
    set :deploy_via, :copy

    # Require subversion to do an export instead of a checkout.
    set :checkout, 'export'

    # The user you are using to deploy with (This user should have SSH access to your server)
    set :user, "root"

    # We want to deploy everything under your user, and we don’t want to use sudo
    set :use_sudo, false

    # Where to deploy your application to.
    set :deploy_to, "/var/www/html/gestorlcc"

    # ——————————– Server Definitions ——————————–
    # Define the hostname of your server. If you have multiple servers for multiple purposes, we can define those below as well.
    set :server_name, "gestorlab.lcc.uma.es"

    # We’re assuming you’re using a single server for your site, but if you have a seperate asset server or database server, you can specify that here.
    role :app, "150.214.108.29"
    role :web, "150.214.108.29"
    role :db, "150.214.108.29", :primary => true

    # ——————————– Final Config ——————————–
    # This configuration option is helpful when using svn+ssh but doesn’t hurt anything to leave it enabled always.
    default_run_options[:pty] = true

    namespace :deploy do
    task :restart do
    run "touch #{deploy_to}current/tmp/restart.txt"
    end

    task :start do
    run "cd #{deploy_to} && ln -s current/public public_html"
    run "touch #{deploy_to}current/tmp/restart.txt"
    end

    task :symlink do
    run "cd #{deploy_to} && rm current ; ln -s releases/#{release_name} current"
    run <<-CMD
    rm -rf #{latest_release}/log /home/#{user}/#{latest_release}/public/system #{latest_release}/tmp/pids &&
    ln -s /home/#{user}#{shared_path}/log /home/#{user}#{latest_release}/log &&
    ln -s /home/#{user}#{shared_path}/system /home/#{user}#{latest_release}/public/system &&
    ln -s /home/#{user}#{shared_path}/pids /home/#{user}#{latest_release}/tmp/pids
    CMD
    end

    task :stop do
    run "rm #{deploy_to}public_html"
    end

    namespace :web do
    task :disable do
    run "cd #{deploy_to} && rm public_html && ln -s static_site public_html"
    end

    task :enable do
    run "cd #{deploy_to} && rm public_html && ln -s current/public public_html"
    end
    end

    end

    task :after_setup do
    run "rm -rf #{deploy_to}public_html"
    run "mkdir #{deploy_to}static_site"
    end
