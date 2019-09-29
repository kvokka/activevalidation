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
    And defined versions are:
      | klass | version |
      |   Foo |       2 |
    And klass Foo have method 'another_method'
    And Foo have manifest version 2 with checks:
      | method_name | argument       | options            |
      |   validates | another_method | { presence: true } |
    And store Foo instance in record_v2 variable


  Scenario: The validations from the manifest should not apply on the instance with out the context
    Then variable record should be valid

  Scenario: The validations from the manifest should apply on the instance with correct context
    Then variable record in context 'active_validation_v1' should not be valid

  Scenario: The validations from the manifest should not apply on the instance with incorrect context
    Then variable record in context 'active_validation_v42' should be valid

  Scenario: The v2 record should check only another_method
    When variable record_v2 method 'another_method' returns something
    Then variable record_v2 in context 'active_validation_v1' should not be valid
    Then variable record_v2 in context 'active_validation_v2' should be valid
