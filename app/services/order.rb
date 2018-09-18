class Order
  include ActionView::Helpers::NumberHelper

  def initialize(amount, fee)
    @amount = amount.to_i
    @fee = fee.to_i
  end

  attr_reader :amount, :fee

  def amount_to_currency
    to_currency(amount)
  end

  def fee_to_currency
    to_currency(fee)
  end

  def total
    amount + fee
  end

  def total_to_currency
    to_currency(total)
  end

  private

    def to_currency(num)
      number_to_currency(num.to_d / 100, unit: '£')
    end
end
