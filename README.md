TwitPrompt
==========

#Summary:

This is Ruby script to display tweets on shell prompt


#Features:

- display latest tweet of your timeline on your shell prompt
- update automatically when stored tweets is run out
- tweet, retweet, fav
- filtering tweet using ruby
- execute `twit_prompt help` to get more information

#Requirements:

##Required gems

'twitter' and 'thor' is required.
execute `gem install twitter thor` before install twit\_prompt


##Twitter App Registration

Below keys is required to authenticate Twitter.
Visit https://dev.twitter.com/ and register your app to get keys.

- consumer key
- consumer secret key
- oauth key
- oauth secret key


#Installation:

Add twit\_prompt.rb in $PATH and add below to your .zshrc

    precmd(){
        twit_prompt.rb put
    }
    twit_prompt.rb init


#License:

##The MIT License

    Copyright (c) 2012 rhysd

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:


    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
    THE USE OR OTHER DEALINGS IN THE SOFTWARE.
