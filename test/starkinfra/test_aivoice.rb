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
