require 'featurist/specification'
require 'featurist/text_formatter'
require 'featurist/pdf_formatter'
require 'featurist/config'

include Specification # Bring in build_spec module method TODO: figure out proper organization/naming/means to include stuff

class Featurist
  def initialize options
    @options = options
    Featurist::Config.load @options.dir
  end

  def run
    spec = Specification::Document.new

    # Dynamically generate stuff from "/Features"
    puts "\nBuilding requirements specification from features in #{@options.dir}"
    build_spec @options.dir, spec.root

    # Output our spec
    puts "Generating #{@options.output}"

    if @options.format == "txt"
      TextFormatter.new(@options.output, spec).run
    elsif @options.format == "pdf"
      PDFFormatter.new(@options.output, spec).run
    end

    puts "Finished."
  end
end
