require 'spec_helper'
require 'serverspec'

describe group('bamboo') do
  it { should exist }
end

describe user('bamboo') do
  it { should exist }
  it { should belong_to_group 'bamboo' }
  it { should have_home_directory '/home/bamboo' }
  it { should have_login_shell '/bin/false' }
end

describe file('/home/bamboo') do
  it { should be_directory }
  it { should be_owned_by 'bamboo' }
  it { should be_grouped_into 'bamboo' }
end

describe file('/opt/atlassian/bamboo') do
  it { should be_directory }
  it { should be_owned_by 'bamboo' }
  it { should be_grouped_into 'bamboo' }
end

describe file('/var/opt/atlassian/application-data/bamboo') do
  it { should be_directory }
  it { should be_owned_by 'bamboo' }
  it { should be_grouped_into 'bamboo' }
end

describe file('/var/opt/atlassian/application-data/bamboo') do
  it { should be_directory }
  it { should be_owned_by 'bamboo' }
  it { should be_grouped_into 'bamboo' }
end

describe file('/opt/atlassian/bamboo/conf/wrapper.conf') do
  it { should contain 'wrapper.java.initmemory=2048' }
  it { should contain 'wrapper.java.maxmemory=4096' }
  it { should contain 'wrapper.app.parameter.2=https://build.streacs.com/agentServer' }
  it { should contain '-DDISABLE_AGENT_AUTO_CAPABILITY_DETECTION=false' }
end