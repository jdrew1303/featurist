require 'featurist/specification'
require 'featurist/text_formatter'
require 'featurist/config'

include Specification # Bring in build_spec module method TODO: figure out proper organization/naming/means to include stuff

class Featurist
  def initialize options
    @options = options
    Featurist::Config.load @options.dir
  end

  def run
    # Create a spec
    spec = Specification::Document.new

    # Manually add any sections you want
    spec.add_or_update_section Specification::Section.new 1, "Introduction", "The intro...", spec.root

    # Dynamically generated stuff from "/Features"
    build_spec @options.dir, spec.root

    # Process the featurist config
    p Featurist::Config.config.directory_config

    # Another manual add at the end
    spec.add_or_update_section Specification::Section.new 100, "Sign off", "Sign it in...PMED.", spec.root

    # Output our spec
    formatter = TextFormatter.new @options.output, spec
    formatter.run

  end

end
