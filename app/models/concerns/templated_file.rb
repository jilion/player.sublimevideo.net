module TemplatedFile

  def _template_path(filename)
    @_template_path ||= Rails.root.join('app', 'templates', filename)
  end

  def _template(filename)
    @_template ||= ERB.new File.new(_template_path(filename)).read
  end

  def _tempfile
    @_tempfile ||= Tempfile.new [self.class, '.js'], Rails.root.join('tmp')
  end

end
