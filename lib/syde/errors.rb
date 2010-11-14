module Syde
	module Errors
		class PasswordIncorrectError < StandardError; end
		class MissingPasswordError < StandardError; end
		class AccessError < StandardError; end
	end
end
