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
      raise Repsheet::Exception.new("Must supply an actor") if options[:actor].nil?
      raise Repsheet::Exception.new("Must supply a list") if options[:list].nil?

      reason = options[:reason] || "default"
      type = options[:type] || :ip
      @connection.set("#{options[:actor]}:repsheet:#{type}:#{options[:list]}ed", reason)
    end

    def lookup(options = {})
      if reason = get(actor: options[:actor], list: :whitelist, type: options[:type])
        return {status: :whitelisted, reason: reason}
      end

      if reason = get(actor: options[:actor], list: :blacklist, type: options[:type])
        return {status: :blacklisted, reason: reason}
      end

      if reason = get(actor: options[:actor], list: :mark, type: options[:type])
        return {status: :marked, reason: reason}
      end

      {status: :ok}
    end

    private

    def get(options = {})
      type = options[:type] || :ip
      @connection.get("#{options[:actor]}:repsheet:#{type}:#{options[:list]}ed")
    end
  end
end
