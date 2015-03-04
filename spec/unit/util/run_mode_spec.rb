#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Util::RunMode do
  before do
    @run_mode = Puppet::Util::RunMode.new('fake')
  end

  describe Puppet::Util::UnixRunMode, :unless => Puppet.features.microsoft_windows? do
    before do
      @run_mode = Puppet::Util::UnixRunMode.new('fake')
    end

    describe "#conf_dir" do
      it "has confdir /etc/puppetlabs/puppet when run as root" do
        as_root { expect(@run_mode.conf_dir).to eq(File.expand_path('/etc/puppetlabs/puppet')) }
      end

      it "has confdir ~/.puppet when run as non-root" do
        as_non_root { expect(@run_mode.conf_dir).to eq(File.expand_path('~/.puppet')) }
      end

      context "master run mode" do
        before do
          @run_mode = Puppet::Util::UnixRunMode.new('master')
        end
        it "has confdir ~/.puppet when run as non-root and master run mode (#16337)" do
          as_non_root { expect(@run_mode.conf_dir).to eq(File.expand_path('~/.puppet')) }
        end
      end

      it "fails when asking for the conf_dir as non-root and there is no $HOME" do
        as_non_root do
          without_home do
            expect { @run_mode.conf_dir }.to raise_error ArgumentError, /couldn't find HOME/
          end
        end
      end
    end

    describe "#code_dir" do
      it "has codedir /etc/puppetlabs/code when run as root" do
        as_root { expect(@run_mode.code_dir).to eq(File.expand_path('/etc/puppetlabs/code')) }
      end

      it "has codedir ~/.puppet/code when run as non-root" do
        as_non_root { expect(@run_mode.code_dir).to eq(File.expand_path('~/.puppet/code')) }
      end

      context "master run mode" do
        before do
          @run_mode = Puppet::Util::UnixRunMode.new('master')
        end

        it "has codedir ~/.puppet/code when run as non-root and master run mode" do
          as_non_root { expect(@run_mode.code_dir).to eq(File.expand_path('~/.puppet/code')) }
        end
      end

      it "fails when asking for the code_dir as non-root and there is no $HOME" do
        as_non_root do
          without_home do
            expect { @run_mode.code_dir }.to raise_error ArgumentError, /couldn't find HOME/
          end
        end
      end
    end

    describe "#var_dir" do
      it "has vardir /opt/puppetlabs/puppet/cache when run as root" do
        as_root { expect(@run_mode.var_dir).to eq(File.expand_path('/opt/puppetlabs/puppet/cache')) }
      end

      it "has vardir ~/.puppet/var when run as non-root" do
        as_non_root { expect(@run_mode.var_dir).to eq(File.expand_path('~/.puppet/var')) }
      end

      it "fails when asking for the var_dir as non-root and there is no $HOME" do
        as_non_root do
          without_home do
            expect { @run_mode.var_dir }.to raise_error ArgumentError, /couldn't find HOME/
          end
        end
      end
    end

    describe "#log_dir" do
      describe "when run as root" do
        it "has logdir /var/log/puppetlabs" do
          as_root { expect(@run_mode.log_dir).to eq(File.expand_path('/var/log/puppetlabs')) }
        end
      end

      describe "when run as non-root" do
        it "has default logdir ~/.puppet/var/log" do
          as_non_root { expect(@run_mode.log_dir).to eq(File.expand_path('~/.puppet/var/log')) }
        end

        it "fails when asking for the log_dir and there is no $HOME" do
          as_non_root do
            without_home do
              expect { @run_mode.log_dir }.to raise_error ArgumentError, /couldn't find HOME/
            end
          end
        end
      end
    end

    describe "#run_dir" do
      describe "when run as root" do
        it "has rundir /var/run/puppetlabs" do
          as_root { expect(@run_mode.run_dir).to eq(File.expand_path('/var/run/puppetlabs')) }
        end
      end

      describe "when run as non-root" do
        it "has default rundir ~/.puppet/var/run" do
          as_non_root { expect(@run_mode.run_dir).to eq(File.expand_path('~/.puppet/var/run')) }
        end

        it "fails when asking for the run_dir and there is no $HOME" do
          as_non_root do
            without_home do
              expect { @run_mode.run_dir }.to raise_error ArgumentError, /couldn't find HOME/
            end
          end
        end
      end
    end
  end

  describe Puppet::Util::WindowsRunMode, :if => Puppet.features.microsoft_windows? do
    before do
      if not Dir.const_defined? :COMMON_APPDATA
        Dir.const_set :COMMON_APPDATA, "/CommonFakeBase"
        @remove_const = true
      end
      @run_mode = Puppet::Util::WindowsRunMode.new('fake')
    end

    after do
      if @remove_const
        Dir.send :remove_const, :COMMON_APPDATA
      end
    end

    describe "#conf_dir" do
      it "has confdir ending in Puppetlabs/puppet/etc when run as root" do
        as_root { expect(@run_mode.conf_dir).to eq(File.expand_path(File.join(Dir::COMMON_APPDATA, "PuppetLabs", "puppet", "etc"))) }
      end

      it "has confdir in ~/.puppet when run as non-root" do
        as_non_root { expect(@run_mode.conf_dir).to eq(File.expand_path("~/.puppet")) }
      end

      it "fails when asking for the conf_dir as non-root and there is no %HOME%, %HOMEDRIVE%, and %USERPROFILE%" do
        as_non_root do
          without_env('HOME') do
            without_env('HOMEDRIVE') do
              without_env('USERPROFILE') do
                expect { @run_mode.conf_dir }.to raise_error ArgumentError, /couldn't find HOME/
              end
            end
          end
        end
      end
    end

    describe "#code_dir" do
      it "has codedir ending in PuppetLabs/code when run as root" do
        as_root { expect(@run_mode.code_dir).to eq(File.expand_path(File.join(Dir::COMMON_APPDATA, "PuppetLabs", "code"))) }
      end

      it "has codedir in ~/.puppet/code when run as non-root" do
        as_non_root { expect(@run_mode.code_dir).to eq(File.expand_path("~/.puppet/code")) }
      end

      it "fails when asking for the code_dir as non-root and there is no %HOME%, %HOMEDRIVE%, and %USERPROFILE%" do
        as_non_root do
          without_env('HOME') do
            without_env('HOMEDRIVE') do
              without_env('USERPROFILE') do
                expect { @run_mode.code_dir }.to raise_error ArgumentError, /couldn't find HOME/
              end
            end
          end
        end
      end
    end

    describe "#var_dir" do
      it "has vardir ending in PuppetLabs/puppet/cache when run as root" do
        as_root { expect(@run_mode.var_dir).to eq(File.expand_path(File.join(Dir::COMMON_APPDATA, "PuppetLabs", "puppet", "cache"))) }
      end

      it "has vardir in ~/.puppet/var when run as non-root" do
        as_non_root { expect(@run_mode.var_dir).to eq(File.expand_path("~/.puppet/var")) }
      end

      it "fails when asking for the conf_dir as non-root and there is no %HOME%, %HOMEDRIVE%, and %USERPROFILE%" do
        as_non_root do
          without_env('HOME') do
            without_env('HOMEDRIVE') do
              without_env('USERPROFILE') do
                expect { @run_mode.var_dir }.to raise_error ArgumentError, /couldn't find HOME/
              end
            end
          end
        end
      end
    end

    describe "#log_dir" do
      describe "when run as root" do
        it "has logdir ending in PuppetLabs/puppet/var/log" do
          as_root { expect(@run_mode.log_dir).to eq(File.expand_path(File.join(Dir::COMMON_APPDATA, "PuppetLabs", "puppet", "var", "log"))) }
        end
      end

      describe "when run as non-root" do
        it "has default logdir ~/.puppet/var/log" do
          as_non_root { expect(@run_mode.log_dir).to eq(File.expand_path('~/.puppet/var/log')) }
        end

        it "fails when asking for the log_dir and there is no $HOME" do
          as_non_root do
            without_env('HOME') do
              without_env('HOMEDRIVE') do
                without_env('USERPROFILE') do
                  expect { @run_mode.log_dir }.to raise_error ArgumentError, /couldn't find HOME/
                end
              end
            end
          end
        end
      end
    end

    describe "#run_dir" do
      describe "when run as root" do
        it "has rundir ending in PuppetLabs/puppet/var/run" do
          as_root { expect(@run_mode.run_dir).to eq(File.expand_path(File.join(Dir::COMMON_APPDATA, "PuppetLabs", "puppet", "var", "run"))) }
        end
      end

      describe "when run as non-root" do
        it "has default rundir ~/.puppet/var/run" do
          as_non_root { expect(@run_mode.run_dir).to eq(File.expand_path('~/.puppet/var/run')) }
        end

        it "fails when asking for the run_dir and there is no $HOME" do
          as_non_root do
            without_env('HOME') do
              without_env('HOMEDRIVE') do
                without_env('USERPROFILE') do
                  expect { @run_mode.run_dir }.to raise_error ArgumentError, /couldn't find HOME/
                end
              end
            end
          end
        end
      end
    end
  end

  def as_root
    Puppet.features.stubs(:root?).returns(true)
    yield
  end

  def as_non_root
    Puppet.features.stubs(:root?).returns(false)
    yield
  end

  def without_env(name, &block)
    saved = ENV[name]
    ENV.delete name
    yield
  ensure
    ENV[name] = saved
  end

  def without_home(&block)
    without_env('HOME', &block)
  end
end
