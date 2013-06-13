require 'solve'
require 'stage'

class PackageDependenciesSolver

  def self.dependencies(site, stage)
    new(site, stage).solve
  end

  def initialize(site, stage)
    @site, @stage, @graph = site, stage, Solve::Graph.new

    @packages  = Package.app_packages(@stage)
    @packages += @site.packages(@stage)
    @packages.each { |package| _add_package(package) }
  end

  def solve
    demands = @packages.map { |package| [package.name, '>= 0.0.0-alpha'] }.uniq

    Solve.it!(@graph, demands)
  end

  private

  def _add_package(package)
    artifact = @graph.artifacts(package.name, package.version)

    package.dependencies.each do |dependent_package_name, version_contraint|
      artifact.depends(dependent_package_name, version_contraint)

      Package.packages_for_name(dependent_package_name, @stage).each do |dependent_package|
        if @graph.artifacts.none? { |a| a.name == dependent_package.name && a.version.to_s == dependent_package.version }
          _add_package(dependent_package)
        end
      end
    end
  end

end
