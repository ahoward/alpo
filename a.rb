
errors = Alpo::Errors.new
errors.add 'foobar'
errors.add 'foobar', 'barfoo', 'message'
errors.add :key => :val 
errors.add [:a, :b] => 'msg' 
p errors
# p errors.invalid?(:key)
# p errors.invalid?(:foobar, :barfoo)
# p errors.invalid?(:k)

errors.depth_first_each do |keys, value|
  p keys => value
end

p errors.size

p errors.full_messages

__END__
data = Alpo.data.new(:foobar, 1)
data.set([:a,:b,:c] => 42)
data.set([:array, 0] => 40)
data.set([:array, 1] => 2)

puts data.form.input(:a,:b,:c)
puts data.form.button(:a,:b,:c)
puts data.form.textarea(:a,:b,:c)

puts data.form.select
