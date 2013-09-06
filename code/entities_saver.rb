### Download and save the entities information for each element

require 'curl'
require 'json'
require 'net/http'
require 'CGI'
require 'entities_retrieving'

$SRC = '../data/aggregated_by_categories.json'

def select_entities(entities)
	entities = entities.sort_by do |e|
		(1-e['confidence'])*(1-e['relevance'])
	end
	entities = entities[0..10]
	entities
end

def id_to_output_path(id)
	"../data/alchemy/entities_#{id}.json"
end

def save_entities_for(id,text)
	output_path = id_to_output_path(id)

	entities = entities_for_text(text)

	File.open(output_path, 'w') do |file| 		
		file.write(JSON.pretty_generate(entities))
	end
end

def save_entities_for_everybody
	data = JSON.parse(File.read($SRC))
	data.each do |prov,dfp|
		puts "...province #{prov}"
		dfp.each do |cat,dfc|
			puts "\t...cat #{cat}"
			dfc.each do |id,entry|
				puts "\t\t...#{entry['nome']}"
				desc = entry['descrizione']				
				unless File.exists? id_to_output_path(id)
					begin
						save_entities_for(id,desc)
					rescue Object => e
						puts "...failed, let's skip it for now: #{e}"
					end
				end
			end
		end
	end
end

save_entities_for_everybody

