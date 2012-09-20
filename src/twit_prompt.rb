#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ファイルの更新時間を見ればどこまでツイートを取れば良いか分かるので，ファイルに記録する必要はない
# execute in background and quietly
Process.daemon true,true if %w[init update].any?{|a| a =~ /^#{ARGV[0]}/}

# methods to colorize
class String

    def self.methods_to_colorize(color_codes)
        color_codes.each do |color,code|
            define_method(color) do
                "\e[#{code}m#{self}\e[0m"
            end
        end
    end

    # private :colorize_method

    methods_to_colorize({
        dark_blue:   "0;34",
        dark_green:  "0;32",
        dark_cyan:   "0;36",
        dark_red:    "0;31",
        dark_purple: "0;35",
        dark_yellow: "0;33",
        red:         "1;31",
        blue:        "1;34",
        en:          "1;32",
        cyan:        "1;36",
        red:         "1;31",
        purple:      "1;35",
        yellow:      "1;33",
        black:       "0;30",
        dark_gray:   "0;37",
        gray:        "1;30",
        white:       "1;37"
    })

end

module TwitPrompt extend self

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
        last_update = File.exist?(TwitPromptTimelineData) ?
            File.atime(TwitPromptTimelineData) :
            Time.local(1900)
        File.open TwitPromptTimelineData,"w+" do |file|
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

    def reply?(text)
        text =~ /^#{UserName}/
    end

    def mention?(text)
        text.include? UserName
    end

    def rt?(text)
        text =~ /^RT @[a-zA-Z0-9_]+: /
    end

    def build_tweet(user,text,created_at)
        user = "@#{user}: ".dark_cyan
        text = text.gsub /\n/,' '
        text = text.include?(UserName) ? text.dark_green : text # whether mention or not
        created_at = ' [' + Time.new(created_at).strftime("%m/%d %T") + ']'
        created_at = created_at.dark_yellow
        user + text + created_at
    end

    def stored_timeline
        File.open TwitPromptTimelineData,"r" do |file|

        end
    end

    private :check_config,
            :config_twitter,
            :filtering?,
            :update_timeline,
            :build_tweet,
            :reply?,
            :mention?,
            :rt?

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


