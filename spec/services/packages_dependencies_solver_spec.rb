require 'fast_spec_helper'

require 'packages_dependencies_solver'

Package = Class.new unless defined? Package

def create_package(name, version, dependencies = {})
  mock("#{name}-#{version}", name: name, version: version, dependencies: {})
end

describe PackagesDependenciesSolver do
  let!(:app_100)       { create_package('app', '1.0.0') }
  let!(:app_200alpha1) { create_package('app', '2.0.0-alpha.1') }
  let!(:app_200beta1)  { create_package('app', '2.0.0-beta.1') }
  let!(:app_200)       { create_package('app', '2.0.0') }

  let!(:logo_100)       { create_package('logo', '1.0.0') }
  let!(:logo_110)       { create_package('logo', '1.1.0') }
  let!(:logo_200alpha1) { create_package('logo', '2.0.0-alpha.1') }
  let!(:logo_200beta1)  { create_package('logo', '2.0.0-beta.1') }

  let!(:stats_100) { create_package('stats', '1.0.0') }
  let!(:stats_200) { create_package('stats', '2.0.0') }

  let!(:embed_100) { create_package('embed', '1.0.0') }
  let!(:embed_200) { create_package('embed', '2.0.0') }

  let!(:support_100alpha1) { create_package('support', '1.0.0-alpha.1') }

  pending '.dependencies' do
    context 'when stage is "stable"' do
      let(:initial_packages) { [] }
      before do
        Package.should_receive(:app_packages).with('stable') { [app_200, app_100] }
      end

      context 'with no packages' do
        it 'depends on the latest stable "app" package' do
          described_class.dependencies(initial_packages, 'stable').should eq('app' => '2.0.0')
        end
      end

      context 'when the "app" package with no dependencies' do
        let(:initial_packages) { [app_100] }
        it 'depends only once on the latest stable "app" package' do
          described_class.dependencies(initial_packages, 'stable').should eq('app' => '2.0.0')
        end
      end

      context 'when several packages' do
        let(:initial_packages) { [logo_110, logo_100] }
        before do
          Package.stub(:packages_for_name_and_stage).with('app', 'stable') { [app_200, app_100] }
          Package.stub(:packages_for_name_and_stage).with('stats', 'stable') { [stats_200, stats_100] }
          Package.stub(:packages_for_name_and_stage).with('embed', 'stable') { [embed_200, embed_100] }
        end

        context 'with no dependencies' do
          it 'depends on the latest stable "app" & "logo" packages' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '2.0.0', 'logo' => '1.1.0')
          end
        end

        context 'with a simple dependency' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0' } }
          end

          it 'depends on the "app 1.0.0" package & the latest stable "logo" package' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.1.0')
          end
        end

        context 'with dependency on an unexistant package' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '3.0.0' } } # unexistent
          end

          it 'depends on the "app 1.0.0" package & the latest stable "logo" package' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.0.0')
          end
        end

        context 'with simple dependencies' do
          before do
            Package.should_receive(:packages_for_name_and_stage).with('stats', 'stable') { [stats_100, stats_200] }
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '>= 1.0.0' } }
          end

          it 'depends on all dependencies' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.1.0', 'stats' => '2.0.0')
          end
        end

        context 'with a dependency depending on an unresolvable package' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '>= 1.0.0' } }
            stats_200.stub(:dependencies) { { 'app' => '2.0.0' } } # impossible
          end

          it 'do not depend on the impossible dependency' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.1.0', 'stats' => '1.0.0')
          end
        end

        context 'with nested dependencies' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '>= 1.0.0' } }
            stats_200.stub(:dependencies) { { 'app' => '1.0.0', 'embed' => '1.0.0' } }
          end

          it 'depends on all dependencies' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.1.0', 'stats' => '2.0.0', 'embed' => '1.0.0')
          end
        end

        context 'with the latest package version impossible to solve' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '1.0.0' } }
            stats_100.stub(:dependencies) { { 'app' => '2.0.0' } }
            stats_200.stub(:dependencies) { { 'app' => '2.0.0' } }
          end

          it 'do not depend on the new version' do
            described_class.dependencies(initial_packages, 'stable').should eq('app' => '1.0.0', 'logo' => '1.0.0')
          end
        end

        context 'with all package versions impossible to solve' do
          before do
            logo_100.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '1.0.0' } }
            logo_110.stub(:dependencies) { { 'app' => '1.0.0', 'stats' => '1.0.0' } }
            stats_100.stub(:dependencies) { { 'app' => '2.0.0' } }
            stats_200.stub(:dependencies) { { 'app' => '2.0.0' } }
          end

          it 'raise Solve::Errors::NoSolutionError' do
            expect { described_class.dependencies(initial_packages, 'stable') }.to raise_error(Solve::Errors::NoSolutionError)
          end
        end
      end
    end

    context 'with stage is "beta"' do
      let(:initial_packages) { [logo_200beta1, logo_110, logo_100] }
      before do
        Package.should_receive(:app_packages).with('beta') { [app_200, app_200beta1, app_100] }
        Package.stub(:packages_for_name_and_stage).with('app', 'beta') { [app_200, app_200beta1, app_100] }
        Package.stub(:packages_for_name_and_stage).with('logo', 'beta') { [logo_200beta1, logo_110, logo_100] }
      end

      context 'with simple dependencies' do
        before do
          logo_100.stub(:dependencies) { { 'app' => '1.0.0' } }
          logo_110.stub(:dependencies) { { 'app' => '1.0.0' } }
          logo_200alpha1.stub(:dependencies) { { 'app' => '2.0.0-alpha.1' } }
          logo_200beta1.stub(:dependencies) { { 'app' => '2.0.0-beta.1' } }
        end

        it 'depends on all beta dependencies' do
          described_class.dependencies(initial_packages, 'beta').should eq('app' => '2.0.0-beta.1', 'logo' => '2.0.0-beta.1')
        end
      end
    end

    context 'with stage is "alpha"' do
      let(:initial_packages) { [support_100alpha1] }
      before do
        Package.should_receive(:app_packages).with('alpha') { [app_200, app_200beta1, app_200alpha1, app_100] }
        Package.stub(:packages_for_name_and_stage).with('app', 'alpha') { [app_200, app_200beta1, app_200alpha1, app_100] }
        Package.stub(:packages_for_name_and_stage).with('support', 'alpha') { [support_100alpha1] }
      end

      context 'with simple dependencies' do
        before do
          support_100alpha1.stub(:dependencies) { { 'app' => '1.0.0' } }
        end

        it 'depends on all dependencies' do
          described_class.dependencies(initial_packages, 'alpha').should eq('app' => '1.0.0', 'support' => '1.0.0-alpha.1')
        end
      end
    end
  end

end
