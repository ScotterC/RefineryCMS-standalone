class ImagePage < ActiveRecord::Base
  
  belongs_to :refinery_image
  belongs_to :page, :polymorphic => true

  translates :caption if self.respond_to?(:translates)

  attr_accessible :refinery_image_id, :position, :locale
  ::ImagePage::Translation.send :attr_accessible, :locale

end