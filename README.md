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

## Hosting the application on Heroku

Heroku is a service where we can host our Rails server. 

### Setting up Heroku

If you haven't already, sign up for a Heroku account here: https://signup.heroku.com/

You will also need to download the Heroku CLI. This will give us a variety of tools we can use to manage our application directly from our terminal. You can download the Heroku CLI using the instructions on this page: https://devcenter.heroku.com/articles/heroku-cli. Note: If you're on Windows using WSL, make sure to follow the Ubuntu instructions, not the Windows instructions.

Now let's put the Heroku CLI to use. We're going to log into Heroku using the CLI. To do so, use the ```heroku login``` command in your terminal. This will give you instructions for logging into your account. Once you've done so, you're good to go!

### Setting up your Heroku server

Before we host our application on Heroku, we need to make our Rails application compatible with our Heroku server. In your terminal, run the following command: ```bundle lock --add-platform x86_64-linux --add-platform ruby```. This command allows your Rails application to run on the linux platform used by our Heroku server. If you do not run this command, you will receive an error that says ```Failed to install gems via Bundler.```

Now we need to create our Heroku server. We will again use the Heroku CLI to do so. The ```heroku create``` command will create a Heroku server for our current folder. Run ```heroku create``` in your terminal. 

You'll notice that the ```heroku create``` comand gives you a url. That is the url where your server is hosted. Typing ```heroku open``` will also open your browser to that url.

Now we can push our code to Heroku. We are going to use git to push our code to Heroku. Just like you push your code to Github, you can also use git to push your code elsewhere. **You will still push your code to Github as well.** Github is used for version control. Heroku is used to host your server.

To push our code to Heroku, we need to specify our branch name and our origin. ```git push <branch-name> <origin>```. Your branch name will either be 'main' or 'master'. When you follow the instructions to push your code to Github, your primary branch is automatically renamed to main. However, if you have not yet pushed your code to Github, you will have to use master. The origin will always be 'heroku'. With that in mind, run the following command to push your codebase to Heroku.

```git push heorku main```

You'll notice that the terminal outputs steps of the build process. All of that is taking place on your Heroku server. Once that is finished, you can run ```heroku open``` to open your server in your browser.

We can also access our rails server remotely. If you run ```heroku run <command>```, it will run that command on your rails server. Some helpful commands will be: 
- ```heroku run rails db:migrate``` - to run our database migrations
- ```heroku run rails db:seed``` - to seed our database
- ```heroku run rails console``` - to access our heroku server's rails console
- ```heroku run bash``` - to access a bash terminal on our server

Let's go ahead and run our migrations and seeds. Note: You won't have to create the database on your Heroku server. That is already set up for you. Run the following command to migrate and seed your database.

```heroku run rails db:migrate db:seed```

Your heroku server is good to go! Any time you want to push your updates to the server, simply run ```git push heroku main``` again, and those updates will be propogated on your server. 

## Setting up a CORS Policy

Now we're read
