# frozen_string_literal: true

placeholder :klass do
  match(/[\w|:]+/, &:constantize)
end
