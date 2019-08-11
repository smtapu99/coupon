module CurrencyHelper

  def currency_symbol currency

    return if currency.blank?

    currency_hash = {:EUR => '€', :USD => '$', :DOL => '$'}

    if currency_hash.key?(currency.to_sym)
      currency_symbol = currency_hash[currency.to_sym]
    else
      currency_symbol = currency
    end

    currency_symbol
  end

end
