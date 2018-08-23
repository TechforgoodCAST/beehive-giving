json.array! @country&.districts do |district|
  json.value district.id.to_s
  json.label district.name
end
