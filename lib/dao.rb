# built-ins
#
  require 'enumerator'
  require 'fileutils'
  require 'pathname'
  require 'yaml'
  require 'yaml/store'

# gems
#
  begin
    require 'rubygems'
    gem 'map', '~> 2.0'
    gem 'tagz', '~> 8.0'
    gem 'yajl-ruby'
  rescue LoadError
    nil
  end

  require 'map'
  require 'tagz'
  require 'yajl'

# dao libs
#
  module Dao
    Version = '2.0.0' unless defined?(Version)

    def version
      Dao::Version
    end

    def libdir(*args, &block)
      @libdir ||= Pathname.new(__FILE__).realpath.to_s.sub(/\.rb$/,'')
      args.empty? ? @libdir : File.join(@libdir, *args)
    ensure
      if block
        begin
          $LOAD_PATH.unshift(@libdir)
          block.call()
        ensure
          $LOAD_PATH.shift()
        end
      end
    end

    extend self
  end

  Dao.libdir do
    #load 'json.rb'
    load 'blankslate.rb'
    load 'exceptions.rb'
    load 'support.rb'
    load 'map.rb'
    load 'slug.rb'

    load 'path.rb'
    load 'params.rb'
    load 'result.rb'
    load 'status.rb'
    load 'data.rb'
    load 'form.rb'
    load 'errors.rb'
    load 'validations.rb'

    load 'api.rb'
    load 'rails.rb'
    load 'active_record.rb'
    load 'mongo_mapper.rb'
    load 'stdext.rb'
    load 'db.rb'
  end

  unless defined?(A)
    A = Dao

    def Dao(*args, &block)
      Dao.data(*args, &block)
    end

    def A(*args, &block)
      Dao.data(*args, &block)
    end
  end
