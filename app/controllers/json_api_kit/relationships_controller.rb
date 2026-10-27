# frozen_string_literal: true

module JsonApiKit
  class RelationshipsController < EndpointController
    include RelationshipReading

    def show = render_relationship(relationship.linkage_document)
  end
end
