# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Clearing Database..."

User.destroy_all
Post.destroy_all

puts "Database cleared!"

puts "Seeding..."

puts "Seeding Users..."

User.create!({username: "user1"})
User.create!({username: "user2"})
User.create!({username: "user3"})
User.create!({username: "user4"})
User.create!({username: "user5"})

puts "Users seeded!"

puts "Seeding Posts..."

Post.create!({content: "First post", user: User.first})
Post.create!({content: "Second post", user: User.first})
Post.create!({content: "Third post", user: User.first})
Post.create!({content: "Fourth post", user: User.first})
Post.create!({content: "Fifth post", user: User.second})
Post.create!({content: "Sixth post", user: User.second})
Post.create!({content: "Seventh post", user: User.second})
Post.create!({content: "Eighth post", user: User.second})
Post.create!({content: "Ninth post", user: User.third})
Post.create!({content: "Tenth post", user: User.third})
Post.create!({content: "Eleventh post", user: User.third})
Post.create!({content: "Twelth post", user: User.third})
Post.create!({content: "Thirteenth post", user: User.fourth})
Post.create!({content: "Fourteenth post", user: User.fourth})
Post.create!({content: "Fifteenth post", user: User.fourth})
Post.create!({content: "Sixteenth post", user: User.fourth})
Post.create!({content: "Seventeenth post", user: User.fifth})
Post.create!({content: "Eighteenth post", user: User.fifth})
Post.create!({content: "Nineteenth post", user: User.fifth})
Post.create!({content: "Twentieth post", user: User.fifth})

puts "Posts seeded!"

puts "Seeding complete!"
