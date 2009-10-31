# built-in libs
#
  require 'enumerator'

# rubygem libs
#
  begin
    require 'rubygems'
  rescue LoadError
    nil
  end

  require 'tagz'
  #require 'orderedhash'
  require 'json'

# alpo libs
#
  module Alpo
    Version = '0.0.1' unless defined?(Version)

    def version
      Alpo::Version
    end

    def libdir(*args, &block)
      @libdir ||= File.expand_path(__FILE__).sub(/\.rb$/,'')
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
    load 'exceptions.rb'
    load 'hash_with_indifferent_access.rb'
    load 'data.rb'
    load 'errors.rb'
    load 'slug.rb'
    load 'support.rb'
    load 'parameter_parser.rb'
  end
