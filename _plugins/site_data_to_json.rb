require 'json'

module Jekyll
    class JSONTag < Liquid::Tag
        def initialize(tag_name, text, tokens)
            @key = text.strip
            super
        end
        def render(context)
            return context['site']['data'][@key].to_json
        end
    end
end

Liquid::Template.register_tag('site_data_to_json', Jekyll::JSONTag)
