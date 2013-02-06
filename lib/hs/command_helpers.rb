require 'tempfile'

module HS
  module CommandHelpers
    def editor_input(initial_value="")
      tempfile do |f|
        f.puts initial_value
        f.close
        open_editor(f.path)
        File.read(f.path)
      end
    end

    def open_editor(path)
      invocation = "#{ENV['EDITOR']} #{path}"
      system(invocation) or raise CommandError, "#{invocation} gave exit status #{$?.exitstatus}"
    end

    def tempfile
      file = ::Tempfile.new('hs')
      yield file
    ensure
      file.close
      file.unlink
    end
  end
end
