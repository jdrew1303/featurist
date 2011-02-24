Feature: Test Script
  In a 21 CFR part 11 regulated business, many auditors expect to see test scripts which have been
  reviewed and approved for use prior to a lifecycle phase typically referred to as "Controlled
  Test". Such expectations come from a history of waterfall software development and manual testing.
  In such an environment one would find manual test script documents that got approved toward the
  final stages of the project before being run in this "Controlled Test" stage.

  However, when developing software using an agile approach, one usually employs automated tests
  and the "test scripts" are programs rather than documents created in a word processor. When
  using a BDD tool like Cucumber or SpecFlow it can be difficult to explain to people used to
  seeing test script documents, and harder still to explain that code review of step definitions
  can effectively correspond to script sign off.

  The test script feature of Featurist generates a test script document from the scenarios found
  in .feature files with an appendix containing the step definition code. This document can be
  "signed off" and automated test runs after that sign off can be considered "controlled test" runs.

  Scenario: Simple test script
    Given the features in "test_data/examples/example_1"
    When I run Featurist
    Then I get the same results as in "test_data/expected_results/example_1/test_script.txt"
