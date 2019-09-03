@no_orm

Feature: Validate instance is possible
  With manual installation we can validate the instance with
  provided validations

  Background:
    Given class Foo with active validation with out ORM
    And   defined versions are:
           | klass | version |
           |   Foo |       1 |
    When klass Foo have method 'my_method'
    And  Foo have manifest with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: true } |
    And  active validation for class Foo installed


  Scenario: The validations from the manifest should not apply on the instance with out the context
    Then class Foo instance should be valid

  Scenario: The validations from the manifest should apply on the instance with correct context
    Then class Foo instance in context 'active_validation_v1' should not be valid

  Scenario: The validations from the manifest should not apply on the instance with incorrect context
    Then class Foo instance in context 'active_validation_v42' should be valid
