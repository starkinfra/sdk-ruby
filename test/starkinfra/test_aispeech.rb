# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

def finished_speech
  StarkInfra::AiSpeech.query(fields: %w[id status]).find { |speech| speech.status == 'success' }
end

describe(StarkInfra::AiSpeech, '#ai-speech#') do
  it 'query leaves the audio out' do
    StarkInfra::AiSpeech.query.first(5).each do |speech|
      expect(speech.id).wont_be_nil
      expect(speech.audio).must_be_nil
      expect(speech.created).must_be_kind_of(DateTime)
    end
  end

  it 'query fields keep only what was asked' do
    StarkInfra::AiSpeech.query(fields: %w[id status]).first(5).each do |speech|
      expect(speech.id).wont_be_nil
      expect(speech.text).must_be_nil
    end
  end

  it 'get returns the audio' do
    speech = finished_speech
    skip('the workspace has no finished speech to read') if speech.nil?

    fetched = StarkInfra::AiSpeech.get(speech.id)
    expect(fetched.id).must_equal(speech.id)
    expect(fetched.audio).wont_be_empty
  end

  it 'get expands the voice name' do
    speech = finished_speech
    skip('the workspace has no finished speech to read') if speech.nil?

    fetched = StarkInfra::AiSpeech.get(speech.id, fields: %w[id voice_name], expand: %w[voice_name])
    expect(fetched.voice_name).wont_be_empty
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiSpeech.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end
end

# A speech cannot be deleted and every creation leaves one behind, so creating is checked at the HTTP boundary.
describe(StarkInfra::AiSpeech, '#ai-speech at the http boundary#') do
  let(:speech_json) do
    {
      'id' => '5646488461901824', 'voiceId' => '5632499082330112', 'text' => 'Short test.', 'status' => 'success',
      'audio' => 'SUQzBAAAAAAA', 'errors' => [], 'created' => '2026-10-01T14:28:06.942491+00:00',
      'updated' => '2026-10-01T14:28:07.605185+00:00'
    }
  end

  it 'create sends only the creatable fields' do
    returned = StarkInfra::AiSpeech.new(
      voice_id: '5632499082330112', text: 'Short test.', id: '5646488461901824', status: 'success',
      audio: 'SUQzBAAAAAAA', voice_name: 'Fakas', errors: []
    )
    created = nil
    with_http_answer('speech' => speech_json) do |requests|
      created = StarkInfra::AiSpeech.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-speech')
      expect(JSON.parse(requests[0].body)).must_equal('voiceId' => '5632499082330112', 'text' => 'Short test.')
    end
    expect(created.voice_id).must_equal('5632499082330112')
    expect(created.audio).must_equal('SUQzBAAAAAAA')
    expect(created.updated).must_be_kind_of(DateTime)
  end

  it 'query reads the speeches key and sends fields and expand in camel case' do
    with_http_answer('speeches' => [speech_json]) do |requests|
      found = StarkInfra::AiSpeech.query(fields: %w[id voice_name], expand: %w[voice_name]).to_a
      expect(found.map(&:id)).must_equal(%w[5646488461901824])
      expect(requests[0].path).must_equal('/v2/ai-speech?fields=id%2CvoiceName&expand=voiceName')
    end
  end

  it 'query without parameters sends no query string' do
    with_http_answer('speeches' => []) do |requests|
      StarkInfra::AiSpeech.query.to_a
      expect(requests[0].path).must_equal('/v2/ai-speech')
    end
  end

  it 'get reads the speech key' do
    with_http_answer('speech' => speech_json) do |requests|
      fetched = StarkInfra::AiSpeech.get('5646488461901824', fields: %w[id audio])
      expect(requests[0].path).must_equal('/v2/ai-speech/5646488461901824?fields=id%2Caudio')
      expect(fetched.text).must_equal('Short test.')
    end
  end
end
