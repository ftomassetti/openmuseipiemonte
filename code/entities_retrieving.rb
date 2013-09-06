require 'curl'
require 'json'
require 'net/http'
require 'cgi'

def path_with_params(page, params)
  return page if params.empty?
  page + "?" + params.map {|k,v| CGI.escape(k.to_s)+'='+CGI.escape(v.to_s) }.join("&")
end

def entities_for_text(text,verbose = false)
	res1 = Curl::Easy.perform("http://nerd.eurecom.fr/api/document") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "text=\"#{text}\"&key=1h70m496377mon3jgqhhi8f56bkqr342"
		curl.verbose = true if verbose
	end
	iddoc = JSON.parse(res1.body_str)['idDocument']

	res2 = Curl::Easy.perform("http://nerd.eurecom.fr/api/annotation") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "idDocument=#{iddoc}&extractor=alchemyapi&key=1h70m496377mon3jgqhhi8f56bkqr342"
	   	curl.verbose = true if verbose
	end
	idanno = JSON.parse(res2.body_str)['idAnnotation']

	res3 = Net::HTTP.start('nerd.eurecom.fr', 80) do |http|
	  http.get(path_with_params('/api/entity',{'idAnnotation'=>idanno, 'key'=>'1h70m496377mon3jgqhhi8f56bkqr342'}))
	end
	entities = JSON.parse(res3.body)
	entities
end