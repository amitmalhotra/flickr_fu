class Flickr::Photosets < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end
  
  # Get the authorized user's contact list.
  # 
  def get_list(options={})
    rsp = @flickr.send_request('flickr.photosets.getList', options)
    collect_photosets(rsp)
  end
    
  protected  
    def collect_photosets(rsp)
      photosets = []
      return photosets unless rsp
      if rsp.photosets.photoset
        rsp.photosets.photoset.each do |photoset|
          attributes = create_attributes(photoset)
          photosets << Photoset.new(@flickr, attributes)
        end
      end
      return photosets
    end
  
    def create_attributes(photoset)

      {
        :id => photoset[:id], 
        :num_photos => photoset[:photos],
        :title => photoset.title,
        :description => photoset.description,
        :primary => photoset[:primary],
        :farm => photoset[:farm],
        :server => photoset[:server],
        :secret => photoset[:secret]        
       }
    end
  
end
