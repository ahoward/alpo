require 'alpo'

Testing Alpo do

# data
#
  testing 'basic data can be constructed' do
    data = assert{ Alpo.data.new }
  end
  testing 'basic data can be constructed with a name' do
    data = assert{ Alpo.data.new('name') }
    assert{ data._name == 'name' }
  end
  testing 'basic data can be constructed with a name and id' do
    data = assert{ Alpo.data.new('name', 42) }
    assert{ data._name == 'name' }
    assert{ data._id == 42 }
  end
  testing 'basic data can be constructed with a name-id' do
    data = assert{ Alpo.data.new('name-42') }
    assert{ data._name == 'name' }
    assert{ data._id == 42 }
  end
  testing 'basic data can be constructed with a name-new' do
    data = assert{ Alpo.data.new('name-new') }
    assert{ data._name == 'name' }
    assert{ data._id == 'new' }
  end
  testing 'data can be constructed with values' do
    data = assert{ Alpo.data.new(:key => :value) }
    assert{ data._name == nil }
    assert{ data._id == nil }
    assert{ data =~ {:key => :value} }
  end
  testing 'data can be constructed with name and id and values' do
    data = assert{ Alpo.data.new('name', 42, :key => :value) }
    assert{ data._name == 'name' }
    assert{ data._id == 42 }
    assert{ data =~ {:key => :value} }
  end
  testing 'data can be constructed with name-id and values' do
    data = assert{ Alpo.data.new('name-42', :key => :value) }
    assert{ data._name == 'name' }
    assert{ data._id == 42 }
    assert{ data =~ {:key => :value} }
  end
  testing 'data can be constructed with name-new and values' do
    data = assert{ Alpo.data.new('name-new', :key => :value) }
    assert{ data._name == 'name' }
    assert{ data._id == 'new' }
    assert{ data =~ {:key => :value} }
  end
  testing 'indifferent access' do
    data = assert{ Alpo.data.new(:key => :value) }
    assert{ data =~ {:key => :value} }
    assert{ data[:key] == :value }
    assert{ data['key'] == :value }
  end
  testing 'nested indifferent access' do
    data = assert{ Alpo.data.new(:a => {:b => :value}) }
    assert{ data =~ {:a => {:b => :value}} }
    assert{ data[:a] =~ {:b => :value} }
    assert{ data['a'] =~ {:b => :value} }
    assert{ data[:a][:b] == :value }
    assert{ data[:a]['b'] == :value }
  end
  testing 'deeply nested indifferent access' do
    data = assert{ Alpo.data.new(:x => {:y => {:z => :value}}) }
    assert{ data =~ {:x => {:y => {:z => :value}}} }
    assert{ data[:x] =~ {:y => {:z => :value}} }
    assert{ data['x'] =~ {:y => {:z => :value}} }
    assert{ data[:x][:y] =~ {:z => :value} }
    assert{ data[:x]['y'] =~ {:z => :value} }
    assert{ data[:x][:y][:z] == :value }
    assert{ data[:x][:y]['z'] == :value }
  end
  testing 'setting/getting a deeply nested value' do
    data = assert{ Alpo.data.new }
    assert{ data.set([:a,:b,:c] => 42) }
    assert{ data =~ {:a => {:b => {:c => 42}}} }
    assert{ data.get(:a,:b,:c) == 42 }
  end
  testing 'setting/getting a deeply nested array' do
    data = assert{ Alpo.data.new }
    assert{ data.set([:a,:b,0] => 40) }
    assert{ data.set([:a,:b,1] => 2) }
    assert{ data =~ {:a => {:b => [40,2]}} }
    assert{ data.get(:a,:b) == [40,2] }
  end


# parser
#
  testing 'parsing a simple hash by name' do
    params = {
      'name(a)' => 40,
      'name(b)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => 40, 'b' => 2}
    assert{ parsed =~ expected }
  end
  testing 'parsing a simple hash by name-id' do
    params = {
      'name-42(a)' => 40,
      'name-42(b)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => 40, 'b' => 2}
    assert{ parsed =~ expected }
    assert{ parsed['_id'] == 42 }
    assert{ parsed._id == 42 }
  end
  testing 'parsing a simple hash by name-new' do
    params = {
      'name-new(a)' => 40,
      'name-new(b)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => 40, 'b' => 2}
    assert{ parsed =~ expected }
    assert{ parsed['_id'] == 'new' }
    assert{ parsed._id == 'new' }
  end
  testing 'parsing a nested hash by name' do
    params = {
      'name(a,x)' => 40,
      'name(a,y)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => {'x' => 40, 'y' => 2}} 
    assert{ parsed =~ expected }
  end
  testing 'parsing a deeply nested hash by name' do
    params = {
      'name(a,b,x)' => 40,
      'name(a,b,y)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => {'b' => {'x' => 40, 'y' => 2}}} 
    assert{ parsed =~ expected }
  end
  testing 'parsing a deeply nested hash by name-id' do
    params = {
      'name-42(a,b,x)' => 40,
      'name-42(a,b,y)' => 2
    }
    parsed = Alpo.parse(:name, params)
    expected = {'a' => {'b' => {'x' => 40, 'y' => 2}}} 
    assert{ parsed =~ expected }
    assert{ parsed['_id'] == 42 }
    assert{ parsed._id == 42 }
  end

end









BEGIN {
  require 'test/unit'
  STDOUT.sync = true
  $:.unshift 'lib'
  $:.unshift '../lib'
  $:.unshift '.'

  def Testing(*args, &block)
    Class.new(Test::Unit::TestCase) do
      def self.slug_for(*args)
        string = args.flatten.compact.join('-')
        words = string.to_s.scan(%r/\w+/)
        words.map!{|word| word.gsub %r/[^0-9a-zA-Z_-]/, ''}
        words.delete_if{|word| word.nil? or word.strip.empty?}
        words.join('-').downcase
      end

      @@testing_subclass_count = 0 unless defined?(@@testing_subclass_count) 
      @@testing_subclass_count += 1
      slug = slug_for(*args).gsub(%r/-/,'_')
      name = ['TESTING', '%03d' % @@testing_subclass_count, slug].delete_if{|part| part.empty?}.join('_')
      name = name.upcase!
      const_set(:Name, name)
      def self.name() const_get(:Name) end

      def self.testno()
        '%05d' % (@testno ||= 0)
      ensure
        @testno += 1
      end

      def self.testing(*args, &block)
        method = ["test", testno, slug_for(*args)].delete_if{|part| part.empty?}.join('_')
        define_method("test_#{ testno }_#{ slug_for(*args) }", &block)
      end

      alias_method '__assert__', 'assert'

      def assert(*args, &block)
        if block
          label = "assert(#{ args.join(' ') })"
          result = nil
          assert_nothing_raised{ result = block.call }
          __assert__(result, label)
          result
        else
          result = args.shift
          label = "assert(#{ args.join(' ') })"
          __assert__(result, label)
          result
        end
      end

      def subclass_of exception
        class << exception
          def ==(other) super or self > other end
        end
        exception
      end

      module_eval &block
      self
    end
  end
}
