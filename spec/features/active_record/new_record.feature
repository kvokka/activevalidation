@active_record

Feature: New record do correct checks and store validation version

  Background:
    Given class Foo with active validation and superclass ActiveRecord::Base
    And   defined versions are:
      | klass | version |
      |   Foo |       1 |
    When klass Foo have method 'my_method'
    And  Foo have manifest version unprovided with checks:
      | method_name | argument  | options            |
      |   validates | my_method | { presence: true } |

  Scenario: Should use active validation xontext
    Then class Foo instance should not be valid

  Scenario: Should became valid
    When store Foo instance in record variable
    When variable record method 'my_method' returns something
    Then variable record should be valid

