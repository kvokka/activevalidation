# frozen_string_literal: true

# This module help to improve RSpec speed to 5-10%
# It is switched on by default, and accepts `DEFER_GC` ENV variable
# with Float value.

class DeferredGarbageCollection
  DEFERRED_GC_THRESHOLD = (ENV["DEFER_GC"] || 15.0).to_f

  @last_gc_run = Time.now

  def self.start
    GC.disable
  end

  def self.reconsider
    return unless Time.now - @last_gc_run >= DEFERRED_GC_THRESHOLD

    GC.enable
    GC.start
    GC.disable
    @last_gc_run = Time.now
  end
end

unless ENV["DEFER_GC"] == "0" || ENV["DEFER_GC"] == "false"
  RSpec.configure do |config|
    config.before(:all) { DeferredGarbageCollection.start }
    config.after(:all)  { DeferredGarbageCollection.reconsider }
  end
end
