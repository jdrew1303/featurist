
module TestScript
#  class Feature
#    attr_reader :req_id, :title, :narrative, :sub_sections, :parent_section
#
#    def add_subsection child
#      @sub_sections[child.req_id] = child
#    end
#  end

  class Section
    attr_reader :section_id, :sub_sections
    attr_accessor :title, :narrative, :parent_section

    def initialize section_id, title, narrative, parent_section
      @section_id = section_id
      @title = title
      @narrative = narrative
      @parent_section = parent_section
      @sub_sections = {}
    end

    def add_subsection child
      child.parent_section = self
      @sub_sections[child.section_id] = child
    end

    def ordered_sections
      retval = []
      @sub_sections.keys.sort.each do |key|
        retval << @sub_sections[key]
      end
      retval
    end

    def max_section_id
      ordered_sections.size
    end

    def fully_qualified_id
      fqid = @section_id.to_s
      parent = @parent_section
      begin
        fqid = parent.section_id.to_s + '.' + fqid unless parent.section_id == 0
        parent = parent.parent_section
      end while not parent.nil?
      fqid
    end
  end

  class TestCase < Section
  end

  class Feature < Section
  end

  class StepDefinition
    attr_accessor :filename, :source
  end

  class Document
    attr_accessor :root
    
    def initialize
      # A Test script in our sense is comprised a set of Features with TestCases (Scenarios and Scenario Outlines
      # from .feature files) and an "appendix" of step definition classes
      @root = Section.new 0, "Root", "Root", nil # magic root node -- constant?
    end

    def build dir, section
      Dir[ dir + '/*' ].each do |entry|
        if File::directory?(entry)
          # only do anything with this directory if it's *not* on the configured ignore list
          if not Featurist::Config.config.ignore_directories.include? entry.rpartition(/\//).last
            sub_section = Section.new section.max_section_id + 1, entry.rpartition(/\//).last, entry, section

            # if details are provided in the config.yml update this sub section
            if Featurist::Config.config.directory_config.has_key? sub_section.title
              sub_section.narrative = Featurist::Config.config.directory_config[sub_section.title]["narrative"]
              sub_section.title = Featurist::Config.config.directory_config[sub_section.title]["title"]
              # TODO: ordering
            end

            section.add_subsection sub_section
            build entry, sub_section
          end
        elsif entry.end_with? '.feature'
          process_feature entry, section
        end
      end
    end

    def process_feature feature_file, section
      File::open feature_file, 'r' do |feature|
        parsing_feature = false
        parsing_scenario = false
        feature_id = nil
        feature_title = feature_narrative = test_case_title = test_case_narrative = line = ""
        test_cases = []
        begin
          # TODO: Handle Background sections
          line.gsub!("\xEF\xBB\xBF", '') #strip off the stupid BOM-UTF8 marker that VS (sometimes) seems to slip in
          next if line.length == 0
          line = line.split('#')[0] # chop off comments
          if line.include? '@'
            next unless parsing_feature
            feature_id = line.slice(/@id_\d+/).slice(/\d+/).to_i if line.include? '@id'
          elsif line.include? 'Feature:'
            parsing_feature = true
            feature_title = line.gsub('Feature:', '').lstrip
          elsif line.match 'Scenario'
            if parsing_scenario
              test_case = TestCase.new( test_cases.size + 1, test_case_title, test_case_narrative, section )
              test_cases << test_case
              test_case_narrative = ""
            end
            test_case_title = line.gsub('Scenario: ', '').lstrip
            parsing_scenario = true
            parsing_feature = false
          else
            feature_narrative   += line if parsing_feature
            test_case_narrative += line if parsing_scenario
          end
        end while line = feature.gets

        # dangling
        if parsing_scenario
          test_case = TestCase.new( test_cases.size + 1, test_case_title, test_case_narrative, section )
          test_cases << test_case
        end

        feature_id = section.max_section_id + 1 if feature_id.nil?
        f = Feature.new( feature_id, feature_title, feature_narrative, section)
        section.add_subsection f

        puts "For feature: #{feature_title} found #{test_cases.size} test cases"

        # add our test_cases to the feature
        test_cases.each do |tc|
          f.add_subsection tc
        end

      end
    end
  end

end

