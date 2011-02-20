require 'yaml'

class Featurist

  class Config
    attr_reader :ignore_directories, :section_config

    def initialize
      @ignore_directories = []
      @directory_config = {}
    end

    class << self
      def save
        File.open("featurist-config.yml", "w") {|f| f.write(@@config.to_yaml) }
      end

      def config
        @@config
      end

      def load dir
        @@config = begin
          YAML.load(File.open("#{dir}/featurist-config.yml"))
        rescue ArgumentError => e
          puts "Could not parse YAML: #{e.message}"
        end    
      end
    end
  end

end