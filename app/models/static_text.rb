class StaticText < ActiveRecord::Base
  def self.retrieve(name)
    if (st = StaticText.find_by_name(name))
      st.content.to_s.gsub(/\r/, '').gsub(/\n/, '<br />')
    else
      ''
    end
  end

  def self.content_type_override
    :text_area
  end
end
