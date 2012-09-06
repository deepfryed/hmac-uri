require 'openssl'
require 'addressable/uri'

# HMAC based request signing with uri

module HMAC
  class URI
    def initialize options = {}
      @secret    = options.fetch(:secret)
      @validator = options.fetch(:validator, method(:default_validator))
      @digest    = OpenSSL::Digest::Digest.new('sha1')
    end

    def sign uri
      uri = merge_query(Addressable::URI.parse(timestamp(uri)), nonce: nonce)
      merge_query(uri, signature: signature(uri))
    end

    def signed? uri, options = {}
      delta = options.fetch(:delta, 300).to_i
      uri   = Addressable::URI.parse(uri)
      query = uri.query_values || {}
      ts    = query['timestamp'].to_i
      nonce = query['nonce']
      hmac  = query.delete('signature')
      uri   = uri.tap {|u| u.query_values = query}

      validate(nonce, ts, delta) && hmac == signature(uri.to_s)
    end

    private

    def default_validator nonce, ts, delta
      nonce.to_i > 0 && valid_timestamp?(ts, delta)
    end

    def validate nonce, ts, delta
      @validator.call(nonce, ts, delta)
    end

    def stringy_hash hash
      hash.inject({}) {|a, (k, v)| a.tap {a[k.to_s] = Hash === v ? stringy_hash(v) : v}}
    end

    def nonce
      (Time.now.to_f.round(6) * 1_000_000).to_i
    end

    def merge_query uri, hash
      uri.tap do
        uri.query_values = (uri.query_values || {}).merge(stringy_hash(hash))
      end
    end

    def valid_timestamp? ts, delta
      (Time.now.utc.to_f - ts.to_f).abs < delta
    end

    def timestamp uri
      merge_query(Addressable::URI.parse(uri), timestamp: Time.now.utc.to_i)
    end

    def signature message
      OpenSSL::HMAC.hexdigest(@digest, @secret, message.to_s)
    end
  end # URI
end # HMAC
