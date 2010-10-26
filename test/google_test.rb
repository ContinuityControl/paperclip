require 'test/helper'

class Dummy
  # This is a dummy class
end

class AttachmentTest < Test::Unit::TestCase
  should "return google docs url" do
    @attachment = attachment :url => "/:class/:id/:basename", :storage => :google, :cred_proc => Proc.new { '1234567890' }
    @model = @attachment.instance
    @model.id = 1234
    @model.avatar_file_name = 'https://docs.google.com/edit?1234567890'
    assert_equal 'https://docs.google.com/edit?1234567890', @attachment.path(:original)
  end

  setup do
    rebuild_model
    @old_default_options = Paperclip::Attachment.default_options.dup
    @new_default_options = @old_default_options.merge({
                                                        :path => "argle/bargle",
                                                        :url => "fooferon",
                                                        :default_url => "not here.png"
                                                      })
    
  end
end
