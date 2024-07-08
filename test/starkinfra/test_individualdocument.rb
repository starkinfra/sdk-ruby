# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IndividualDocument, '#IndividualDocument#') do
  it 'post' do
    identities = StarkInfra::IndividualIdentity.create([ExampleGenerator.individual_identity_example()])
    expect(identities.length).must_equal(1)
    expect(identities[0].id).wont_be_nil

    image = ExampleGenerator.individual_document_image("front")
    documents = StarkInfra::IndividualDocument.create([
      StarkInfra::IndividualDocument.new(
        type: 'identity-front',
        content: image,
        content_type: 'image/png',
        identity_id: identities[0].id
      )
    ])

    expect(documents[0].id).wont_be_nil

    image = ExampleGenerator.individual_document_image("back")
    documents = StarkInfra::IndividualDocument.create([
      StarkInfra::IndividualDocument.new(
        type: 'identity-back',
        content: image,
        content_type: 'image/png',
        identity_id: identities[0].id
      )
    ])

    expect(documents[0].id).wont_be_nil

    image = ExampleGenerator.individual_document_image("selfie")
    documents = StarkInfra::IndividualDocument.create([
      StarkInfra::IndividualDocument.new(
        type: 'selfie',
        content: image,
        content_type: 'image/png',
        identity_id: identities[0].id
      )
    ])

    expect(documents[0].id).wont_be_nil

    individual = StarkInfra::IndividualIdentity.update(
      identities[0].id, 
      status: 'processing'
    )

    expect(individual.status).must_equal('processing')
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      documents, cursor = StarkInfra::IndividualDocument.page(limit: 5, cursor: cursor)

      documents.each do |document|
        expect(ids).wont_include(document.id)
        ids << document.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    document = StarkInfra::IndividualDocument.query(limit: 1).to_a[0]

    get_document = StarkInfra::IndividualDocument.get(document.id)
    expect(document.id).must_equal(get_document.id)
  end

end
