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

res = {}

data.each do |m|
	prov = m['nome_provincia']
	cat = m['nome_categoria']
	id = m['id_pubblico']
	res[prov] = {} unless res[prov]
	res[prov][cat] = {} unless res[prov][cat]
	res[prov][cat][id] = m
end
tot = 0 
res.keys.each do |p|
	puts "== Prov #{p} =="
	res[p].keys.each do |c|
		puts "\t#{c} #{res[p][c].count}"
	end
end
File.open(out, 'w') do |file| 		
	file.write(JSON.pretty_generate(res))
end