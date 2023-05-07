# Some pomp and circumstance to create a deep OpenStruct copy of a hash.  Used initially in app_config.rb

class Hash
  def deep_slice( *args )
    internal_deep_slice(self, *args)
  end

  # options:
  # :exclude => [keys] - keys need to be symbols
  def to_ostruct(options = {})
    convert_to_ostruct_recursive(self, options)
  end

  private
  # started from https://stackoverflow.com/a/73489288
  def internal_deep_slice( obj, *args )
    deep_arg = {}
    slice_args = []
    args.each do |arg|
      if arg.is_a? Hash
        arg.each do |hash|
          key, value = hash
          if obj[key].is_a? Hash
            deep_arg[key] = internal_deep_slice( obj[key], *value )
          elsif obj[key].is_a? Array
            deep_arg[key] = obj[key].map{ |arr_el| internal_deep_slice( arr_el, *value) }
          end
        end
      elsif arg.is_a? String
        slice_args << arg
      end
    end
    obj.slice(*slice_args).merge(deep_arg)
  end

  def convert_to_ostruct_recursive(obj, options = {})
    result = obj

    if result.is_a? Hash
      result = result.dup.tap{|h| h.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }}

      result.each do |key, val|
        result[key] = convert_to_ostruct_recursive(val, options) unless options[:exclude].try(:include?, key)
      end

      result = OpenStruct.new result
    elsif result.is_a? Array
      result = result.map { |r| convert_to_ostruct_recursive(r, options) }
    end

    result
  end
end


# also a patch for rails < 6
if Rails::VERSION::MAJOR >= 6
  # Do the new thing
else
  class Hash
    # Returns a new hash with all values converted by the block operation.
    # This includes the values from the root hash and from all
    # nested hashes and arrays.
    #
    #  hash = { person: { name: 'Rob', age: '28' } }
    #
    #  hash.deep_transform_values{ |value| value.to_s.upcase }
    #  # => {person: {name: "ROB", age: "28"}}
    def deep_transform_values(&block)
      _deep_transform_values_in_object(self, &block)
    end

    # Destructively converts all values by using the block operation.
    # This includes the values from the root hash and from all
    # nested hashes and arrays.
    def deep_transform_values!(&block)
      _deep_transform_values_in_object!(self, &block)
    end

    private
    # Support methods for deep transforming nested hashes and arrays.
    def _deep_transform_values_in_object(object, &block)
      case object
      when Hash
        object.transform_values { |value| _deep_transform_values_in_object(value, &block) }
      when Array
        object.map { |e| _deep_transform_values_in_object(e, &block) }
      else
        yield(object)
      end
    end

    def _deep_transform_values_in_object!(object, &block)
      case object
      when Hash
        object.transform_values! { |value| _deep_transform_values_in_object!(value, &block) }
      when Array
        object.map! { |e| _deep_transform_values_in_object!(e, &block) }
      else
        yield(object)
      end
    end
  end
end
