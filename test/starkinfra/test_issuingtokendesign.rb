# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingTokenDesign, '#issuing-token-design#') do
  it 'query' do
    designs = StarkInfra::IssuingTokenDesign.query(limit: 5).to_a
    designs.each do |design|
      expect(design.id).wont_be_nil
    end
  end

  it 'query params' do
    designs = StarkInfra::IssuingTokenDesign.query(
      limit: 4,
      ids: %w[1 2 3]
    ).to_a
    expect(designs.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      designs, cursor = StarkInfra::IssuingTokenDesign.page(limit: 5, cursor: cursor)

      designs.each do |design|
        expect(ids).wont_include(design.id)
        ids << design.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    designs = StarkInfra::IssuingTokenDesign.page(
      limit: 4,
      ids: %w[1 2 3]
    ).to_a
    expect(designs.length).must_equal(2)
  end

  it 'query and get' do
    design = StarkInfra::IssuingTokenDesign.query(limit: 1).to_a[0]

    get_design = StarkInfra::IssuingTokenDesign.get(design.id)
    expect(design.id).must_equal(get_design.id)
  end

  it 'get exposes output fields' do
    design = StarkInfra::IssuingTokenDesign.query(limit: 1).to_a[0]

    design = StarkInfra::IssuingTokenDesign.get(design.id)
    expect(design.id).wont_be_nil
    expect(design.respond_to?(:name)).must_equal(true)
    expect(design.respond_to?(:created)).must_equal(true)
    expect(design.respond_to?(:updated)).must_equal(true)
  end

  it 'query and pdf' do
    design = StarkInfra::IssuingTokenDesign.query(limit: 1).to_a[0]

    pdf = StarkInfra::IssuingTokenDesign.pdf(design.id)
    expect(pdf.length).must_be(:>, 1000)
    File.binwrite('issuing_token_design.pdf', pdf)
  end
end
