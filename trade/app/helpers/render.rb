module Helpers

  def render_file(filename)
    contents = File.read("#{:views}/#{filename}")
    Haml::Engine.new(contents).render
  end

end