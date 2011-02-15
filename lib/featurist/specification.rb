require 'prawn'

# It's a hierarchy of nodes
# 2 types of node
#   - A feature: made up of an ID, a title and some narrative
#   - A subsection: made up of an ID, a title, some narrative and a collection of child nodes
# Not really two kinds of node, they are the same, just some have children and some don't.
#
# IDs, narratives and child noses are optional, titles are not
# Nodes are sorted by ID, then alphabetically

class SpecSection
  attr_reader :id, :sub_sections
  attr_accessor :title, :narrative

  #todo optional id & narrative, mandatory title
  def initialize id, title, narrative
    if id.nil?
      @id = title
    else
      @id = id
    end
    @title = title
    @narrative = narrative
    @sub_sections = {}
  end

  def add_subsection child
    @sub_sections[child.id] = child
  end

  def ordered_sections
    ordered_sections = []
    @sub_sections.keys.sort.each { |key| ordered_sections << sub_sections[key] }
  end
end

# TODO: redo Specification so it has a root SpecSection node
# and the current @contents becomes @root_node.sub_sections???
class Specification
  attr_accessor :root

  def initialize
    @root = SpecSection.new 0, "Root", "Root" # magic root node -- constant?
  end

  def add_or_update_section section
    if @root.sub_sections.has_key? section.id
      # update the title, narrative -- leave children intact
      @root.sub_sections[section.id].title = section.title
      @root.sub_sections[section.id].narrative = section.narrative
    else
      @root.sub_sections[section.id] = section
    end
  end

  def print
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
      pdf.text '<b>' << r.id.to_s << '. ' << r.title << '</b>', :inline_format => true
      pdf.text r.narrative
      pdf.text "\n" # should be able to configure feature separation behavior

      # deal with the children
      if not r.sub_sections.nil?
        print_section r.sub_sections, pdf
      end
  end
end

