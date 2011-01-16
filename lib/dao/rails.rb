if defined?(Rails)
  Dao::Data::Apply.blacklist << :controller << :action

  # Dao.load('rails/controller')
end
