# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::BusinessAttachment, '#BusinessAttachment#') do
  it 'create' do
    business_identity_id = StarkInfra::BusinessIdentity.create([ExampleGenerator.business_identity_example()]).first.id

    image = ExampleGenerator.individual_document_image("front")
    attachments = StarkInfra::BusinessAttachment.create([
      StarkInfra::BusinessAttachment.new(
        name: 'articles-of-incorporation.png',
        content: image,
        content_type: 'image/png',
        business_identity_id: business_identity_id
      )
    ])

    expect(attachments[0].id).wont_be_nil
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      attachments, cursor = StarkInfra::BusinessAttachment.page(limit: 5, cursor: cursor)

      attachments.each do |attachment|
        expect(ids).wont_include(attachment.id)
        ids << attachment.id
      end
      break if cursor.nil?
    end
  end

  it 'query and get' do
    attachment = StarkInfra::BusinessAttachment.query(limit: 1).to_a[0]

    get_attachment = StarkInfra::BusinessAttachment.get(attachment.id, expand: ['content'])
    expect(attachment.id).must_equal(get_attachment.id)
  end

end
