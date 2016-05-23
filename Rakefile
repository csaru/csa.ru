require 'rake'
require 'yaml'

task :default => :csa

task :csa do
	generate_site_configuration('csa')
end

task :apmath do
	generate_site_configuration('apmath')
end

def generate_site_configuration(site_name)
	head = YAML::load(File.open("_data/#{site_name}.yml"))
	body = YAML::load(File.open('_data/config.yml'))
	head['id'] = site_name
	File.open('_config.yml', 'w').puts head.merge(body).to_yaml
end
