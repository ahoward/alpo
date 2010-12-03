if defined?(Rails)
  Alpo::Data::Apply.blacklist << :controller << :action

  # Alpo.load('rails/controller')
end
