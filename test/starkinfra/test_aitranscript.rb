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

describe(StarkInfra::AiTranscript, '#ai-transcript at the http boundary#') do
  let(:transcript_json) do
    {
      'id' => '5147403464212480',
      'text' => 'This is a short recording used to test the transcription service.',
      'status' => 'success', 'errors' => [],
      'created' => '2026-10-01T14:28:04.482326+00:00', 'updated' => '2026-10-01T14:28:05.752389+00:00'
    }
  end

  it 'create sends only the audio' do
    created = nil
    with_http_answer('transcript' => transcript_json) do |requests|
      created = StarkInfra::AiTranscript.create(StarkInfra::AiTranscript.new(audio: 'UklGRg=='))
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-transcript')
      expect(JSON.parse(requests[0].body)).must_equal('audio' => 'UklGRg==')
    end
    expect(created.text).must_equal('This is a short recording used to test the transcription service.')
    expect(created.status).must_equal('success')
    expect(created.created).must_be_kind_of(DateTime)
  end

  it 'page returns the items and the cursor and sends limit and cursor' do
    with_http_answer('cursor' => 'next-page', 'transcripts' => [transcript_json]) do |requests|
      items, cursor = StarkInfra::AiTranscript.page(cursor: 'current-page', limit: 1)
      expect(query_of(requests[0])).must_equal('cursor' => 'current-page', 'limit' => '1')
      expect(items.map(&:id)).must_equal(%w[5147403464212480])
      expect(cursor).must_equal('next-page')
    end
  end

  it 'page returns a null cursor on the last page' do
    with_http_answer('cursor' => nil, 'transcripts' => [transcript_json]) do
      _, cursor = StarkInfra::AiTranscript.page
      expect(cursor).must_be_nil
    end
  end

  it 'query follows the cursor and honours the limit' do
    with_http_answers({ 'cursor' => 'next-page', 'transcripts' => [transcript_json] }, { 'cursor' => nil, 'transcripts' => [transcript_json] }) do |requests|
      expect(StarkInfra::AiTranscript.query(limit: 150).to_a.length).must_equal(2)
      expect(query_of(requests[0])).must_equal('limit' => '100')
      expect(query_of(requests[1])).must_equal('limit' => '50', 'cursor' => 'next-page')
    end
  end

  it 'query without parameters sends no query string' do
    with_http_answer('cursor' => nil, 'transcripts' => [transcript_json]) do |requests|
      StarkInfra::AiTranscript.query.to_a
      expect(requests[0].path).must_equal('/v2/ai-transcript')
    end
  end
end
