module Helpers
  def render_file(filename)
    if ENV['RACK_ENV'] == 'test'
        contents = File.read(absolute_path("../views/#{filename}", __FILE__))
    else
        contents = File.read("views/#{filename}")
    end
    Haml::Engine.new(contents).render
  end

  #Returns absolute path to the given relative path and __FILE__
  #
  #@param relative_path: absolute_path path seen from file of the calling class
  #@param path_of_file: use __FILE__ as argument

  def absolute_path(relative_path, path_of_file)
    File.join(File.expand_path(File.dirname(path_of_file)), relative_path)
  end
end