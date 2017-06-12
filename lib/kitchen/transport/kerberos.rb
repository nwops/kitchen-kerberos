# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "net/ssh"
require "net/ssh/gateway"
require 'net/ssh/kerberos'
require 'kitchen/transport/ssh'
require "net/scp"
require "timeout"
require "benchmark"

module Kitchen
  module Transport
    # Wrapped exception for any internally raised SSH-related errors.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class SshFailed < TransportFailed; end

    # A Transport which uses the SSH protocol to execute commands and transfer
    # files.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Kerberos < Kitchen::Transport::Base
      kitchen_transport_api_version 1

      plugin_version Kitchen::VERSION

      default_config :port, 22
      default_config :username, "root"
      default_config :keepalive, true
      default_config :keepalive_interval, 60
      # needs to be one less than the configured sshd_config MaxSessions
      default_config :max_ssh_sessions, 9
      default_config :connection_timeout, 15
      default_config :connection_retries, 5
      default_config :connection_retry_sleep, 1
      default_config :max_wait_until_ready, 600

      default_config :ssh_gateway, nil
      default_config :ssh_gateway_username, nil

      # compression disabled by default for speed
      default_config :compression, false
      required_config :compression

      default_config :compression_level do |transport|
        transport[:compression] == false ? 0 : 6
      end


      private

      # Builds the hash of options needed by the Connection object on
      # construction.
      #
      # @param data [Hash] merged configuration and mutable state data
      # @return [Hash] hash of connection options
      # @api private
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def connection_options(data)
        opts = {
          logger: logger,
          user_known_hosts_file: "/dev/null",
          paranoid: false,
          hostname: data[:hostname],
          port: data[:port],
          username: data[:username],
          compression: data[:compression],
          compression_level: data[:compression_level],
          keepalive: data[:keepalive],
          keepalive_interval: data[:keepalive_interval],
          timeout: data[:connection_timeout],
          connection_retries: data[:connection_retries],
          connection_retry_sleep: data[:connection_retry_sleep],
          max_ssh_sessions: data[:max_ssh_sessions],
          max_wait_until_ready: data[:max_wait_until_ready],
          ssh_gateway: data[:ssh_gateway],
          ssh_gateway_username: data[:ssh_gateway_username],
	  auth_methods: %w[gssapi-with-mic]
        }

        opts[:forward_agent] = data[:forward_agent] if data.key?(:forward_agent)
        opts[:verbose] = data[:verbose].to_sym      if data.key?(:verbose)

        opts
      end
    end
  end
end