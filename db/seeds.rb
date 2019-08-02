# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create one admin example user
User.create!(
  name: "Example User",
  email: "test@example.com",
  password: "foobarbaz",
  password_confirmation: "foobarbaz",
  admin: true,
  activated: true,
  activated_at: Time.zone.now,
)

# Create 99 random example users
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n + 1}@railstutorial.org"
  password = "password"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now,
  )
end

# Create microposts for the first 6 users from above
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content:content) }
end

# Following relationshops
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

all_skills = ["Java", "Ruby On Rails", "Python", "React", "Javascript", "Ruby", "Selenium", "Excel", "Linux", "C", "C++", "Junit", "Project Planning", "Product Mangement", "Entrepreneurship", "Data Analysis", "Public Speaking", "Teamwork", "Management", "Pitch Development"]
all_portfolios = ["Finance", "Engineering", "Human Resources", "Marketing", "Accounting"]
uid_index = 111111
99.times do |n|
  # This needs to be unique, so make sure it's constantly rising
  uid_index += rand(1000)
  uid = uid_index
  name = Faker::Name.unique.name
  phone_number = Faker::PhoneNumber.unique.cell_phone_with_country_code
  email = Faker::Internet.email
  skills = all_skills.sample(rand(1..(all_skills.length)/2)).sort # Get a sample of skills from the above array
  portfolio = all_portfolios.sample # Get one portfolio
  start_date = Date.today - Faker::Number.number(3).to_i.days
  location = Faker::Address.city
  manager = Faker::Name.name
  
  Resource.create!(
    uid: uid,
    name: name,
    phone_number: phone_number,
    email: email,
    skills: skills,
    portfolio: portfolio,
    start_date: start_date,
    location: location,
    manager: manager
  )
end
