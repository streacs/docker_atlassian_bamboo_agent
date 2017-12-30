require 'spec_helper'
require 'serverspec'

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