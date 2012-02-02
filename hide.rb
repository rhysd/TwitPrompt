#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# main
#
if __FILE__ == $0 then

    lines = []
    File.open('twit_prompt.rb', 'r') do |file|
        lines = file.read.split "\n"
    end

    # File.open('twit_prompt.rb', 'w') do |file|
        lines.each do |line|
            if line =~ /^(\s+)config\.(\w+?)\s*=\s*'[0-9a-zA-Z-]+'\s*$/ 
                puts "#{$1}config.#{$2} = 'your_#{$2}'"
            elsif line =~ /^(\s*)bl_users = .*/
                puts "#{$1}bl_users = %w[]"
            elsif line =~ /^MyScreenName = "\w+"/
                puts 'MyScreenName = "your_screen_name"'
            else
                puts line
            end
        end
    # end

end

