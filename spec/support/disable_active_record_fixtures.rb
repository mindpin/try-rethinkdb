# http://stackoverflow.com/questions/27294077/rspec-with-mongoid-devise-database-cleaner-activerecordconnectionnotestabl
module ActiveRecord::TestFixtures
  def before_setup
    super
  end

  def after_teardown
    super
  end
end
