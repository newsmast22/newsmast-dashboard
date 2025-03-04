# frozen_string_literal: true

# Form::Community is a form object used for handling community-related form data.
# It is not directly associated with a database table but manages form inputs

class Form::Community
  include ActiveModel::Model

  attr_accessor :id, :name, :slug, :collection_id, :bio, :banner_image, :logo_image, :avatar_image, :community_type_id, :is_recommended, :is_custom_domain

  def initialize(options = {})
    options = options.is_a?(Hash) ? options.symbolize_keys : options
    @id = options.fetch(:id) if options[:id]
    @name = options.fetch(:name) if options[:name]
    @slug = options.fetch(:slug) if options[:slug]
    @collection_id = options.fetch(:collection_id) if options[:collection_id]
    @bio = options.fetch(:bio, nil) if options[:bio]
    @banner_image = options.fetch(:banner_image, nil) if options[:banner_image]
    @logo_image = options.fetch(:logo_image, nil) if options[:logo_image]
    @avatar_image = options.fetch(:avatar_image, nil) if options[:avatar_image]
    @community_type_id = options.fetch(:community_type_id) if options[:community_type_id]
    @is_recommended = options.fetch(:is_recommended) if options[:is_recommended]
    @is_custom_domain = options.fetch(:is_custom_domain) if options[:is_custom_domain]
  end
end
