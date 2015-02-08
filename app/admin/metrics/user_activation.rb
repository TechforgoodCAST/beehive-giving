ActiveAdmin.register_page "User Activation"  do

  content do
    @metric = Recipient.group_by_week(:created_at).count
    render :partial => 'metrics/line_chart', :locals => {:metric => @metric}
  end

end