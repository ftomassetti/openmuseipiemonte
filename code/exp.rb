$: << '../lib/dbpedia-spotlight-rb/lib/'

require 'dbpedia/spotlight'

require 'curl'
require 'json'
require 'net/http'
require 'CGI'

def path_with_params(page, params)
  return page if params.empty?
  page + "?" + params.map {|k,v| CGI.escape(k.to_s)+'='+CGI.escape(v.to_s) }.join("&")
end

def spotlight_entities(text)
	spotlight = DBpedia::Spotlight("http://spotlight.sztaki.hu:2230/rest")
	entities = spotlight.annotate(text)
	entities
end

def entities_for_text(method,text)
	res1 = Curl::Easy.perform("http://nerd.eurecom.fr/api/document") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "text=#{text}&key=1h70m496377mon3jgqhhi8f56bkqr342"
		#curl.verbose = true
	end
	iddoc = JSON.parse(res1.body_str)['idDocument']

	res2 = Curl::Easy.perform("http://nerd.eurecom.fr/api/annotation") do |curl| 
	    curl.headers["Accept"] = "application/json"
	   	curl.post_body = "idDocument=#{iddoc}&extractor=#{method}&key=1h70m496377mon3jgqhhi8f56bkqr342"
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

text = <<-eos
Il castello, edificato in epoca medievale (per la potente famiglia dei San Martino d'Aglié) con le due possenti ali laterali e la scalinata centrale, acquisisce la struttura attuale soltanto nella seconda metà del Settecento. Negli anni 1646-1657 Filippo di San Martino, consigliere della reggente Maria Cristina di Francia, realizza la prima fondamentale trasformazione del maniero medioevale in residenza, ma la svolta si attua nel 1764, quando il castello viene acquistato, insieme ai feudi di Bairo e Ozegna, da Carlo Emanuele III per farne la residenza del figlio secondogenito Benedetto Maria Maurizio, dando l'avvio a un nuovo grandioso progetto di riqualificazione e di ampliamento del complesso ad opera dell'architetto Ignazio Birago di Borgaro. Durante l'occupazione napoleonica (1802-1814) il Castello viene in parte trasformato in ricovero di mendicità e gravemente spogliato dei suoi arredi, in seguito attraverso Marianna, vedova di Benedetto Maria Maurizio, il castello passa in eredità al fratello Carlo Felice, che ne prese possesso nel 1825: da quell'anno e sino alla morte della sua vedova Maria Cristina (1849), la residenza è oggetto di un totale riallestimento secondo il gusto dell'epoca, affidato all'architetto Borda di Saluzzo. Con la morte di Maria Cristina, avvenuta nel 1849, il castello  passa in eredità a Carlo Alberto e al figlio cadetto Ferdinando, primo Duca di Genova. Nel 1939 i duchi di Genova cedono il castello al Demanio. Grazie a una lunga serie di interventi di restauro e di riallestimento, il Castello di Agliè è diventato un grandioso spazio museale (si possono visitare diversi ambienti: Salone delle Guardie del Corpo, Sala dei Valletti, Biblioteca, Sala degli Antenati, Sala Cinese, Galleria d'Arte, Sala della Deposizione, Sala del Biliardo, Sala d'Angolo, Salone da Ballo Salone da Ballo, Sala Tuscolana, Sala Gialla, Galleria Verde, Sala della Musica) che ospita manifestazioni nel corso dell'anno mostre e manifestazioni internazionali. Nel 1986, dopo un complesso intervento di restauro botanico e di bonifiche idrauliche, anche il parco e il giardino sono stati aperti alle visite.
eos

#entities_for_text('alchemyapi',text).each do |e|
#	puts "#{e}" 
#end

puts text
puts spotlight_entities(text)