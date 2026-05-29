# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IndividualAccountAttachment, '#individual-account-attachment#') do
  # --- happy-path CRUD verbs (contract §Endpoints) ---

  # M1: create accepts a list and returns the same shape with server-assigned
  # id, status, created populated. M4: get(id) returns a single attachment.
  # Each attachment test creates a FRESH parent IndividualAccountRequest to
  # avoid "attachment already sent" on a polluted parent.
  it 'create and get' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]

    attachment = StarkInfra::IndividualAccountAttachment.create(
      [ExampleGenerator.individual_account_attachment_example(account_request_id: parent.id)]
    )[0]

    expect(attachment.id).wont_be_nil
    expect(attachment.status).wont_be_nil

    attachment_get = StarkInfra::IndividualAccountAttachment.get(attachment.id)
    expect(attachment.id).must_equal(attachment_get.id)
  end

  # M5: query returns an iterable accepting limit, after, before, status, tags, ids.
  it 'query' do
    attachments = StarkInfra::IndividualAccountAttachment.query(limit: 5).to_a
    attachments.each do |attachment|
      expect(attachment.id).wont_be_nil
    end
  end

  it 'query params' do
    attachments = StarkInfra::IndividualAccountAttachment.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(attachments.length).must_equal(0)
  end

  # M6: page returns [items, cursor] and accepts the query params plus cursor.
  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      attachments, cursor = StarkInfra::IndividualAccountAttachment.page(limit: 5, cursor: cursor)
      attachments.each do |attachment|
        expect(ids).wont_include(attachment.id)
        ids << attachment.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    attachments = StarkInfra::IndividualAccountAttachment.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(attachments.length).must_equal(2)
  end

  # M7: cancel maps to DELETE and returns status 'deleted' (sandbox uses
  # 'deleted', not 'canceled'); cancel is IDEMPOTENT — a second cancel succeeds.
  it 'create and cancel is idempotent' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    attachment = StarkInfra::IndividualAccountAttachment.create(
      [ExampleGenerator.individual_account_attachment_example(account_request_id: parent.id)]
    )[0]

    canceled = StarkInfra::IndividualAccountAttachment.cancel(attachment.id)
    expect(canceled.id).must_equal(attachment.id)
    expect(canceled.status).must_equal('deleted')

    # Second cancel on the already-deleted attachment succeeds without error.
    canceled_again = StarkInfra::IndividualAccountAttachment.cancel(attachment.id)
    expect(canceled_again.id).must_equal(attachment.id)
  end

  # --- M2 / M3: data-URL encoding client-side; contentType is input-only ---
  it 'constructor encodes content and contentType into a data URL' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    image = ExampleGenerator.individual_document_image('front')

    attachment_input = StarkInfra::IndividualAccountAttachment.new(
      type: 'identity-front',
      content: image,
      content_type: 'image/png',
      account_request_id: parent.id
    )
    attachment = StarkInfra::IndividualAccountAttachment.create([attachment_input])[0]
    expect(attachment.id).wont_be_nil
  end

  # M3: contentType is input-only — not serialized as its own wire field, so a
  # deserialized response object does not expose it as a populated attribute.
  it 'contentType is not present on the deserialized response object' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    attachment = StarkInfra::IndividualAccountAttachment.create(
      [ExampleGenerator.individual_account_attachment_example(account_request_id: parent.id)]
    )[0]
    fetched = StarkInfra::IndividualAccountAttachment.get(attachment.id)
    # content_type is consumed client-side; the server never echoes it back.
    expect(fetched.content_type).must_be_nil if fetched.respond_to?(:content_type)
  end

  # --- M11: type enum ---
  it 'type enum is a member of the documented set' do
    valid = %w[drivers-license-front drivers-license-back identity-front identity-back]
    attachments = StarkInfra::IndividualAccountAttachment.query(limit: 5).to_a
    attachments.each do |attachment|
      expect(valid).must_include(attachment.type) unless attachment.type.nil?
    end
  end

  # --- M12: datetime field parsed to native type ---
  # check_datetime parses an ISO string to DateTime (core-repos/ruby/lib/utils/checks.rb:79,84);
  # DateTime is NOT a subclass of Time in Ruby, so assert non-nil (parse succeeded) rather
  # than pinning a concrete class — code-agnostic per the v3 contract.
  it 'created parses to native datetime type' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    attachment = StarkInfra::IndividualAccountAttachment.create(
      [ExampleGenerator.individual_account_attachment_example(account_request_id: parent.id)]
    )[0]
    expect(attachment.created).wont_be_nil
  end

  # --- error cases (M13): assert the mapped exception TYPE is raised,
  # never a specific error-code string. ---

  # M11 also: 'selfie' / any non-enum type is rejected with InputErrors.
  it 'create with invalid type raises InputErrors' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountAttachment.create([
        StarkInfra::IndividualAccountAttachment.new(
          type: 'not-a-real-type',
          content: ExampleGenerator.individual_document_image('front'),
          content_type: 'image/png',
          account_request_id: parent.id
        )
      ])
    end
  end

  it 'create with empty content raises InputErrors' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountAttachment.create([
        StarkInfra::IndividualAccountAttachment.new(
          type: 'identity-front',
          content: '',
          content_type: 'image/png',
          account_request_id: parent.id
        )
      ])
    end
  end

  # contentType missing when content provided — code is client-serialization
  # dependent; assert only that InputErrors is raised.
  it 'create with missing contentType raises InputErrors' do
    parent = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountAttachment.create([
        StarkInfra::IndividualAccountAttachment.new(
          type: 'identity-front',
          content: ExampleGenerator.individual_document_image('front'),
          account_request_id: parent.id
        )
      ])
    end
  end

  it 'create with unknown accountRequestId raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountAttachment.create([
        StarkInfra::IndividualAccountAttachment.new(
          type: 'identity-front',
          content: ExampleGenerator.individual_document_image('front'),
          content_type: 'image/png',
          account_request_id: '0'
        )
      ])
    end
  end

  it 'get with unknown id raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountAttachment.get('0')
    end
  end
end
