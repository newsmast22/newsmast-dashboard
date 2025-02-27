class KeywordFilterGroup < ApplicationRecord
  belongs_to :server_setting, class_name: 'ServerSetting', optional: true
  has_many :keyword_filters, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :server_setting_id }

  accepts_nested_attributes_for :keyword_filters,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes['keyword'].blank? }

  def self.fetch_keyword_filter_group_api(setting_name, server_setting_id)
    new_data = fetch_data_from_api(setting_name)
    filter_type = filter_type_for(setting_name)
    redis_key = redis_key_name(setting_name)

    new_data.each do |group_data|
      filter_group = find_or_initialize_filter_group(group_data, server_setting_id)
      filter_group.update(is_active: group_data['is_active'])

      new_keywords = update_or_create_keywords(group_data[filter_type], filter_group, redis_key)
      filter_group.keyword_filters.where.not(keyword: new_keywords).destroy_all
    end

    cleanup_old_groups(new_data, server_setting_id)
  end

  def self.delete_all_when_inactive(server_setting)
    KeywordFilterGroup.where(server_setting_id: server_setting.id, is_custom: false).destroy_all

    redis_key = redis_key_name(server_setting.name)
    delete_redis_filters(redis_key)
  end

  def self.get_redis_key_name(setting_name)
    redis_key_name(setting_name)
  end
  private

  def self.fetch_data_from_api(setting_name)
    api_service = KeywordFilterGroupApiService.new(setting_name)
    api_service.get_keywords
  end

  def self.filter_type_for(setting_name)
    setting_name == 'Spam filters' ? 'spam_filters' : 'keyword_filters'
  end

  def self.find_or_initialize_filter_group(group_data, server_setting_id)
    KeywordFilterGroup.find_or_initialize_by(
      name: group_data['name'],
      server_setting_id: server_setting_id,
      is_custom: false
    )
  end

  def self.update_or_create_keywords(keywords_data, filter_group, redis_key)
    keywords_data.map do |keyword_data|
      keyword_filter = KeywordFilter.find_or_initialize_by(
        keyword: keyword_data['keyword'],
        keyword_filter_group_id: filter_group.id
      )
      keyword_filter.update(filter_type: keyword_data['filter_type'])

      # Store the keyword in Redis
      add_or_update_filter(redis_key, keyword_filter.keyword, filter_group.server_setting_id, keyword_filter.filter_type, filter_group.is_active, filter_group.id)
      
      keyword_filter.keyword
    end
  end

  def self.cleanup_old_groups(new_data, server_setting_id)
    new_group_names = new_data.map { |group| group['name'] }
    KeywordFilterGroup.where(server_setting_id: server_setting_id, is_custom: false)
                      .where.not(name: new_group_names)
                      .destroy_all
  end

  def filter_exists?(keyword, filter_type, is_spam)
    # Store the keyword in Redis
    redis = RedisService.client(namespace: 'channel')
    redis_key = is_spam ? 'spam_filters' : 'content_filters'
    composite_key = "#{keyword.downcase}:#{filter_type}"
    redis.current.hexists(redis_key, composite_key)
  end

  def self.add_or_update_filter(redis_key, keyword, server_setting_id, filter_type, is_active, group_id)
    # Store the keyword in Redis
    redis = RedisService.client(namespace: 'channel')
    group_id = group_id
    composite_key = "#{keyword.downcase}:#{filter_type}"
  
    # Prepare the new value
    new_value = {
      keyword: keyword,
      filter_type: filter_type,
      server_setting_id: server_setting_id,
      group_id: group_id,
      is_active: is_active,
      custom: false
    }.to_json
  
    # Overwrite or create the entry
    redis.hset(redis_key, composite_key, new_value)
  end

  def self.delete_redis_filters(redis_key)
    redis = RedisService.client(namespace: 'channel')
    redis.del(redis_key) if redis.exists(redis_key)
  end

  def self.redis_key_name(setting_name)
    setting_name == 'Spam filters' ? 'spam_filters' : 'content_filters'
  end
end
