
require 'featurist/options'
require 'featurist/specification'



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
    @spec.add_or_update_section SpecSection.new(1, "Introduction", "The intro...", @spec.root)

    # Dynamically generated stuff from "/Features"
    build_spec @opts.dir, @spec.root

    # Update section descriptions from /Features/**/*.sections


    # Another manual add at the end
    @spec.add_or_update_section SpecSection.new(1000, "Sign off", "Sign it in...PMED.", @spec.root)

    @spec.diagnostics
    #@spec.print_spec
  end

  def build_spec dir, section
    Dir[ dir + '/*' ].each do |entry|
      if File::directory?(entry)
        # we need a SpecSection here to represent this
        sub_section = SpecSection.new section.max_section_id + 1, entry.rpartition(/\//).last, entry, section
        section.add_subsection sub_section
        build_spec entry, sub_section
      elsif entry.end_with? '.feature'
        add_feature entry, section
      end
    end
  end

  def add_feature feature_file, section
    File::open feature_file, 'r' do |feature|
      feature_id = nil
      feature_title = feature_narrative = line = ""
      begin
        next if line.length == 0
        break if line.match 'Scenario|Background' # Scenario, Scenario Outline or Background = we're done
        line.gsub!("\xEF\xBB\xBF", '') #strip off the stupid BOM-UTF8 marker that VS (sometimes) seems to slip in
        line = line.split('#')[0] # chop off comments
        if line.include? '@id'
          feature_id = line.slice(/@id_\d+/).slice(/\d+/).to_i 
        elsif line.include? 'Feature:'
          feature_title = line.gsub('Feature:', '').lstrip
        else
          feature_narrative << line.lstrip
        end
      end while line = feature.gets
      feature_id = section.max_section_id + 1 if feature_id.nil?
      section.add_subsection SpecSection.new( feature_id, feature_title, feature_narrative, section)
    end
  end

end



# TODO: Massive amounts of instrumentation!!!!!!!

featurist = Featurist.new
featurist.run
