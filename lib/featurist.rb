require 'featurist/specification'
require 'featurist/text_formatter'
require 'featurist/pdf_formatter'
require 'featurist/config'

include Specification # Bring in build_spec module method TODO: figure out proper organization/naming/means to include stuff

class Featurist
  def initialize options
    @options = options
    Featurist::Config.load @options.features_dir
  end

  def run
    spec = Specification::Document.new

    # Dynamically generate stuff from "/Features"
    puts "\nBuilding requirements specification from features in #{@options.features_dir}"
    build_spec @options.features_dir, spec.root

    # Output our spec
    if @options.format == "txt"
      output_filename = @options.output_dir + '/' + @options.file_prefix + 'spec.txt'
      TextFormatter.new(output_filename, spec).run
      puts "Generating #{output_filename}"

    elsif @options.format == "pdf"
      output_filename = @options.file_prefix + 'spec.pdf'
      PDFFormatter.new(output_filename, spec).run
      puts "Generating requirements specification #{output_filename}"
    end

    if @options.test_script?
      puts "\nGenerating test script #{@options.file_prefix}test-script.#{@options.format}"
      # TODO
    end

    if @options.trace_matrix?
      puts "\nGenerating trace matrix #{@options.file_prefix}trace-matrix.#{@options.format}"
      # TODO
    end

    puts "Finished."
  end
end
