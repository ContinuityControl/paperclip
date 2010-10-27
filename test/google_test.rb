require 'test/helper'

class Dummy
  # This is a dummy class
end

class AttachmentTest < Test::Unit::TestCase
  should "return google docs url" do
    @attachment = attachment :url => "/:class/:id/:basename", :storage => :google, :cred_proc => Proc.new { '1234567890' }
    @attachment.assign StringIO.new("Fake Attachment")
    @fake_result = %w{ Fake Result }
    @fake_result.stubs(:body => '<fake><link rel="alternate" href="https://docs.google.com/edit?1234567890" /></fake>')
    @attachment.instance_variable_get(:@client).stubs(:post_file => @fake_result)
    @model = @attachment.instance
    @model.id = 1234
    # @model.avatar_file_name = 'https://docs.google.com/edit?1234567890'
    debugger
    assert_equal 'https://docs.google.com/edit?1234567890', @attachment.path(:original)
  end

  context "should not break attachment settings" do
    setup do
      rebuild_model
      @old_default_options = Paperclip::Attachment.default_options.dup
      @new_default_options = @old_default_options.merge({
                                                          :path => "argle/bargle",
                                                          :url => "fooferon",
                                                          :default_url => "not here.png"
                                                        })
      @attachment = attachment :url => "/:class/:id/:basename", :storage => :google, :cred_proc => Proc.new { '1234567890' }
      @file = StringIO.new("Fake Attached File")
      @attachment.assign @file
    end

    should "not break content_type" do
      assert_equal @attachment.instance_read(:content_type), 'text/plain'
    end

    should "not break file_name" do
      assert_equal @attachment.instance_read(:file_name), 'stringio.txt'
    end
  end
end
