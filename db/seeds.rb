# Admin
# admin = Admin.new(email: 'user@email.com', password: 'Password5*')
# admin.skip_confirmation!
# admin.save!

# Company
# Company.create(name: 'Gotham Industries', size: 5, admin: admin)

# CONTENT
# General
general = Metric.create(en: 'About Felix', image_url: 'https://s3.amazonaws.com/felixthebot/general_cover.png')

# Question #1
welcome = Question.create(
  en: 'Is tracking how happy we are at work important?',
  metric: general
)

welcome.options << Option.create(en: "It's stupid", value: 0)
welcome.options << Option.create(en: "I've seen worse", value: 33)
welcome.options << Option.create(en: "I like it", value: 66)
welcome.options << Option.create(en: "Love it!", value: 100)
