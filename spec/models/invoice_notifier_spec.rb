require "rails_helper"

describe InvoiceNotifier do
  describe '#send_receipt' do
    context 'invoice has a user' do
      it 'sends a receipt to the person who was charged' do
        ActionMailer::Base.deliveries.clear
        payment_processor = InvoiceNotifier.new(stub_invoice)

        payment_processor.send_receipt

        customer_should_receive_receipt_email(stub_invoice)
      end
    end

    context 'invoice has no user' do
      it "sends a notification to Honeybadger for further debugging" do
        allow(Honeybadger).to receive(:notify)
        payment_processor =
          InvoiceNotifier.new(stub_invoice_with_no_user)

        payment_processor.send_receipt

        expect(Honeybadger).to have_received(:notify)
      end
    end
  end

  def stub_invoice
    double(
      'invoice',
      user: true,
      user_email: 'someone@example.com',
      amount_paid: '$500',
      stripe_invoice_id: 'stripe_id'
    )
  end

  def stub_invoice_with_no_user
    double(
      'invoice',
      user: nil,
      user_email: nil,
      amount_paid: '$500',
      stripe_invoice_id: 'stripe_id',
      stripe_invoice: nil
    )
  end

  def customer_should_receive_receipt_email(invoice)
    email = ActionMailer::Base.deliveries.first
    expect(email.subject).to include("receipt")
    expect(email.to).to eq [invoice.user_email]
  end
end
