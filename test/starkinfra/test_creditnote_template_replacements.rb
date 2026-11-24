# frozen_string_literal: true

gem('minitest')
gem('starkcore', '~> 0.2.2')
require('minitest/autorun')
require('json')
require('starkbank-ecdsa')
require('./lib/starkinfra')

# Offline: only Net::HTTP.start is replaced, so the real constructor, serialization and parsing run.
class FakeHttp
  attr_reader :requests

  def initialize(body)
    @body = body
    @requests = []
  end

  def request(req)
    @requests << req
    Struct.new(:code, :body).new('200', @body)
  end
end

describe(StarkInfra::CreditNote, '#template_replacements# (offline)') do
  let(:user) do
    StarkInfra::Project.new(
      environment: 'sandbox',
      id: '9999999999999999',
      private_key: EllipticCurve::PrivateKey.new.toPem
    )
  end

  def build_note(**extra)
    StarkInfra::CreditNote.new(
      template_id: '0123456789101112',
      name: 'Jamie Lannister',
      tax_id: '012.345.678-90',
      nominal_amount: 100_000,
      scheduled: '2022-04-28',
      invoices: [StarkInfra::Invoice.new(amount: 100_000, due: '2023-06-25')],
      payment: StarkInfra::Transfer.new(
        bank_code: '00000000', branch_code: '1234', account_number: '129340-1',
        tax_id: '012.345.678-90', name: 'Jamie Lannister'
      ),
      payment_type: 'transfer',
      signers: [StarkInfra::CreditSigner.new(name: 'Jamie Lannister', contact: 'a@b.com', method: 'link')],
      external_id: '1234',
      street_line_1: 'Rua ABC',
      street_line_2: 'Ap 123',
      district: 'Jardim Paulista',
      city: 'Sao Paulo',
      state_code: 'SP',
      zip_code: '01234-567',
      **extra
    )
  end

  # The API answers with the created note, so the response is the note's own JSON plus the extras.
  def post_and_capture(note, response_extras = {})
    response_note = StarkCore::Utils::API.api_json(note).merge('id' => '5656565656565656').merge(response_extras)
    http = FakeHttp.new(JSON.generate({ 'notes' => [response_note] }))
    original = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, **_opts, &block| block.call(http) }
    begin
      created = StarkInfra::CreditNote.create([note], user: user)
    ensure
      Net::HTTP.define_singleton_method(:start, original)
    end
    [JSON.parse(http.requests.first.body)['notes'].first, created.first]
  end

  it 'sends template_replacements as templateReplacements with snake_case keys cast to camelCase' do
    replacements = {
      'guarantor_name' => 'Jon Snow',
      :guarantor_tax_id => '012.345.678-90',
      'guarantor_address' => 'Av. Paulista, 200 - Bela Vista - Sao Paulo, SP'
    }
    sent, = post_and_capture(build_note(template_replacements: replacements))

    expect(sent['templateReplacements']).must_equal({
      'guarantorName' => 'Jon Snow',
      'guarantorTaxId' => '012.345.678-90',
      'guarantorAddress' => 'Av. Paulista, 200 - Bela Vista - Sao Paulo, SP'
    })
    expect(sent).wont_include('template_replacements')
  end

  it 'does not send nested keys with nil values' do
    sent, = post_and_capture(build_note(template_replacements: { 'guarantor_name' => 'Jon Snow', 'guarantor_address' => nil }))

    expect(sent['templateReplacements']).must_equal({ 'guarantorName' => 'Jon Snow' })
  end

  it 'omits templateReplacements when absent or nil' do
    sent, = post_and_capture(build_note)
    expect(sent).wont_include('templateReplacements')

    sent, = post_and_capture(build_note(template_replacements: nil))
    expect(sent).wont_include('templateReplacements')
  end

  it 'core serializes arbitrary instance variables of a SubResource (proof)' do
    free_form = Class.new(StarkCore::Utils::SubResource)
    resource = free_form.new
    resource.instance_variable_set('@guarantor_name', 'Jon Snow')
    resource.instance_variable_set('@guarantorName', 'Arya')
    resource.instance_variable_set('@empty_value', nil)

    expect(StarkCore::Utils::API.api_json(resource)).must_equal({ 'guarantorName' => 'Jon Snow', 'guarantorname' => 'Arya' })
  end

  it 'object and raw hash produce the same payload' do
    values = { 'guarantor_name' => 'Jon Snow', :guarantor_tax_id => '012.345.678-90', 'empty_value' => nil }
    from_hash, = post_and_capture(build_note(template_replacements: values))
    from_object, = post_and_capture(
      build_note(template_replacements: StarkInfra::CreditNote::TemplateReplacements.new(**values))
    )

    expect(from_object['templateReplacements']).must_equal(from_hash['templateReplacements'])
    expect(from_object['templateReplacements']).must_equal({
      'guarantorName' => 'Jon Snow',
      'guarantorTaxId' => '012.345.678-90'
    })
  end

  it 'converts a raw hash into TemplateReplacements and keeps an instance as is' do
    note = build_note(template_replacements: { 'guarantor_name' => 'Jon Snow' })
    expect(note.template_replacements).must_be_instance_of(StarkInfra::CreditNote::TemplateReplacements)

    replacements = StarkInfra::CreditNote::TemplateReplacements.new(guarantor_name: 'Jon Snow')
    expect(build_note(template_replacements: replacements).template_replacements).must_be_same_as(replacements)
  end

  it 'raises a clear error for any other type' do
    error = expect { build_note(template_replacements: ['guarantor_name']) }.must_raise(RuntimeError)
    expect(error.message).must_include('template_replacements must be')
  end

  it 'keeps every key returned by the API as a TemplateReplacements attribute' do
    returned = { 'templateReplacements' => { 'guarantorName' => 'Jon Snow', 'someKeyNobodyDeclared' => 'Y' } }
    _, parsed = post_and_capture(build_note, returned)

    replacements = parsed.template_replacements
    expect(replacements).must_be_instance_of(StarkInfra::CreditNote::TemplateReplacements)
    expect(replacements.instance_variables.sort).must_equal(%i[@guarantorName @someKeyNobodyDeclared])
    expect(replacements.instance_variable_get('@guarantorName')).must_equal('Jon Snow')
    expect(replacements.instance_variable_get('@someKeyNobodyDeclared')).must_equal('Y')
  end

  it 'sends keys that are not valid Ruby identifiers' do
    values = { 'guarantor-name' => 'Jon Snow', '1st_guarantor' => 'Arya', 'guarantor.tax id' => '012.345.678-90' }
    from_hash, = post_and_capture(build_note(template_replacements: values))
    from_object, = post_and_capture(
      build_note(template_replacements: StarkInfra::CreditNote::TemplateReplacements.new(**values))
    )

    expect(from_object['templateReplacements']).must_equal(from_hash['templateReplacements'])
    expect(from_object['templateReplacements'].values).must_equal(['Jon Snow', 'Arya', '012.345.678-90'])
  end

  it 'keeps response keys that are not valid Ruby identifiers instead of failing the whole parse' do
    returned = { 'templateReplacements' => { 'guarantor-name' => 'Jon', '1st_guarantor' => 'Arya', '' => 'blank' } }
    _, parsed = post_and_capture(build_note, returned)

    replacements = parsed.template_replacements
    expect(replacements).must_be_instance_of(StarkInfra::CreditNote::TemplateReplacements)
    expect(replacements.to_h).must_equal({ 'guarantor-name' => 'Jon', '1st_guarantor' => 'Arya', '' => 'blank' })
  end

  it 'reads the values through a public interface' do
    returned = { 'templateReplacements' => { 'guarantorName' => 'Jon Snow', 'guarantor-name' => 'dash' } }
    _, parsed = post_and_capture(build_note, returned)

    replacements = parsed.template_replacements
    expect(replacements['guarantorName']).must_equal('Jon Snow')
    expect(replacements[:guarantorName]).must_equal('Jon Snow')
    expect(replacements['guarantor-name']).must_equal('dash')
    expect(replacements['absent']).must_be_nil
    expect(replacements.to_h).must_equal({ 'guarantorName' => 'Jon Snow', 'guarantor-name' => 'dash' })
  end

  it 'pretty prints the values, including keys that are not valid Ruby identifiers' do
    require('pp')
    replacements = StarkInfra::CreditNote::TemplateReplacements.new(
      'guarantorName' => 'Jon Snow', 'guarantor-name' => 'dash'
    )

    printed = replacements.pretty_inspect
    expect(printed).must_include('Jon Snow')
    expect(printed).must_include('guarantor-name')
    expect(printed).must_include('dash')

    note_printed = build_note(template_replacements: replacements).pretty_inspect
    expect(note_printed).must_include('guarantor-name')
    expect(note_printed).must_include('Jon Snow')
  end

  it 'leaves template_replacements nil when the API does not return it' do
    _, parsed = post_and_capture(build_note)
    expect(parsed.template_replacements).must_be_nil
  end
end
