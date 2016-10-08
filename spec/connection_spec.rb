require 'spec_helper'

describe Repsheet::Connection do
  context '.new' do
    it 'assigns the proper host and port when specified' do
      connection = Repsheet::Connection.new(host: 'localhost', port: 6379)
      expect(connection.host).to eq('localhost')
      expect(connection.port).to eq(6379)
    end

    it 'defaults to localhost:6379 when not specified' do
      connection = Repsheet::Connection.new
      expect(connection.host).to eq('localhost')
      expect(connection.port).to eq(6379)
    end
  end

  context '#lookup' do
    let(:conn) { Repsheet::Connection.new }

    after { conn.connection.flushdb }

    it 'returns :ok if the actor is not flagged' do
      expect(conn.lookup(actor: '1.1.1.1')).to eq(:ok)
    end

    it 'returns :whitelisted if the actor is whitelisted' do
      conn.flag(actor: '1.1.1.1', list: :whitelist, reason: 'whitelist test')
      expect(conn.lookup(actor: '1.1.1.1')).to eq(:whitelisted)
    end

    it 'returns :blacklisted if the actor is blacklisted' do
      conn.flag(actor: '1.1.1.1', list: :blacklist, reason: 'blacklist test')
      expect(conn.lookup(actor: '1.1.1.1')).to eq(:blacklisted)
    end

    it 'returns :marked if the actor is marked' do
      conn.flag(actor: '1.1.1.1', list: :mark, reason: 'mark test')
      expect(conn.lookup(actor: '1.1.1.1')).to eq(:marked)
    end

    it 'returns whitelisted when whitelist and other flags are set' do
      conn.flag(actor: '1.1.1.1', list: :whitelist, reason: 'whitelist test')
      conn.flag(actor: '1.1.1.1', list: :blacklist, reason: 'blacklist test')
      conn.flag(actor: '1.1.1.1', list: :mark, reason: 'mark test')
      expect(conn.lookup(actor: '1.1.1.1')).to eq(:whitelisted)
    end
  end
end
