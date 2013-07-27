require 'rubygems'
require 'json'

path = '../data/architect.json'
out  = '../data/architect_by_categories.json'

data = JSON.parse(File.read(path))['all_architect']['architect']

res = {}

data.each do |m|
	prov = m['nome_provincia']
	cat = m['nome_categoria']
	id = "arch_#{m['id']}"
	res[prov] = {} unless res[prov]
	res[prov][cat] = {} unless res[prov][cat]
	res[prov][cat][id] = m
	res[prov][cat][id].each do |k,v|
		res[prov][cat][id][k] = v.encode('utf-8', 'iso-8859-1') if v.is_a? String
	end
end
res.keys.each do |p|
	puts "== Prov #{p} =="
	res[p].keys.each do |c|
		puts "\t#{c} #{res[p][c].count}"
	end
end
File.open(out, 'w') do |file| 		
	file.write(JSON.pretty_generate(res))
end