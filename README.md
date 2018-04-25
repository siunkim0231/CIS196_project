# Homework 8: Facebook Lite
Due **March 20, 2018 at 11:59pm**

## Before Starting
Be sure to review <a href="https://www.seas.upenn.edu/~cis196/lectures/CIS196-2018s-lecture8.pdf" target="_blank">lecture 8</a>.

## Task
This assignment is designed to help you become more comfortable with Advanced Active Record Queries, Validations, and Sessions.

You will implement a subset of Facebook features including login, friending, and creating statuses.

You can run `rails console` (or `rails c`) to bring up an interactive console that will allow you to directly create students, courses, and reviews. However, you will also be able to run `rails server` (or `rails s`) and visit http://localhost:3000 to see your code in action! Note that you must have the server running in order to be able to visit localhost. While making changes, you will not have to restart the server every time.

To check your style, run `rubocop`. To run the test suite, run `rspec`.

## Database Schema
You won't write any code in this section, just open up the image and take a look at the schema describing the tables you'll need. There is an explanation about the way that friendship relationships should be defined. This may be a little confusing, so please take the time to fully understand this and ask on Piazza for clarifications.

![Database Schema](database-schema.png)

## Models

Be sure to run `bundle install` before beginning.

You will need three models: `user`, `friendship`, and `status`. I recommend creating all of these with the model generator since you're being provided with the controller and views in this assignment.

1. **User**: A user should have a `first_name`, `last_name`, `email`, and `password_hash` (all of type string).
2. **Status**: A status should have a reference to the `user` table and a `text` column of type text.
3. **Friendship**: A friendship should have a reference to a `user`, a reference to a `friend`, and a `state` of type string. Since there is no `friend` table, there are a couple of ways to create this reference. The first is to use the references type and then open the created migration and remove `, foreign_key: true` next to `friend`. The second is to make a `friend_id` column of type integer. I recommend the first.

### Associations

Be sure to set the `dependent` option to `:destroy` where appropriate.

#### Status
1. A `status` should belong to a `user`.

#### Friendship
1. A `friendship` should belong to a `user`.
2. A `friendship` should belong to a friend. Be sure to set the `class_name` option to `'User'`.

#### User
1. A `user` should have many `statuses`.
2. A `user` should have many `friendships`.
3. A `user` should have many `friends` through `friendships`. This should be scoped to only reference `friendships` where the `state` is `'accepted'`. Note that the lambda defining the scope must come before `through: :friendships`.
4. A `user` should have many `requested_friends` through `friendships`. This should be scoped to only reference `friendships` where the `state` is `'requested'`. Be sure to set the `source` option to `:friend`.
5. A `user` should have many `pending_friends` through `friendships`. This should be scoped to only reference `friendships` where the `state` is `'pending'`. Be sure to set the `source` option to `:friend`.

### Validations

We did not go over all of the validations that you will need in class. Use the <a href="http://guides.rubyonrails.org/active_record_validations.html" target="_blank">Validations Guide</a> to find any that you are not sure how to implement.

#### Status
1. The `text` must be present and at least 5 characters in length.

#### Friendship
1. A `state` must be present and its value must be one of the following: `'accepted'`, `'pending'`, `'requested'`.
2. A `friend` must be unique in the scope of the `user`.
3. Write a custom validation that adds to `errors` with the attribute `:user` and message `'cannot friend itself'` if `user` equals `friend`.

#### User
1. A `first_name` must be present.
2. A `last_name` must be present.
3. An `email` must be present and unique.
4. Write a custom validation that adds to `errors` with the attribute `:first_name` and message `'must be capitalized'` if the `first_name` is not `nil` and not capitalized. Make sure that you check that the `first_name` is `nil` first, otherwise it will throw an error.
5. Write a custom validation that adds to `errors` with the attribute `:last_name` and message `'must be capitalized'` if the `last_name` is not `nil` and not capitalized.
6. Write a custom validation that adds to `errors` with the attribute `:email` and message `"must have an '@' and a '.'"` if the `email` is not `nil` and either does not contain an `@` or a `.`.

### Additional Methods

#### `User#full_name`
This method should return the `first_name` and `last_name` separated by a space.

#### `User#send_friend_request(friend)`
This is an instance method that attempts to send a friend request from the instance it is being called on to the `friend` argument that it is passed.

You should immediately return if a friendship already exists either from the user that the method is being called on to `friend` or vice versa. Remember that you can access the user that an instance method is being called on with `self`.

As an example of the above, imagine we have `user1` and `user2`. If we call `user1.send_friend_request(user2)`, the method call should immediately return if `Friendship.exists?(user: user1, friend: user2)` or `Friendship.exists(user: user2, friend: user1)` returned true.

Create a `Friendship` instance from the current instance to the passed in `friend` argument with `state` `'requested'`. Create another `Friendship` instance from the passed in `friend` to the current instance with `state` `'pending'`. (Refer back to the database schema diagram if this is confusing)

#### `User#accept_friend_request(friend)`
This is an instance method that attempts to accept a friend request from `friend` to the current instance.

You can only accept a friend request if a request has actually been sent, which means that there must be a `requested` friendship from `friend` to the current instance and a `pending` friendship from the current instance to `friend`. Attempt to find both of these relationships and return unless they both exist.

Update both of the friendships that you just found with a `state` of `accepted` (make sure that this change is committed to the database).

#### `User#delete_friend(friend)`
This is an instance method that attempts to delete friendships in both directions.

Try to find a friendship from the current instance to the current user to the `friend` and destroy the relationship if it exists. Try to find a relationship in the other direction and destroy it if it exists.

### BCrypt

You should use BCrypt to manage password encryption in your `User` model. The `bcrypt` gem has already been added to your Gemfile, so you just need to `include BCrypt` and implement the `#password` and `#password=` methods according to the <a href="https://github.com/codahale/bcrypt-ruby" target="_blank">documentation</a>.

You will have to make one small modification to the `#password` method. In this method, you should only attempt to conditionally assign `@password` if `password_hash` is not `nil`.

### Sanity Check
At this point, you should be able to run `rspec spec/models` and pass all of these tests.

## Controllers & Views

### Application Controller

#### `logged_in?`
You should define a `helper_method` that returns the value of `:user_id` in the `session` hash.

#### `current_user`
You should define a `helper_method` that conditionally assigns (and returns) `@current_user` if there is a user logged in.

#### `authenticate_user`
This should not be a `helper_method` since we do not want to access this method in the view. It should redirect to the root path unless a user is logged in.

### Navbar Partial
Right now all of the links will be displayed in the navbar (regardless of whether or not the user is logged in). Update the navbar to make sure that the user's full name, `Friend Requests`, and `Log out` links are only displayed if the user is logged in. If the user is not logged in, you should display `Sign up` and `Log in` links instead.

### Sessions Controller

You should create the `SessionsController` with the controller generator.

#### `new`
This should be a GET request to `/login`. Don't forget to define the route in `config/routes.rb`.

This action will be responsible for rendering the login form.

#### `create`
This should be a POST request to `/login`.

This action will be responsible for logging the user in. When the user fills in the login form, they will pass in an `email` and a `password`. Attempt to find the `user` with the passed in email (it will be accessible from the `params` hash) and assign this user to a variable.

If the user that you just found is not `nil` and the user's `password` equals the password passed into the form, log the user in by assigning `:user_id` in the `session` hash to the user's `id`. Redirect to the root path.

Otherwise, redirect to the login path.

#### `destroy`
This should be a DELETE request to `/logout`.

This action will be responsible for logging the user out. Log the user out with `reset_session` and then redirect to the root path.

### Users Controller

This controller is being provided to you mostly intact. All of the routes have been defined. Take a look at `config/routes.rb` to see the routes related to users.

#### Authentication
You should authenticate the user before all actions except `index`, `show`, `new`, and `create`.

#### `create`
If the user is successfully saved to the database, be sure to log them in by setting the `user_id` in the `session` hash.

#### `update`
If the user is successfully updated, be sure to log them in.

#### `destroy`
After destroying a user, you should be sure to log them out.

#### `user_params`
Right now, `user_params` is expecting a `password_hash` to be submitted with the user form since the `users` table has a `password_hash` column. We know that the form will actually submit a `password` so change `user_params` to expect a `password` instead.

#### `friend_requests`, `send_friend_request`, `accept_friend_request`, `delete_friend`
These actions have been implemented for you, but take a second to familiarize yourself with their behavior (take a look at the view for `friend_requests` to get an idea of what it does).

#### Sanity Check
At this point, you should be able to create a user and be automatically logged in, log the user out, and then log back in. You should also be able to send and accept friend requests and delete existing friends.

### Statuses Controller
This file is being provided to you almost completely intact and the routes have already been defined. You should be sure to authenticate the user before every action. After you've done this, try creating a status from the logged in user's profile.

### Welcome Controller

#### `index`
This is almost implemented for you. Right now, `@statuses` will contain all of the statuses for the current user and their friends, but it needs to be ordered in descending order of `created_at`. You can chain a call to `order` onto the current implementation.

## Submitting
Be sure to run `rubocop` and `rspec` to catch any errors that need to be fixed before submitting.

Perform these steps in the Command Line to submit your assignment:
1. If you're not already there, `cd` into the Homework 8 directory.
2. Run `git status` to see all of the changes that you've made.
3. Run `git add .` to stage all of the changes.
4. Run `git commit -m "Complete Homework 8"` to commit your changes locally (note that you can change the commit message to anything you want).
5. Run `git push -u origin master` to push up the changes to your Homework 8 GitHub repository.
6. Visit <a href="https://www.travis-ci.com" target="_blank">Travis CI</a> to see the result of your submission. Here you can see how you performed against the tests and style cops. You can submit as many times as you'd like (just repeat these steps), only your last submission will be graded.
