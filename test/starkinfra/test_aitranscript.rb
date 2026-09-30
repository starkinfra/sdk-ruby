# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiTranscript, '#ai-transcript#') do
  it 'query returns transcripts without the audio' do
    StarkInfra::AiTranscript.query.first(5).each do |transcript|
      expect(transcript.id).wont_be_nil
      expect(transcript.audio).must_be_nil
      expect(transcript.created).must_be_kind_of(DateTime)
    end
  end
end

# A transcript cannot be deleted and every creation leaves one behind, so creating is checked at the HTTP boundary.
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
    returned = StarkInfra::AiTranscript.new(audio: 'UklGRg==', id: '5147403464212480', text: 'old', status: 'success')
    created = nil
    with_http_answer('transcript' => transcript_json) do |requests|
      created = StarkInfra::AiTranscript.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-transcript')
      expect(JSON.parse(requests[0].body)).must_equal('audio' => 'UklGRg==')
    end
    expect(created.text).must_equal('This is a short recording used to test the transcription service.')
    expect(created.status).must_equal('success')
    expect(created.created).must_be_kind_of(DateTime)
  end

  it 'query reads the transcripts key and sends no parameters' do
    with_http_answer('transcripts' => [transcript_json]) do |requests|
      found = StarkInfra::AiTranscript.query.to_a
      expect(requests[0].path).must_equal('/v2/ai-transcript')
      expect(found.map(&:id)).must_equal(%w[5147403464212480])
    end
  end
end
