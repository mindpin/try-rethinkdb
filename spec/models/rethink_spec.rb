# THREADS_COUNT = 40
# LOOPS_COUNT = 40

# TOTAL_COUNT = THREADS_COUNT * LOOPS_COUNT

# 多线程并发执行
def concurrent(threads_count, loop_count, &block)
  threads = []

  threads_count.times do
    threads.push Thread.new {
      loop_count.times do
        yield
        sleep rand(10) / 100.0
      end
    }
  end

  threads.each {|t| t.join}
end

def clean_data
  Book.destroy_all
  User.destroy_all
end

describe 'RethinkDB Test' do
  describe "单模型访问测试" do
    # 目前是假想代码，需要替换成实际代码

    before {
      clean_data
      Book.create({:stock_count => 40 * 40})

      @tc = 40
      @lc = 40
      @total = @tc * @lc
    }

    it "并发减少一本书的库存" do
      concurrent(@tc, @lc) do
        book = Book.first
        book.sell(1)
      end

      expect(Book.first.stock_count).to eq 0
    end

    it "库存不可低于 0" do
      concurrent(@tc, @lc) do
        begin
          book = Book.first
          book.sell(2)
        rescue
        end
      end

      expect(Book.first.stock_count).to eq 0
    end
  end

  describe "多模型访问测试" do
    describe "一本书" do
      before {
        clean_data

        100.times do |i|
          user = User.create({:email => "a#{i}@a.com"})
          user.chong_zhi(10000)
        end

        @tc = 10
        @lc = 10
        @total = @tc * @lc

        Book.create({:stock_count => @total, :price => 1})
      }

      it "多个用户买一本书" do
        orders = []

        concurrent(@tc, @lc) do
          # 每次随机一个用户下订单
          user = User.limit(1).skip(rand(100)).first
          book = Book.first

          order = user.create_order
          order.add_book book, 1

          # 以 90% 的比率每次随机支付一个订单
          r = rand(100)
          if r > 10
            # no_paid_orders = Order.where(:state => 'UNPAY').all
            # no_paid_order = no_paid_orders[rand(no_paid_orders.length)]
            # no_paid_order.pay!
            Order.where(:state => 'UNPAY').sample(1).first.pay!
          end
        end

        # 总订单数
        expect(Order.count).to eq @total

        # 总支付数 + 库存剩余数 = @total
        paid_count = Order.where(:state => 'PAY_SUCCESS').count
        expect(paid_count).to be < @total
        expect(paid_count + Book.first.stock_count).to eq @total
      end

    #   it "订单防止重复支付测试" do
    #     orders = []

    #     concurrent do
    #       # 每次随机一个用户下订单
    #       user = @users[rand(100)]
    #       order = Order.new
    #       order.book = @book
    #       order.user = user
    #       order.paid = false
    #       order.count = 1
    #       # order.save
    #       orders.push order

    #       # 每次随机支付一个订单
    #       no_paid_order = orders[rand(orders.length)]
    #       no_paid_order.pay
    #     end

    #     # 总订单数 2000
    #     expect(orders.length).to eq 2000

    #     # 总支付数 + 库存剩余数 = 2000
    #     paid_count = orders.count {|o| o.paid == true}
    #     expect(paid_count + @book.count).to eq 2000
    #   end
    end

    # describe "多本书" do
    #   before {
    #     @books = []
    #     @total = 0
    #     10.times do 
    #       book = Book.new
    #       book.count = rand(2000)
    #       @total += book.count
    #       @books.push book
    #     end
    #   }

    #   it "多个用户买多本书" do
    #     orders = []

    #     concurrent do
    #       book = @books[rand(@books.length)]
    #       user = @users[rand(100)]
    #       count = rand(5) + 1

    #       order = Order.new
    #       order.book = book
    #       order.user = user
    #       order.paid = false
    #       order.count = count
    #       # order.save
    #       orders.push order

    #       # 每次随机支付一个订单
    #       no_paid_order = orders[rand(orders.length)]
    #       no_paid_order.pay
    #     end

    #     # 总订单数 2000
    #     expect(orders.length).to eq 2000

    #     # 总支付数 + 库存剩余数 = total
    #     paid_orders = orders.select {|o| o.paid == true}
    #     paid_count = paid_orders.map {|o| o.count}.sum
    #     book_count = @books.map {|b| b.count}.sum

    #     expect(paid_count + book_count).to eq @total
    #   end
    # end
  end
end