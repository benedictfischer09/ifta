class Transaction < ActiveRecord::Base

  #associations
  has_many :line_items
  has_one :payment
  belongs_to :itinerary

  #life cycle hooks
  after_save :mark_line_items
  before_destroy :clean_up

  delegate :user, :to => :itinerary

  def self.search_for_transactions(options)
    #set defaults for the search
    options[:status] = []
    options[:status] << true if options[:paid] == "true"
    options[:status] << false if options[:unpaid] == "true"
    options[:email] ||= ""
    options[:first_name] ||= ""
    options[:last_name] ||= ""
    where('transactions.paid IN (?)', options[:status]).joins(:itinerary => :user).where('users.first_name LIKE ? AND users.last_name LIKE ? AND users.email LIKE ? AND itineraries.conference_id = ?', options[:first_name] + "%", options[:last_name] + "%", options[:email] + "%", options[:conference_id])
  end

  def pre_tax_total
    return line_items.inject(0){|sum, item| sum + item.price}
  end

  def post_tax_total
    self.pre_tax_total + tax
  end

  def paypal_encrypted
    values = {
      :business => ENV["PAYPAL_SELLER"],
      :cmd => '_cart',
      :upload => 1,
      :return => ENV["PAYPAL_RETURN_URL"],
      :invoice => id,
      :notify_url => ENV["PAYPAL_NOTIFY_URL"],
      :cert_id => ENV["PAYPAL_CERT_ID"]
    }

    line_items.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => item.price,
        "item_name_#{index+1}" => item.conference_item.name,
        "item_number_#{index+1}" => item.id
      })

     tax_id = line_items.length + 1
     values.merge!({
       "amount_#{tax_id}" => sprintf("%.2f", tax),
       "item_name_#{tax_id}" => "Admin Fee",
       "item_number_#{tax_id}" => id
     })
     values[:invoice] = id

    end
    encrypt_for_paypal(values)
  end

  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/#{ENV["PAYPAL_CERT_PEM"]}")
  APP_CERT_PEM = "-----BEGIN CERTIFICATE-----\n" + ENV['APP_CERT'] + "\n-----END CERTIFICATE-----\n"
  APP_KEY_PEM = "-----BEGIN RSA PRIVATE KEY-----\n" + ENV['APP_KEY'] + "\n-----END RSA PRIVATE KEY-----\n"

  private
  def encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end

  def mark_line_items
    line_items.update_all(:paid => paid)
  end

  def clean_up
    line_items.update_all(:paid => false, :transaction_id => nil)
    payment.destroy unless payment.nil?
  end
end
