require 'solve'
require 'stage'

class PackagesDependenciesSolver

  def self.dependencies(packages, stage)
    new(packages, stage).solve
  end

  def initialize(initial_packages, stage)
    @stage = stage
    # FIXME
    # @packages = Package.app_packages(@stage) + initial_packages
    @packages = initial_packages
    @demands = @packages.map { |package| [package.name, '>= 0.0.0-alpha'] }.uniq
    _build_graph
  end

  def solve
    Solve.it!(@graph, @demands)
  end

  private

  def _build_graph
    @graph = Solve::Graph.new
    @packages.each { |package| _add_package_to_graph(package) }
  end

  def _add_package_to_graph(package)
    artifact = @graph.artifacts(package.name, package.version)

    package.dependencies.each do |dependent_package_name, version_contraint|
      artifact.depends(dependent_package_name, version_contraint)
      _add_package_dependencies_to_graph(dependent_package_name)
    end
  end

  def _add_package_dependencies_to_graph(package)
    Package.packages_for_name_and_stage(package, @stage).each do |package|
      _add_package_to_graph(package) unless _graph_includes_package_already?(package)
    end
  end

  def _graph_includes_package_already?(package)
    @graph.artifacts.any? { |a| a.name == package.name && a.version.to_s == package.version }
  end

end
