@active_record

Feature: New record do correct checks and store validation version

  Background:
    Given class Foo with active validation
    And   defined versions are:
      | klass | version |
      |   Foo |       1 |
    When klass Foo have method 'my_method'
    And  Foo have manifest version unprovided with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: true } |

  Scenario: The validations from the manifest should not apply on the instance with out the context
    Then class Foo instance should be valid

  Scenario: The validations from the manifest should apply on the instance with correct context
    Then class Foo instance in context 'active_validation_v1' should not be valid

  Scenario: The validations from the manifest should not apply on the instance with incorrect context
    Then class Foo instance in context 'active_validation_v42' should be valid
