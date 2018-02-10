# encoding: utf-8
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
# Author:: Dominik Richter (<dominik.richter@gmail.com>)
# Author:: Christoph Hartmann (<chris@lollyrock.com>)
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

require 'net/ssh'
require 'net/scp'
require 'train/errors'
require 'train/transports/ssh'
require 'net/ssh/kerberos'
module Train::Transports
  # Wrapped exception for any internally raised SSH-related errors.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class SSHFailed < Train::TransportError; end
  class SSHPTYFailed < Train::TransportError; end

  # A Transport which uses the SSH protocol to execute commands and transfer
  # files while using gssapi-with-mic authentication
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Kerberos < Train::Transports::SSH
    name 'kerberos'

    private

    def validate_options(options)
      super(options)
      if options[:pty]
        logger.warn('[SSH] PTY requested: stderr will be merged into stdout')
      end

      super
      self
    end

    # Builds the hash of options needed by the Connection object on
    # construction.
    #
    # @param opts [Hash] merged configuration and mutable state data
    # @return [Hash] hash of connection options
    # @api private
    def connection_options(opts)
      opts = {
        logger:                 logger,
        user_known_hosts_file:  '/dev/null',
        hostname:               opts[:host],
        port:                   opts[:port],
        username:               opts[:user],
        compression:            opts[:compression],
        compression_level:      opts[:compression_level],
        keepalive:              opts[:keepalive],
        keepalive_interval:     opts[:keepalive_interval],
        timeout:                opts[:connection_timeout],
        connection_retries:     opts[:connection_retries],
        connection_retry_sleep: opts[:connection_retry_sleep],
        max_wait_until_ready:   opts[:max_wait_until_ready],
        auth_methods:           %w[gssapi-with-mic],
        keys_only:              false,
        keys:                   opts[:key_files],
        password:               opts[:password],
        forward_agent:          opts[:forward_agent],
        transport_options:      opts,
      }

      opts[verify_host_key_option] = false

      opts
    end

    # net-ssh >=4.2 has renamed paranoid option to verify_host_key
    def verify_host_key_option
      current_net_ssh = Net::SSH::Version::CURRENT
      new_option_version = Net::SSH::Version[4, 2, 0]

      current_net_ssh >= new_option_version ? :verify_host_key : :paranoid
    end
  end
end
