require_relative "lib/solrengine/rpc/version"

Gem::Specification.new do |spec|
  spec.name = "solrengine-rpc"
  spec.version = Solrengine::Rpc::VERSION
  spec.authors = [ "Jose Ferrer" ]
  spec.email = [ "estoy@moviendo.me" ]

  spec.summary = "Solana JSON-RPC client for Ruby with SSL CRL fix and network config"
  spec.description = "Ruby client for Solana's JSON-RPC API. Handles balance, token accounts, signatures, transactions, and blockhash queries. Includes SSL CRL workaround and multi-network configuration."
  spec.homepage = "https://github.com/solrengine/rpc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "config/**/*", "LICENSE", "README.md"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "rails", ">= 7.1"
end
