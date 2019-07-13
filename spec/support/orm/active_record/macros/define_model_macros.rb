# frozen_string_literal: true

# This macros was borrowed from FactoryBot and slightly tuned for this gem
# Thank you, Thoughtbot

module DefineModelMacros
  def define_model(name, columns = {}, &block)
    model = define_class(name, ActiveRecord::Base, &block)
    create_table(model.table_name) do |table|
      columns.each do |column_name, type|
        table.column column_name, type
      end
    end
    model
  end

  def create_table(table_name, &block)
    connection = ActiveRecord::Base.connection

    begin
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      connection.create_table(table_name, &block)
      created_tables << table_name
      connection
    rescue Exception => e # rubocop:disable Lint/RescueException
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      raise e
    end
  end

  def clear_generated_tables
    created_tables.each do |table_name|
      ActiveRecord::Base
        .connection
        .execute("DROP TABLE IF EXISTS #{table_name}")
    end
    created_tables.clear
  end

  private

  def created_tables
    @created_tables ||= []
  end
end

RSpec.configure do |config|
  config.include DefineModelMacros

  config.after do
    clear_generated_tables
  end
end
