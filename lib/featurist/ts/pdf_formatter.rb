module TestScript
  class PDFFormatter
    def initialize output_filename, test_script
      @output_filename = output_filename
      @test_script = test_script
    end
  end
  def run
    puts "Generating PDF Test Script"
  end
end