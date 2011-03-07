require 'prawn'
require 'featurist/config'

module TestScript
  class PDFFormatter
    def initialize output_filename, test_script
      @output_filename = output_filename
      @test_script = test_script
      @level = 0
      @config = Featurist::Config.config
    end

    def run
      puts "Generating PDF Test Script"

      Prawn::Document.generate @output_filename, :top_margin => 50 do |pdf|
        @pdf = pdf
        cover_page if @config.cover_page

        # headers and footers only on pages > 1, i.e. after the cover page.
        @pdf.repeat(lambda { |p| p > 1}) do
          # header
          @pdf.bounding_box [@pdf.bounds.left, @pdf.bounds.top], :width  => @pdf.bounds.width do
            @pdf.text @config.header_text, :align => :left, :size => 10, :inline_format => true
            unless @config.header_logo.nil?
              logo = @config.header_logo
              @pdf.image logo, :width => 150,:at => [@pdf.bounds.right - 140, 33]
            end
            @pdf.stroke_horizontal_rule
            @pdf.move_down 20
          end

          # footer
          @pdf.bounding_box [@pdf.bounds.left, @pdf.bounds.bottom + 25], :width => @pdf.bounds.width do
            @pdf.stroke_horizontal_rule
            @pdf.move_down 10
            @pdf.text @config.footer_text, :align => :left, :inline_format => true
          end
        end

        # main text area
        @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top - 50], :width  => @pdf.bounds.width, :height => @pdf.bounds.height - 100) do
          unwrap @test_script.root
        end

        @pdf.number_pages @config.footer_page_number_format, [@pdf.bounds.right - 100, 8]
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
      @pdf.indent @level * 10 do
        @pdf.text "<b><u>#{node.fully_qualified_id}.  #{node.title}</u></b>", :inline_format => true unless @level == 0 #ignore root
        @pdf.text "\n" unless node.title.match /\n\n$/ #sometimes we need to force a newline after title
        if node.kind_of? TestScript::TestCase
          @pdf.text node.narrative
          @pdf.text "\n" unless node.narrative.match /\n\n\z/
        end
      end
    end

    def cover_page
      @pdf.move_down 100
      @pdf.text '<b><i>' << @config.cover_page_project_name << '</i></b>', :size => 24, :align => :right, :inline_format => true
      @pdf.stroke_horizontal_rule
      @pdf.move_down 100
      @pdf.indent 50 do
        @pdf.text @config.cover_page_narrative, :inline_format => true
        @pdf.move_down 40
        @pdf.text "<b>Generated on:</b> #{Time.new.strftime('%d, %B %Y')}", :inline_format => true
      end
      @pdf.start_new_page :top_margin => 50
    end

  end
end