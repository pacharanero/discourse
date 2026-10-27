# frozen_string_literal: true

module DiscourseDataExplorer
  class CachedResult < Data.define(:identity, :attributes)
    delegate :hash, :id, :query_id, to: :identity

    def [](name) = attributes[name.to_s]
  end
end
