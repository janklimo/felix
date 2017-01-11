def read_fixtures(path)
  path = File.join(Rails.root.join('spec','fixtures'), path)
  File.open(path, 'rb').read
end
