data = Alpo.data.new(:foobar, 1)
data.set([:a,:b,:c] => 42)
data.set([:array, 0] => 40)
data.set([:array, 1] => 2)

puts data.form.input(:a,:b,:c)
puts data.form.button(:a,:b,:c)
puts data.form.textarea(:a,:b,:c)

puts data.form.select
