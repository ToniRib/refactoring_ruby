# In this semi-fictionalised version of the BiggerPockets Store, we are selling
# one of our real estate investing education books and tickets to our
# conference. We are constantly trying to expand to offer our products
# to new markets around the world, so we continually need to add support
# for different payment gateways and methods. Also, as the company grows,
# we plan to bring new sales and marketing staff on board who will need to
# see order data in various formats (HTML, XML, etc.). Additionally, we are
# planning to introduce a lot of new products into the store very soon, such as
# software and training seminars.

class BookOrder
  def initialize(order_number, quantity, address)
    @order_number = order_number
    @quantity = quantity
    @address = address
  end

  def charge(order_type, payment_type)
    if order_type == "ebook"
      shipping = 0
    else
      shipping = 5.99
    end

    if payment_type == :cash
      send_email_receipt
      @status = "charged"
    elsif payment_type == :cheque
      send_email_receipt
      @status = "charged"
    elsif payment_type == :paypal
      if charge_paypal_account(shipping + (quantity * 14.95))
        send_email_receipt
        @status = "charged"
      else
        send_payment_failure_email
        @status = "failed"
      end
    elsif payment_type == :stripe
      if charge_credit_card(shipping + (quantity * 14.95))
        send_email_receipt
        @status = "charged"
      else
        send_payment_failure_email
        @status = "failed"
      end
    end
  end

  def ship(order_type)
    if order_type == "ebook"
      # [send email with download link...]
    else
      # [print shipping label]
    end

    @status = "shipped"
  end

  def quantity
    @quantity
  end

  def status
    @status
  end

  def to_s(order_type)
    if order_type == "ebook"
      shipping = 0
    else
      shipping = 4.99
    end

    report = "Order ##{@order_number}\n"
    report += "Ship to: #{@address.join(", ")}\n"
    report += "-----\n\n"
    report += "Qty   | Item Name                       | Total\n"
    report += "------|---------------------------------|------\n"
    report += "#{@quantity}     | Book                            | $#{shipping + (quantity * 14.95)}"
    report
    return report
  end

  def shipping_cost(order_type)
    if order_type == "ebook"
      shipping = 0
    else
      shipping = 4.95
    end
  end

  def send_email_receipt
    # [send email receipt]
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_paypal_account(amount)
    true
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_credit_card(amount)
    true
  end
end

class ConferenceTicketOrder
  def initialize(order_number, quantity, address)
    @order_number = order_number
    @quantity = quantity
    @address = address
  end

  def charge(payment_type)
    shipping = 0

    if payment_type == :cash
      send_email_receipt
      @status = "charged"
    elsif payment_type == :cheque
      send_email_receipt
      @status = "charged"
    elsif payment_type == :paypal
      charge_paypal_account shipping + (quantity * 300)
      send_email_receipt
      @status = "charged"
    elsif payment_type == :stripe
      charge_credit_card shipping + (quantity * 300)
      send_email_receipt
      @status = "charged"
    end
  end

  def ship
    # [print ticket]
    # [print shipping label]

    @status = "shipped"
  end

  def quantity
    @quantity
  end

  def status
    @status
  end

  def to_s
    shipping = 0
    report = "Order ##{@order_number}\n"
    report += "Ship to: #{@address.join(", ")}\n"
    report += "-----\n\n"
    report += "Qty   | Item Name                       | Total\n"
    report += "------|---------------------------------|------\n"
    report += "#{@quantity}     |"
    report += " Conference Ticket               |"
    report += " $#{shipping + (quantity * 300.0)}"
    report
    return report
  end

  def shipping_cost
    shipping = 0
  end

  def send_email_receipt
    # [send email receipt]
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_paypal_account(amount)
    true
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_credit_card(amount)
    true
  end
end

require "rspec"

describe BookOrder do
  context "with a physical book" do
    subject { BookOrder.new(1, 5, ["1234 Main St.", "New York, NY 12345"]) }

    it "gets marked as charged" do
      subject.charge("print", :stripe)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship("print")

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost("print")

      expect(shipping_cost).to eq(4.95)
    end
  end

  context "as an ebook" do
    subject { BookOrder.new(2, 5, ["1234 Main St.", "New York, NY 12345"]) }

    it "gets marked as charged" do
      subject.charge("ebook", :paypal)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship("ebook")

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost("ebook")

      expect(shipping_cost).to eq(0)
    end
  end

  it "produces a text-based report" do
    order = BookOrder.new(12345, 5, ["1234 Main St.", "New York, NY 12345"])
    report = "Order #12345\n" \
             "Ship to: 1234 Main St., New York, NY 12345\n" \
             "-----\n\n" \
             "Qty   | Item Name                       | Total\n" \
             "------|---------------------------------|------\n" \
             "5     | Book                            | $79.74"

    expect(order.to_s("print")).to eq(report)
  end
end

describe ConferenceTicketOrder do
  context "a valid conference ticket order" do
    subject do
      ConferenceTicketOrder.new(3, 1, ["1234 Main St.", "New York, NY 12345"])
    end

    it "gets marked as charged" do
      subject.charge(:paypal)

      expect(subject.status).to eq("charged")
    end

    it "gets marked as shipped" do
      subject.ship

      expect(subject.status).to eq("shipped")
    end

    it "calculates shipping cost" do
      shipping_cost = subject.shipping_cost

      expect(shipping_cost).to eq(0)
    end

    it "produces a text-based report" do
      order = ConferenceTicketOrder.new(12345,
                                        1,
                                        ["1234 Test St.", "New York, NY 12345"])
      report = "Order #12345\n" \
               "Ship to: 1234 Test St., New York, NY 12345\n" \
               "-----\n\n" \
               "Qty   | Item Name                       | Total\n" \
               "------|---------------------------------|------\n" \
               "1     | Conference Ticket               | $300.00"

      expect(order.to_s).to eq(report)
    end
  end

  it "does not allow more than one conference ticket per order" do
    expect do
      ConferenceTicketOrder.new(1337, 3, ["456 Test St.", "New York, NY 12345"])
    end.to raise_error("Conference tickets are limited to one per customer")
  end
end
