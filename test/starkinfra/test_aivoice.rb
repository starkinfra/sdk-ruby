# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

module SharedVoice
  def self.audio
    return @audio if defined?(@audio)

    @audio = AiFixtures.speech_audio
  end

  def self.get
    return nil if audio.nil?

    @voice ||= StarkInfra::AiVoice.create(StarkInfra::AiVoice.new(audio: audio, name: AiFixtures.unique_name('sdk-ruby-voice')))
  end

  def self.created?
    !@voice.nil?
  end
end

Minitest.after_run do
  next unless SharedVoice.created?

  StarkInfra::AiVoice.delete(ids: [SharedVoice.get.id])
end

describe(StarkInfra::AiVoice, '#ai-voice#') do
  let(:voice) do
    shared = SharedVoice.get
    skip('the workspace has no finished speech to take an audio from') if shared.nil?
    shared
  end

  it 'create returns a processing voice' do
    expect(voice.id).wont_be_nil
    expect(voice.status).must_equal('processing')
    expect(voice.name).must_match(/\Asdk-ruby-voice/)
    expect(voice.created).must_be_kind_of(DateTime)
    expect(voice.audio).must_be_nil
  end

  it 'query lists the created voice without the audio' do
    listed = AiFixtures.eventually { StarkInfra::AiVoice.query.find { |entity| entity.id == voice.id } }
    expect(listed).wont_be_nil
    expect(listed.audio).must_be_nil
    expect(listed.errors).must_be_kind_of(Array)
  end

  it 'query with limit stops at the limit' do
    expect(StarkInfra::AiVoice.query(limit: 1).to_a.length).must_be(:<=, 1)
  end

  it 'page returns the voices and a cursor' do
    voices, cursor = StarkInfra::AiVoice.page(limit: 1)
    expect(voices.length).must_be(:<=, 1)
    expect(cursor.nil? || cursor.is_a?(String)).must_equal(true)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiVoice.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'delete returns the deleted voice' do
    extra = StarkInfra::AiVoice.create(StarkInfra::AiVoice.new(audio: SharedVoice.audio, name: AiFixtures.unique_name('sdk-ruby-voice')))
    deleted = StarkInfra::AiVoice.delete(ids: [extra.id])
    expect(deleted.map(&:id)).must_equal([extra.id])
  end
end

describe(StarkInfra::AiVoice, '#ai-voice at the http boundary#') do
  let(:voice_json) do
    {
      'id' => '5631671361601536', 'name' => 'Helena', 'description' => 'Calm voice', 'language' => 'portuguese',
      'gender' => 'female', 'status' => 'processing', 'errors' => [],
      'created' => '2026-10-01T14:28:24.566332+00:00', 'updated' => '2026-10-01T14:28:24.566342+00:00'
    }
  end

  it 'create sends the attributes that are set' do
    voice = StarkInfra::AiVoice.new(audio: 'SUQzBAAAAAAA', name: 'Helena', description: 'Calm voice', language: 'portuguese', gender: 'female')
    created = nil
    with_http_answer('voice' => voice_json) do |requests|
      created = StarkInfra::AiVoice.create(voice)
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
    with_http_answer('voice' => voice_json) do |requests|
      StarkInfra::AiVoice.create(StarkInfra::AiVoice.new(audio: 'SUQzBAAAAAAA'))
      expect(JSON.parse(requests[0].body)).must_equal('audio' => 'SUQzBAAAAAAA')
    end
  end

  it 'page returns the items and the cursor and sends limit and cursor' do
    with_http_answer('cursor' => 'next-page', 'voices' => [voice_json]) do |requests|
      voices, cursor = StarkInfra::AiVoice.page(cursor: 'current-page', limit: 1)
      expect(query_of(requests[0])).must_equal('cursor' => 'current-page', 'limit' => '1')
      expect(voices.map(&:id)).must_equal(%w[5631671361601536])
      expect(cursor).must_equal('next-page')
    end
  end

  it 'page returns a null cursor on the last page' do
    with_http_answer('cursor' => nil, 'voices' => [voice_json]) do
      _, cursor = StarkInfra::AiVoice.page
      expect(cursor).must_be_nil
    end
  end

  it 'query follows the cursor and honours the limit' do
    with_http_answers({ 'cursor' => 'next-page', 'voices' => [voice_json] }, { 'cursor' => nil, 'voices' => [voice_json] }) do |requests|
      expect(StarkInfra::AiVoice.query(limit: 150).to_a.length).must_equal(2)
      expect(query_of(requests[0])).must_equal('limit' => '100')
      expect(query_of(requests[1])).must_equal('limit' => '50', 'cursor' => 'next-page')
    end
  end

  it 'delete sends ids in the query string without a body' do
    deleted = nil
    with_http_answer('voices' => [voice_json]) do |requests|
      deleted = StarkInfra::AiVoice.delete(ids: %w[5631671361601536 5631671361601537])
      expect(requests[0].method).must_equal('DELETE')
      expect(requests[0].path).must_equal('/v2/ai-voice?ids=5631671361601536%2C5631671361601537')
      expect(requests[0].body.to_s).must_equal('')
    end
    expect(deleted.map(&:id)).must_equal(%w[5631671361601536])
  end
end
