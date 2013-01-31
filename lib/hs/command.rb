module HS

  class Command
    def self.dispatch(command)
      Proc.new do |global_opts, opts, args|
        self.new(global_opts, opts, args).execute(command)
      end
    end

    def initialize(global_opts, opts, args)
      @global_opts = global_opts
      @opts = opts
      @args = args
    end

    def execute(command)
      # validations, etc.
      send(command.name)
    end

    def request
      puts "requesting"
    end

    def review
      puts "reviewing"
    end

    def submit
      puts "submitting"
    end
  end

end
