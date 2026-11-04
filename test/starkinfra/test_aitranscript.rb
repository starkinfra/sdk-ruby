# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiTranscript, '#ai-transcript#') do
  let(:audio) do
    found = AiFixtures.speech_audio
    skip('the workspace has no finished speech to take an audio from') if found.nil?
    found
  end

  it 'create transcribes the audio' do
    created = StarkInfra::AiTranscript.create(StarkInfra::AiTranscript.new(audio: audio))
    expect(created.id).wont_be_nil
    expect(%w[processing success failed]).must_include(created.status)
    expect(created.created).must_be_kind_of(DateTime)
  end

  it 'query returns transcripts without the audio' do
    StarkInfra::AiTranscript.query(limit: 5).each do |transcript|
      expect(transcript.id).wont_be_nil
      expect(transcript.audio).must_be_nil
      expect(transcript.created).must_be_kind_of(DateTime)
    end
  end

  it 'query with limit stops at the limit' do
    expect(StarkInfra::AiTranscript.query(limit: 1).to_a.length).must_be(:<=, 1)
  end

  it 'page returns the transcripts and a cursor' do
    transcripts, cursor = StarkInfra::AiTranscript.page(limit: 1)
    expect(transcripts.length).must_be(:<=, 1)
    expect(cursor.nil? || cursor.is_a?(String)).must_equal(true)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiTranscript.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end
end
