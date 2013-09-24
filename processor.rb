require 'mongo'
require 'yaml'
include Mongo

class Processor

  def initialize
    @config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))

    client = MongoClient.new(@config["mongo"]["host"], @config["mongo"]["port"])
    db = client.db(@config["mongo"]["database"])
    @terms = db[@config["mongo"]["collection"]]
  end

  def to_json
    @json = File.new("terms.json", "w")
    @json.write("{\"name\": \"terms\",\n\"children\":[\n")

    term_name = @config["term_fields"]["name"]
    term_freq = @config["term_fields"]["frequency"]
    term_sort = @config["term_fields"]["sort"].to_sym

    content = ""
    @terms.find.sort(term_sort => :asc).limit(1000).each do |term|
      content = content + "{\"name\": \"#{term["#{term_name}"]}\", 
        \"children\": [{ \"name\": \"#{term["#{term_name}"]}\", 
        \"size\": #{term["#{term_freq}"]} }]},\n"
    end

    content.chomp!(",\n")
    content = content + "\n]\n}"

    @json.write(content)
    @json.close
  end
end

processor = Processor.new
processor.to_json
