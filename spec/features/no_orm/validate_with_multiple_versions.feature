@no_orm

Feature: Validate instance is possible
  With manual installation we can validate the instance with
  provided validations, when there are a few manifests in
  different versions.

  Background:
    Given class Foo with active validation with out ORM
    And   defined versions are:
           | klass | version |
           |   Foo |       1 |
    When klass Foo have method 'my_method'
    And  Foo have manifest version 1 with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: true } |
    And active validation for class Foo installed
    And store Foo instance in record variable
    And set variable record manifest to current
    And defined versions are:
      | klass | version |
      |   Foo |       2 |
    And klass Foo have method 'another_method'
    And Foo have manifest version 2 with checks:
      | method_name | argument       | options            |
      |   validates | another_method | { presence: true } |
    And store Foo instance in record_v2 variable
    And set active validation version for klass Foo to 2
    And active validation for class Foo installed


  Scenario: Should ve validated with version 1
    Then variable record should not be valid
    Then variable record error message should be on my_method

  Scenario: The v2 record should check only another_method and be valid
    When variable record_v2 method 'another_method' returns something
    Then variable record_v2 should be valid

  Scenario: The v2 record should check only another_method
    Then variable record_v2 should not be valid
    Then variable record_v2 error message should be on another_method
