require 'redis'

module Repsheet
  class Connection
    attr_accessor :host, :port, :connection

    def initialize(options = {})
      @host = options[:host] || 'localhost'
      @port = options[:port] || 6379
      @connection = Redis.new(host: host, port: port)
    end

    def flag(options = {})
      @connection.set("#{options[:actor]}:repsheet:ip:#{options[:list]}ed", options[:reason])
    end

    def lookup(options = {})
      return :whitelisted if get(actor: options[:actor], list: :whitelist, type: options[:type])
      return :blacklisted if get(actor: options[:actor], list: :blacklist, type: options[:type])
      return :marked if get(actor: options[:actor], list: :mark, type: options[:type])
      :ok
    end

    private

    def get(options = {})
      @connection.get("#{options[:actor]}:repsheet:ip:#{options[:list]}ed")
    end
  end
end
