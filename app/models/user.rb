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

class User < ActiveRecord::Base
    has_and_belongs_to_many :scans
    has_and_belongs_to_many :profiles
    has_many :comments
    has_many :notifications, dependent: :destroy
    has_and_belongs_to_many :scan_groups

    rolify
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :rememberable, :trackable, :validatable

    def scan_limit_exceeded?
        !admin? &&
            Settings.per_user_scan_limit && own_scans.active.size >= Settings.per_user_scan_limit
    end

    def available_profiles
        Profile.where( id: profiles.pluck( :id ) + Profile.global.pluck( :id ) )
    end

    def admin?
        has_role? :admin
    end

    def to_s
        name
    end

    def notifications
        super.where( 'actor_id IS NULL OR actor_id != ?', id ).order( 'id desc' )
    end

    def activities
        Notification.group( %w(model_type model_id action text)).
            where( 'actor_id == ?', id ).order( 'id desc' )
    end

    def self.recent( limit = 5 )
        limit( limit ).order( "id desc" )
    end

    def own_scans
        scans.where( owner_id: id ).order( 'id desc' )
    end

    def own_scan_groups
        scan_groups.where( owner_id: id ).order( 'id desc' )
    end

    def shared_scan_groups
        scan_groups.where( 'owner_id != ?', id ).order( 'id desc' )
    end

    def others_scan_groups
        return none if !admin?

        ScanGroup.where( 'owner_id != ?', id ).
            where( 'id not in (?)', scan_group_ids ).
            order( 'id desc' )
    end

    def ability
        @ability ||= Ability.new( self )
    end
    delegate :can?, :cannot?, to: :ability
end
