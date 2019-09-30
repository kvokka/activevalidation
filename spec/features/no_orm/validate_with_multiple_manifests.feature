@no_orm

Feature: Validate instance is possible
  With manual installation we can validate the instance with
  provided validations, when there are a few manifests.

  Background:
    Given class Foo with active validation with out ORM
    And   defined versions are:
           | klass | version |
           |   Foo |       1 |
    When klass Foo have method 'my_method'
    And  Foo have manifest version unprovided with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: false } |
    And active validation for class Foo installed
    And store Foo instance in record variable
    And klass Foo have method 'another_method'
    And Foo have manifest version unprovided with checks:
      | method_name | argument       | options            |
      |   validates | another_method | { presence: true } |
    And active validation for class Foo installed

  Scenario: The validations from the manifest should not apply on the instance with out the context
    Then variable record should not be valid

  Scenario: The validations from the manifest should apply on the instance with correct context
    When variable record method 'another_method' returns something
    Then variable record should be valid
