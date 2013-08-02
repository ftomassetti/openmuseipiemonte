require 'json'

class CountingMap

	def initialize
		@map = {}
	end

	def count
		@map.count
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

# leggo l'aggregato
agg_path  = '../data/aggregated_by_categories.json'

aggregated = JSON.parse(File.read(agg_path))

maps = {}

aggregated.each do |prov,data_prov|
	maps[prov] = CountingMap.new
	data_prov.each do |cat,map|
		ids = map.keys
		ids.each do |id|
			file = "../data/alchemy/entities_#{id}.json"
			if File.exists? file
				puts "#{id} loaded"
				entities = JSON.parse(File.read(file))
				entities.each do |e|
					puts "\tentity #{e.keys} #{e.class} #{e['uri']}"
					uri = e['uri']
					if uri
						puts "\t#{uri}"
						maps[prov].inc uri
					end
				end
			else
				#puts "...skip #{id}"
			end
		end
	end
end

output = {}

maps.each do |prov,map|
	puts "=== #{prov} (#{map.count}) ==="
	entries = []
	map.each do |uri,count|
		entries << {'uri'=>uri, 'count'=>count}
	end
	puts "#{entries.count}"
	entries = entries.sort_by do |e|
		-1*e['count']
	end
	entries = entries[0..5]
	entries.each do |e|
		puts "\t#{e}"
	end

	output[prov] = entries
end

#File.open('../data/entities_per_province.json', 'w') do |file| 		
#	file.write(JSON.pretty_generate(output))
#end

puts output

# per ogni provincia calcolo le entity piu' comuni