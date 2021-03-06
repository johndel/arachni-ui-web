=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

class Notification < ActiveRecord::Base
    belongs_to :user

    def self.mark_read
        update_all( { read: true }, { read: false } )
    end

    def self.unread
        where( read: false )
    end

    def read?
        read
    end

    def unread?
        !read?
    end

    def user=( u )
        return if !u
        self.user_id = u.id
    end

    def user
        return if !user_id
        User.find( user_id )
    end

    def actor=( u )
        return if !u
        self.actor_id = u.id
    end

    def actor
        return if !actor_id
        User.find( actor_id )
    end

    def model=( m )
        self.model_type = m.class.to_s
        self.model_id   = m.id
        m
    end

    def model
        model_class.find( model_id ) rescue nil
    end

    def model_class
        model_type.classify.constantize
    end

    def action
        super.to_sym
    end

    def action_description
        model_class.describe_notification action
    end

    def to_s
        s = if model
                model.family.reverse.map do |model|
                "#{model.class} <em>#{model}</em>"
                end.join( ' of ' )
            else
                "(Now deleted) #{model_type} ##{model_id}"
            end

        s << " #{action_description}"
        s << " by #{actor}" if actor
        s
    end

end
