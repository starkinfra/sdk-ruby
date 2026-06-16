# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::PixDispute, '#pix-dispute/event-registration#') do
  it 'resource constants resolve' do
    expect(defined?(StarkInfra::PixDispute)).must_equal('constant')
    expect(defined?(StarkInfra::PixDispute::Log)).must_equal('constant')
    expect(defined?(StarkInfra::PixDispute::Transaction)).must_equal('constant')
  end

  it 'resource hash is well formed' do
    resource = StarkInfra::PixDispute.resource
    expect(resource[:resource_name]).must_equal('PixDispute')
    expect(resource[:resource_maker]).wont_be_nil

    log_resource = StarkInfra::PixDispute::Log.resource
    expect(log_resource[:resource_name]).must_equal('PixDisputeLog')
    expect(log_resource[:resource_maker]).wont_be_nil
  end

  it 'pix-dispute subscription resolves to PixDispute::Log' do
    event = StarkInfra::Event.query(limit: 100).to_a.find do |candidate|
      candidate.subscription.to_s.start_with?('pix-dispute')
    end
    next if event.nil?

    expect(event.log).must_be_instance_of(StarkInfra::PixDispute::Log)
    expect(event.log.dispute.status).wont_be_nil
  end
end
