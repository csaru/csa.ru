# encoding: utf-8

require 'bibtex'
require 'citeproc/ruby'
require 'csl/styles'

module Jekyll
	class BibliographyTag < Liquid::Tag
		def initialize(tag_name, args, tokens)
			@args = Hash[args.strip.split(/\s+/).map { |pair| pair.split('=') }]
			puts @args.inspect
			@config = Jekyll.configuration({})['bibtex'] || {}
			super
		end
		def bibtex_path
			File.join Jekyll.configuration({})['source'], (@config['path'] || '_bibtex')
		end
		def bibtex
			files = Dir.entries(bibtex_path).select{
				|f| File.extname(f) == '.bib'
			}
			content = files.reduce('') { |s, p| s << IO.read(File.join bibtex_path, p) }
			do_sort BibTeX.parse(content, {
				:filter => :latex
			})
		end
		def param(name, defval)
			@config[name] || @args[name] || defval
		end
		def style
			param 'style', 'apa'
		end
		def locale
			param 'locale', 'en'
		end
		def list_css
			param 'list_css', 'bibtex_list'
		end
		def item_css
			param 'item_css', 'bibtex_item'
		end
		def list_tag
			param 'list_tag', 'ol'
		end
		def item_tag
			param 'item_tag', 'li'
		end
		def sort_by
			name = 'sort_by'
			val = @config[name] || @args[name] || 'year'
			val.strip.split(',')
		end
		def sort_order
			param 'sort_order', 'descending'
		end
		def render(context)
			puts "Style: #{style}"
			puts "Locale: #{locale}"
			puts "Sort by: #{sort_by}"
			cslStyle = CSL::Style.load style
			items = bibtex.each_with_index.map{ |entry, index|
				loc = locale
				if entry['language']
					loc = 'ru' if /Russian/i.match entry.language
					loc = 'en' if /English/i.match entry.language
				end
				citationItem = CiteProc::CitationItem.new id: entry.id do |c|
					c.data = CiteProc::Item.new entry.to_citeproc
					c.data[:'citation-number'] = index
				end
	            renderer = CiteProc::Ruby::Renderer.new :format => 'html',
					:style => style, :locale => loc
				item = renderer.render citationItem, cslStyle.bibliography
				"<#{item_tag} class=\"#{item_css}\">#{typeset item}</#{item_tag}>"
			}.join("\n")
			"<#{list_tag} class=\"#{list_css}\">#{items}</#{list_tag}>"
		end
		def typeset(text)
			text.gsub(/([0-9])(th|st|nd|rd)\b/, '\1<sup>\2</sup>')
				.gsub(/(Т|С|Vol|Вып). ([0-9])/, '\1.&nbsp;\2')
				.gsub(/(№) ([0-9])/, '\1&nbsp;\2')
				.gsub(/---/,'&mdash;')
				.gsub(/--/,'&ndash;')
				.gsub(/``/,'&ldquo;')
				.gsub(/''/,'&rdquo;')
				.gsub(/<</,'&laquo;')
				.gsub(/>>/,'&raquo;')
				.gsub(/\[DOI:(.*)\]/, '<a href="\1">[doi]</a>')
		end
		def do_sort(entries)
			ret = entries.sort_by { |entry|
				entry.values_at(*sort_by).map { |v| v.nil? ? BibTeX::Value.new : v }
			}
			ret.reverse! if sort_order == 'descending'
			ret
		end
	end
end

Liquid::Template.register_tag('bibliography', Jekyll::BibliographyTag)
