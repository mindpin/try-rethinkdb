class Order
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  STATES = ['UNPAY', 'PAY_FAIL', 'PAY_SUCCESS']

  # 订单金额
  field :price_sum,    :type => Integer

  field :user_id, :type => String
  # 支付成功|支付失败
  field :state,   :type => String, :default => 'UNPAY',
    :validates => { :inclusion => { :in => STATES } }

  has_many :order_items

  # 向订单增加想要购买的书和数量
  def add_book(book, count)
    OrderItem.create!(
      :order => self,
      :book  => book,
      :count => count
    )
    self.price_sum = self.price_sum + book.price * count
    self.save!
  end

  # 订单支付
  def pay!
    self.order_items.each do |order_item|
      order_item.book.sell(order_item.count)
    end

    self.user.pay(self.price_sum)

    self.state = 'PAY_SUCCESS'
    self.save!
  rescue
    self.state = 'PAY_FAIL'
    self.save!
  end

  module UserMethods
    # 查询用户的订单
    def orders
      Order.where(:user_id => self.id.to_s)
    end

    # 创建订单
    def create_order
      Order.create!(:user_id => self.id.to_s)
    end
  end
end
