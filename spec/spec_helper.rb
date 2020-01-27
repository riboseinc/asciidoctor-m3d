require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-m3d"
require "asciidoctor/m3d"
require "isodoc/m3d/html_convert"
require "isodoc/m3d/word_convert"
require "asciidoctor/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "metanorma/m3d"
require "rexml/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def htmlencode(x)
  HTMLEntities.new.encode(x, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n").
    gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, '&').gsub(/&#x27;/, "'").
    gsub(/\\u(....)/) { |s| "&#x#{$1.downcase};" }
end

def xmlpp(x)
  s = ""
  f = REXML::Formatters::Pretty.new(2)
  f.compact = true
  f.write(REXML::Document.new(x),s)
  s
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

HDR

BOILERPLATE =
  HTMLEntities.new.decode(
  File.read(File.join(File.dirname(__FILE__), "..", "lib", "asciidoctor", "m3d", "boilerplate.xml"), encoding: "utf-8").
  gsub(/\{\{ docyear \}\}/, Date.today.year.to_s).
  gsub(/<p>/, '<p id="_">').
  gsub(/<p class="boilerplate-address">/, '<p id="_" class="boilerplate-address">').
  gsub(/\{% if unpublished %\}.+?\{% endif %\}/m, "").
  gsub(/\{% if ip_notice_received %\}\{% else %\}not\{% endif %\}/m, ""))

BOILERPLATE_LICENSE = <<~END
<license-statement>
             <clause>
               <title>Warning for Drafts</title>
               <p id='_'>
                 This document is not an M3AAWG Standard. It is distributed for review
                 and comment, and is subject to change without notice and may not be
                 referred to as a Standard. Recipients of this draft are invited to
                 submit, with their comments, notification of any relevant patent
                 rights of which they are aware and to provide supporting
                 documentation.
               </p>
             </clause>
           </license-statement>
END

BLANK_HDR = <<~"HDR"
       <?xml version="1.0" encoding="UTF-8"?>
       <m3d-standard xmlns="https://open.ribose.com/standards/m3d">
       <bibdata type="standard">

        <title language="en" format="text/plain">Document title</title>
         <contributor>
           <role type="author"/>
           <organization>
             <name>Messaging Malware and Mobile Anti-Abuse Working Group</name>
             <abbreviation>M3AAWG</abbreviation>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>Messaging Malware and Mobile Anti-Abuse Working Group</name>
             <abbreviation>M3AAWG</abbreviation>
           </organization>
         </contributor>
        <language>en</language>
         <script>Latn</script>
        <status>
                <stage>published</stage>
        </status>

         <copyright>
           <from>#{Time.new.year}</from>
           <owner>
             <organization>
             <name>Messaging Malware and Mobile Anti-Abuse Working Group</name>
             <abbreviation>M3AAWG</abbreviation>
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>report</doctype>
         </ext>
       </bibdata>
       #{BOILERPLATE}
HDR

HTML_HDR = <<~"HDR"
           <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
           <div class="title-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="main-section">
HDR
