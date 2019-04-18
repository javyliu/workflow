#source 'https://ruby.taobao.org'
#source 'http://ruby.taobao.org'
source 'http://gems.ruby-china.com/'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#
# for the queue job and recurring job
gem 'sidekiq'
#for sidekiq monitoring
gem 'sinatra',require: false
#gem 'sidetiq'
gem 'whenever',require: false


#webui
gem 'foundation-rails'
#for mail receive
#
#handle html or xml
gem 'nokogiri'

#for draper
gem 'draper'
#server
gem 'puma'
#gem 'passenger'

#for memcache
gem 'dalli'

#for role authentication
#gem 'cancan'
gem 'cancancan', '~> 1.10'

#my lib
#gem 'javy_tool',path: '../gems/javy_tool'
#gem 'javy_tool',git: 'https://github.com/javyliu/javy_tool.git'
gem 'javy_tool',github: 'javyliu/javy_tool', branch: 'master'

#paginate
gem 'kaminari'

#inline editor
gem 'rest_in_place'

#for role_making
#gem 'role_making',path: '../gems/role_making'
#gem 'role_making',git: 'https://github.com/javyliu/role_making.git'
gem 'role_making',github: 'javyliu/role_making', branch: 'master'

gem 'rails_kindeditor'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'
  #gem 'annotate'

	gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'guard-livereload', '~> 2.4', require: false


  # Access an IRB console on exception pages or by using <%= console %> in views
  #gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  #annotate
  gem 'annotate','~>2.6.4'
end

