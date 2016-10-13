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

  context '#flag' do
    let(:conn) { Repsheet::Connection.new }

    after { conn.connection.flushdb }

    it 'sets a default value when no reason is provided' do
      conn.flag(actor: '1.1.1.1', list: :whitelist)
      expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :whitelisted, reason: 'default')
    end

    it 'propagates the reason when it is provided' do
      conn.flag(actor: '1.1.1.1', list: :whitelist, reason: 'test')
      expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :whitelisted, reason: 'test')
    end

    it 'raises an exception if no actor is provided' do
      expect do
        conn.flag(list: :whitelist)
      end.to raise_error(Repsheet::Exception, 'Must supply an actor')
    end

    it 'raises an exception if no list is provided' do
      expect do
        conn.flag(actor: '1.1.1.1')
      end.to raise_error(Repsheet::Exception, 'Must supply a list')
    end
  end

  context '#lookup' do
    let(:conn) { Repsheet::Connection.new }

    after { conn.connection.flushdb }

    context 'when type is :ip' do
      it 'returns :ok if the actor is not flagged' do
        expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :ok)
      end

      it 'returns :whitelisted if the actor is whitelisted' do
        conn.flag(actor: '1.1.1.1', list: :whitelist, reason: 'whitelist test')
        expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :whitelisted, reason: 'whitelist test')
      end

      it 'returns :blacklisted if the actor is blacklisted' do
        conn.flag(actor: '1.1.1.1', list: :blacklist, reason: 'blacklist test')
        expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :blacklisted, reason: 'blacklist test')
      end

      it 'returns :marked if the actor is marked' do
        conn.flag(actor: '1.1.1.1', list: :mark, reason: 'mark test')
        expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :marked, reason: 'mark test')
      end

      it 'returns whitelisted when whitelist and other flags are set' do
        conn.flag(actor: '1.1.1.1', list: :whitelist, reason: 'whitelist test')
        conn.flag(actor: '1.1.1.1', list: :blacklist, reason: 'blacklist test')
        conn.flag(actor: '1.1.1.1', list: :mark, reason: 'mark test')
        expect(conn.lookup(actor: '1.1.1.1')).to eq(status: :whitelisted, reason: 'whitelist test')
      end
    end

    context 'when type is :user' do
      it 'returns :ok if the actor is not flagged' do
        expect(conn.lookup(actor: 'user', type: :user)).to eq(status: :ok)
      end

      it 'returns :whitelisted if the actor is whitelisted' do
        conn.flag(actor: 'user', type: :user, list: :whitelist, reason: 'whitelist test')
        expect(conn.lookup(actor: 'user', type: :user)).to eq(status: :whitelisted, reason: 'whitelist test')
      end

      it 'returns :blacklisted if the actor is blacklisted' do
        conn.flag(actor: 'user', type: :user, list: :blacklist, reason: 'blacklist test')
        expect(conn.lookup(actor: 'user', type: :user)).to eq(status: :blacklisted, reason: 'blacklist test')
      end

      it 'returns :marked if the actor is marked' do
        conn.flag(actor: 'user', type: :user, list: :mark, reason: 'mark test')
        expect(conn.lookup(actor: 'user', type: :user)).to eq(status: :marked, reason: 'mark test')
      end

      it 'returns whitelisted when whitelist and other flags are set' do
        conn.flag(actor: 'user', type: :user, list: :whitelist, reason: 'whitelist test')
        conn.flag(actor: 'user', type: :user, list: :blacklist, reason: 'blacklist test')
        conn.flag(actor: 'user', type: :user, list: :mark, reason: 'mark test')
        expect(conn.lookup(actor: 'user', type: :user)).to eq(status: :whitelisted, reason: 'whitelist test')
      end
    end
  end
end
