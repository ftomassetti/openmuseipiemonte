require 'json'

class CountingMap < Hash

	def initialize
		super do |h,k|
			h[k] = 0
		end
	end

	def inc(key)
		self[key] += 1
	end

	def value(key)
		self[key]
	end

end

def combine_self(arr,&op)
	for i in 0..(arr.count-2)
		for j in (i+1)..(arr.count-1)
			op.call(arr[i],arr[j])
		end
	end
end

for_entities = {}
Dir['../data/entities_*.json'].each do |ef|
	id = "#{File.basename(ef,'.json')[9..-1]}"
	es = JSON.parse(File.read(ef))
	es.each do |e|
		uri = e['uri']
		if uri
			if not for_entities[uri]
				for_entities[uri] = []
			end
			for_entities[uri] << id
		end
	end
end

connections = {}
for_entities.each do |k,v|
	ids = v.sort
	combine_self(ids) do |id1,id2|
		#puts "Connection #{id1} #{id2}"
		connections[id1] = {} unless connections[id1]
		connections[id1][id2] = 0 unless connections[id1][id2]
		connections[id1][id2] += 1	
	end
end

connections.each do |id1,sub|
	sub.each do |id2,v|
		if v>3
			puts "#{v}] Connection #{id1} #{id2}"
		end
	end
end
