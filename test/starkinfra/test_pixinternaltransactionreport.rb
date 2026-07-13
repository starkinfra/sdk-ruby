# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

bank_code = BankCode.bank_code
describe(StarkInfra::PixInternalTransactionReport, '#pix-internal-transaction-report#') do
  it 'query params' do
    reports = StarkInfra::PixInternalTransactionReport.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[success],
      ids: %w[1 2 3]
    ).to_a
    expect(reports.length).must_equal(0)
  end

  it 'query' do
    reports = StarkInfra::PixInternalTransactionReport.query(limit: 10).to_a
    expect(reports.length).must_equal(10)
    reports_ids_expected = []
    reports.each do |report|
      reports_ids_expected.push(report.id)
    end

    reports_ids_result = []
    StarkInfra::PixInternalTransactionReport.query(limit: 10, ids: reports_ids_expected).each do |report|
      reports_ids_result.push(report.id)
    end

    reports_ids_expected = reports_ids_expected.sort
    reports_ids_result = reports_ids_result.sort
    expect(reports_ids_expected).must_equal(reports_ids_result)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      reports, cursor = StarkInfra::PixInternalTransactionReport.page(limit: 5, cursor: cursor)
      reports.each do |report|
        expect(ids).wont_include(report.id)
        ids << report.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'create and get' do
    report_example = ExampleGenerator.pixinternaltransactionreport_example(bank_code)
    report = StarkInfra::PixInternalTransactionReport.create([report_example])[0]

    report_get = StarkInfra::PixInternalTransactionReport.get(report.id)
    expect(report.id).must_equal(report_get.id)
  end

  it 'create reversal and get' do
    report_example = ExampleGenerator.pixinternaltransactionreport_reversal_example(bank_code)
    report = StarkInfra::PixInternalTransactionReport.create([report_example])[0]

    report_get = StarkInfra::PixInternalTransactionReport.get(report.id)
    expect(report.id).must_equal(report_get.id)
    expect(report_get.reference_type).must_equal('reversal')
    expect(report_get.return_id).wont_be_nil
  end

  it 'create populates output-only fields' do
    report_example = ExampleGenerator.pixinternaltransactionreport_example(bank_code)
    report = StarkInfra::PixInternalTransactionReport.create([report_example])[0]

    expect(report.id).wont_be_nil
    expect(report.status).wont_be_nil
  end

  it 'create parses datetime fields' do
    report_example = ExampleGenerator.pixinternaltransactionreport_example(bank_code)
    report = StarkInfra::PixInternalTransactionReport.create([report_example])[0]

    expect(report.created).wont_be_nil
    expect(report.updated).wont_be_nil
  end
end
