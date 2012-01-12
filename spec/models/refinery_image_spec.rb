require 'spec_helper'

describe RefineryImage do
  let(:image) do
    RefineryImage.create!(:id => 1,
                  :image => File.new(File.expand_path('../../uploads/beach.jpeg', __FILE__)))
  end

  context "with valid attributes" do
    it "should create successfully" do
      image.errors.should be_empty
    end
  end

  context "image url" do
    it "should respond to .thumbnail" do
      image.should respond_to(:thumbnail)
    end

    it "should contain its filename at the end" do
      image.thumbnail(nil).url.split('/').last.should == image.image_name
    end

    it "should be different when supplying geometry" do
      image.thumbnail(nil).url.should_not == image.thumbnail('200x200').url
    end

    it "should have different urls for each geometry string" do
      image.thumbnail('200x200').url.should_not == image.thumbnail('200x201').url
    end

    it "should use right geometry when given a thumbnail name" do
      name, geometry = RefineryImage.user_image_sizes.first
      image.thumbnail(name).url.should == image.thumbnail(geometry).url
    end
  end

  describe "#title" do
    it "returns a titleized version of the filename" do
      image.title.should == "Beach"
    end
  end

  describe ".per_page" do
    context "dialog is true" do
      context "has_size_options is true" do
        it "returns image count specified by PAGES_PER_DIALOG_THAT_HAS_SIZE_OPTIONS constant" do
          RefineryImage.per_page(true, true).should == RefineryImage::PAGES_PER_DIALOG_THAT_HAS_SIZE_OPTIONS
        end
      end

      context "has_size_options is false" do
        it "returns image count specified by PAGES_PER_DIALOG constant" do
          RefineryImage.per_page(true).should == RefineryImage::PAGES_PER_DIALOG
        end
      end
    end

    context "dialog is false" do
      it "returns image count specified by PAGES_PER_ADMIN_INDEX constant" do
        RefineryImage.per_page.should == RefineryImage::PAGES_PER_ADMIN_INDEX
      end
    end
  end

  describe ".user_image_sizes" do
    it "sets and returns a hash consisting of the keys contained in the RefinerySetting" do
      RefineryImage.user_image_sizes.should == RefinerySetting.get(:user_image_sizes)
    end
  end

  # The sample image has dimensions 500x375
  describe '#thumbnail_dimensions returns correctly with' do
    it 'nil' do
      image.thumbnail_dimensions(nil).should == { :width => 500, :height => 375 }
    end

    it '200x200#ne' do
      image.thumbnail_dimensions('200x200#ne').should == { :width => 200, :height => 200 }
    end

    it '100x150#c' do
      image.thumbnail_dimensions('100x150#c').should == { :width => 100, :height => 150 }
    end

    it '250x250>' do
      image.thumbnail_dimensions('250x250>').should == { :width => 250, :height => 188 }
    end

    it '600x375>' do
      image.thumbnail_dimensions('600x375>').should == { :width => 500, :height => 375 }
    end

    it '100x475>' do
      image.thumbnail_dimensions('100x475>').should == { :width => 100, :height => 75 }
    end

    it '100x150' do
      image.thumbnail_dimensions('100x150').should == { :width => 100, :height => 75 }
    end

    it '200x150' do
      image.thumbnail_dimensions('200x150').should == { :width => 200, :height => 150 }
    end

    it '300x150' do
      image.thumbnail_dimensions('300x150').should == { :width => 200, :height => 150 }
    end

    it '5x5' do
      image.thumbnail_dimensions('5x5').should == { :width => 5, :height => 4 }
    end
  end

end
