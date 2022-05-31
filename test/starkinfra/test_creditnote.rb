# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../end_to_end_id')
require_relative('../user')

describe(StarkInfra::CreditNote, '#credit-note#') do
  it 'query params' do
    notes = StarkInfra::CreditNote.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(notes.length).must_equal(0)
  end

  it 'page params' do
    notes, _ = StarkInfra::CreditNote.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(notes.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    notes = nil
    (0..1).step(1) do
      notes, cursor = StarkInfra::CreditNote.page(limit: 5, cursor: cursor)
      notes.each do |note|
        expect(ids).wont_include(note.id)
        ids << note.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    notes = StarkInfra::CreditNote.query(limit: 10).to_a
    expect(notes.length).must_equal(10)
    notes_ids_expected = []
    notes.each do |note|
      notes_ids_expected.push(note.id)
    end

    notes_ids_result = []
    StarkInfra::CreditNote.query(limit: 10, ids: notes_ids_expected).each do |note|
      notes_ids_result.push(note.id)
    end

    notes_ids_expected = notes_ids_expected.sort
    notes_ids_result = notes_ids_result.sort
    expect(notes_ids_expected).must_equal(notes_ids_result)
  end

  it 'create and get' do
    credit_note = ExampleGenerator.creditnote_example
    note = StarkInfra::CreditNote.create([credit_note])[0]
    note_get = StarkInfra::CreditNote.get(note.id)
    expect(note.id).must_equal(note_get.id)
    note_canceled = StarkInfra::CreditNote.cancel(note_get.id)
    expect(note_canceled.status).must_equal('canceled')
  end
end
