class Setting < ActiveRecord::Base
    serialize :target_whitelist_patterns, Array
    serialize :target_blacklist_patterns, Array

    def target_whitelist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    def target_blacklist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    private

    def self.string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject( &:empty? )
        end
    end
end
