
module TestScript
  class Feature
    attr_reader :req_id, :title, :narrative, :sub_sections, :parent_section

    def add_subsection child
      @sub_sections[child.req_id] = child
    end
  end

  class TestCase
    attr_reader :tc_id, :feature, :sub_sections, :parent_section

    def initialize tc_id, feature, narrative, parent_section
      @tc_id = tc_id
      @feature = feature
      @narrative = narrative
      @parent_section = parent_section
    end

    def add_subsection child
      @sub_sections[child.tc_id] = child
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
      fqid = @tc_id.to_s
      parent = @parent_section
      begin
        fqid = parent.tc_id.to_s + '.' + fqid unless parent.tc_id == 0
        parent = parent.parent_section
      end while not parent.nil?
      fqid
    end

  end

  class StepDefinition
    attr_accessor :filename, :source
  end

  class Document
    def initialize
      # A Test script in our sense is comprised a graph of Features with TestCases (Scenarios and Scenario Outlines
      # from .feature files) and an "appendix" of step definition classes

    end

    def build
      Dir[ dir + '/*' ].each do |entry|
        if File::directory?(entry)
        elsif entry.end_with? '.feature'
          process_feature entry
        end
      end
    end

    def process_feature feature_file
      File::open feature_file, 'r' do |feature|
        parsing_feature = false
        feature_id = nil
        feature_title = feature_narrative = line = ""
        begin
          line.gsub!("\xEF\xBB\xBF", '') #strip off the stupid BOM-UTF8 marker that VS (sometimes) seems to slip in
          next if line.length == 0
          line = line.split('#')[0] # chop off comments
          if line.include? '@'
            next unless parsing_feature
            feature_id = line.slice(/@id_\d+/).slice(/\d+/).to_i if line.include? '@id'
          elsif line.include? 'Feature:'
            parsing_feature = true
            feature_title = line.gsub('Feature:', '').lstrip
          else
            feature_narrative << line #.lstrip
          end
        end while line = feature.gets
        feature_id = section.max_section_id + 1 if feature_id.nil?
        section.add_subsection Section.new( feature_id, feature_title, feature_narrative, section)
      end
    end

  end



end

