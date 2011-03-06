require 'featurist/rs/specification'
require 'featurist/rs/text_formatter'
require 'featurist/rs/pdf_formatter'
require 'featurist/ts/test_script'
require 'featurist/config'

include Specification # Bring in build_spec module method TODO: figure out proper organization/naming/means to include stuff

class Featurist
  def initialize options
    @options = options
    Featurist::Config.load @options.features_dir
  end

  def run
    if @options.requirements?
      puts "\nGenerating requirements specification from features in #{@options.features_dir}"
      spec = Specification::Document.new
      build_spec @options.features_dir, spec.root
      TextFormatter.new(@options.output_filename, spec).run if @options.output_format == 'txt'
      Specification::PDFFormatter.new(@options.output_filename, spec).run if @options.output_format == 'pdf'
    end

    if @options.test_script?
      puts "\nGenerating test script #{@options.file_prefix}test-script.#{@options.output_format}"
      test_script = TestScript::Document.new
      test_script.build @options.features_dir, test_script.root
      TestScript::PDFFormatter.new(@options.output_filename, test_script).run
    end

    if @options.trace_matrix?
      puts "\nGenerating trace matrix #{@options.file_prefix}trace-matrix.#{@options.output_format}"
      # TODO
    end

    puts "Finished."
  end
end
