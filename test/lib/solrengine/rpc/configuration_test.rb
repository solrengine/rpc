require "test_helper"

class Solrengine::Rpc::ConfigurationTest < Minitest::Test
  def test_default_network
    config = Solrengine::Rpc::Configuration.new
    assert_equal "mainnet", config.network
  end

  def test_default_rpc_url_for_mainnet
    config = Solrengine::Rpc::Configuration.new
    assert_equal "https://api.mainnet-beta.solana.com", config.rpc_url
  end

  def test_default_rpc_url_for_devnet
    config = Solrengine::Rpc::Configuration.new
    config.network = "devnet"
    assert_equal "https://api.devnet.solana.com", config.rpc_url
  end

  def test_default_ws_url_for_mainnet
    config = Solrengine::Rpc::Configuration.new
    assert_equal "wss://api.mainnet-beta.solana.com", config.ws_url
  end

  def test_custom_rpc_url
    config = Solrengine::Rpc::Configuration.new
    config.rpc_url = "https://custom-rpc.example.com"
    assert_equal "https://custom-rpc.example.com", config.rpc_url
  end

  def test_mainnet_predicate
    config = Solrengine::Rpc::Configuration.new
    assert config.mainnet?

    config.network = "devnet"
    refute config.mainnet?
  end

  def test_explorer_base_for_mainnet
    config = Solrengine::Rpc::Configuration.new
    assert_equal "https://solscan.io", config.explorer_base
  end

  def test_explorer_base_for_devnet
    config = Solrengine::Rpc::Configuration.new
    config.network = "devnet"
    assert_equal "https://explorer.solana.com", config.explorer_base
  end

  def test_explorer_cluster_for_mainnet
    config = Solrengine::Rpc::Configuration.new
    assert_equal "", config.explorer_cluster
  end

  def test_explorer_cluster_for_devnet
    config = Solrengine::Rpc::Configuration.new
    config.network = "devnet"
    assert_equal "?cluster=devnet", config.explorer_cluster
  end
end
