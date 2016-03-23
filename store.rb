# In this semi-fictionalised version of the BiggerPockets Store, we are selling
# one of our real estate investing education books and tickets to our
# conference. We are constantly trying to expand to offer our products
# to new markets around the world, so we continually need to add support
# for different payment gateways and methods. Also, as the company grows,
# we plan to bring new sales and marketing staff on board who will need to
# see order data in various formats (HTML, XML, etc.). Additionally, we are
# planning to introduce a lot of new products into the store very soon, such as
# software and training seminars.

# Note from Toni: To simplify your review of this, I did separate out the test
# file but kept all of the classes togther in one file. Please know that I did
# this only for ease of review, and that normally I would always have each class
# in its own separate file.

class BookOrder
  attr_reader :quantity, :status, :order_number, :order_type

  def initialize(order_number, quantity, address)
    @order_number = order_number
    @quantity = quantity
    @address = address
  end

  def charge(order_type, payment_type)
    @order_type = order_type

    payment = Payment.new(payment_type)
    payment.process(total)

    @status = payment.status
  end

  def ship(order_type)
    if order_type == "ebook"
      # [send email with download link...]
    else
      # [print shipping label]
    end

    update_status_to_shipped
  end

  def to_s(order_type)
    report = OrderReport.new(@address, quantity, total, order_number, order_type)

    report.generate_as(:string)
  end

  def shipping_cost(order_type)
    order_type == "ebook" ? 0 : cost_to_ship_physical_book
  end

  private

  def update_status_to_shipped
    @status = "shipped"
  end

  def price_of_book
    14.95
  end

  def cost_to_ship_physical_book
    4.95
  end

  def total
    shipping_cost(order_type) + (quantity * price_of_book)
  end
end

class ConferenceTicketOrder
  attr_reader :quantity, :status, :order_number

  def initialize(order_number, quantity, address)
    fail quantity_error_message if more_than_one_ticket_requested(quantity)

    @order_number = order_number
    @quantity = quantity
    @address = address
  end

  def charge(payment_type)
    payment = Payment.new(payment_type)
    payment.process(total)

    @status = payment.status
  end

  def ship
    # [print ticket]
    # [print shipping label]

    update_status_to_shipped
  end

  def to_s
    report = OrderReport.new(@address,
                             quantity,
                             total,
                             order_number,
                             "conference ticket")

    report.generate_as(:string)
  end

  def shipping_cost
    0
  end

  private

  def update_status_to_shipped
    @status = "shipped"
  end

  def price_of_ticket
    300.0
  end

  def quantity_error_message
    "Conference tickets are limited to one per customer"
  end

  def more_than_one_ticket_requested(quantity)
    quantity != 1
  end

  def total
    shipping_cost + (quantity * price_of_ticket)
  end
end

class Payment
  attr_reader :type, :status

  def initialize(type)
    @type = type
  end

  def process(total)
    case type
    when :cash, :cheque
      send_email_receipt_and_update_status_to_charged
    when :paypal, :stripe
      attempt_to_charge_account(total)
    end
  end

  private

  def attempt_to_charge_account(total)
    if charge_account(total)
      send_email_receipt_and_update_status_to_charged
    else
      send_failure_email_and_update_status_to_failed
    end
  end

  def send_email_receipt_and_update_status_to_charged
    send_email_receipt
    update_status_to_charged
  end

  def send_failure_email_and_update_status_to_failed
    send_payment_failure_email
    update_status_to_failed
  end

  def charge_account(total)
    case type
    when :paypal then charge_paypal_account(total)
    when :stripe then charge_credit_card(total)
    end
  end

  def update_status_to_charged
    @status = "charged"
  end

  def update_status_to_failed
    @status = "failed"
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_paypal_account(amount)
    true
  end

  # In real life, charges would happen here. For sake of this test, it simply returns true
  def charge_credit_card(amount)
    true
  end

  def send_email_receipt
    # [send email receipt] Toni - I assume this would do something in real life
    true
  end

  def send_payment_failure_email
    # [send failure email receipt]
    true
  end
end

class OrderReport
  attr_reader :address, :quantity, :total, :order_number, :order_type

  def initialize(address, quantity, total, order_number, order_type)
    @address = address
    @quantity = quantity
    @total = total
    @order_number = order_number
    @order_type = order_type
  end

  def generate_as(format)
    case format
    when :string
      report_as_string
    end
  end

  private

  def report_as_string
    "Order ##{order_number}\n" \
    "Ship to: #{mailing_address}\n" \
    "-----\n\n" \
    "Qty   | Item Name                       | Total\n" \
    "------|---------------------------------|------\n" \
    "#{quantity}     |" \
    " #{printable_order_type}               |" \
    " $#{total_with_two_decimals}"
  end

  def printable_order_type
    pad_to_fit(order_type_conversion[order_type])
  end

  def order_type_conversion
    {
      "print" => "Book",
      "conference ticket" => "Conference Ticket",
      "ebook" => "eBook"
    }
  end

  def pad_to_fit(text)
    text.ljust(17, " ")
  end

  def mailing_address
    address.join(", ")
  end

  def total_with_two_decimals
    "%.2f" % total
  end
end
