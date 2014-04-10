module CC
  RECONFIG_CUSTOMER = true

  def self.ask_reconfig
    reconf = ask("Do you want to reconfigure all existing settings? (y/N)")
    const_set("RECONFIG_CUSTOMER", (reconf.to_s.downcase == 'y'))
  end

  def self.ask(message, old_val=nil, default=nil)
    return old_val if !old_val.blank? and !RECONFIG_CUSTOMER

    if !old_val.nil?
      puts "#{message} [#{old_val}]"
    elsif !default.nil?
      puts "#{message} [#{default}]"
    else
      puts message
    end

    val = STDIN.gets.strip

    return (old_val || default) if val.blank?

    if val == 'false'
      val = false
    elsif val == 'true'
      val = true
    end

    val
  end

  def self.ask_hash(keys, messages, old_val=nil, defaults={})
    return old_val if !old_val.nil? and !RECONFIG_CUSTOMER

    new_hash = defaults.dup
    new_hash.merge!(old_val) if old_val

    keys.each_with_index do |key,i|
      puts new_hash[key] ? "#{messages[i]} [#{new_hash[key]}]" : messages[i]
      val = STDIN.gets.strip
      new_hash[key] = val unless val.blank?
    end
    new_hash
  end

  def self.ask_host_info
    return if ![CustomerConfig.protocol, CustomerConfig.host, CustomerConfig.port].include?(nil) and !RECONFIG_CUSTOMER

    CustomerConfig.protocol = "{{protocol}}"
    CustomerConfig.host = "{{host}}"
    CustomerConfig.port = ""
  end

  def self.ask_smtp_info
    return if !CustomerConfig.smtp.nil? and !RECONFIG_CUSTOMER

    CustomerConfig.smtp = {:address => "{{address}}", :port => "{{port}}", :domain => "{{domain}}"}
  end

end
