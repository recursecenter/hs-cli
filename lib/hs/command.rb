module HS

  class Command
    def self.dispatch(c)
      Proc.new do |global_options, options, args|
        puts "#{c.name} command ran. options: #{options}\nargs: #{args}"
      end
    end
  end

end
