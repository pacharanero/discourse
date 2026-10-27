# frozen_string_literal: true

module JsonApiKit
  module Adapters
    class ActiveRecord < Adapter
      class Association
        class Through < Association
          def initialize(join_scope:, join_owner_key:, join_related_key:, **)
            super(**)
            @join_scope = join_scope
            @join_owner_key = join_owner_key.to_sym
            @join_related_key = join_related_key.to_sym
          end

          def related_scope = scope.where(related_key => joins.select(join_related_key))

          private

          attr_reader :join_scope, :join_owner_key, :join_related_key

          def pair_groups(related_by_key)
            positions = related_by_key.keys.each_with_index.to_h
            related_keys.transform_values do |keys|
              keys.sort_by { positions.fetch(it, 0) }.flat_map { related_by_key.fetch(it, []) }
            end
          end

          def joins = join_scope.where(join_owner_key => owner_values)

          def related_keys
            @related_keys ||=
              joins
                .pluck(join_owner_key, join_related_key)
                .group_by(&:first)
                .then do |pairs|
                  owner_records.to_h { [it, pairs.fetch(owner_value(it), []).map(&:last)] }
                end
          end
        end
      end
    end
  end
end
