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
---------------------------------------------------

Turn a directory full of Gherkin features into a simple
requirements specification.
\t
      EOS
      opt :dir,     "Directory containing .feature files to process", :type => :string
      opt :output,  "Output filename", :default => "spec.pdf"
      opt :format,  "Output format: txt | pdf", :default => "pdf"
    end

#    dir = opts[:dir].nil? ? '.' : opts[:dir].gsub('\\', '/')
#    output = opts[:output]
#    format = opts[:format]

    # parameter verification
    Trollop::die :dir, "Cannot find #{opts[:dir]}" unless File.directory?(opts[:dir])
    Trollop::die :format, "Must be either 'txt' or 'pdf'" unless opts[:format].match /^(txt|pdf)$/

    @config        = Featurist::Config.new
    @config.dir    = opts[:dir].nil? ? '.' : opts[:dir].gsub('\\', '/') #turn backslashes in Windows paths to forward slashes so paths work in Dir[...]
    @config.output = opts[:output]
    @config.format = opts[:format]
  end

  def execute!
    f = Featurist.new @config
    f.run
  end
end

class Featurist
  class Config
    attr_accessor :dir, :output, :format
  end
end
