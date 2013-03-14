# HMAC URI

HMAC based request signing of URI.


## Example

```ruby
require 'hmac/uri'

mac = HMAC::URI.new(secret: 'some long shared secret')
uri = mac.sign "http://example.org/resource?id=1"

mac.signed?(uri)           #=> true
mac.signed?(uri, delta: 0) #=> false
```

## Nonce

`HMAC::URI` generates nonces which can be used to prevent replay attacks.

```ruby
require 'hmac/uri'

seen  = {}
check = proc {|nonce, ts, delta| (Time.now.to_i - ts) < delta && !seen.include?(nonce) && seen << nonce}
mac   = HMAC::URI.new(secret: 'some long shared secret', validator: check)
uri   = mac.sign "http://example.org/resource?id=1"

mac.signed?(uri)           #=> true
mac.signed?(uri, delta: 0) #=> false
```

## License

MIT
