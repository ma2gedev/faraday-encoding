require 'spec_helper'

describe Faraday::Encoding do
  let(:client) do
    Faraday.new do |connection|
      connection.response :encoding
      connection.adapter :test, stubs
    end
  end

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/') do
        [response_status, response_headers, response_body]
      end
    end
  end

  let(:response_status) { 200 }
  let(:response_headers) do
    { 'content-type' => "text/plain; charset=#{response_encoding}" }
  end

  context 'http adapter return binary encoded body' do
    let(:response_encoding) do
      'utf-8'
    end
    let(:response_body) do
      'ねこ'.force_encoding(Encoding::ASCII_8BIT)
    end

    it 'set encoding specified by http header' do
      response = client.get('/')
      expect(response.body.encoding).to eq(Encoding::UTF_8)
    end
  end

  context 'deal correctly with a non standard encoding names' do
    context 'utf8' do
      let(:response_encoding) do
        'utf8'
      end
      let(:response_body) do
        'abc'.force_encoding(Encoding::ASCII_8BIT)
      end

      it 'set encoding to utf-8' do
        response = client.get('/')
        expect(response.body.encoding).to eq(Encoding::UTF_8)
      end
    end

    context 'for unknown encoding' do
      let(:response_encoding) do
        'unknown-encoding'
      end
      let(:response_body) do
        'abc'.force_encoding(Encoding::ASCII_8BIT)
      end

      it 'does not enforce encoding' do
        response = client.get('/')
        expect(response.body.encoding).to eq(Encoding::ASCII_8BIT)
      end
    end
  end
end
