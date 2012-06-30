#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ファイルの更新時間を見ればどこまでツイートを取れば良いか分かるので，ファイルに記録する必要はない
require 'rubygems' if RUBY_VERSION < '1.9'

# execute in background and quietly
Process.daemon true,true if %w[init update].any?{|a| a =~ /^#{ARGV[0]}/}

class String

    def self.colorize_method name,code
        define_method(name) do
            "\e[#{code}m#{self}\e[0m"
        end
    end

    # private :colorize_method

    colorize_method :dark_blue,   "0;34"
    colorize_method :dark_green,  "0;32"
    colorize_method :dark_cyan,   "0;36"
    colorize_method :dark_red,    "0;31"
    colorize_method :dark_purple, "0;35"
    colorize_method :dark_yellow, "0;33"
    colorize_method :red,         "1;31"
    colorize_method :blue,        "1;34"
    colorize_method :en,          "1;32"
    colorize_method :cyan,        "1;36"
    colorize_method :red,         "1;31"
    colorize_method :purple,      "1;35"
    colorize_method :yellow,      "1;33"
    colorize_method :black,       "0;30"
    colorize_method :dark_gray,   "0;37"
    colorize_method :gray,        "1;30"
    colorize_method :white,       "1;37"

end

module TwitPrompt
    class << self

        TwitPromptConfigDir = File.expand_path('~')+'/.twit_prompt'
        # TwitPromptCredentialFile = TwitPromptConfigDir+"/credential.yml"
        TwitPromptCredentialFile = '.twit_prompt_config.yml'
        TwitPromptTimelineData = "/tmp/timeline"
        UserName = "@Linda_pp"

        def check_config

            Dir.mkdir TwitPromptConfigDir unless File.exist? TwitPromptConfigDir
            unless File.exist? TwitPromptCredentialFile
                File.open(TwitPromptCredentialFile, "w") do |file|
                    file.print <<-EOS.gsub(/^\s+/, '')
                        # get app keys at https://dev.twitter.com/ and write them

                        consumer_key:       YourConsumerKey
                        consumer_secret:    YourConsumerSecretKey
                        oauth_token:        YourOAuthToken
                        oauth_token_secret: YourOAuthSecretToken
                    EOS

                    STDERR.puts "Configuration-keys are not found."
                    STDERR.puts "Write your consumer keys and OAuth keys to #{TwitPromptCredentialFile}"
                end
                system 'bash', '-c', (ENV['EDITOR'] || 'vi')+' "$@"', '--', TwitPromptCredentialFile
                false
            else
                true
            end

        end

        def config_twitter
            return if @already_authorized

            require 'twitter'
            require 'yaml'

            check_config

            yaml = YAML.load(File.open(TwitPromptCredentialFile).read)
            Twitter.configure do |config|
                config.consumer_key = yaml['consumer_key']
                config.consumer_secret = yaml['consumer_secret']
                config.oauth_token = yaml['oauth_token']
                config.oauth_token_secret = yaml['oauth_token_secret']
            end

            @already_authorized = true
        end

        def filtering? status
            false
        end

        def update_timeline
            config_twitter
            File.open TwitPromptTimelineData,"a+" do |file|
                content = file.read
                last_update = content.empty? ?
                                Time.local(1900) :
                                Time.new(content.split("\n").last)
                Twitter.home_timeline.reverse_each do |status|
                    break if status.created_at < last_update
                    unless filtering? status
                        user = status.user.screen_name
                        text = status.text.gsub /\n/,' '
                        created_at = status.created_at
                        file.puts created_at,user,text
                    end
                end
            end
        end

        def build_tweet user,text,created_at
            user = "@#{user}: ".dark_cyan
            text = text.gsub /\n/,' '
            text = text.include?(UserName) ? text.dark_green : text # whether mention or not
            created_at = ' [' + Time.new(created_at).strftime("%m/%d %T") + ']'
            created_at = created_at.dark_yellow
            user + text + created_at
        end


        private :check_config, :config_twitter, :filtering?, :update_timeline, :build_tweet

        def init(options)
            update_timeline
        end

        def put(options)
            puts build_tweet("Linda_pp","aiueo @Linda_pp kakikukeko sasissuseso","2012-06-30 11:35:36 +0900")
        end

        def update(options)
            update_timeline
        end

        def list(options)

        end

        def tweet(options,text)
            puts text
            puts "tweeted: #{text}" if options[:verbose]
        end

        def reply(options,text)
            puts "replied: #{text}" if options[:verbose]
        end

        def retweet(options)
            puts "retweeted: " if options[:verbose]
        end

        def fav(options)
            puts "faved: " if options[:verbose]
        end

        def config(options)
            if check_config
                puts "open #{TwitPromptCredentialFile}"
                system 'bash', '-c', (ENV['EDITOR'] || 'vi')+' "$@"', '--', TwitPromptCredentialFile
            end
        end

    end
end

require 'thor'
class TwitPromptApp < Thor

    private

    def self.delegate(name)
        define_method name do |*args|
            TwitPrompt::__send__ name,options,*args
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

    desc 'config', 'configure YAML setting file'
    delegate :config
end

#
# main
#
if __FILE__ == $0 then
    TwitPromptApp::start
end


