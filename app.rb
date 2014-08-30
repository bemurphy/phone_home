require "cuba"
require "basica"
require "redic"

Cuba.plugin Basica

class IpTracking
  def self.redis
    url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL'] || "redis://localhost:6379/"
    @redis ||= Redic.new(url)
  end

  def self.set(location, value)
    redis.call('SET', "ip:#{location}", value)
  end

  def self.get(location)
    redis.call('GET', "ip:#{location}")
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
    Rack::Utils.secure_compare(pass, ENV.fetch('PASSWORD'))
  end

  on authenticated, "track/:location" do |location|
    res.headers['Content-Type'] = 'text/plain'

    on post do
      IpTracking.set(location, req.ip)
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

  on default do
    unauthorized
  end
end
