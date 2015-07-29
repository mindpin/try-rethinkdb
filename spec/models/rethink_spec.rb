describe 'RethinkDB Test' do
  before {
    @threads = []

    @book = {:count => 1000}
    @book1 = {:count => 1000}
    @book2 = {:count => 1000}
    @book3 = {:count => 1000}
    @orders = []
  }

  it "单模型访问测试" do
    # TODO 需要替换成实际代码
    
    20.times do
      @threads.push Thread.new {
        50.times do
          @book[:count] = @book[:count] - 1
          sleep rand(10) / 100.0
        end
      }
    end

    @threads.each {|t| t.join}
    expect(@book[:count]).to eq 0
  end

  it "多个用户买一本书" do
    # TODO 需要替换成实际代码

    20.times do
      @threads.push Thread.new {
        50.times do
          order = {:paid => false}
          @orders.push order
          sleep rand(10) / 100.0
          order[:paid] = true
        end
      }
    end

    @threads.each {|t| t.join}
    expect(@orders.length).to eq 1000
    expect(@orders.select{|x| x[:paid] == false}.length).to eq 0
  end

  it "多个用户买多本书" do
    # TODO 需要替换成实际代码

    books = [@book, @book1, @book2, @book3]

    20.times do
      @threads.push Thread.new {
        50.times do
          order = {:paid => false, :book => books[rand(4)], :count => 1}
          @orders.push order
          sleep rand(10) / 100.0
          order[:paid] = true
          sleep rand(10) / 100.0
          order[:book][:count] = order[:book][:count] - order[:count]
        end
      }
    end

    @threads.each {|t| t.join}
    expect(@orders.length).to eq 1000
    expect(@orders.select{|x| x[:paid] == false}.length).to eq 0

    books.each do |book|
      c1 = @orders.select{|x| x[:book] == book}.length
      c2 = book[:count]
      puts "#{c1}, #{c2}"
      expect(c1 + c2).to eq 1000
    end
  end  
end