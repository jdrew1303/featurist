require 'prawn'

class PDFFormatter
  def initialize output_filename, spec
    @output_filename = output_filename
    @spec = spec
    @level = 0    
  end

  def run
    Prawn::Document.generate(@output_filename) do |pdf|
      @output_file = pdf
      unwrap @spec.root
    end
  end

  private
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
      #@level.times { @output_file "  " }
      @output_file.text "#{node.fully_qualified_id}.  #{node.title}" unless @level == 0 #ignore root
      @output_file.text "\n" unless node.title.match /\n$/ #sometimes we need to force a newline after title

      @output_file.text node.narrative

      @output_file.text "\n\n" # TODO: configurable section separator???
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
