# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiVoice, '#ai-voice#') do
  it 'query returns voices with their attributes' do
    StarkInfra::AiVoice.query.first(5).each do |voice|
      expect(voice.id).wont_be_nil
      expect(%w[processing success failed]).must_include(voice.status)
      expect(voice.created).must_be_kind_of(DateTime)
      expect(voice.audio).must_be_nil
    end
  end
end

# A voice cannot be deleted and every creation leaves one behind, so creating and deleting are checked at the
# HTTP boundary. Only Net::HTTP.start is replaced.
describe(StarkInfra::AiVoice, '#ai-voice at the http boundary#') do
  let(:voice_body) do
    {
      'voice' => {
        'id' => '5631671361601536', 'name' => 'Helena', 'description' => 'Calm voice', 'language' => 'portuguese',
        'gender' => 'female', 'status' => 'processing', 'errors' => [],
        'created' => '2026-10-01T14:28:24.566332+00:00', 'updated' => '2026-10-01T14:28:24.566342+00:00'
      }
    }
  end

  it 'create sends only the creatable fields' do
    returned = StarkInfra::AiVoice.new(
      audio: 'SUQzBAAAAAAA', name: 'Helena', description: 'Calm voice', language: 'portuguese', gender: 'female',
      id: '5631671361601536', status: 'success', errors: [], created: '2026-10-01T14:28:24+00:00',
      updated: '2026-10-01T14:28:24+00:00'
    )
    created = nil
    with_http_answer(voice_body) do |requests|
      created = StarkInfra::AiVoice.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-voice')
      expect(JSON.parse(requests[0].body)).must_equal(
        'audio' => 'SUQzBAAAAAAA', 'name' => 'Helena', 'description' => 'Calm voice', 'language' => 'portuguese',
        'gender' => 'female'
      )
    end
    expect(created.id).must_equal('5631671361601536')
    expect(created.status).must_equal('processing')
    expect(created.errors).must_equal([])
    expect(created.created).must_be_kind_of(DateTime)
  end

  it 'create drops absent fields' do
    with_http_answer(voice_body) do |requests|
      StarkInfra::AiVoice.create(StarkInfra::AiVoice.new(audio: 'SUQzBAAAAAAA'))
      expect(JSON.parse(requests[0].body)).must_equal('audio' => 'SUQzBAAAAAAA')
    end
  end

  it 'query reads the voices key and sends no parameters' do
    with_http_answer('voices' => [voice_body['voice']]) do |requests|
      found = StarkInfra::AiVoice.query.to_a
      expect(requests[0].method).must_equal('GET')
      expect(requests[0].path).must_equal('/v2/ai-voice')
      expect(found.map(&:id)).must_equal(%w[5631671361601536])
    end
  end

  it 'delete sends ids in the query string without a body' do
    deleted = nil
    with_http_answer('voices' => [voice_body['voice']]) do |requests|
      deleted = StarkInfra::AiVoice.delete(ids: %w[5631671361601536 5631671361601537])
      expect(requests[0].method).must_equal('DELETE')
      expect(requests[0].path).must_equal('/v2/ai-voice?ids=5631671361601536%2C5631671361601537')
      expect(requests[0].body.to_s).must_equal('')
    end
    expect(deleted.map(&:id)).must_equal(%w[5631671361601536])
  end
end
