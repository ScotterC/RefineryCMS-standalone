class Role < ActiveRecord::Base

  has_and_belongs_to_many :users

  before_validation :camelize_title
  validates :name, :uniqueness => true

  def camelize_title(role_title = self.name)
    self.name = role_title.to_s.camelize
  end

  def self.[](title)
    find_or_create_by_name(name.to_s.camelize)
  end

end
