class UserCard
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  # 用户账户余额
  field :money_count,    :type => Integer

  field :user_id, :type => String

  module UserMethods
    # 查询用户账户余额
    def money_count
      user_card = UserCard.where(:user_id => self.id.to_s)
      return 0 if user_card.blank?
      user_card.money_count
    end

    # 用户支付 money_count 金额
    def pay(money_count)
      raise '用户余额不足' if self.money_count < money_count

      user_card = UserCard.where(:user_id => self.id.to_s)
      user_card.money_count = user_card.money_count - money_count
      user_card.save!
    end

  end
end
