# frozen_string_literal: false

require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::CreditPreview, '#credit-preview#') do
  it 'create' do
    preview_sac = ExampleGenerator.preview_sac_example
    preview_price = ExampleGenerator.preview_price_example
    preview_american = ExampleGenerator.preview_american_example
    preview_bullet = ExampleGenerator.preview_bullet_example

    expected_preview_types = %w[credit-note credit-note credit-note credit-note]
    expected_note_types = %w[sac price american bullet]

    previews = [
      StarkInfra::CreditPreview.new(type: 'credit-note', credit: preview_sac),
      StarkInfra::CreditPreview.new(type: 'credit-note', credit: preview_price),
      StarkInfra::CreditPreview.new(type: 'credit-note', credit: preview_american),
      StarkInfra::CreditPreview.new(type: 'credit-note', credit: preview_bullet)
    ]

    preview_types = []
    note_types = []

    previews = StarkInfra::CreditPreview.create(previews)

    previews.each do |preview|
      assert !preview.nil?
      preview_types.append(preview.type)
      note_types.append(preview.credit.type)
    end

    expect(note_types).must_equal(expected_note_types)
    expect(preview_types).must_equal(expected_preview_types)
  end

  it 'create from hashmap' do
    preview = {
      'credit' => ExampleGenerator.hash_sac_example,
      'type' => 'credit-note'
    }

    previews = StarkInfra::CreditPreview.create([preview])

    previews.each do |preview|
      assert !preview.nil?
    end
  end
end

