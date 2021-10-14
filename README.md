## Creating the Application

Create the application with ```rails new flatbook --api --database=postgresql```

- The ```--api``` flag will cut out the aspects of Rails that we don't need, like creating views in our generators and removing some unnecessary middleware. See more information at their official documenation (https://guides.rubyonrails.org/api_app.html#creating-a-new-application)
- The postgres flag configures our application to use Postgres by default. We won't be able to host with SQLite, so we will use Postgres here.

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

