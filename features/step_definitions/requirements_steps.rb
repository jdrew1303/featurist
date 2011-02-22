require 'featurist'
require 'featurist/cli'

Given /^the features in "([^"]*)"$/ do |features_dir|

  @options = Featurist::Options.new
  @options.features_dir = features_dir
end

When /^I run Featurist$/ do
  featurist = Featurist.new @options
  featurist.run
end

Then /^I get the same results as in "([^"]*)"$/ do |expected_results_file|



  expected  = File::open(expected_results_file, 'r').read
  actual    = File::open(@options.spec_filename, 'r').read

  puts "expected.getwd = #{expected.getwd}"
  puts "actual.getwd = #{actual.getwd}"

  actual.should == expected
end



#When /^I run Featurist with the following additional arguments:$/ do |table|
#  options               = Featurist::Options
#  options.features_dir  = @test_input_dir
#
#  table.hashes.each do |hash|
#    case hash['argument']
#      when '--output'
#        options.format = @actual_results_file = hash['value']
#      when '--format'
#        options.format = hash['value']
#    end
#  end
#
#  featurist = Featurist.new options
#  #featurist.run
#end
