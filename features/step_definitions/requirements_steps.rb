require 'featurist'
require 'featurist/cli'

Given /^the features in "([^"]*)"$/ do |test_input_dir|
  @test_input_dir = test_input_dir
end

When /^I run Featurist with the following additional arguments:$/ do |table|
  config      = Featurist::Config.new
  config.dir  = @test_input_dir
  table.hashes.each do |hash|
    case hash['argument']
      when '--output'
        config.output = @actual_results_file = hash['value']
      when '--format'
        config.format = hash['value']
    end
  end

  featurist = Featurist.new config
  #featurist.run
end

Then /^I get the same results as in "([^"]*)"$/ do |expected_results_file|
  expected_file = File::open expected_results_file, 'r'
  actual_file   = File::open @actual_results_file, 'r'

  actual_file.should == expected_file
end