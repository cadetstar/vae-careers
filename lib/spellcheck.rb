module Spellcheck
 def do_spellcheck(text)
    # This is only ever an ajax request
    # Inputs:
    #   :identifier => the jQuery-pertinent identifier of the target
    #   :text => the text to check
    # Outputs:
    #   :errors => array of hashes of misspelled words:
    #    {:line, :offset, :original, :suggestions}

    @errors = []

    text.gsub(/\r/, '').split(/\n/).each_with_index do |line, i|
      result = `echo "#{line}" | aspell -a`
      puts result
      result.split(/\n/).each do |res|
        if res =~ /^&/
          commands, suggestions = res.gsub(/^& */, '').split(':')
          commands = commands.split(' ')
          @errors << {:line => i, :offset => commands[2], :original => commands[0], :suggestions => suggestions.strip}
        elsif res =~ /^#/ 
          commands = res.gsub(/^#/, '').split(' ')
          @errors << {:line => i, :offset => commands[-1], :original => commands[-2], :suggestions => ''}
        end
      end
    end

    @errors

  end

end
