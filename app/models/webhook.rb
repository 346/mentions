class Webhook < ApplicationRecord
  FROM = %w(github esa)
  TO = %w(slack)

  validates :from, inclusion: { in: FROM }
  validates :to, inclusion: { in: TO }
  validates :token, uniqueness: true

  before_validation :set_token, on: :create, unless: -> { token }

  def from_class
    Webhooks::From.const_get(from.classify)
  end

  def to_class
    Webhooks::To.const_get(to.classify)
  end

  def run(payload:)
    from_instance = from_class.new(payload: payload)
    mentions = from_instance.mentions.map { |m|
      id_mapping ||= IdMapping.new(ENV.fetch('MENTIONS_MAPPING_FILE_PATH'))
      id_mapping.find(user_name: m, from: from, to: to)
    }.compact

    mentions.each do |mention|
      to_class.new(mention: mention, url: from_instance.url, additional_message: from_instance.additional_message).post
    end
  end

  private

  def set_token
    self.token = SecureRandom.uuid.gsub(/-/,'')
  end
end
