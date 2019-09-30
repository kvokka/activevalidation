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
    And  Foo have manifest version unprovided with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: true } |
    And  active validation for class Foo installed


  Scenario: The validations from the manifest should apply on the instance with out the context
    Then class Foo instance should not be valid

  Scenario: The validations from newer manifest should apply on the instance with out the context
    And  Foo have manifest version unprovided with checks:
      | method_name | argument  | options             |
      |   validates | my_method | { presence: false } |

    Then class Foo instance should be valid
