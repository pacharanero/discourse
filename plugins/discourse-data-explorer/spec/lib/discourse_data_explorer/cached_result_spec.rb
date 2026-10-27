# frozen_string_literal: true

RSpec.describe DiscourseDataExplorer::CachedResult do
  subject(:result) { described_class.new(identity:, attributes:) }

  let(:identity) do
    DiscourseDataExplorer::QueryResultCache::Key.new(
      query_id: "1",
      visibility: "admin",
      digest: "a" * 64,
    )
  end
  let(:attributes) { { "rows" => [[1]] } }

  describe "#hash" do
    before { allow(attributes).to receive(:hash).and_call_original }

    it "hashes the result without hashing its payload" do
      result.hash

      expect(attributes).not_to have_received(:hash)
    end
  end

  describe "Hash lookup" do
    subject(:lookup) { index.fetch(other_result, :missing) }

    let(:index) { { result => :cached } }
    let(:other_result) { described_class.new(identity: identity.dup, attributes: other_attributes) }
    let(:other_attributes) { attributes.deep_dup }

    it "finds an equivalent result" do
      expect(lookup).to eq(:cached)
    end

    context "when the payload differs" do
      let(:other_attributes) { super().merge("rows" => [[2]]) }

      it "distinguishes results with the same identity" do
        expect(lookup).to eq(:missing)
      end
    end
  end
end
