# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixDirector, '#pix-director#') do
  it 'create' do
    pix_director = ExampleGenerator.pixdirector_example
    director = StarkInfra::PixDirector.create(pix_director)
    expect(director.id).wont_be_nil
  end
end
