module Helpers

  def render_file(filename)
    contents = File.read(absolute_path("../views/#{filename}", __FILE__))
    Haml::Engine.new(contents).render
  end


  def render_file_with_argument(filename, arguments)
    contents = File.read(absolute_path("../views/#{filename}", __FILE__))
    Haml::Engine.new(contents).render(Object.new, :my_arguments => arguments)
  end


  def render_file_for_mail(filename, arguments)
    contents = File.read(absolute_path("../views/#{filename}", __FILE__))
    Haml::Engine.new(contents).render(Object.new, :mail_arguments => arguments)
  end

  #Returns absolute path to the given relative path and __FILE__
  #
  #@param relative_path: absolute_path path seen from file of the calling class
  #@param path_of_file: use __FILE__ as argument

  def absolute_path(relative_path, path_of_file)
    File.join(File.expand_path(File.dirname(path_of_file)), relative_path)
  end

end