require 'featurist'
require 'trollop'

class CLI
  class << self
    def execute(args)
      if args.size == 0
        args << "--help"
      end
      new(args).execute!
    end
  end

  def initialize args
    @options = Options.new
  end

  def execute!
    f = Featurist.new @options
    f.run
  end
end

class Options
  attr_reader :dir, :out, :verbose
  def initialize
    opts = Trollop::options do
      version       "Feature Publisher v0.1.0, February 2011, Jon Archer"
      banner <<-EOS
FEATURIST (c) 2011, Jon Archer
https://github.com/jonarcher/featurist
---------------------------------------------------

Turn a directory full of Gherkin features into a simple
requirements specification.
\t
      EOS
      opt :dir,     "Directory containing .feature files to process", :type => :string
      opt :output,  "Output filename", :default => "spec.pdf"
      opt :format,  "Output format: txt | pdf", :default => "pdf"
    end

    @dir = opts[:dir].nil? ? '.' : opts[:dir].gsub('\\', '/') #turn those backslashes to forward slashes so paths work in Dir[...]
    @out = opts[:output]
    @verbose = opts[:verbose]
    @format = opts[:format]

    # parameter verification
    Trollop::die :dir, "Cannot find #{@dir}" unless File.directory?(@dir)
    Trollop::die :format, "Must be either 'txt' or 'pdf'" unless @format.match /^(txt|pdf)$/
  end
end
