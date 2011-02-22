require 'prawn'
require 'featurist/config'

class PDFFormatter
  def initialize output_filename, spec
    @output_filename = output_filename
    @spec = spec
    @level = 0
    @config = Featurist::Config.config
  end

  def run
    Prawn::Document.generate @output_filename, :info => {
        :Title => "#{@config.cover_page_project_name} Requirements Specification",
        :Author => "Jon Archer",
    } do |pdf|
      @pdf = pdf
      cover_page if @config.cover_page
      unwrap @spec.root

      #TODO has to be a better way to do this. More investigation of Prawn required...
      @pdf.number_pages "CONFIDENTIAL INTERNAL DOCUMENT                    Page <page> of <total>", [@pdf.bounds.right - 500, 0]
    end
  end

  private
    def cover_page
      @pdf.move_down 100
      @pdf.text @config.cover_page_project_name, :size => 24, :align => :center
      @pdf.move_down 100
      @pdf.text @config.cover_page_narrative
      @pdf.start_new_page
    end

    def unwrap section
      render section
      section.ordered_sections.each do |sub_node|
        @level += 1
        unwrap sub_node
      end
      @level -= 1
    end

    def render node
      return if @level == 0
      #@level.times { @output_file "  " } @pdf.indent( x )
      @pdf.text "#{node.fully_qualified_id}.  #{node.title}" unless @level == 0 #ignore root
      @pdf.text "\n" unless node.title.match /\n$/ #sometimes we need to force a newline after title

      @pdf.text node.narrative

      @pdf.text "\n\n" # TODO: configurable section separator???
    end

end


#def print_section section, pdf
#  section.each do |r|
#    #pdf.text '<b>' << r.id.to_s << '. ' << r.title << '</b>', :inline_format => true
#    #pdf.text r.narrative
#    pdf.text "\n" # should be able to configure feature separation behavior
#
#    # deal with the children
#    #if not r.sub_sections.nil?
#    #  print_section r.sub_sections, pdf
#    #end
#  end
#end
