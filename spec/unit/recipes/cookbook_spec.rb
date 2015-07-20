require 'spec_helper'

describe 'jtcbg::cookbook' do
  let(:skip_git_init) { true }
  let(:have_git) { false }
  let(:cookbook_root) { '/var/tmp' }
  let(:cookbook_name) { 'spaetzle' }
  let(:cookbook_path_in_git_repo?) { false }
  let(:recipe_name) { 'cookbook' }
  let(:copyright_holder) { 'Bear Paw' }
  let(:email) { 'paws@example.com' }
  let(:windows) { nil }

  before(:each) do
    ChefDK::Generator.add_attr_to_context(:skip_git_init, cookbook_path_in_git_repo?)
    ChefDK::Generator.add_attr_to_context(:have_git, have_git)
    ChefDK::Generator.add_attr_to_context(:cookbook_root, cookbook_root)
    ChefDK::Generator.add_attr_to_context(:cookbook_name, cookbook_name)
    ChefDK::Generator.add_attr_to_context(:recipe_name, recipe_name)
    ChefDK::Generator.add_attr_to_context(:copyright_holder, copyright_holder)
    ChefDK::Generator.add_attr_to_context(:email, email)
    ChefDK::Generator.add_attr_to_context(:windows, windows)
  end

  context 'Default for one of our target platforms' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(
        platform: 'ubuntu',
        version: '14.04'
      ).converge(described_recipe)
    end

    it 'converges without error' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a chefignore' do
      expect(chef_run).to create_cookbook_file('/var/tmp/spaetzle/chefignore')
    end

    it 'creates a README.md' do
      expect(chef_run).to create_template_if_missing('/var/tmp/spaetzle/README.md')
    end

    it 'renders the LICENSE file from the correct template source' do
      expect(chef_run).to create_template_if_missing('/var/tmp/spaetzle/LICENSE').with(source: 'LICENSE.apache2.erb')
    end

    it 'creates a Policyfile without a cookbook parent directory' do
      expect(chef_run).to create_template_if_missing('/var/tmp/spaetzle/Policyfile.rb')
    end

    it 'creates a .rubocop.yml file' do
      expect(chef_run).to create_cookbook_file_if_missing('/var/tmp/spaetzle/.rubocop.yml')
    end

    it 'creates a .kitchen.yml file' do
      expect(chef_run).to create_template_if_missing('/var/tmp/spaetzle/.kitchen.yml')
      expect(chef_run).to render_file('/var/tmp/spaetzle/.kitchen.yml')
        .with_content(/driver:\n  name: vagrant/)
    end

    it 'creates a test cookbook for test kitchen' do
      expect(chef_run).to create_remote_directory_if_missing('/var/tmp/spaetzle/test/fixtures/cookbooks/test')
    end

    it 'sets up integration tests with serverspec' do
      expect(chef_run).to create_template_if_missing('/var/tmp/spaetzle/test/integration/default/serverspec/default_spec.rb')
    end
  end

  context 'generating a cookbook for windows' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    let(:windows) { true }

    before(:each) do
      ChefDK::Generator.add_attr_to_context(:windows, windows)
    end

    it 'creates the .kitchen.yml for hyper-v' do
      expect(chef_run).to render_file('/var/tmp/spaetzle/.kitchen.yml')
        .with_content(/driver:\n  name: 'hyperv'/)
    end

    it 'uses pester for the verifier' do
      expect(chef_run).to render_file('/var/tmp/spaetzle/.kitchen.yml')
        .with_content(/verifier:\n  name: 'pester'/)
    end

    it 'includes only windows as the platform' do
      expect(chef_run).to render_file('/var/tmp/spaetzle/.kitchen.yml')
        .with_content(/platforms:\n  - name: windows-8.1-pro/)
    end

    it 'generates pester instead of serverspec' do
      expect(chef_run).to render_file('/var/tmp/spaetzle/test/integration/default/pester/default.tests.ps1')
    end
  end
end
