require 'prawn'

class SpecSection
  attr_reader :req_id, :sub_sections
  attr_accessor :title, :narrative

  def initialize req_id, title, narrative
    @req_id = req_id
    @title = title
    @narrative = narrative
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
    if ordered_sections.size == 0
      0
    else
      ordered_sections.last.req_id      
    end
  end
end

class Specification
  attr_accessor :root

  def initialize
    @root = SpecSection.new 0, "Root", "Root" # magic root node -- constant?
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

  def diagnostics
    unwrap @root, 0
  end

  def unwrap node, indent
    indent.times { print "  " }
    puts "#{node.req_id}.  #{node.title}" unless indent == 0 #ignore root
    node.ordered_sections.each do |sub_node|
      unwrap sub_node, indent + 1
    end
  end

  def print_spec
    Prawn::Document.generate('spec.pdf') do |pdf|
      # put the top level contents in order by key
      #ordered = []
      #@root.ordered_sections.keys.sort.each { |key| ordered << @contents[key] }
      print_section @root.ordered_sections, pdf
      end
    end
  end

  def print_section section, pdf
    section.each do |r|
      #pdf.text '<b>' << r.id.to_s << '. ' << r.title << '</b>', :inline_format => true
      #pdf.text r.narrative
      pdf.text "\n" # should be able to configure feature separation behavior

      # deal with the children
      #if not r.sub_sections.nil?
      #  print_section r.sub_sections, pdf
      #end
  end
end