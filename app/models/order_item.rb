class OrderItem
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  belongs_to :order
  belongs_to :book
  # 购买数量
  field :count, :type => Integer
end
