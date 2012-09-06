require 'helper'

describe 'HMAC::URI' do
  OPTIONS       = {secret: 'foobar'}
  EXAMPLE_URL   = 'http://example.com'
  SIGNED_URI_RE = %r{http://example.com\?nonce=\d+&signature=.+&timestamp=\d+}

  def signed_url
    HMAC::URI.new(OPTIONS).sign(EXAMPLE_URL)
  end

  it 'should sign uri' do
    assert_match SIGNED_URI_RE, signed_url
  end

  it 'should validate signed uri' do
    assert HMAC::URI.new(OPTIONS).signed? signed_url
  end

  it 'should fail on secret mismatch' do
    assert !HMAC::URI.new(secret: 'foo').signed?(signed_url), 'secret mismatch should fail check'
  end

  it 'should fail on invalid nonce' do
    url = signed_url.to_s.sub %r{nonce=\d+}, 'nonce=123'
    assert !HMAC::URI.new(OPTIONS).signed?(url), 'invalid nonce should fail check'
  end

  it 'should fail on invalid timestamp' do
    url = signed_url.to_s.sub %r{timestamp=\d+}, 'timestamp=123'
    assert !HMAC::URI.new(OPTIONS).signed?(url), 'invalid timestamp should fail check'
  end

  it 'should fail on stale timestamp' do
    assert HMAC::URI.new(OPTIONS).signed?(signed_url,  delta: 1), 'valid timestamp should pass check'
    assert !HMAC::URI.new(OPTIONS).signed?(signed_url, delta: 0), 'stale timestamp should fail check'
  end

  it 'should fail on repeated nonces' do
    seen      = []
    url       = signed_url
    validator = proc {|n, ts, delta| ((Time.now.to_i - ts) < delta) && !seen.include?(n) && seen << n}

    assert HMAC::URI.new(OPTIONS.merge(validator: validator)).signed?(url),  'nonce passes'
    assert !HMAC::URI.new(OPTIONS.merge(validator: validator)).signed?(url), 'dupe nonce fails'
  end
end
