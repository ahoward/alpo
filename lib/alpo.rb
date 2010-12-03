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
  rescue LoadError
    nil
  end

  require 'tagz'
  require 'map'

  begin
    gem 'json'
    load 'json.rb'
  rescue Object
    nil
  end

# alpo libs
#
  module Alpo
    Version = '2.0.0' unless defined?(Version)

    def version
      Alpo::Version
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

  Alpo.libdir do
    #load 'json.rb'
    load 'blankslate.rb'
    load 'exceptions.rb'
    load 'support.rb'
    load 'status.rb'
    load 'map.rb'
    load 'data.rb'
    load 'form.rb'
    load 'errors.rb'
    load 'validations.rb'
    load 'slug.rb'
    load 'params.rb'
    load 'api.rb'
    load 'rails.rb'
    load 'active_record.rb'
    load 'mongo_mapper.rb'
    load 'stdext.rb'
    load 'db.rb'
  end

  unless defined?(A)
    A = Alpo

    def Alpo(*args, &block)
      Alpo.data(*args, &block)
    end

    def A(*args, &block)
      Alpo.data(*args, &block)
    end
  end
