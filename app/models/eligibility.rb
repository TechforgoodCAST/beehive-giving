class Eligibility

  include ActiveAttr::Model

  10.times do |n|
    attribute :"restriction#{n+1}",
              unless: Proc.new { |eligibility| eligibility["restriction#{n+1}"].nil? }
    validates :"restriction#{n+1}", presence: true,
              unless: Proc.new { |eligibility| eligibility["restriction#{n+1}"].nil? }
    validates :"restriction#{n+1}", inclusion: {:in => ['false'], :message => 'you are not eligible, please try another funder'},
              unless: Proc.new { |eligibility| eligibility["restriction#{n+1}"].nil? }
  end

end
