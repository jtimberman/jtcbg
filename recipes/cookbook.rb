context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
windows = windows?(context)

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# LICENSE
template "#{cookbook_dir}/LICENSE" do
  source 'LICENSE.apache2.erb'
  action :create_if_missing
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# PolicyFile
template "#{cookbook_dir}/Policyfile.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# Rubocop
cookbook_file "#{cookbook_dir}/.rubocop.yml" do
  source 'rubocop.yml'
  action :create_if_missing
end

# TK & Serverspec
template "#{cookbook_dir}/.kitchen.yml" do
  source 'kitchen.yml.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  variables windows: windows
  action :create_if_missing
end

remote_directory "#{cookbook_dir}/test/fixtures/cookbooks/test" do
  source 'test_cookbook'
  recursive true
  action :create_if_missing
end

if windows
  directory "#{cookbook_dir}/test/integration/default/pester" do
    recursive true
  end

  template "#{cookbook_dir}/test/integration/default/pester/default.tests.ps1" do
    source 'pester-default-tests.ps1.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    action :create_if_missing
  end
else
  directory "#{cookbook_dir}/test/integration/default/serverspec" do
    recursive true
  end

  directory "#{cookbook_dir}/test/integration/helpers/serverspec" do
    recursive true
  end

  cookbook_file "#{cookbook_dir}/test/integration/helpers/serverspec/spec_helper.rb" do
    source 'serverspec_spec_helper.rb'
    action :create_if_missing
  end

  template "#{cookbook_dir}/test/integration/default/serverspec/default_spec.rb" do
    source 'serverspec_default_spec.rb.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    action :create_if_missing
  end
end

# Chefspec
directory "#{cookbook_dir}/spec/unit/recipes" do
  recursive true
end

cookbook_file "#{cookbook_dir}/spec/spec_helper.rb" do
  action :create_if_missing
end

template "#{cookbook_dir}/spec/unit/recipes/default_spec.rb" do
  source 'recipe_spec.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# Recipes
directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# git
if context.have_git
  unless context.skip_git_init
    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end

    execute 'git-remote-add-origin' do
      command "git remote add origin git@github.com:jtimberman/#{context.cookbook_name}-cookbook"
      cwd cookbook_dir
    end
  end

  cookbook_file "#{cookbook_dir}/.gitignore" do
    source 'gitignore'
  end
end
