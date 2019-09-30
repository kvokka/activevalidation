# frozen_string_literal: true

ENV["DB"] ||= "sqlite"

require "active_record"

class PrepareDb
  module Migrations
    def create_active_validation_manifests
      create_table :active_validation_manifests do |t|
        t.string   :name
        t.string   :version
        t.string   :base_klass

        t.datetime :created_at
      end
    end

    def create_active_validation_checks
      create_table :active_validation_checks do |t|
        t.integer    :manifest_id
        t.string     :type
        t.string     :argument

        t.json       :options

        t.datetime   :created_at
      end
    end

    def create_foos
      create_table :foos do |t|
        t.integer    :manifest_id
        t.string     :name

        t.datetime   :created_at
        t.datetime   :updated_at
      end
    end

    def create_bars
      create_table :bars do |t|
        t.integer    :manifest_id
        t.string     :name

        t.datetime   :created_at
        t.datetime   :updated_at
      end
    end
  end

  include Migrations

  class << self
    def call
      new.call
    end
  end

  def call
    establish_connection

    Migrations.instance_methods(false).each { |m| public_send(m) }
  end

  private

  def establish_connection
    relative_path = "db_adapters/database.#{ENV['DB']}.yml"
    full_path = File.expand_path(relative_path, File.dirname(__FILE__))

    # Keep the format of database.*.yml files similar with multi-env configs
    # intentionally. It provide simpler support

    ActiveRecord::Base.establish_connection YAML.load_file(full_path).fetch("test")
  end

  def connection
    ActiveRecord::Base.connection
  end

  def create_table(name, *args, &blk)
    connection.drop_table(name, if_exists: true)
    connection.create_table(name, *args, &blk)
  end
end
