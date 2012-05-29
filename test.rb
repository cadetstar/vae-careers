require 'rjb'

my_path = File.dirname(File.expand_path(__FILE__))
puts my_path
load_path = File.join(my_path, 'lib', 'itextpdf-5.2.1.jar')
puts load_path
options = []
Rjb::load load_path, options

pdfreader = Rjb::import('com.itextpdf.text.pdf.PdfReader')
fields = Rjb::import('com.itextpdf.text.pdf.AcroFields')

f = File.open(File.join('c:/Users/Michael Madison/Desktop', 'i-9.pdf'))

#content = f.read

f.close

pdf = pdfreader.new(File.join('c:/Users/Michael Madison/Desktop', 'i-9.pdf'))
#puts pdf.getAcroFields