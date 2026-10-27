# frozen_string_literal: true

module JsonApiKit
  class FilterPaths
    Path =
      Data.define(:relationships, :filter, :resource) do
        def self.for(name, resource:)
          return name if name.is_a?(self)
          new(
            relationships: [],
            filter: Name::Filter.new(value: name.to_s, type: resource.type),
            resource:,
          )
        end

        def local? = relationships.empty?

        def declared? = resource.filter_names.include?(filter.value)

        def prepend(relationship) = with(relationships: [relationship, *relationships])

        def member_name(glossary)
          [*relationships, filter].map { glossary.member_name(it).value }.join(".")
        end

        def parameters(value)
          relationships
            .reverse_each
            .reduce({ filter: { filter.value => value } }) do |params, name|
              { forwarded_filters: { name.value => params } }
            end
        end
      end

    def initialize(resource:, glossary:)
      @resource = resource
      @glossary = glossary
    end

    def declared_path(member, within: resource)
      name =
        glossary.declared_name(
          Name::Filter.new(value: member, type: glossary.member_type(within.type)),
        )
      if within.filter_names.include?(name.value) || !member.include?(".")
        return Path.new(relationships: [], filter: name, resource: within)
      end

      relationship, rest = member.split(".", 2)
      declared = glossary.declared_relationship(member: relationship, type: within.type)
      declared_path(rest, within: related_resource(within, declared)).prepend(
        Name::Relationship.new(value: declared, type: within.type),
      )
    end

    private

    attr_reader :resource, :glossary

    def related_resource(owner, name)
      declaration =
        owner.relationships.fetch(name) { raise RelationshipPaths::UnknownPath.new(name) }
      return declaration.resource if resource.is_a?(Class)
      resource.resource_for(declaration.resource)
    end
  end
end
