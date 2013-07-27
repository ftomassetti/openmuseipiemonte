require 'rubygems'
require 'json'

class CountingMap

	def initialize
		@map = {}
	end

	def inc(key)
		@map[key] = 0 unless @map[key]
		@map[key] = @map[key]+1
	end

	def value(key)
		@map[key] = 0 unless @map[key]
		@map[key]
	end

	def each(&block)
		@map.each(&block)
	end

end

path = '../data/rows.json'
out  = '../data/museums_by_categories.json'

data = JSON.parse(File.read(path))['File']['Row']

categories = {}

data.each do |m|
	categories[m['nome_categoria']] = {} unless categories[m['nome_categoria']]
	categories[m['nome_categoria']][m['id_pubblico']] = m
end
tot = 0 
categories.keys.each do |c|
	puts "Cat #{c} #{categories[c].count}"
	tot += categories[c].count
end
puts "Tot=#{tot}"
File.open(out, 'w') do |file| 		
	file.write(JSON.pretty_generate(categories))
end