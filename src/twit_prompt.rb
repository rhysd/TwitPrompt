#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ファイルの更新時間を見ればどこまでツイートを取れば良いか分かるので，ファイルに記録する必要はない

def config_twitter

    require 'rubygems' if RUBY_VERSION < "1.9"
    require 'twitter'
    require 'yaml'

    yaml = YAML.load(File.open('.twit_prompt_config.yml').read)
    Twitter.configure do |config|
        config.consumer_key = yaml['consumer_key']
        config.consumer_secret = yaml['consumer_secret']
        config.oauth_token = yaml['oauth_token']
        config.oauth_token_secret = yaml['oauth_token_secret']
    end

end

#
# main
#
if __FILE__ == $0 then

    config_twitter



end

