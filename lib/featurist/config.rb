require 'yaml'

class Featurist

  class Config
    DEFAULT_CONFIG_FILENAME = "featurist-config.yml"
    attr_reader :ignore_directories,
                :directory_config,
                :cover_page,
                :cover_page_project_name,
                :cover_page_narrative

    def initialize
      @ignore_directories = []
      @directory_config = {}
    end

    class << self
      def config
        @@config
      end

      def load dir
        @@config = begin
          YAML.load(File.open("#{dir}/#{DEFAULT_CONFIG_FILENAME}"))
        rescue ArgumentError => e
          puts "Could not parse YAML: #{e.message}"
        rescue Exception => e
          puts "Could not load Featurist config #{dir}/#{DEFAULT_CONFIG_FILENAME}. Exception #{e.message}"
        end    
      end
    end
  end

end