class FileAttachment < ActiveRecord::Base
  belongs_to :project
  belongs_to :client
  belongs_to :ticket
  has_attached_file(:attachment_file, {:url => '/:class/:sha', :path => ':rails_root/:q})
  validates_attachment_presence :attachment_file

  def put_raw_object(content, type)
    size = content.length.to_s

    header = "#{type} #{size}\0" # type(space)size(null byte)
    store = header + content

    sha1 = Digest::SHA1.hexdigest(store)
    path = @git_dir + '/' + sha1[0...2] + '/' + sha1[2..40]

    if !File.exists?(path)
      content = Zlib::Deflate.deflate(store)

      FileUtils.mkdir_p(@directory+'/'+sha1[0...2])
      File.open(path, 'w') do |f|
        f.write content
      end
    end
    return sha1
  end

end
