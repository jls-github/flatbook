# Introduction

Time to put everything together! We're going to create social media application, host it on Heroku, and lock it down with Authorization/Authentication. This guide will get your backend ready. A guide on creating the frontend that access this API can be found here: LINK TBD.

This guide assumes that you have already completed the previous labs on hosting and authorization.

# Code-Along

## Creating the Application

We'll be using Ruby 2.7.4 for this project. Make sure you're using this verison of Ruby before creating this application. You can verify this with the `rvm list` command. If 2.7.4 is installed, it will show up in the list. If it is your current version, it will be selected. If you do not have it installed, install it now with `rvm install 2.7.4`, and select it as your current version with `rvm use 2.7.4`.

You will also need Postgres installed on your computer for this lab.

Now we're ready to create our Rails API. Create the application with `rails new flatbook --api --database=postgresql`

Does this command look a little bit more compolicated to you than other rails commands? That's because we've added a couple of "flags". These are additional pieces of config that will save us time in creating our application.

The `--api` flag will cut out the aspects of Rails that we don't need, like creating views in our generators and removing some unnecessary middleware. See more information at their official documenation (https://guides.rubyonrails.org/api_app.html#creating-a-new-application)

The postgres flag configures our application to use Postgres by default. We won't be able to host with SQLite, so we will use Postgres here.

## Creating our First Resources

We'll create a couple of resources to get our app going. Below is an ERD of our models. Our data will be simple for now, just a user and posts. A user has many posts, and a post belongs to a user. Don't worry, we'll add more later. :)

### Creating Our User Resource

To create these resources, let's use the rails generator we've learned about earlier. `rails g resource User username`

This command will create a migration for a new table in our database called "users". That migration will include a username, defaulting to a string because we didn't give it a data type. It will also create a model and a controller for our User.

### Creating Our Post Resource

Now let's create our post resource. `rails g resource Post content user:references`

This command will similarly create a migration, model, and controller for our post. Note that we use `user:references` here, which will set up a foreign key on our posts table pointing to our users table.

Let's not forget to set up our posts>-users relationship macros! Navigate to the User Model and add your `has_many :posts` macro. Then navigate to your Post model and add your `belongs_to :user` macro.

### Testing our relationship

If you haven't already, go ahead and create your database and run your migrations. You can run these commands one after another with `rails db:create db:migrate`.

Now it's time to test our models. Head into your rails console and create a couple of users and a couple of posts. Make sure this relationship is set up just the way you want it to be. Developing a habit of testing as you go will save you a great deal of headache in your development career. :)

Go ahead and create some seeds in your db/seeds.rb file as well before continuing.

### Adding Controller Actions

Let's add a couple of controller actions now. For now, we want an index and create method on both of our resources.

First, let's set up a controller for our Post resource:

```ruby
# controllers/posts_controller.rb

class PostsController < ApplicationController

    def index
        posts = Post.all
        render json: posts
    end

    def create
        post = Post.create!(post_params)
        render json: post, status: :created
    end

    private

    def post_params
        params.require(:post).permit(:content, :user_id)
    end

end

```

Now, let's set up the controller for our User resource.

```ruby
# controlers/users_controller.rb

class UsersController < ApplicationController

    def index
        users = User.all
        render json: users
    end

    def create
        user = User.create!(user_params)
        render json: user, status: :created
    end

    private

    def user_params
        params.require(:user).permit(:username)
    end

end
```

One more thing. Let's make sure we limit our routes to only accept requests for our index and create actions.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  resources :posts, only: [:index, :create]
  resources :users, only: [:index, :create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

```

We can verify that our routes are correct using the `rails routes` CLI command. Additionally, make sure to test your routes via Postman before continuing on. Remember, test as you go!

## Hosting the Application on Heroku

Heroku is a service where we can host our Rails server.

### Setting up Heroku

If you haven't already, sign up for a Heroku account here: https://signup.heroku.com/

You will also need to download the Heroku CLI. This will give us a variety of tools we can use to manage our application directly from our terminal. You can download the Heroku CLI using the instructions on this page: https://devcenter.heroku.com/articles/heroku-cli. Note: If you're on Windows using WSL, make sure to follow the Ubuntu instructions, not the Windows instructions.

Now let's put the Heroku CLI to use. We're going to log into Heroku using the CLI. To do so, use the `heroku login` command in your terminal. This will give you instructions for logging into your account. Once you've done so, you're good to go!

### Setting up Your Heroku Server

Before we host our application on Heroku, we need to make our Rails application compatible with our Heroku server. In your terminal, run the following command: `bundle lock --add-platform x86_64-linux --add-platform ruby`. This command allows your Rails application to run on the linux platform used by our Heroku server. If you do not run this command, you will receive an error that says `Failed to install gems via Bundler.`

Now we need to create our Heroku server. We will again use the Heroku CLI to do so. The `heroku create` command will create a Heroku server for our current folder. Run `heroku create` in your terminal.

You'll notice that the `heroku create` comand gives you a url. That is the url where your server is hosted. Typing `heroku open` will also open your browser to that url.

Now we can push our code to Heroku. We are going to use git to push our code to Heroku. Just like you push your code to Github, you can also use git to push your code elsewhere. **You will still push your code to Github as well.** Github is used for version control. Heroku is used to host your server.

To push our code to Heroku, we need to specify our branch name and our origin. `git push <branch-name> <origin>`. Your branch name will either be 'main' or 'master'. When you follow the instructions to push your code to Github, your primary branch is automatically renamed to main. However, if you have not yet pushed your code to Github, you will have to use master. The origin will always be 'heroku'. With that in mind, run the following command to push your codebase to Heroku.

`git push heorku main`

You'll notice that the terminal outputs steps of the build process. All of that is taking place on your Heroku server. Once that is finished, you can run `heroku open` to open your server in your browser.

We can also access our rails server remotely. If you run `heroku run <command>`, it will run that command on your rails server. Some helpful commands will be:

- `heroku run bundle exec rails db:migrate` - to run our database migrations
- `heroku run bundle exec rails db:seed` - to seed our database
- `heroku run bundle exec rails console` - to access our heroku server's rails console
- `heroku run bash` - to access a bash terminal on our server

Let's go ahead and run our migrations and seeds. Note: You won't have to create the database on your Heroku server. That is already set up for you. Run the following command to migrate and seed your database.

`heroku run bundle exec rails db:migrate db:seed`

Your heroku server is good to go! Any time you want to push your updates to the server, simply run `git push heroku main` again, and those updates will be propogated on your server.

### Setting up a CORS Policy

CORS stands for Cross-Origin Resource Sharing. a CORS policy defines which domains can make requests to your backend via a browser. CORS policies do not actually protect your backend resources, as requests made outside of a browser ignore CORS policies. Instead, they protect your frontend from Cross-Site Request Forgery (CSRF) attacks. Whenever we host our applications, we need to add a CORS policy so that our frontends aren't vulnerable.

First, we need to add a gem in our Gemfile. In the standard Rails buildout, in your Gemfile on line 26, there is a gem called rack-cors that is commented out. Go ahead and uncomment that gem and run bundle install.

Second, we need to add an initializer that holds our CORS policy. Initializers are files that hold config for our Rails application. These files are run after the Rails framework is loaded and any gems or plugins are installed. They can be found in config/initializers.rb.

Within config/initializers.rb, you should have a file called cors.rb.

After the initial documentation section, comment back in the actual rails config section (starting with `Rails.application.config.middleware....`). Line 10 specifies origins that you will allow to access your backend. By default, example.com is listed. When we have completed our application, we will list our frontend's url here. For now, though, go ahead and put a wildcared (\*) for the allowed origin. This will allow any origin to access our API. We will change this in the future to provide more security.

Your CORS initializer should look like this:

```ruby
# config/initializers/cors.rb

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Our CORS policy is now set up to allow any URL origin to access our backend.

## Authorization/Authentication

Now we're ready to set up auth in our application. We'll be authenticating based on jwt tokens sent in an Authorization header.

If you are unfamiliar with `bcrypt` or jwt tokens, please take a break from this guide and read through this Canvas page before continuing: https://my.learn.co/courses/262/assignments/12052?module_item_id=26733.

### Configuring Our User Model

First, we need to set up our user. We'll need a gem to do so. In your Gemfile, there should be a gem called `bcrypt` that is commented out. Comment that gem back in and run `bundle install`.

We now need to add a password field to our User model. We are going to store this in our database as a password_digest instead of a password, as the password we keep is going to be hashed by that `bcrypt` gem we just added. Let's make a migration to add this column to our users table.

`rails g migration AddPasswordDigestToUsers password_digest`

The migration generated by this command should look like this:

```ruby
class AddPasswordDigestToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :password_digest, :string
  end
end
```

Go ahead and run this migration with `rails db:migrate`.

Great! Now we just need to hook up our `bcrypt` gem with our User model. We're going to add the has_secure_password to our User model to do so. We will also add a validation to our user model to make sure that two users cannot be created with the same name.

```ruby
# models/user.rb
class User < ApplicationRecord
    has_secure_password
    validates :username, uniqueness: { case_sensitive: false }
    has_many :posts, dependent: :destroy
end
```

Our User model is all set up to accept passwords now. We can now add the password field to our User#create contorller action.

```ruby
#controllers/users_controller.rb
class UsersController < ApplicationController

    def index
        users = User.all
        render json: users
    end

    def create
        @user = User.create(user_params)
        if @user.valid?
            render json: { user: @user }, status: :created
        else
            render json: { error: 'failed to create user' }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        {username: params["username"], password: params["password"], password_confirmation: params["password_confirmation"]}
    end

end
```

You'll notice that we accept a `password` and `password_confirmation` instead of a `password_digest`. We do that because `bcrypt` will take those passwords and check them against the hashed `password_digest` in our database. We will never directly access our `password_digest`. Additionally, `bcrypt` will ensure that `password` matches `password_confirmation`. This is purely optional. We can enter just one password if we want to.

One last thing: Make sure to edit any User seeds you've created to accept a password as well.

### Creating Tokens on Login

Before we lock down our API, we need to create some way for a user to gain access to a token. When a user logs in, we will create a JWT token that contains their user_id. They will then send that token whenever they're requesting secure data from our API.

First, we need to add the `jwt` gem to our Gemfile. This library will handle the encoding and decoding of our JWT tokens throughout our application.

In our `ApplicationController`, we'll add a public method that will allow us to easily encode the tokens we want to send back to the frontend. Because all of our controllers inherit from this controller, all of our controllers will also be able to access our `encode_token` method.

```ruby
# controllers/application_controller.rb

class ApplicationController < ActionController::API

    def encode_token(payload)
        JWT.encode(payload, 'my_s3cr3t') # make sure to hide your secret in an environment variable before hosting your application!
    end

end
```

Next, let's create a controller for our sessions. This controller will handle our login endpoint. Create a controller called SessionsController with a `create` action. We'll also create a "/signup" endpoint that points to this action.

```ruby
# controllers/sessions_controller.rb
class SessionsController < ApplicationController

    def create

    end

end
```

```ruby
# config/routes.rb

Rails.application.routes.draw do
  resources :posts, only: [:index, :create]
  resources :users, only: [:index, :create]
  post "/login", to: "sessions#create"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

We can now build our `Session#create` method. First, we will find a user based on the username we receive. We will then use the `authenticate` method given to use by `bcrypt` to verify that our user's password matches their username. If the user doesn't exist or the password doesn't match, we'll send back and `unauthorized` status to our user. If they do match up, we'll create a token with the `encode_token` method we created earlier and send it back to the user.

```ruby
# controllers/sessions_controller.rb

class SessionsController < ApplicationController

    def create
      @user = User.find_by(username: user_login_params[:username])
      if @user && @user.authenticate(user_login_params[:password])
        token = encode_token({ user_id: @user.id })
        render json: { user: @user, jwt: token }, status: :accepted
      else
        render json: { message: 'Invalid username or password' }, status: :unauthorized
      end
    end

    private

    def user_login_params
      params.require(:user).permit(:username, :password)
    end

end
```

A client that consumes our API can now send a POST request to this endpoint with a correct username and password and receive back a corresponding token. The client should store that token somewhere (localStorage or sessionStorage) and send it back with every request in an Authorization header. They'll also add the word "Bearer" before their token to match standard convention The header should look something like this: `Authorization: Bearer <token>`

### Securing Our Application with JWT Tokens

We're now ready to secure the rest of our application with JWT tokens.

To do so, we're going to build out two public methods and several private methods within our Application Controller.

- `current_user` will return the user associated with a particular token.
- `authorized` will return a boolean value based on whether or not a user has sent a token corresponding with a user. If a user does not exist for the given token, or if no token was received, we will immediately respond with an `unauthorized` status. We will call this method before our secure endpoints using the `before_all` hook.

Additionally, we will create several private methods

- `auth_header` will return the received Authorization header.
- `header_token` will extract the token from the `auth_header`.
- `decoded_token` will return a user_id based on our `header_token`.
- `valid_token?` will return a boolean based on whether or not the token is valid or not.
- `logged_in?` will return a boolean based on whether or not a current_user can be found in the database corresponding to the received token.
- `unauthorized_user_response` will render an unauthorized response to the user if their token is not valid or they are not logged in.

Last, but certainly not least, we will add our `authorized` method to our before_all hook. Rails will now call our `authorized` method before any of our resources can be accessed.

```ruby
# controllers/application_controller.rb

class ApplicationController < ActionController::API
    before_action :authorized

    def encode_token(payload)
        JWT.encode(payload, 'my_s3cr3t') # make sure to hide your secret in an environment variable before hosting your application!
    end

    def current_user
        user_id = decoded_token[0]['user_id']
        @cached_current_user ||= User.find_by(id: user_id)
    end

    def authorized
        unauthorized_user_response unless valid_token? && logged_in?
    end

    private

    def auth_header
        @cached_auth_header ||= request.headers['Authorization']
    end

    def header_token
        @cached_header_token ||= auth_header.split(' ')[1]
    end

    def decoded_token
        begin
            @cached_decoded_token ||= JWT.decode(header_token, 'my_s3cr3t', true, algorithm: 'HS256')
        rescue JWT::DecodeError
            nil
        end
    end

    def valid_token?
        !!(auth_header && header_token && decoded_token)
    end

    def logged_in?
        !!current_user
    end

    def unauthorized_user_response
        render json: { message: 'Please log in' }, status: :unauthorized
    end

end
```

Note: You may notice that we are using instance variables and the `||=` operator in several of our private methods. We do so because we want to cache the return values of our methods in case we call these methods more than once in the same request/response cycle. For example, we will call all of these methods in our `valid_token` method, and we will call them again in our `current_user` method. Our instance variable will save our data from the earlier run of that method, and our `||=` operator will return that value. If that value doesn't yet exist, it will set it equal to the second half of the expression.

Our API will now make sure that a valid token is received before it allows access to any of its controllers.

There is one problem, however. Our `UsersController#create` and `SesssionsController#create` methods are also locked behind a token. Because those are the endpoints we use to signup and login, we want to skip our before_action hook on those methods. We can do so by adding the `skip_before_action` macro at the top of those controllers.

```ruby
# controllers/users_controller.rb

class UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def index
        users = User.all
        render json: users
    end

    def create
        @user = User.create(user_params)
        if @user.valid?
            render json: { user: @user }, status: :created
        else
            render json: { error: 'failed to create user' }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        {username: params["username"], password: params["password"], password_confirmation: params["password_confirmation"]}
    end

end
```

```ruby
# controllers/sessions_controller.rb

class SessionsController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def create
        @user = User.find_by(username: user_login_params[:username])
        if @user && @user.authenticate(user_login_params[:password])
          token = encode_token({ user_id: @user.id })
          render json: { user: @user, jwt: token }, status: :accepted
        else
          render json: { message: 'Invalid username or password' }, status: :unauthorized
        end
      end

      private

      def user_login_params
        params.require(:user).permit(:username, :password)
      end

end
```

We're finally finished! Our API is now secured with JWT Tokens! We've come a long way. Take a few minutes to appreciate your progress.

As you know by now, there is always more to do when it comes to programming. Here are some helpful next steps for your API.

1. Create a User Serializer. Did you notice that we're still sending back all of the data for our users? We probably shouldn't send back their id or password_digest. Create a User Serializer to filter those attributes out.
2. Send back a token in our ```User#create``` response. 
3. If you're really in for a challenge, set up some different roles and access levels for your users. 

Next, we'll move on to creating a frontend that consumes this API.
