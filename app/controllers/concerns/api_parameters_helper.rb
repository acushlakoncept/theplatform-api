module ApiParametersHelper
	def snakecase_params
		@old_params ||= params.permit!.to_h.deep_dup
		new_params = params.permit!.to_h.deep_transform_keys {|k| k.to_s.underscore.to_sym }
		@camelcase = !(new_params == @old_params)
    ActionController::Parameters.new(new_params)
	end

	def is_snakecase_params
		!@camelcase
	end

	def setup_json_serializer(json, *args)
		@serializer = Jbuilder::KeyFormatter.new(*args)
		@json ||= json
		@json.key_format! *args
	end
	
	def json_merge!(hash_or_array)
		if ::Hash === hash_or_array
			@json.merge! hash_or_array.deep_transform_keys! {
					|k|
				@serializer.format(k)
			}
		else
			@json.merge! hash_or_array
		end
  end

  def array_from_param(param)
    Array(param).flat_map{|l| l.split(',')}.flat_map{|l| l.strip.presence}.compact
  end
end
