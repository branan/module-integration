require 'vagrant'
require 'veewee'
require 'puppet_acceptance'
require 'test/unit'

Test::Unit.run = true

module Module_acceptance
  def self.execute(module_name, dir)
    lib_dir = File.dirname(__FILE__)
    data_dir = File.expand_path("#{lib_dir}/../data/")

    env = Vagrant::Environment.new({ :ui_class => Vagrant::UI::Basic,
                                     :cwd      => data_dir })

    if not env.boxes.find("systest")
      veewee = Veewee::Environment.new({ :cwd => data_dir })
      veewee.ui = Veewee::UI::Shell.new(veewee, Thor::Shell::Basic.new)
      options = {'force'=>true}
      veewee.providers["virtualbox"].get_box('systest').build(options)
      options = {'force'=>true, 'vagrantfile' => '', 'include' => '' }
      veewee.providers["virtualbox"].get_box('systest').export_vagrant(options)
      env.boxes.add('systest', 'systest.box')
      env.boxes.reload!
    end

    options = {
      :random    => false,
      :noinstall => true,
      :keyfile   => "#{data_dir}/id_rsa",
      :config    => "#{data_dir}/module.cfg",
      :modroot   => dir,
      :modname   => module_name
    }

    PuppetAcceptance::Options.override(options)
    config = PuppetAcceptance::TestConfig.load_file("#{data_dir}/module.cfg")

    env.cli("up")

    begin
      hosts = config['HOSTS'].collect { |name,overrides| PuppetAcceptance::Host.create(name, overrides, config['CONFIG']) }
      begin
        setup_options = options.merge({ :tests => ["#{data_dir}/setup"] })
        PuppetAcceptance::TestSuite.new('core-setup', hosts, setup_options, config).run_and_exit_on_failure
        if File.exists?("#{dir}/acceptance/setup")
          setup_options = options.merge({ :tests => ["#{dir}/acceptance/setup"] })
          PuppetAcceptance::TestSuite.new('acceptance-setup', hosts, setup_options, config).run_and_exit_on_failure
        end
        options.merge!({ :tests => ["#{dir}/acceptance/test/"]} )
        PuppetAcceptance::TestSuite.new('acceptance', hosts, options, config).run_and_exit_on_failure
      rescue
        raise $!
      ensure
        hosts.each {|host| host.close}
      end
    rescue
      raise $!
    ensure
      env.cli("destroy", "-f")
    end
  end
end
