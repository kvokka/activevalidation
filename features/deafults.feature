Feature: Manual installation is possible
  We are able to use active validation with out any ORM

  Scenario: With defaults and with out any Versions
    Given class "Foo" with active validation with out ORM
    When active validation for class "Foo" installed
    Then class "Foo" instance should be valid
