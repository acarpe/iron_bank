# encoding: utf-8

module IronBank

  class DraftInvoice < IronBank::Base

    def initialize(api, invoice_id = nil)
      @api        = api
      @attributes = {}

      if invoice_id
        response = self.class.get(
          "/sales/draftinvoices/#{invoice_id}/v3",
          headers: @api.authorization_headers
        )

        if response.code == 200
          @attributes = response.parsed_response
        else
          raise RequestError.new(response)
        end
      end
    end

    def create(options = {})
      response = self.class.post(
        '/sales/draftinvoices/v4',
        body: options.camelize_keys!.to_json,
        headers: @api.authorization_headers.merge({"Content-Type" => "application/json"})
      )

      if response.code == 200
        @attributes = response.parsed_response
      else
        raise RequestError.new(response)
      end

      self
    end

    def book
      raise BaseError.new("draft_invoice.id missing") unless self.id

      response = self.class.post(
        "/sales/draftinvoices/#{self.id}/book/v4",
        headers: @api.authorization_headers.merge({"Content-Type" => "application/json"})
      )
      if response.code == 200
        @attributes = response.parsed_response
      else
        raise RequestError.new(response)
      end

      Invoice.new(@api, nil, @attributes)
    end

    def method_missing(m, *args, &block)
      if @attributes.has_key?(m.to_s)
        @attributes[m.to_s]
      else
        super
      end
    end

  end

end