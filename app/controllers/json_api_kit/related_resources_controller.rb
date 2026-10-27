# frozen_string_literal: true

module JsonApiKit
  class RelatedResourcesController < EndpointController
    include RelationshipReading

    def index = render_relationship(relationship.related_document)

    def show = render_relationship(relationship.related_document)
  end
end
