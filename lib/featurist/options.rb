require 'trollop'

class Options
  attr_reader :dir, :out, :verbose
  def initialize
    opts = Trollop::options do
      version       "Feature Publisher v0.0.1, February 2011, Jon Archer"
      opt :dir,     "Directory containing .feature files to process", :type => :string
      opt :output,  "Output filename", :default => "spec.pdf"
      opt :format,  "Output format: txt | pdf", :default => "pdf"
      opt :verbose, "Output detailed diagnostics"
    end

    @dir = opts[:dir].nil? ? '.' : opts[:dir].gsub('\\', '/') #turn those backslashes to forward slashes so paths work in Dir[...]
    @out = opts[:output]
    @verbose = opts[:verbose]
    @format = opts[:format]

    # parameter verification
    Trollop::die :dir, "Cannot find #{@dir}" unless File.directory?(@dir)
    Trollop::die :format, "Must be either 'txt' or 'pdf'" unless @format.match /^(txt|pdf)$/
  end

  def welcome
    puts %{
FEATURIST v0.0.1, February 2011, Jon Archer
https://github.com/jonarcher/featurist

email jon at rollinsville dot org
twitter @9200feet
---------------------------------------------------

Turn a directory full of Gherkin features into a simple
requirements specification.
    }
    puts "Try featurist --help" if ARGV.empty?
  end
end
