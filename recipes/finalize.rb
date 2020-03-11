# frozen_string_literal: true

#
# Cookbook Name:: aws-parallelcluster
# Recipe:: finalize
#
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Restart supervisord
# service "supervisord" do
#   supports restart: true
#   action %i[enable start]
# end

# execute "compute_ready" do
#   command "/opt/parallelcluster/scripts/compute_ready"
#   environment('PATH' => '/usr/local/bin:/usr/bin/:$PATH')
#   only_if { node['cfncluster']['cfn_node_type'] == 'ComputeFleet' }
# end

if node['cfncluster']['cfn_node_type'] == 'ComputeFleet'
  require 'chef/mixin/shell_out'
  nodename = shell_out("/opt/slurm/bin/scontrol show nodes -F | grep -B5 $(hostname) | grep -oP '^NodeName=\\K(\\S+)'", :user=>'root').stdout.strip

  directory '/etc/sysconfig' do
    user 'root'
    group 'root'
    mode '0755'
  end

  file '/etc/sysconfig/slurmd' do
    content "SLURMD_OPTIONS='-N #{nodename}'"
    mode '0755'
    owner 'root'
    group 'root'
  end

  service "slurmd" do
    supports restart: true
    action %i[enable start]
  end
end
