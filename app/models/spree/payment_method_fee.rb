class Spree::PaymentMethodFee < ActiveRecord::Base
  belongs_to :payment_method, class_name: 'Spree::PaymentMethod'
  validates :currency, uniqueness: {scope: :payment_method_id}
end
