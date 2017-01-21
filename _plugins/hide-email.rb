module JekyllProtectEmail
	class ProtectEmailTag < Liquid::Tag
		def initialize(tag, text, tokens)
			super
			@args = text.split(' ')
		end

		def render(context)
			email = encode("#{@args[0]}@#{@args[1]}")
			ret = <<eos
<a href="mailto:#{email}" class="protect-email #{@args[2..-1].join(' ') if @args[2]}">#{email}</a>
eos
			ret.strip
		end

		def encode(str)
			str.chars.map { |code| "&##{code.ord};" }.join("")
		end
	end
end

Liquid::Template.register_tag('protect_email', JekyllProtectEmail::ProtectEmailTag)
