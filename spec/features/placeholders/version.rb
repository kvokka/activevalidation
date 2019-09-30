# frozen_string_literal: true

placeholder :manifest_version do
  match(/unprovided|none|undefined/) do
    nil
  end

  match(/\d+/) do |version|
    version.to_i.tap { |ver| raise("Version must be integer") if ver.zero? }
  end
end
