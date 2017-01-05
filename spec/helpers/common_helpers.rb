def read_fixtures(path)
  path = File.join(Rails.root.join('spec','fixtures'), path)
  File.open(path, 'rb').read
end

def mock_text(text)
  data = JSON.parse(read_fixtures('text.json'))
  hash = { 'message' => { 'text' => text } }
  { "events" => [ data.deep_merge(hash) ] }
end

def mock_follow
  data = JSON.parse(read_fixtures('follow.json'))
  { "events" => [ data ] }
end

def mock_location
  data = JSON.parse(read_fixtures('location.json'))
  { "events" => [ data ] }
end

def mock_postback(value = 'value=1234')
  data = JSON.parse(read_fixtures('postback.json'))
  hash = { 'postback' => { 'data' => value } }
  { "events" => [ data.deep_merge(hash) ] }
end

def mock_profile
  JSON.parse(read_fixtures('profile.json'))
end
