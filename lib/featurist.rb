require_relative 'featurist/options'
require_relative 'featurist/specification'

class Featurist
  def initialize
    @opts = Options.new
    @opts.welcome

    @spec = Specification.new

    # Other basic setup of spec
    #@spec.cover_page ...
    #@spec.toc = true
    #@spec.page_numbering = true
  end

  def run
    # Manually add any sections you want
    @spec.add_or_update_section SpecSection.new(1, "Introduction", "The intro...")

    # Dynamically generated stuff from "/Features"
    build_spec @opts.dir, @spec.root

    # Update section descriptions from /Features/**/*.sections


    # Another manual add at the end
    @spec.add_or_update_section SpecSection.new(1000, "Sign off", "Sign it in...PMED.")

    @spec.print
  end

  def build_spec dir, section
    Dir[ dir + '/*' ].each do |entry|
      if File::directory?(entry)
        # we need a SpecSection here to represent this
        sub_section = SpecSection.new entry, entry, entry # bad naming scheme...
        build_spec entry, sub_section
      elsif entry.end_with? '.feature'
        add_feature entry, section
      end
    end
  end

  def add_feature feature_file, section
    File::open feature_file, 'r' do |feature|
      feature_id = feature_title = feature_narrative = line = ""
      begin
        next if line.length == 0
        next if line.include? '#' # skip over comments
        break if line.match 'Scenario|Background' # Scenario, Scenario Outline or Background = we're done
        if line.include? '@id'
          #TODO: extract req ID number and stuff it in feature_id
        elsif
          line.include? 'Feature:'
          feature_title = line.gsub('Feature:', '').lstrip
        else
          feature_narrative << line.lstrip
        end
      end while line = feature.gets
      # arse...we can't always be adding to @spec because then everything will be at the root
      # level. Instead we want to be adding to something like current_node
      section.add_subsection SpecSection.new( feature_id, feature_title, feature_narrative)
    end
  end

end

# TODO: Massive amounts of instrumentation!!!!!!!

featurist = Featurist.new
featurist.run
