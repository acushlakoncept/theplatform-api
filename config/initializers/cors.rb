# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins '*'

#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       expose: %w(Authorization),
#       max_age: 600
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: false,
             expose: %w[Authorization],
             max_age: 600
  end
end
