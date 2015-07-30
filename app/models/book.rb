class Book
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :name,        :type => String

  # 库存数量
  field :stock_count, :type => Integer

  # 价格
  field :price, :type => Integer

  # 减少 count 数量的库存
  def sell(count)
    raise '库存不足' if self.stock_count < count
    self.stock_count = self.stock_count - count
    self.save!
  end
end
