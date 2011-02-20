require 'text/format'

class TextFormatter
  def initialize output_filename, spec
    @output_filename = output_filename
    @spec = spec
    @level = 0
    @formatter = Text::Format.new
    @formatter.columns = 60
    @formatter.first_indent = 0
  end

  def run
    # open the file
    unwrap @spec.root
    # close the file
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
    @level.times { print "  " }
    puts "#{node.fully_qualified_id}.  #{node.title}" unless @level == 0 #ignore root

    @formatter.left_margin = ( @level * 2 ) + node.fully_qualified_id.size + 3
    @formatter.text = node.narrative

    puts @formatter.paragraphs

    puts "\n\n" # TODO: configurable section separator???
  end
end
