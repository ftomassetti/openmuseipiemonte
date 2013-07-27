# Prende musei e beni architettonici e crea un unico dataset

require 'rubygems'
require 'json'

path_m = '../data/rows.json'
path_a = '../data/architect.json'
out  = '../data/aggregated_by_categories.json'

museums = JSON.parse(File.read(path_m))['File']['Row']
archs = JSON.parse(File.read(path_a))['all_architect']['architect']

res = {}

museums.each do |m|
	prov = m['nome_provincia']
	cat = "Musei #{m['nome_categoria']}"
	id = m['id_pubblico']
	res[prov] = {} unless res[prov]
	res[prov][cat] = {} unless res[prov][cat]
	res[prov][cat][id] = m
end
archs.each do |m|
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