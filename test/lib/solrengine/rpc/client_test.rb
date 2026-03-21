require "test_helper"

class Solrengine::Rpc::ClientTest < Minitest::Test
  def test_initializes_with_default_rpc_url
    client = Solrengine::Rpc::Client.new
    assert_instance_of Solrengine::Rpc::Client, client
  end

  def test_initializes_with_custom_rpc_url
    client = Solrengine::Rpc::Client.new(rpc_url: "https://custom.example.com")
    assert_instance_of Solrengine::Rpc::Client, client
  end

  def test_get_balance_returns_sol
    client = Solrengine::Rpc::Client.new(rpc_url: "https://api.devnet.solana.com")
    balance = client.get_balance("11111111111111111111111111111111")
    # System program account has minimal balance on devnet
    assert_kind_of Float, balance
  end

  def test_get_balance_returns_nil_for_empty_response
    client = Solrengine::Rpc::Client.new(rpc_url: "https://invalid.example.com")
    balance = client.get_balance("11111111111111111111111111111111")
    assert_nil balance
  end

  def test_get_latest_blockhash
    client = Solrengine::Rpc::Client.new(rpc_url: "https://api.devnet.solana.com")
    result = client.get_latest_blockhash
    assert_kind_of Hash, result
    assert_kind_of String, result[:blockhash]
    assert result[:blockhash].length > 30
    assert_kind_of Integer, result[:last_valid_block_height]
  end

  def test_get_token_accounts_returns_array
    client = Solrengine::Rpc::Client.new(rpc_url: "https://api.devnet.solana.com")
    tokens = client.get_token_accounts("11111111111111111111111111111111")
    assert_kind_of Array, tokens
  end

  def test_get_recent_signatures_returns_array
    client = Solrengine::Rpc::Client.new(rpc_url: "https://api.devnet.solana.com")
    sigs = client.get_recent_signatures("11111111111111111111111111111111", limit: 1)
    assert_kind_of Array, sigs
  end

  def test_generic_request
    client = Solrengine::Rpc::Client.new(rpc_url: "https://api.devnet.solana.com")
    result = client.request("getHealth")
    assert_equal "ok", result["result"]
  end

  def test_module_client_shortcut
    client = Solrengine::Rpc.client
    assert_instance_of Solrengine::Rpc::Client, client
  end
end
