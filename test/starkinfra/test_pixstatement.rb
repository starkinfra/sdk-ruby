# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixStatement, '#pix-statement#') do
  it 'query' do
    statements = StarkInfra::PixStatement.query(limit: 10).to_a
    expect(statements.length).must_equal(10)
    statements.each do |statement|
      expect(statement.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    statements = nil
    (0..1).step(1) do
      statements, cursor = StarkInfra::PixStatement.page(limit: 5, cursor: cursor)
      statements.each do |statement|
        expect(ids).wont_include(statement.id)
        ids << statement.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    statements = StarkInfra::PixStatement.query(limit: 10).to_a
    expect(statements.length).must_equal(10)
    statements_ids_expected = []
    statements.each do |statement|
      statements_ids_expected.push(statement.id)
    end

    statements_ids_result = []
    StarkInfra::PixStatement.query(limit: 10, ids: statements_ids_expected).each do |statement|
      statements_ids_result.push(statement.id)
    end

    statements_ids_expected = statements_ids_expected.sort
    statements_ids_result = statements_ids_result.sort
    expect(statements_ids_expected).must_equal(statements_ids_result)
  end

  it 'create' do
    statement = StarkInfra::PixStatement.create(ExampleGenerator.pixstatement_example)
    get_statement = StarkInfra::PixStatement.get(statement.id)
    expect(statement.id).must_equal(get_statement.id)
    csv = StarkInfra::PixStatement.csv(statement.id)
    File.binwrite('statement.zip', csv)
  end

  it 'query params' do
    statement = StarkInfra::PixStatement.query(
      limit: 1,
      ids: ['1']
    ).to_a[0]
    expect(statement.nil?)
  end

  it 'page params' do
    statement = StarkInfra::PixStatement.page(
      limit: 1,
      ids: ['1']
    ).to_a[0]
    expect(statement.nil?)
  end
end
