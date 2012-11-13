require 'cgi'
require 'openssl'
require 'addressable/uri'

# HMAC based request signing with uri

module HMAC
  class URI
    module QSParser
      def query_values
        query.to_s.split(/&/).each_with_object({}) do |pair, hash|
          key, value = pair.split(/=/, 2).map {|s| CGI.unescape(s)}
          hash[key]  = hash.key?(key) ? [hash[key], value].flatten : value
        end
      end

      def query_values= hash
        self.query = flatten_query_values(hash).map {|pair| pair.map {|s| CGI.escape(s.to_s)}.join('=')}.join('&')
      end

      def flatten_query_values hash
        hash.keys.sort.each_with_object([]) do |key, q|
          [hash[key]].flatten.each do |value|
            q << [key, value]
          end
        end
      end
    end # QSParser

    def initialize options = {}
      @secret    = options.fetch(:secret)
      @validator = options.fetch(:validator, method(:default_validator))
      @digest    = OpenSSL::Digest::Digest.new('sha1')
    end

    def parse uri
      Addressable::URI.parse(uri).tap {|u| u.extend(QSParser)}
    end

    def sign uri
      uri = merge_query(parse(timestamp(uri)), nonce: nonce)
      merge_query(uri, signature: signature(uri))
    end

    def signed? uri, options = {}
      delta = options.fetch(:delta, 300).to_i
      uri   = parse(uri)
      query = uri.query_values
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
      merge_query(parse(uri), timestamp: Time.now.utc.to_i)
    end

    def signature message
      OpenSSL::HMAC.hexdigest(@digest, @secret, message.to_s)
    end
  end # URI
end # HMAC
