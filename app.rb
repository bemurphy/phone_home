require "basica"
require "cuba"
require "json"
require "redic"

Cuba.plugin Basica

class IpTracking
  KEY = "locations"

  def self.redis
    url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL'] || "redis://localhost:6379/"
    @redis ||= Redic.new(url)
  end

  def self.set(location, value)
    redis.call('HSET', KEY, location, value)
  end

  def self.get(location)
    redis.call('HGET', KEY, location)
  end

  def self.del(location)
    redis.call('HDEL', KEY, location)
  end

  def self.all
    Hash[*redis.call('HGETALL', KEY)]
  end
end

Cuba.define do
  def unauthorized
    res.status = 401
    res.headers["WWW-Authenticate"] = 'Basic realm="PhoneHome"'
    res.write "Unauthorized"
  end

  on env["HTTP_AUTHORIZATION"].nil? do
    unauthorized
  end

  authenticated =  basic_auth(env) do |_, pass|
    given    = Digest::MD5.hexdigest(pass.to_s)
    expected = Digest::MD5.hexdigest(ENV.fetch('PASSWORD'))
    Rack::Utils.secure_compare(given, expected)
  end

  on authenticated, "track" do
    on get, root do
      res.headers["Content-Type"] = "application/json; charset=utf-8"
      res.write IpTracking.all.to_json
    end

    on ":location" do |location|
      res.headers['Content-Type'] = 'text/plain'

      on post do
        IpTracking.set(location, req.ip)
        res.write 'ok'
      end

      on delete do
        IpTracking.del(location)
        res.write 'ok'
      end

      on get do
        location_ip = IpTracking.get(location)

        on !location_ip.to_s.empty? do
          res.write location_ip
        end

        on default do
          res.status = 404
          res.write 'Not Found'
        end
      end
    end
  end

  on default do
    unauthorized
  end
end
