require 'featurist/config'

module Specification
  class Section
    attr_reader :req_id, :sub_sections, :parent_section
    attr_accessor :title, :narrative

    def initialize req_id, title, narrative, parent_section
      @req_id = req_id
      @title = title
      @narrative = narrative
      @parent_section = parent_section
      @sub_sections = {}
    end

    def add_subsection child
      @sub_sections[child.req_id] = child
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
      fqid = @req_id.to_s
      parent = @parent_section
      begin
        fqid = parent.req_id.to_s + '.' + fqid unless parent.req_id == 0
        parent = parent.parent_section
      end while not parent.nil?
      fqid
    end
  end

  # TODO: does this Document class serve *any* purpose any longer?
  class Document
    attr_accessor :root

    def initialize
      @root = Section.new 0, "Root", "Root", nil # magic root node -- constant?
    end

    def add_or_update_section section
      if @root.sub_sections.has_key? section.req_id
        # update the title, narrative -- leave children intact
        @root.sub_sections[section.req_id].title = section.title
        @root.sub_sections[section.req_id].narrative = section.narrative
      else
        @root.sub_sections[section.req_id] = section
      end
    end
  end

  #
  # TODO: Where do the below methods really belong?
  #       Currently Featurist::methods.
  #

  def build_spec dir, section
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
          build_spec entry, sub_section
        end
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
        break if line.match 'Scenario|Background' # Scenario, Scenario Outline or Background = we're done
        line.gsub!("\xEF\xBB\xBF", '') #strip off the stupid BOM-UTF8 marker that VS (sometimes) seems to slip in
        next if line.length == 0
        line = line.split('#')[0] # chop off comments
        if line.include? '@id'
          feature_id = line.slice(/@id_\d+/).slice(/\d+/).to_i
        elsif line.include? 'Feature:'
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

