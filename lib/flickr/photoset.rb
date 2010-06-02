class Flickr::Photosets::Photoset
  attr_accessor :id,:num_photos,:title,:description,:primary,:secret,:server,:farm
  attr_accessor :comments # comment attributes

  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
  
  def get_photos(options={})
    options = options.merge(:photoset_id=>id)
    rsp = @flickr.send_request('flickr.photosets.getPhotos', options)
    collect_photos(rsp)
  end

  def add_comment(message)
    @flickr.send_request('flickr.photosets.comments.addComment',{:photoset_id => self.id, :comment_text => message}, :post)
    true
  end
  
  def comments 
    @comments ||= begin
      if @comment_count == 0
        self.comments = []
      else
        rsp = @flickr.send_request('flickr.photosets.comments.getList', :photoset_id => self.id)
      
        self.comments = []
      
        rsp.comments.comment.each do |comment|
          self.comments << Flickr::Photos::Comment.new(:id => comment[:id],
            :comment => comment.to_s,
            :author => comment[:author],
            :author_name => comment[:authorname],
            :permalink => comment[:permalink],
            :created_at => (Time.at(comment[:datecreate].to_i) rescue nil))
        end
      end

      self.comments
    end
  end

  
  protected
    def collect_photos(rsp)
      photos = []
      return photos unless rsp
      if rsp.photoset.photo
        rsp.photoset.photo.each do |photo|
          attributes = create_attributes(photo)
          photos << Flickr::Photos::Photo.new(@flickr,attributes)
        end
      end
      return photos
    end
    
    def create_attributes(photo)
      {:id => photo[:id],
       :secret => photo[:secret], 
       :server => photo[:server], 
       :title => photo[:title]}
    end
end
