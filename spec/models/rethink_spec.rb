def concurrent(&block)
  threads = []

  100.times do
    threads.push Thread.new {
      20.times do
        yield
        sleep rand(10) / 100.0
      end
    }
  end

  threads.each {|t| t.join}
end

Book = Struct.new(:count) do
  # 减少库存
  def reduce(delta)
    if self.count >= delta
      self.count = self.count - delta
      return true
    end

    return false
  end
end

MockUser = Struct.new(:id)

Order = Struct.new(:book, :user, :paid, :count) do
  # 确定支付，同时减少库存
  def pay
    return false if self.paid
    if self.book.reduce(self.count)
      self.paid = true
      return true
    end
    return false
  end
end

describe 'RethinkDB Test' do
  describe "单模型访问测试" do
    # 目前是假想代码，需要替换成实际代码

    before {
      @book = Book.new
      @book.count = 2000
    }

    it "并发减少一本书的库存" do
      concurrent do
        @book.reduce(1)
      end

      expect(@book.count).to eq 0
    end

    it "库存不可低于 0" do
      concurrent do
        @book.reduce(2)
      end

      expect(@book.count).to eq 0
    end

  end

  describe "多模型访问测试" do
    # 目前是假想代码，需要替换成实际代码

    before {
      @users = []
      100.times do |i|
        user = MockUser.new
        user.id = i + 1
        @users.push user
      end
    }

    describe "一本书" do
      before {
        @book = Book.new
        @book.count = 2000
      }

      it "多个用户买一本书" do
        orders = []

        concurrent do
          # 每次随机一个用户下订单
          user = @users[rand(100)]
          order = Order.new
          order.book = @book
          order.user = user
          order.paid = false
          order.count = 1
          # order.save
          orders.push order

          # 以 10% 的比率每次随机支付一个订单
          r = rand(100)
          if r > 10
            no_paid_orders = orders.select {|o| o.paid == false}
            no_paid_order = no_paid_orders[rand(no_paid_orders.length)]
            no_paid_order.pay
          end
        end

        # 总订单数 2000
        expect(orders.length).to eq 2000

        # 总支付数 + 库存剩余数 = 2000
        paid_count = orders.count {|o| o.paid == true}
        expect(paid_count).to be < 2000
        expect(paid_count + @book.count).to eq 2000
      end

      it "订单防止重复支付测试" do
        orders = []

        concurrent do
          # 每次随机一个用户下订单
          user = @users[rand(100)]
          order = Order.new
          order.book = @book
          order.user = user
          order.paid = false
          order.count = 1
          # order.save
          orders.push order

          # 每次随机支付一个订单
          no_paid_order = orders[rand(orders.length)]
          no_paid_order.pay
        end

        # 总订单数 2000
        expect(orders.length).to eq 2000

        # 总支付数 + 库存剩余数 = 2000
        paid_count = orders.count {|o| o.paid == true}
        expect(paid_count + @book.count).to eq 2000
      end
    end

    describe "多本书" do
      before {
        @books = []
        @total = 0
        10.times do 
          book = Book.new
          book.count = rand(2000)
          @total += book.count
          @books.push book
        end
      }

      it "多个用户买多本书" do
        orders = []

        concurrent do
          book = @books[rand(@books.length)]
          user = @users[rand(100)]
          count = rand(5) + 1

          order = Order.new
          order.book = book
          order.user = user
          order.paid = false
          order.count = count
          # order.save
          orders.push order

          # 每次随机支付一个订单
          no_paid_order = orders[rand(orders.length)]
          no_paid_order.pay
        end

        # 总订单数 2000
        expect(orders.length).to eq 2000

        # 总支付数 + 库存剩余数 = total
        paid_orders = orders.select {|o| o.paid == true}
        paid_count = paid_orders.map {|o| o.count}.sum
        book_count = @books.map {|b| b.count}.sum

        expect(paid_count + book_count).to eq @total
      end
    end
  end
end