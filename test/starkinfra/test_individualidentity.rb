# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IndividualIdentity, '#individual-identity#') do
  it 'query' do
    identities = StarkInfra::IndividualIdentity.query(limit: 100)

    identities.each do |identity|
      expect(identity.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      identities, cursor = StarkInfra::IndividualIdentity.page(limit: 5, cursor: cursor)

      identities.each do |identity|
        expect(ids).wont_include(identity.id)
        ids << identity.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    identity = StarkInfra::IndividualIdentity.query(limit: 1).first

    identity = StarkInfra::IndividualIdentity.get(identity.id)
    expect(identity.id).wont_be_nil
  end

  it 'create and delete' do
    identity_id = StarkInfra::IndividualIdentity.create([ExampleGenerator.individual_identity_example()]).first.id

    identity = StarkInfra::IndividualIdentity.cancel(identity_id)
    expect(identity.status).must_equal('canceled')
  end
end
