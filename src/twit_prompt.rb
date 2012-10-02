#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# encoding: utf-8

# Monkey patch to making String colorful
class String # {{{

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
# }}}

# app's config
module TwitPromptConfig extend self # {{{
  Root = File.expand_path('~')+'/.twit_prompt'
  # File = TwitPromptConfigDir+"/credential.yml"
  Setting = '.twit_prompt_config.yml'
  Cache = "/tmp/timeline"
  ScreenName = "@Linda_pp"

  def check_config
    Dir.mkdir Root unless Dir.exist? Root
    unless File.exist? Setting
      File.open(Setting, "w") do |file|
        file.print <<-EOS.gsub(/^\s+/, '')
                        # get app keys at https://dev.twitter.com/ and write them
                        consumer_key:       YourConsumerKey
                        consumer_secret:    YourConsumerSecretKey
                        oauth_token:        YourOAuthToken
                        oauth_token_secret: YourOAuthSecretToken
        EOS

        STDERR.puts "Configuration-keys are not found."
        STDERR.puts "Write your consumer keys and OAuth keys to #{Setting}"
      end
      system 'bash', '-c', (ENV['EDITOR'] || 'vi')+' "$@"', '--', Setting
    end
  end

  def config_twitter
    require 'twitter'
    require 'yaml'

    check_config

    yaml = YAML.load(File.open(Setting).read)
    Twitter::client.new(
      consumer_key: yaml['consumer_key'],
      consumer_secret: yaml['consumer_secret'],
      oauth_token: yaml['oauth_token'],
      oauth_token_secret: yaml['oauth_token_secret']
    )
  end

  private :check_config, :config_twitter

  def client
    @client ||= config_twitter
  end

end
# }}}

# maintain timeline cache
class Timeline # {{{

  def head
    # head of cached tweets
    #  not implemented
  end

  def all
    # list of cached tweets
    # not implemented
  end

  def construct
    File.delete(TwitPromptConfig::Setting)
    update
  end

  def update
    Process.daemon true,true
    # not implemented
    # get timelines from the file
    twitter = TwitPromptConfig::client
    last_update = File.exist?(@cache) ?
      File.atime(TwitPromptConfig::Cache) :
      Time.local(1900)
    File.open(TwitPromptConfig::Cache,"w+") do |file|
      twitter.home_timeline.reverse_each do |status|
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

  private :update

end
# }}}

# Main module {{{
module TwitPrompt extend self

  @timeline = Timeline.new
  @screen_name = TwitPromptConfig::ScreenName

  def filtering? status
    false
  end

  def reply?(text)
    text =~ /^#{@screen_name}/
  end

  def mention?(text)
    text.include? @screen_name
  end

  def rt?(text)
    text =~ /^RT @[a-zA-Z0-9_]+: /
  end

  def build_tweet(user,text,created_at)
    user = "@#{user}: ".dark_cyan
    text = text.gsub /\n/,' '
    text = text.include?(@screen_name) ? text.dark_green : text # whether mention or not
    created_at = ' [' + Time.new(created_at).strftime("%m/%d %T") + ']'
    created_at = created_at.dark_yellow
    user + text + created_at
  end

  private :filtering?,
          :build_tweet,
          :reply?,
          :mention?,
          :rt?

  def init(options)
    @timeline.construct
  end

  def prompt(options)
    puts build_tweet("Linda_pp","aiueo @Linda_pp kakikukeko sasissuseso","2012-06-30 11:35:36 +0900")
  end

  def listup(options)

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
    system 'bash', '-c', (ENV['EDITOR'] || 'vi')+' "$@"', '--', TwitPromptConfig::Setting
  end

end
# }}}

# Interface {{{
require 'thor'
class TwitPromptApp < Thor

  private

  def self.def_command(name)
    define_method name do |*args|
      TwitPrompt::__send__ name,options,*args
    end
  end

  def self.verbose_option
    method_option :verbose, :type => :boolean, :aliases => '-v', :default => true, :desc => 'output result'
  end

  public

  desc 'init', 'initialize timeline cache'
  def_command :init

  desc 'prompt', 'show a tweet for a shell prompt'
  def_command :prompt

  desc 'listup', 'show timeline to stdout'
  def_command :listup

  desc 'tweet [TEXT]', 'tweet TEXT'
  def_command :tweet

  desc 'reply [TEXT]', 'reply to last-displayed tweet'
  verbose_option
  def_command :reply

  desc 'retweet', 'retweet last-displayed tweet'
  verbose_option
  def_command :retweet

  desc 'fav', 'add last-desplayed tweet to favorite tweets'
  verbose_option
  def_command :fav

  desc 'config', 'configure YAML setting file'
  def_command :config
end
# }}}

#
# main
#
if __FILE__ == $0 then
  TwitPromptApp::start
end


