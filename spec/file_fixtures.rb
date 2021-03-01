require 'fileutils'

class FileFixtures
  def fixtures_path(*args)
    File.join(__dir__ + '/file-fixtures', *args)
  end

  def clear_files
    Dir[fixtures_path('*')]
      .filter { |f| File.basename(f) != '.gitignore' }
      .each { |f| FileUtils.rm_rf(f) }
  end

  # @param contents [String]
  def given_a_file_with_contents(name, contents)
    file_path = "#{fixtures_path}/#{name}"
    dir = File.dirname(file_path)
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
    File.open(file_path, 'w') do |f|
      f.write(contents)
    end
  end
end