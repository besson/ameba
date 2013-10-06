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
    @json.write("{\"nodes\": [\n")

    label = @config["term_fields"]["label"]
    size = @config["term_fields"]["size"]
    sort = @config["term_fields"]["sort"].to_sym
    cluster = @config["term_fields"]["cluster"].to_sym

    content = ""
    @terms.find.sort(sort => :desc).limit(150).each do |term|
      content = content + "{\"label\": \"#{term["#{label}"]}\", \"size\": #{term["#{size}"]}, \"cluster\": \"#{term["#{cluster}"][0]}\"},\n"
    end

    content.chomp!(",\n")
    content = content + "\n]}"

    @json.write(content)
    @json.close
  end
end

processor = Processor.new
processor.to_json
