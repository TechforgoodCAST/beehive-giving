class AddClassesToThemes < ActiveRecord::Migration[5.1]
  def up
    add_column :themes, :classes, :string
    {
      'Accountability and fair trade' => 'orange',
      'Addiction' => 'light-green',
      'Animals and wildlife' => 'green',
      'Armed and rescue services' => 'pink',
      'Arts' => 'red',
      'Arts and recreation' => 'red',
      'Building and places' => 'indigo',
      'Care' => 'blue-grey',
      'Children and young people' => 'purple',
      'Climate and the environment' => 'green',
      'Community improvement and capacity building' => 'indigo',
      'Conflict and violence' => 'orange',
      'Crime and justice' => 'orange',
      'Crisis intervention' => 'blue-grey',
      'Disability' => 'light-green',
      'Disaster preparedness and relief' => 'pink',
      'Domestic and sexual abuse' => 'blue-grey',
      'Education and training' => 'teal',
      'Employment' => 'cyan',
      'Family and relationships' => 'blue-grey',
      'Food and agriculture' => 'pink',
      'Groups' => 'purple',
      'Health and medicine' => 'light-green',
      'Heritage and preservation' => 'pink',
      'Housing and shelter' => 'blue-grey',
      'Human rights and exploitation' => 'orange',
      'Inequality and discrimination' => 'orange',
      'International and foreign affairs' => 'dark-purple',
      'Isolation and loneliness' => 'blue-grey',
      'Medical research' => 'light-green',
      'Mental wellbeing, diseases and disorders' => 'light-green',
      'Migration, refugees and asylum seekers' => 'dark-purple',
      'Minority or marginalised communities' => 'purple',
      'Older people' => 'purple',
      'Organisational development' => 'indigo',
      'Palliative Care and Hospices' => 'light-green',
      'People from a specific ethnic background' => 'purple',
      'People in, leaving or providing care' => 'purple',
      'People with a specific gender or sexual identity' => 'purple',
      'People with a specific religious/spiritual beliefs' => 'purple',
      'Personal and skills development' => 'teal',
      'Physical wellbeing, diseases and disorders' => 'light-green',
      'Policy development' => 'indigo',
      'Poverty' => 'blue-grey',
      'Public and societal benefit' => 'pink',
      'Public safety' => 'pink',
      'Science and technology' => 'yellow',
      'Scientific research' => 'yellow',
      'Social welfare' => 'blue-grey',
      'Sport and leisure' => 'red',
      'Technology' => 'yellow',
      'Volunteering and civic participation' => 'indigo',
      'Water, sanitation and public infrastructure' => 'pink',
      'Women and girls' => 'purple'
    }.each do |k, v|
      Theme.find_by(name: k).update(classes: "tag-#{v} white")
    end
  end

  def down
    remove_column :themes, :classes
  end
end
