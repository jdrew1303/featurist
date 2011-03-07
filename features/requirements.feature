@wip
Feature: Requirements Specification
  In a project using a BDD tool such as Cucumber or SpecFlow, the requirements specification
  is, essentially, the contents of the .feature files. However, access to these files is not
  necessarily straightforward for non technical users. The Cucumber tool does provide a
  formatter that can generate PDF output but it's not focused on creating a traditional
  requirements specification, rather a PDF version of a typical Cucumber run including test
  results.

  The Requirements Specification feature of Featurist is for creating such a document as
  consumers of more traditional documentation will recognize and be at ease with.

  Scenario: Simple requirements specification
    Given the features in "./features"
    When I run Featurist
    Then I get the same results as in "./test_data/expected-requirements.txt"

  Scenario: Complex requirements specification
    Given a complicated product
    When I create an RS from the .features files
    Then there will be a huge PDF file with much indentation

  Scenario: A third requirements scenario
    Given blaa blaa blaa
    When I blaa de blaa
    Then Holy blaa blaa