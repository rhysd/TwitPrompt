#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ファイルの更新時間を見ればどこまでツイートを取れば良いか分かるので，ファイルに記録する必要はない
require 'rubygems' if RUBY_VERSION < '1.9'

module TwitPrompt
    class << self

        TwitPromptConfigDir = File.expand_path('~')+'/.twit_prompt'
        TwitPromptCredentialFile = TwitPromptConfigDir+"/credential.yml"
        TwitPromptTimelineData = TwitPromptConfigDir+"/timeline"
        TwitPromptCredentialTmp = '.twit_prompt_config.yml'

        def check_config

            Dir.mkdir TwitPromptConfigDir unless File.exist? TwitPromptConfigDir
            unless File.exist? TwitPromptCredentialFile
                File.open(TwitPromptCredentialFile, "w") do |file|
                    text = <<-EOF
consumer_key:       YourConsumerKey
consumer_secret:    YourConsumerSecretKey
oauth_token:        YourOAuthToken
oauth_token_secret: YourOAuthSecretToken
                    EOF
                    file.print text

                    STDERR.puts "Configuration-keys are not found."
                    STDERR.puts "Write your consumer keys and OAuth keys to #{TwitPromptCredentialFile}"
                    exit
                end
            end

        end

        def config_twitter

            require 'twitter'
            require 'yaml'

            check_config

            yaml = YAML.load(File.open(TwitPromptCredentialTmp).read)
            Twitter.configure do |config|
                config.consumer_key = yaml['consumer_key']
                config.consumer_secret = yaml['consumer_secret']
                config.oauth_token = yaml['oauth_token']
                config.oauth_token_secret = yaml['oauth_token_secret']
            end

        end

        def init(options)

        end

        def put(options)

        end

        def update(options)

        end

        def list(options)

        end

        def tweet(options,text)
            puts text
            puts "tweeted: #{text}" if options[:verbose]
        end

        def reply(options,text)
            puts "replyed: #{text}" if options[:verbose]
        end

        def retweet(options)
            puts "retweeted: " if options[:verbose]
        end

        def fav(options)
            puts "faved: " if options[:verbose]
        end

    end
end

require 'thor'

class TwitPromptApp < Thor

    private

    def self.delegate(name)
        define_method name do |*args|
            TwitPrompt.send name,options,*args
        end
    end

    def self.verbose_option
        method_option :verbose, :type => :boolean, :aliases => '-v', :default => true, :desc => 'output result'
    end

    public

    desc 'init', 'initialize timeline data'
    delegate :init

    desc 'put', 'get a tweet from data'
    delegate :put

    desc 'update', 'update timeline'
    delegate :update

    desc 'list', 'display timeline to stdout'
    delegate :list

    desc 'tweet [TEXT]', 'tweet'
    delegate :tweet

    desc 'reply [TEXT]', 'reply to last-displayed tweet'
    verbose_option
    delegate :reply

    desc 'retweet', 'retweet last-displayed tweet'
    verbose_option
    delegate :retweet

    desc 'fav', 'add last-desplayed tweet to favorite tweets'
    verbose_option
    delegate :fav

end

#
# main
#
if __FILE__ == $0 then
    TwitPromptApp.start
end


