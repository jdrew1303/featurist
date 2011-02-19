Feature: Trace Matrix
  A trace matrix is a document mapping requirements to tests. In a 21 CFR part 11
  regulated business, auditors expect to see such a document as it demonstrates
  test coverage for the functional requirements of a software product.

  The trace matrix feature of Featurist generates a trace matrix document from a
  project's .feature files.

  Scenario: Simple trace matrix
    Given the features in "test_data/examples/example_1"
    When I run Featurist
    Then I get the same results as in "test_data/expected_results/example_1/trace_matrix.txt"