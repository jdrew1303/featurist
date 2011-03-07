require 'featurist'
require 'trollop'

class CLI
  class << self
    def execute(args)
      if args.size == 0
        args << "--help"
      end
      new.execute!
    end
  end

  def execute!
    options = Featurist::Options.new
    f = Featurist.new options
    f.run
  end
end

class Featurist
  class Options

    attr_reader :features_dir, :output_dir, :file_prefix, :output_format

    def initialize
      opts = Trollop::options do
        version       "Feature Publisher v0.1.0, February 2011, Jon Archer"
        banner <<-EOS
  FEATURIST (c) 2011, Jon Archer
  https://github.com/jonarcher/featurist
  -------------------------------------------------------
  Turn a directory full of Gherkin features into documents
  including requirements specification, test script and
  trace matrix.

  See https://github.com/jonarcher/featurist for
  background information and important additional
  instructions.
  \t
EOS
        opt :features_dir,  "Directory containing .feature files to process", :type => :string,         :short => "d"
        opt :output_dir,    "Directory to write output to",                   :default => "./",         :short => "o"
        opt :file_prefix,   "Output filename prefix",                         :default => "featurist-", :short => "p"
        opt :output_format, "Output format: txt | pdf",                       :default => "pdf",        :short => "f"
        opt :requirements,  "Generate requirements specification",            :default => false,        :short => "r"
        opt :test_script,   "Generate test script",                           :default => false,        :short => "t"
        opt :steps_dir,     "Directory containing step definitions",                                    :short => "s"
        opt :trace_matrix,  "Generate trace matrix",                          :default => false,        :short => "m"
      end

      # parameter verification
      Trollop::die :features_dir, "Cannot find #{opts[:features_dir]}" unless File.directory?(opts[:features_dir])
      Trollop::die :output_format, "Must be either 'txt' or 'pdf'" unless opts[:output_format].match /^(txt|pdf)$/
      Trollop::die "Select at least one document (requirements specification, test script or trace matrix) to generate" unless opts[:requirements] || opts[:test_script] || opts[:trace_matrix]

      @features_dir   = opts[:features_dir].nil? ? '.' : opts[:features_dir].gsub('\\', '/') #turn backslashes in Windows paths to forward slashes so paths work in Dir[...]
      @output_dir     = opts[:output_dir]
      @file_prefix    = opts[:file_prefix]
      @output_format  = opts[:output_format]
      @requirements   = opts[:requirements]
      @test_script    = opts[:test_script]
      @trace_matrix   = opts[:trace_matrix]
    end

    def requirements?
      @requirements
    end

    def test_script?
      @test_script
    end

    def trace_matrix?
      @trace_matrix
    end

    def output_filename
      filename = @output_dir
      filename += '/' unless @output_dir.end_with? '/'
      filename += @file_prefix
      filename += 'requirements.' if @requirements
      filename += 'test-script.'  if @test_script
      filename += 'trace-matrix.' if @trace_matrix
      filename +=  @output_format
      filename
    end

  end
end
