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

  def initialize
    opts = Trollop::options do
      version       "Feature Publisher v0.1.0, February 2011, Jon Archer"
      banner <<-EOS
FEATURIST (c) 2011, Jon Archer
https://github.com/jonarcher/featurist
-------------------------------------------------------
Turn a directory full of Gherkin features into a simple
requirements specification and (optionally) generate
"test script" and "trace matrix" documents.

See https://github.com/jonarcher/featurist for
important additional instructions.
\t
      EOS
      opt :dir,           "Directory containing .feature files to process", :type => :string
      opt :file_prefix,   "Output filename prefix", :default => "featurist-", :short => "p"
      opt :format,        "Output format: txt | pdf", :default => "txt"
      opt :test_script,   "Also output test script?", :default => false, :short => "s"
      opt :trace_matrix,  "Also output a trace matrix?", :default => false, :short => "m"
    end

    # parameter verification
    Trollop::die :dir, "Cannot find #{opts[:dir]}" unless File.directory?(opts[:dir])
    Trollop::die :format, "Must be either 'txt' or 'pdf'" unless opts[:format].match /^(txt|pdf)$/

    @config               = Featurist::Options.new
    @config.dir           = opts[:dir].nil? ? '.' : opts[:dir].gsub('\\', '/') #turn backslashes in Windows paths to forward slashes so paths work in Dir[...]
    @config.file_prefix   = opts[:file_prefix]
    @config.format        = opts[:format]
    @config.test_script   = opts[:test_script]
    @config.trace_matrix  = opts[:trace_matrix]
  end

  def execute!
    f = Featurist.new @config
    f.run
  end
end

class Featurist
  class Options
    attr_accessor :dir, :file_prefix, :format, :test_script, :trace_matrix

    def test_script?
      @test_script
    end

    def trace_matrix?
      @trace_matrix
    end
  end
end
