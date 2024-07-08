# frozen_string_literal: false

require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::BrcodePreview, '#brcode-preview#') do
  it 'create' do
    static_brcodes = StarkInfra::StaticBrcode.query(limit: 2).to_a
    dynamic_brcodes = StarkInfra::DynamicBrcode.query(limit: 2).to_a

    brcodes = static_brcodes.concat(dynamic_brcodes)

    previews = StarkInfra::BrcodePreview.create(
      [StarkInfra::BrcodePreview.new(id: brcodes[0].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[1].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[2].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[3].id, payer_id: "20.018.183/0001-80")]
    )

    index = 0
    previews.each do |preview|
      assert !preview.nil?
      expect(preview.id).must_equal(brcodes[index].id)
      index += 1
    end
  end
end
