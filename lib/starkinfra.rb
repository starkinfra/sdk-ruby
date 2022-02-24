# frozen_string_literal: true

require('starkbank')
require_relative('key')
require_relative('workspace/workspace')
require_relative('pixrequest/pixrequest')
require_relative('pixrequest/log')
require_relative('pixreversal/pixreversal')
require_relative('pixreversal/log')
require_relative('pixbalance/pixbalance')
require_relative('pixstatement/pixstatement')
require_relative('event/event')

# SDK to facilitate Ruby integrations with Stark Infra
module StarkInfra
  include StarkBank
  @user = nil
  @language = 'en-US'
  class << self; attr_accessor :user, :language; end
end
