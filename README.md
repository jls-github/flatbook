# Introduction

Time to put everything together! We're going to create social media application, host it on Heroku, and lock it down with Authorization/Authentication. This guide will get your backend ready. A guide on creating the frontend that access this API can be found here: LINK TBD.

This guide assumes that you have already completed the previous labs on hosting and authorization.

# Code-Along

## Creating the Application

We'll be using Ruby 2.7.4 for this project. Make sure you're using this verison of Ruby before creating this application. You can verify this with the ```rvm list``` command. If 2.7.4 is installed, it will show up in the list. If it is your current version, it will be selected. If you do not have it installed, install it now with ```rvm install 2.7.4```, and select it as your current version with ```rvm use 2.7.4```.

You will also need Postgres installed on your computer for this lab. 

Now we're ready to create our Rails API. Create the application with ```rails new flatbook --api --database=postgresql```

Does this command look a little bit more compolicated to you than other rails commands? That's because we've added a couple of "flags". These are additional pieces of config that will save us time in creating our application.

The ```--api``` flag will cut out the aspects of Rails that we don't need, like creating views in our generators and removing some unnecessary middleware. See more information at their official documenation (https://guides.rubyonrails.org/api_app.html#creating-a-new-application)

The postgres flag configures our application to use Postgres by default. We won't be able to host with SQLite, so we will use Postgres here.

## Creating our First Resources

We'll create a couple of resources to get our app going. Below is an ERD of our models. Our data will be simple for now, just a user and posts. A user has many posts, and a post belongs to a user. Don't worry, we'll add more later. :)

### Creating Our User Resource

To create these resources, let's use the rails generator we've learned about earlier. ```rails g resource User username```

This command will create a migration for a new table in our database called "users". That migration will include a username, defaulting to a string because we didn't give it a data type. It will also create a model and a controller for our User.

### Creating Our Post Resource

Now let's create our post resource. ```rails g resource Post content user:references```

This command will similarly create a migration, model, and controller for our post. Note that we use ```user:references``` here, which will set up a foreign key on our posts table pointing to our users table. 

Let's not forget to set up our posts>-users relationship macros! Navigate to the User Model and add your ```has_many :posts``` macro. Then navigate to your Post model and add your ```belongs_to :user``` macro.

### Testing our relationship

If you haven't already, go ahead and create your database and run your migrations. You can run these commands one after another with ```rails db:create db:migrate```.

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

We can verify that our routes are correct using the ```rails routes``` CLI command. Additionally, make sure to test your routes via Postman before continuing on. Remember, test as you go!

## Hosting the Application on Heroku

Heroku is a service where we can host our Rails server. 

### Setting up Heroku

If you haven't already, sign up for a Heroku account here: https://signup.heroku.com/

You will also need to download the Heroku CLI. This will give us a variety of tools we can use to manage our application directly from our terminal. You can download the Heroku CLI using the instructions on this page: https://devcenter.heroku.com/articles/heroku-cli. Note: If you're on Windows using WSL, make sure to follow the Ubuntu instructions, not the Windows instructions.

Now let's put the Heroku CLI to use. We're going to log into Heroku using the CLI. To do so, use the ```heroku login``` command in your terminal. This will give you instructions for logging into your account. Once you've done so, you're good to go!

### Setting up Your Heroku Server

Before we host our application on Heroku, we need to make our Rails application compatible with our Heroku server. In your terminal, run the following command: ```bundle lock --add-platform x86_64-linux --add-platform ruby```. This command allows your Rails application to run on the linux platform used by our Heroku server. If you do not run this command, you will receive an error that says ```Failed to install gems via Bundler.```

Now we need to create our Heroku server. We will again use the Heroku CLI to do so. The ```heroku create``` command will create a Heroku server for our current folder. Run ```heroku create``` in your terminal. 

You'll notice that the ```heroku create``` comand gives you a url. That is the url where your server is hosted. Typing ```heroku open``` will also open your browser to that url.

Now we can push our code to Heroku. We are going to use git to push our code to Heroku. Just like you push your code to Github, you can also use git to push your code elsewhere. **You will still push your code to Github as well.** Github is used for version control. Heroku is used to host your server.

To push our code to Heroku, we need to specify our branch name and our origin. ```git push <branch-name> <origin>```. Your branch name will either be 'main' or 'master'. When you follow the instructions to push your code to Github, your primary branch is automatically renamed to main. However, if you have not yet pushed your code to Github, you will have to use master. The origin will always be 'heroku'. With that in mind, run the following command to push your codebase to Heroku.

```git push heorku main```

You'll notice that the terminal outputs steps of the build process. All of that is taking place on your Heroku server. Once that is finished, you can run ```heroku open``` to open your server in your browser.

We can also access our rails server remotely. If you run ```heroku run <command>```, it will run that command on your rails server. Some helpful commands will be: 
- ```heroku run bundle exec rails db:migrate``` - to run our database migrations
- ```heroku run bundle exec rails db:seed``` - to seed our database
- ```heroku run bundle exec rails console``` - to access our heroku server's rails console
- ```heroku run bash``` - to access a bash terminal on our server

Let's go ahead and run our migrations and seeds. Note: You won't have to create the database on your Heroku server. That is already set up for you. Run the following command to migrate and seed your database.

```heroku run bundle exec rails db:migrate db:seed```

Your heroku server is good to go! Any time you want to push your updates to the server, simply run ```git push heroku main``` again, and those updates will be propogated on your server. 

### Setting up a CORS Policy

CORS stands for Cross-Origin Resource Sharing. a CORS policy defines which domains can make requests to your backend via a browser. CORS policies do not actually protect your backend resources, as requests made outside of a browser ignore CORS policies. Instead, they protect your frontend from Cross-Site Request Forgery (CSRF) attacks. Whenever we host our applications, we need to add a CORS policy so that our frontends aren't vulnerable.

First, we need to add a gem in our Gemfile. In the standard Rails buildout, in your Gemfile on line 26, there is a gem called rack-cors that is commented out. Go ahead and uncomment that gem and run bundle install.

Second, we need to add an initializer that holds our CORS policy. Initializers are files that hold config for our Rails application. These files are run after the Rails framework is loaded and any gems or plugins are installed. They can be found in config/initializers.rb.

Within config/initializers.rb, you should have a file called cors.rb.

After the initial documentation section, comment back in the actual rails config section (starting with ```Rails.application.config.middleware....```). Line 10 specifies origins that you will allow to access your backend. By default, example.com is listed. When we have completed our application, we will list our frontend's url here. For now, though, go ahead and put a wildcared (*) for the allowed origin. This will allow any origin to access our API. We will change this in the future to provide more security.

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
