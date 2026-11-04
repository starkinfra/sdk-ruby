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
    expect(StarkInfra::AiSpeech.get(speech.id, expand: %w[voiceName]).voice_name).wont_be_empty
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
    found = AiFixtures.eventually { StarkInfra::AiSpeech.query(expand: %w[voiceName]).find { |entity| entity.id == speech.id } }
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
