# frozen_string_literal: true

class CreateModels < ActiveRecord::Migration[5.0]
  def up
    create_table :foods, id: :integer do |t|
      t.string   :name
      t.timestamps
    end

    create_table :fruits, id: :integer do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
    # we just do not need to support thi method
    raise IrreversibleMigration
  end
end
