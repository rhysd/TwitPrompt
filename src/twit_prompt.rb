#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ファイルの更新時間を見ればどこまでツイートを取れば良いか分かるので，ファイルに記録する必要はない
TwitPromptConfigDir = File.expand_path('~')+'.twit_prompt'
TwitPromptCredentialFile = TwitPromptConfigDir+"/credential.yml"
TwitPromptTimelineData = TwitPromptConfigDir+"/timeline"
TwitPromptCredentialTmp = '.twit_prompt_config.yml'

def config_twitter

    require 'rubygems' if RUBY_VERSION < "1.9"
    require 'twitter'
    require 'yaml'

    yaml = YAML.load(File.open(TwitPromptCredentialTmp).read)
    Twitter.configure do |config|
        config.consumer_key = yaml['consumer_key']
        config.consumer_secret = yaml['consumer_secret']
        config.oauth_token = yaml['oauth_token']
        config.oauth_token_secret = yaml['oauth_token_secret']
    end

end



require 'thor'

class TwitPrompt < Thor

    desc 'init', 'initialize timeline data'
    def init

    end

    desc 'put', 'get a tweet from data'
    def one_tweet

    end

    desc 'update', 'update timeline'
    def update

    end

    desc 'list', 'display timeline to stdout'
    def list

    end

    desc 'tweet [TEXT]', 'tweet'
    method_option :verbose, :aliases => '-v', :default => false, :desc => 'output result'
    def tweet(text)
        puts text
    end

    desc 'reply [TEXT]', 'reply to last-displayed tweet'
    method_option :verbose, :aliases => '-v', :default => false, :desc => 'output result'
    def reply(text)

    end

    desc 'retweet', 'retweet last-displayed tweet'
    method_option :verbose, :aliases => '-v', :default => false, :desc => 'output result'
    def retweet

    end

    desc 'fav', 'add last-desplayed tweet to favorite tweets'
    method_option :verbose, :aliases => '-v', :default => false, :desc => 'output result'
    def fav

    end

end

#
# main
#
if __FILE__ == $0 then
    TwitPrompt.start
end


