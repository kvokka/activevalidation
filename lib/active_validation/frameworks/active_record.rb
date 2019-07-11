# frozen_string_literal: true

loader = Zeitwerk::Loader.new
loader.push_dir "#{__dir__}/active_record/models"
loader.setup
loader.eager_load
