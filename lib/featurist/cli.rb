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

    attr_reader :features_dir, :output_dir, :file_prefix, :format

    def initialize
      opts = Trollop::options do
        version       "Feature Publisher v0.1.0, February 2011, Jon Archer"
        banner <<-EOS
  FEATURIST (c) 2011, Jon Archer
  https://github.com/jonarcher/featurist
  -------------------------------------------------------
  Turn a directory full of Gherkin features into a simple
  requirements specification and (optionally) generate
  test script and trace matrix documents.

  See https://github.com/jonarcher/featurist for
  background information and important additional
  instructions.
  \t
EOS
        opt :features_dir,  "Directory containing .feature files to process", :default => ".",          :short => "d"
        opt :output_dir,    "Directory to write output to",                   :default => ".",          :short => "o"
        opt :file_prefix,   "Output filename prefix",                         :default => "featurist-", :short => "p"
        opt :format,        "Output format: txt | pdf",                       :default => "txt",        :short => "f"
        opt :test_script,   "Also output test script?",                       :default => false,        :short => "s"
        opt :trace_matrix,  "Also output a trace matrix?",                    :default => false,        :short => "m"
      end

      # parameter verification
      Trollop::die :features_dir, "Cannot find #{opts[:features_dir]}" unless File.directory?(opts[:features_dir])
      Trollop::die :format, "Must be either 'txt' or 'pdf'" unless opts[:format].match /^(txt|pdf)$/

      @features_dir  = opts[:features_dir].nil? ? '.' : opts[:features_dir].gsub('\\', '/') #turn backslashes in Windows paths to forward slashes so paths work in Dir[...]
      @output_dir    = opts[:output_dir]
      @file_prefix   = opts[:file_prefix]
      @format        = opts[:format]
      @test_script   = opts[:test_script]
      @trace_matrix  = opts[:trace_matrix]
    end

    def test_script?
      @test_script
    end

    def trace_matrix?
      @trace_matrix
    end

    def spec_filename
      @output_dir + '/' + @file_prefix + 'spec.' + @format
    end

  end
end
