# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
types = %w{病假 哺乳期晚到1小时 哺乳期早走1小时 产假 倒休 事假}
Holiday.create(types.map{|item|{name: item}})


