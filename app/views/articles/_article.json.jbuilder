json.extract! article, :id, :title, :published_on, :created_at, :updated_at
json.url article_url(article, format: :json)
