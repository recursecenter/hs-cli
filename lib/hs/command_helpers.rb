require 'tempfile'

module HS
  module CommandHelpers

    def editor_input(initial_value="")
      temp_file do |f|
        f.puts initial_value
        f.flush
        f.close(false)
        open_editor(f.path)
        File.read(f.path)
      end
    end

    def open_editor(path)
      invocation = "#{ENV['EDITOR']} #{path}"
      system(invocation) or raise CommandError, "#{invocation} gave exit status #{$?.exitstatus}"
    end

    def temp_file
      file = ::Tempfile.new('hs')
      yield file
    ensure
      file.close(true) if file
    end

  end
end
