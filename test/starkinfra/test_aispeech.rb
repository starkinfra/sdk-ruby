# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

module SharedSpeech
  def self.get
    return @speech if defined?(@speech)

    ready = StarkInfra::AiVoice.query(limit: 100).find { |voice| voice.status == 'success' }
    @speech = ready.nil? ? nil : StarkInfra::AiSpeech.create(StarkInfra::AiSpeech.new(voice_id: ready.id, text: 'Short test.'))
  end
end

describe(StarkInfra::AiSpeech, '#ai-speech#') do
  let(:speech) do
    shared = SharedSpeech.get
    skip('the workspace has no ready voice to speak with') if shared.nil?
    shared
  end

  it 'create returns the synthesized audio' do
    expect(speech.id).wont_be_nil
    expect(speech.status).must_equal('success')
    expect(speech.text).must_equal('Short test.')
    expect(speech.audio).wont_be_empty
    expect(speech.created).must_be_kind_of(DateTime)
  end

  it 'get returns the audio' do
    fetched = StarkInfra::AiSpeech.get(speech.id)
    expect(fetched.id).must_equal(speech.id)
    expect(fetched.audio).wont_be_empty
  end

  it 'get expands the voice name' do
    expect(StarkInfra::AiSpeech.get(speech.id, expand: %w[voice_name]).voice_name).wont_be_empty
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiSpeech.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'query leaves the audio out' do
    StarkInfra::AiSpeech.query(limit: 5).each do |entity|
      expect(entity.id).wont_be_nil
      expect(entity.audio).must_be_nil
      expect(entity.created).must_be_kind_of(DateTime)
    end
  end

  it 'query with limit stops at the limit' do
    expect(StarkInfra::AiSpeech.query(limit: 1).to_a.length).must_be(:<=, 1)
  end

  it 'query with expand brings the voice name' do
    found = AiFixtures.eventually { StarkInfra::AiSpeech.query(expand: %w[voice_name]).find { |entity| entity.id == speech.id } }
    expect(found.voice_name).wont_be_empty
  end

  it 'page returns the speeches and a cursor' do
    speeches, cursor = StarkInfra::AiSpeech.page(limit: 1)
    expect(speeches.length).must_be(:<=, 1)
    expect(cursor.nil? || cursor.is_a?(String)).must_equal(true)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiSpeech.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end
end

describe(StarkInfra::AiSpeech, '#ai-speech at the http boundary#') do
  let(:speech_json) do
    {
      'id' => '5646488461901824', 'voiceId' => '5632499082330112', 'text' => 'Short test.', 'status' => 'success',
      'audio' => 'SUQzBAAAAAAA', 'errors' => [], 'created' => '2026-10-01T14:28:06.942491+00:00',
      'updated' => '2026-10-01T14:28:07.605185+00:00'
    }
  end

  it 'create sends only the voice and the text' do
    created = nil
    with_http_answer('speech' => speech_json) do |requests|
      created = StarkInfra::AiSpeech.create(StarkInfra::AiSpeech.new(voice_id: '5632499082330112', text: 'Short test.'))
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-speech')
      expect(JSON.parse(requests[0].body)).must_equal('voiceId' => '5632499082330112', 'text' => 'Short test.')
    end
    expect(created.voice_id).must_equal('5632499082330112')
    expect(created.audio).must_equal('SUQzBAAAAAAA')
    expect(created.updated).must_be_kind_of(DateTime)
  end

  it 'get reads the speech key and sends expand in camel case' do
    with_http_answer('speech' => speech_json) do |requests|
      fetched = StarkInfra::AiSpeech.get('5646488461901824', expand: %w[voice_name])
      expect(requests[0].path).must_equal('/v2/ai-speech/5646488461901824?expand=voiceName')
      expect(fetched.text).must_equal('Short test.')
    end
  end

  it 'page reads the speeches key and returns the items and the cursor' do
    with_http_answer('cursor' => 'next-page', 'speeches' => [speech_json]) do |requests|
      items, cursor = StarkInfra::AiSpeech.page(cursor: 'current-page', limit: 1, expand: %w[voice_name])
      expect(query_of(requests[0])).must_equal('cursor' => 'current-page', 'limit' => '1', 'expand' => 'voiceName')
      expect(items.map(&:id)).must_equal(%w[5646488461901824])
      expect(cursor).must_equal('next-page')
    end
  end

  it 'page returns a null cursor on the last page' do
    with_http_answer('cursor' => nil, 'speeches' => [speech_json]) do |requests|
      _, cursor = StarkInfra::AiSpeech.page
      expect(cursor).must_be_nil
      expect(requests[0].path).must_equal('/v2/ai-speech')
    end
  end

  it 'query follows the cursor through an empty page' do
    pages = [
      { 'cursor' => 'second', 'speeches' => [] },
      { 'cursor' => nil, 'speeches' => [speech_json] }
    ]
    with_http_answers(*pages) do |requests|
      found = StarkInfra::AiSpeech.query(expand: %w[voice_name]).to_a
      expect(found.map(&:id)).must_equal(%w[5646488461901824])
      expect(query_of(requests[1])).must_equal('expand' => 'voiceName', 'cursor' => 'second')
    end
  end

  it 'query honours the limit across pages' do
    hundred = Array.new(100) { |index| speech_json.merge('id' => index.to_s) }
    fifty = Array.new(50) { |index| speech_json.merge('id' => "b#{index}") }
    with_http_answers({ 'cursor' => 'second', 'speeches' => hundred }, { 'cursor' => 'third', 'speeches' => fifty }) do |requests|
      expect(StarkInfra::AiSpeech.query(limit: 150).to_a.length).must_equal(150)
      expect(requests.length).must_equal(2)
      expect(query_of(requests[0])).must_equal('limit' => '100')
      expect(query_of(requests[1])).must_equal('limit' => '50', 'cursor' => 'second')
    end
  end
end
