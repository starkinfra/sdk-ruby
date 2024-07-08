# frozen_string_literal: false

require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::StaticBrcode, '#static-brcode#') do
  it 'query' do
    previews = StarkInfra::StaticBrcode.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      tags: %w[tony stark]
    ).to_a

    previews.each do |preview|
      expect(previews.length).must_equal(4)
      assert !preview.nil?
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      previews, cursor = StarkInfra::StaticBrcode.page(
        limit: 5,
        cursor: cursor,
        after: '2022-01-01',
        before: '2022-02-01',
        tags: %w[tony stark]
      )

      previews.each do |preview|
        expect(ids).wont_include(preview.id)
        ids << preview.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'get' do
    brcodes = StarkInfra::StaticBrcode.query(limit: 2).to_a

    brcodes.each do |brcode|
      assert !brcode.nil?
      brcode = StarkInfra::StaticBrcode.get(brcode.uuid)
      assert !brcode.nil?
    end
  end

  it 'create' do
    preview_brcode = ExampleGenerator.staticbrcode_example

    previews = StarkInfra::StaticBrcode.create([preview_brcode])
    previews.each do |preview|
      assert !preview.nil?
    end
  end
end
