namespace :tarantula do

  def retrieve_db_info
    result = File.read "#{Rails.root}/config/database.yml"
    result.strip!
    config_file = YAML::load(ERB.new(result).result)
    return [
      config_file[Rails.env]['database'],
      config_file[Rails.env]['username'],
      config_file[Rails.env]['password'],
      config_file[Rails.env]['host']
    ]
  end

def check_if_database_exists 
    database, user, password, host = retrieve_db_info
    
    cmd = "mysql -u #{user} -h #{host} "
    puts cmd + "... [password filtered]"
    cmd += " -p'#{password}'" unless password.nil?
    cmd += " #{database}"
    cmd += " -e 'show tables like \"users\"'"
    output = system cmd
    output = output.to_s
    return output
end

  desc "Initialize and install new Tarantula instance"
    if check_if_database_exists === "false"
      task :install => ['db:setup', 'delayed_job:install', 'assets:precompile', :environment] do
        Rake::Task['db:config:app'].invoke
        # Prompt about initial data and generate if needed
        Rake::Task['tarantula:init_db'].execute
        # Create db views
        Rake::Task['db:create_views'].execute
        puts "Initialization tasks done. Please restart your web server services. Eg. apache, memcached etc"
      end
    else 
  task :update => :environment do
    system('git fetch')

    all_tags = IO.popen('git tag').read.split

    valid_tags = []
    all_tags.each do |tag|
      if tag  =~ /(\d{4})\.(\d{2})\.(\d{1,2})/
        year = $1
        week = $2.length == 1 ? "0"+$2 : $2
        rel = $3.length == 1 ? "0"+$3 : $3
        valid_tags << ["#{year}#{week}#{rel}".to_i, tag]
      end
    end
    valid_tags.sort!{|a,b| a[0] <=> b[0]}
    last_tag = valid_tags.last[1]

    system("git checkout #{last_tag}")
    system('bundle install')
    Rake::Task['db:migrate'].execute
    Rake::Task['assets:clean'].execute
    Rake::Task['assets:precompile'].execute
    FileUtils.touch(File.join(Rails.root, 'tmp','restart.txt'))
    system('/etc/init.d/delayed_job restart')
  end

    end
end
