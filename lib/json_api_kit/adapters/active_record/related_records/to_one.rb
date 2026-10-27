# frozen_string_literal: true

module JsonApiKit
  module Adapters
    class ActiveRecord < Adapter
      class RelatedRecords
        class ToOne < RelatedRecords
          def scope = Scoping::ToOne.new(super, association:)

          private

          def sideload_scope = Scoping::ToOne.new(super, association:)

          def pair(records) = super.transform_values { it.first(1) }
        end
      end
    end
  end
end
