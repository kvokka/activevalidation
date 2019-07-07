# frozen_string_literal: true

class CreateActiveValidations < ActiveRecord::Migration[5.2]
  def change
    create_table :active_validation_manifests, id: :integer do |t|
      t.string   :name
      t.string   :version, index: true
      t.integer  :edition, auto_increment: true
      t.string   :model_klass, index: true

      t.datetime :created_at, null: false
    end

    add_index :active_validation_manifests, %i[model_klass version],
              name: "index_active_validation_manifest_on_model_klass_version"

    create_table :active_validation_checks, id: :integer do |t|
      t.references :manifest, type: :integer
      t.string     :klass_helper
      t.string     :field
      t.json       :options

      t.datetime :created_at, null: false
    end
  end
end
