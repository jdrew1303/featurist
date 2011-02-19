class TextFormatter
  def initialize output_filename, spec
    @output_filename = output_filename
    @spec = spec
    @level = 0
    @line_length = 60
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

    # TODO: detect and fix words split across lines
    # TODO: also detect when end of one sentence runs into beginning of another

    lines = node.narrative.scan /.{1,#{@line_length}}/
    lines.each do |line|
      @level.times { print "  " }
      narrative_indent = node.fully_qualified_id.size + 3
      narrative_indent.times { print " " }
      puts line
    end
    puts "\n" # TODO: configurable section separator???
  end
end
