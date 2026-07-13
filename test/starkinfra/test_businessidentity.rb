# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::BusinessIdentity, '#business-identity#') do
  it 'create' do
    identity = StarkInfra::BusinessIdentity.create([ExampleGenerator.business_identity_example()]).first
    expect(identity.id).wont_be_nil
  end

  it 'query' do
    identities = StarkInfra::BusinessIdentity.query(limit: 1)

    identities.each do |identity|
      expect(identity.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      identities, cursor = StarkInfra::BusinessIdentity.page(limit: 2, cursor: cursor)

      identities.each do |identity|
        expect(ids).wont_include(identity.id)
        ids << identity.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(4)
  end

  it 'query and get' do
    identity = StarkInfra::BusinessIdentity.query(limit: 1).first

    identity = StarkInfra::BusinessIdentity.get(identity.id)
    expect(identity.id).wont_be_nil
  end

  it 'update' do
    identity_id = StarkInfra::BusinessIdentity.query(limit: 1).first.id

    identity = StarkInfra::BusinessIdentity.update(identity_id, tags: ['test', 'testing'])
    expect(identity.tags).must_equal(['test', 'testing'])
  end
end
