@active_record

Feature: When the class is a child of active_validation class it should
  preform own checks and parent checks with correct versions

Background:
    Given class Bar with active validation and superclass ActiveRecord::Base
    And   class Foo with active validation and superclass Bar
    And   defined versions are:
    | klass | version |
    |   Foo |       1 |
    |   Foo |       2 |
    |   Bar |       1 |
    |   Bar |       2 |

    When klass Bar have method 'parent_method'
    And  Bar have manifest version 2 with checks:
    | method_name | argument      | options                       |
    |   validates | parent_method | { inclusion: { in: ['v2'] } } |
    And  Bar have manifest version 1 with checks:
    | method_name | argument      | options                       |
    |   validates | parent_method | { inclusion: { in: ['v1'] } } |
    And store Foo instance in record variable


    Scenario: With parent validation check
    When variable record method 'parent_method' returns 'v2'
    Then variable record should be valid

    Scenario: With out parent validation check
    When variable record method 'parent_method' returns 'v1'
    Then variable record should be valid
