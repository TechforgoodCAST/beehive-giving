ActiveAdmin.register_page 'Proposal Dashboard' do

  sidebar :filter do
    form title: "Filters applied" do |f|
      label 'Proposal created'
      div _class: 'date_range input optional stringish filter_form_field filter_date_range' do
        f.input :created_since, value: params['created_since'], name: 'created_since', type: 'date', placeholder: 'From'
        f.input :created_before, value: params['created_before'], name: 'created_before', type: 'date', placeholder: 'To'
      end
      f.input :submit, value: 'Filter', type: 'submit'
    end
    a 'Last week', href: "?created_since=#{7.days.ago.to_date}"
    a 'Last month', href: "?created_since=#{1.months.ago.to_date}"
    a 'This year', href: "?created_since=#{DateTime.now.beginning_of_year.to_date}"
  end

  content title: 'Proposal Analysis' do

    def band_fields(bands, field)
      sql_string = "case"
      bands.each_with_index do |v, k|
        if v == Float::INFINITY
          sql_string += " when CAST(#{field} AS FLOAT) <= 'Infinity' then #{k}"
        else
          sql_string += " when #{field} <= #{v} then #{k}"
        end
      end
      sql_string += " else #{bands.size} end"
      sql_string
    end

    def band_name(bands, index, prefix: "", suffix: "")
      return "Up to #{prefix}#{number_with_delimiter bands[0]}#{suffix}" if index == 0
      return "Unknown" if index >= bands.size
      return "#{prefix}#{number_with_delimiter bands[index-1]+1}#{suffix} or more" if bands[index] == Float::INFINITY
      "#{prefix}#{number_with_delimiter bands[index-1]+1} - #{prefix}#{number_with_delimiter bands[index]}#{suffix}"
    end

    def get_proposals
      q = Proposal
      q = q.where("proposals.created_at > ?", params['created_since']) if DateTime.parse params['created_since'] rescue nil
      q = q.where("proposals.created_at < ?", params['created_before']) if DateTime.parse params['created_before'] rescue nil
      q
    end

    def org_type(k)
      return 'Unknown' if k.nil?
      ORG_TYPES[k.to_i+1][2].upcase_first
    end

    def org_size(k)
      return 'Unknown' if k.nil?
      Organisation::INCOME_BANDS[k][0]
    end

    def operating_for(k)
      return 'Unknown' if k.nil?
      Organisation::OPERATING_FOR[k.to_i][0].upcase_first
    end

    def funding_type(k)
      return 'Unknown' if k.nil?
      FUNDING_TYPES[k][0].truncate_words(2)
    end

    total_costs_bands = [100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 500000, 1000000, 5000000, 10000000, 100000000, Float::INFINITY]
    duration_bands = [9, 15, 21, 27, 42, 54, Float::INFINITY]

    columns do
      column do
        panel "Proposal amount" do
          render partial: "bar_chart", locals: {
            data: get_proposals.group(band_fields(total_costs_bands, :total_costs))
                               .count
                               .sort_by { |key, val| key }
                               .map{ |k, v| [band_name(total_costs_bands, k, prefix: "£"), v]}
                             }
        end
      end

      column do
        panel "Funding type" do
          render partial: "pie_chart", locals: {
            data: get_proposals.group(:funding_type)
                               .count
                               .map{ |k, v| [funding_type(k), v]}
                             }
        end
      end

      column do
        panel "Funding duration" do
          render partial: "bar_chart", locals: {
            data: get_proposals.group(band_fields(duration_bands, :funding_duration))
                               .count
                               .sort_by { |key, val| key }
                               .map{ |k, v| [band_name(duration_bands, k, suffix: " months"), v]}
                             }
        end
      end
    end

    columns do
      column do
        panel "Top proposal themes" do
          render partial: "bar_chart", locals: {
            data: get_proposals.joins(:themes)
                               .group('themes.name')
                               .count
                               .sort_by { |key, val| -val }
                               .take(24)
                               .map{ |k, v| [(k == nil ? 'Unknown' : k), v]},
            height: '600px'
          }
        end
      end

      column do
        panel "Top fund themes" do
          render partial: "bar_chart", locals: {
            data: Fund.joins(:themes)
                      .group('themes.name')
                      .count
                      .sort_by { |key, val| -val }
                      .take(24)
                      .map{ |k, v| [(k == nil ? 'Unknown' : k), v]},
            height: '600px'
          }
        end
      end
    end

    columns do
      column do
        panel "Recipient type" do
          data = get_proposals.joins(:recipient)
                              .group(:org_type)
                              .count
                              .map { |k, v| [org_type(k), v] }
                              .to_h
          data["Registered charities"] = data.fetch("Registered charities", 0) + data.fetch("Charities registered as companies", 0)
          char_and_comp = data.delete("Charities registered as companies")
          render partial: "bar_chart", locals: {data: data.sort_by { |key, val| -val }}
          text_node "NB #{number_with_delimiter char_and_comp} charities are also registered companies"
        end
      end

      column do
        panel "Recipient age" do
          render partial: "bar_chart", locals: {
            data: get_proposals.joins(:recipient)
                               .group('org_type IN (2,4)')
                               .group(:operating_for)
                               .count
                               .sort_by { |key, val| key[1].to_i }
                               .map { |k, v| [[(k[0] ? 'Registered charity' : 'Other organisation'), operating_for(k[1])], v] }
                               .to_h
          }
        end
      end

      column do
        panel "Recipient size" do
          render partial: "bar_chart", locals: {
            data: get_proposals.joins(:recipient)
                               .group('org_type IN (2,4)')
                               .group(:income_band)
                               .count
                               .sort_by { |key, val| key[1].to_i }
                               .map { |k, v| [[
                                 (k[0] ? 'Registered charity' : 'Other organisation'),
                                 org_size(k[1])
                                 ], v] }
                               .to_h
                             }
        end
      end
    end

    columns do
      column do
        panel "Proprosal size vs Org Size" do
          bands = get_proposals.joins(:recipient)
                               .group(:income_band)
                               .group(band_fields(total_costs_bands, :total_costs))
                               .count
                               .sort_by { |key, val| [key[0].to_i, key[1].to_i] }
                               .group_by { |k, v| k[0] }
          bands.each do |index, band|
            data = total_costs_bands.map.with_index{ |b, k| [k, band.to_h[[index, k]]] }.to_h
            height = '100px'
            if index == bands.keys[-1]
              data = data.map{ |k, v| [band_name(total_costs_bands, k, prefix: "£"), v] }.to_h
              height = '150px'
            end
            render partial: "column_chart_micro", locals: {data: data, height: height, ytitle: org_size(index)}
          end
        end
      end

      column do
        panel "Funding type by organisation size" do
          render partial: "bar_chart", locals: {
            data: get_proposals.joins(:recipient)
                               .group(:funding_type)
                               .group(:income_band)
                               .count
                               .sort_by { |key, val| key[1].to_i }
                               .map {|k, v| [[funding_type(k[0]), org_size(k[1])], v]}
                               .to_h,
            stacked: true
          }
        end
      end

      column do
        panel "Funding type by organisation type" do
          render partial: "bar_chart", locals: {
            data: get_proposals.joins(:recipient)
                               .group(:funding_type)
                               .group(:org_type)
                               .count
                               .sort_by { |key, val| key[1].to_i }
                               .map {|k, v| [[funding_type(k[0]), org_type(k[1])], v]}
                               .to_h,
            stacked: true
          }
        end
      end
    end

  end
end
