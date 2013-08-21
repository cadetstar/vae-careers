module PdfForms
  
  # Map keys and values to Adobe's FDF format.
  #
  # Straight port of Perl's PDF::FDF::Simple by Steffen Schwigon.
  # Parsing FDF files is not supported (yet).
  class Fdf
    
    attr_reader :options
    
    def initialize(data = {}, options = {})
      @data = data
      @options = {
        :file => nil,
        :ufile => nil,
        :id => nil
      }.merge(options)
    end

    # generate FDF content
    def to_fdf
      fdf = header
      
      @data.each do |key, value|
        if Hash === value
          value.each do |sub_key, sub_value|
            fdf << field("#{key}_#{sub_key}", sub_value)
          end
        else
          fdf << field(key, value)
        end
      end

      fdf << footer
      return fdf
    end
    
    # write fdf content to path
    def save_to(path)
      (File.open(path, 'w') << to_fdf).close
    end
    
    protected
    
    def header
      header = "%FDF-1.2\n\n1 0 obj\n<<\n/FDF << /Fields 2 0 R"
      
      # /F
      header << "/F (#{options[:file]})" if options[:file]
      # /UF
      header << "/UF (#{options[:ufile]})" if options[:ufile]
      # /ID
      header << "/ID[" << options[:id].join << "]" if options[:id]
      
      header << ">>\n>>\nendobj\n2 0 obj\n["
      return header
    end

    def field(key, value)
      "<</T(#{key})/V" +
        (Array === value ? "[#{value.map{ |v|"(#{quote(v)})" }.join}]" : "(#{quote(value)})") +
        ">>\n"
    end
    
    def quote(value)
      value.to_s.strip.
        gsub( /\\/, '\\' ).
        gsub( /\(/, '\(' ).
        gsub( /\)/, '\)' ).
        gsub( /\n/, '\r' )
    end
    
    FOOTER =<<-EOFOOTER
]
endobj
trailer
<<
/Root 1 0 R

>>
%%EOF
EOFOOTER
    
    def footer
      FOOTER
    end
    
  end
end