class UserCard
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  # 用户账户余额
  field :money_count,    :type => Integer

  field :user_id, :type => String
end
