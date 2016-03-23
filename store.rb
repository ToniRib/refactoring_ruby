# In this semi-fictionalised version of the BiggerPockets Store, we are selling
# one of our real estate investing education books and tickets to our
# conference. We are constantly trying to expand to offer our products
# to new markets around the world, so we continually need to add support
# for different payment gateways and methods. Also, as the company grows,
# we plan to bring new sales and marketing staff on board who will need to
# see order data in various formats (HTML, XML, etc.). Additionally, we are
# planning to introduce a lot of new products into the store very soon, such as
# software and training seminars.

require "pry"

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
  attr_reader :quantity, :status

  def initialize(order_number, quantity, address)
    fail quantity_error_message if more_than_one_ticket_requested(quantity)

    @order_number = order_number
    @quantity = quantity
    @address = address
  end

  def charge(payment_type)
    Payment.new(payment_type).process(total)

    update_status_to_charged
  end

  def ship
    # [print ticket]
    # [print shipping label]

    @status = "shipped"
  end

  def to_s
    report = "Order ##{@order_number}\n"
    report += "Ship to: #{@address.join(", ")}\n"
    report += "-----\n\n"
    report += "Qty   | Item Name                       | Total\n"
    report += "------|---------------------------------|------\n"
    report += "#{@quantity}     |"
    report += " Conference Ticket               |"
    report += " $#{total_with_two_decimals}"
    report
    return report
  end

  def shipping_cost
    0
  end

  private

  def update_status_to_charged
    @status = "charged"
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

  def total_with_two_decimals
    "%.2f" % total
  end

  def total
    shipping_cost + (quantity * price_of_ticket)
  end
end

class Payment
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def process(total)
    case type
    when :cash || :cheque
    when :paypal
      charge_paypal_account total
    when :stripe
      charge_credit_card total
    end

    send_email_receipt
  end

  private

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
end
