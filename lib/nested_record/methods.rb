class NestedRecord::Methods < Module
  def initialize(setup)
    @setup = setup
  end

  def define(name)
    method_name = public_send("#{name}_method_name")
    method_body = (bodym = public_method("#{name}_method_body")).call
    case method_body
    when Proc
      define_method(method_name, &method_body)
    when String
      location = bodym.source_location
      location[1] += 1
      module_eval <<~RUBY, *location
        def #{method_name}
          #{method_body}
        end
      RUBY
    else
      fail
    end
  end

  def reader_method_name
    @setup.name
  end

  def writer_method_name
    :"#{@setup.name}="
  end

  def upsert_attributes_method_name
    :"upsert_#{@setup.name}_attributes"
  end

  def rewrite_attributes_method_name
    :"rewrite_#{@setup.name}_attributes"
  end

  def attributes_writer_method_name
    :"#{@setup.name}_attributes="
  end

  def define_attributes_writer_method
    case @setup.attributes_writer_strategy
    when :rewrite
      alias_method attributes_writer_method_name, rewrite_attributes_method_name
    when :upsert
      alias_method attributes_writer_method_name, upsert_attributes_method_name
    end
  end

  require 'nested_record/methods/many'
  require 'nested_record/methods/one'
end
