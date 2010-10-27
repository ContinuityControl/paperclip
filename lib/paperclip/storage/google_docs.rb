module Paperclip
  module Storage
    module Google
   
      def self.extended base
        begin
          require 'gdata'
        rescue LoadError => e
          e.message << " (You may need to install the gdata gem)"
          raise e
        end

        base.instance_eval do
          @google_credentials = @options[:cred_proc]
          @google_credentials = @google_credentials.call(self) if @google_credentials.is_a?(Proc)
          @google_url = 'https://docs.google.com/feeds/documents/private/fulll'

          @client = GData::Client::DocList.new
          @client.authsub_token = @google_credentials
        end        

        Paperclip.interpolates(:original) do |attachment, style|
          attachment.instance_read(:file_name)
        end

        Paperclip.interpolates(:google) do |attachment, style|
          attachment.instance_read(:file_name)
        end

      end


      def exists?(style = default_style)
        original_filename
      end

      def to_file style = default_style
        #return @queued_for_write[style] if @queued_for_write[style]
        filename = original_filename
        extname  = File.extname(filename)
        basename = File.basename(filename, extname)
        file = Tempfile.new(basename, extname)
        file.write(path(style))
        file.rewind
        return file
      end

      def url
        instance_read(:file_name)
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          #begin
            if !@saved
              log("saving #{path(style)}")
              
              result = @client.post_file(@google_url, file.path, instance_read(:content_type))
              doc = ::Nokogiri::XML(result.body)
              @google_path = doc.css('link[rel=alternate]').first['href']
              instance_write(:file_name, @google_path)
              @_file_name = @google_path
              puts instance_read(:file_name)
              @saved = true
            end
          #rescue Exception => e
            # something
          #end
        end
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          begin
            @client.delete(path)
          rescue Exception => e
            # something else
          end
        end
      end
    end
  end
end
