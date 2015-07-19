
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

resource_path = File.join(cookbook_dir, 'libraries', "#{context.new_file_basename}_resource.rb")
provider_path = File.join(cookbook_dir, 'libraries', "#{context.new_file_basename}_provider.rb")

directory 'libraries'

template resource_path do
  source 'resource.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

template provider_path do
  source 'provider.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end
