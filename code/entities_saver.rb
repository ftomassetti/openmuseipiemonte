require 'curl'
require 'json'
require 'net/http'
require 'CGI'

def path_with_params(page, params)
  return page if params.empty?
  page + "?" + params.map {|k,v| CGI.escape(k.to_s)+'='+CGI.escape(v.to_s) }.join("&")
end

def entities_for_text(text)
	res1 = Curl::Easy.perform("http://nerd.eurecom.fr/api/document") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "text=#{text}&key=1h70m496377mon3jgqhhi8f56bkqr342"
		#curl.verbose = true
	end
	iddoc = JSON.parse(res1.body_str)['idDocument']

	res2 = Curl::Easy.perform("http://nerd.eurecom.fr/api/annotation") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "idDocument=#{iddoc}&extractor=alchemyapi&key=1h70m496377mon3jgqhhi8f56bkqr342"
	   	#curl.verbose = true
	end
	#puts "--- START ---"
	#puts res2.body_str
	#puts "--- END ---"
	idanno = JSON.parse(res2.body_str)['idAnnotation']

	res3 = Net::HTTP.start('nerd.eurecom.fr', 80) do |http|
	  http.get(path_with_params('/api/entity',{'idAnnotation'=>idanno, 'key'=>'1h70m496377mon3jgqhhi8f56bkqr342'}))
	end
	entities = JSON.parse(res3.body)
	entities
end

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

$src = '../data/aggregated_by_categories.json'

def save_entities_for_everybody
	data = JSON.parse(File.read($src))
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

