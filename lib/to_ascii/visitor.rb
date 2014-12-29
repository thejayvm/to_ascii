module ToAscii
  module ColumnDefiner
    def column(name, width)
      columns << [name, width]
    end

    def id(width = 6)
      column :id, width
    end

    def respond_to_missing?(method, include_private = false) # ruby 1.9+ only, but 1.8 won't care because it just looks like a method #honeybadger
      true
    end

    def respond_to?(method, include_private = false)
      true
    end # for ruby 1.8 completeness

    def method_missing(method, *args, &block)
      raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)" if args.length > 1
      width = args.length == 1 ? args[0] : method.to_s.length + 2
      column method, width
    end
  end

  class Visitor
    class << self
      include ColumnDefiner

      def for_class(clazz)
        "#{clazz.name}ToAscii".constantize
      end

      def columns
        @columns ||= []
      end
    end

    include ColumnDefiner

    attr_reader :columns

    def initialize
      @columns = self.class.columns.dup
    end

    def cell_border
      @cell_border ||= "|#{columns.map { |c| '-' * c[1] }.join('|')}|"
    end

    def headers(io)
      io.puts cell_border
      io.puts "|#{columns.map { |c| c[0].to_s.center(c[1]) }.join('|')}|"
      io.puts cell_border
    end

    def visit(o)
      "|#{columns.map { |c| o.send(c[0]).to_s.center(c[1]) }.join('|')}|"
    end
  end
end
