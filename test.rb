require 'pdf_forms'

pdftk = PdfForms.new('C:\Windows\System32\pdftk')

puts pdftk.get_field_names 'C:\Users\Michael Madison\Desktop\i-9.pdf'