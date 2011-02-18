require 'featurist/options'
require 'featurist/specification'
include Featurist # TODO: figure out proper organization/naming/means to include stuff

opts = Options.new
opts.welcome

# Create a spec
spec = Featurist::Specification.new

# Manually add any sections you want
spec.add_or_update_section Featurist::SpecSection.new 1, "Introduction", "The intro...", spec.root

# Dynamically generated stuff from "/Features"
build_spec opts.dir, spec.root

# Process the featurist.config
# TODO: see above :)

# Another manual add at the end
spec.add_or_update_section Featurist::SpecSection.new 100, "Sign off", "Sign it in...PMED.", spec.root

# Output our spec
spec.diagnostics
#@spec.print_spec




