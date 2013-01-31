module HS
  module CommandHelpers

    def temp_file
      file = Tempfile.new('hs')
      yield file
    ensure
      file.close(true) if file
    end

  end
end
