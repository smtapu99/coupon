module ActsAsCurrentEntity
  extend ActiveSupport::Concern

  included do
    after_commit :clear_current_entity_cache

    def self.current
      if RequestStore.store["#{self.name.downcase.to_sym}_current".to_sym].present?
        return RequestStore.store["#{self.name.downcase.to_sym}_current".to_sym]
      end

      # this allows to use Site.current in tasks in production
      if self.name.present? && self.name == 'Site' && ($current_site.present?)
        return $current_site
      end

      session_vars = read_session

      return nil if session_vars.nil?

      if current_entity_is_user?
        class_name = session_vars.first[0] #key
        record_id  = session_vars.first[1] #value
      else
        class_name = self.name
        record_id = session_vars
      end

      if Rails.env.test?
        class_name.constantize.find(record_id) rescue class_name.constantize.first # this is as the IDs change during a test
      else
        record = class_name.constantize.find(record_id)
        RequestStore.store["#{self.name.downcase.to_sym}_current".to_sym] = record
      end
    end

    #
    # self.current
    #
    # saves the ID of the current entity into the session. If the entity is a type of User it also saves
    # the class_name as key and the Id as value.
    #
    # @param  entity [Integer || ActiveRecord] ID or record
    #
    def self.current=(entity)

      if is_a_record?(entity)
        if user_classes.include?(entity.class.name)
          session_vars = {entity.class.name => entity.id}
        else
          session_vars = entity.id
        end
      elsif entity.is_a? Integer
        session_vars = entity
      elsif !entity.nil?
        raise 'Invalid current entity type. Provide ActiveRecord or Id (Integer) or nil'
      end

      write_session session_vars
    end

    def self.read_session
      RequestStore.store["#{self.name.downcase.to_sym}_current_vars".to_sym]
    end

    def self.write_session session_vars
      RequestStore.store["#{self.name.downcase.to_sym}_current_vars".to_sym] = session_vars
    end

    def self.is_a_record? entity
      entity.respond_to?('class') && entity.class < ApplicationRecord
    end

    def self.user_classes
      ['User'] + User.subclasses
    end

    def self.current_entity_is_user?
      self.name == 'User'
    end

    #
    # clear_current_entity_cache
    #
    # Drops all cache entries for current entities; If the current entity is a user, it drops all cache entries
    # for all user types
    def clear_current_entity_cache
      class_names = self.class.user_classes.include?(self.class.name) ? self.class.user_classes : [self.class.name]
      class_names.each do |class_name|
        Rails.cache.delete([class_name, 'current', id])
      end
    end
  end

end
