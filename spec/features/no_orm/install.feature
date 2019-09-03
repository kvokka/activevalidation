@no_orm

Feature: Manual installation is possible
  We are able to install active validation with out any ORM

  Background:
    Given class Foo with active validation with out ORM

  Scenario: With defaults and with out any Versions
    When active validation for class Foo installed
    Then class Foo instance should be valid

  Scenario: With defaults and with defined Versions
    When defined versions are:
        | klass | version |
        |   Foo |      23 |
        |   Foo |      42 |
    When active validation for class Foo installed
    Then class Foo instance should be valid
