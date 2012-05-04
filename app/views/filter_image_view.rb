class FilteredImageView < UIView
  attr_accessor :inputImage, :datasource

  def reloadData
    return unless @inputImage
    
    Dispatch::Queue.concurrent.async do
      @filteredImage = CIImage.alloc.initWithCGImage(@inputImage.CGImage, options:nil)
      filters = self.datasource.filtersToApply
      if filters
        filters.each do |filter|
          filter.setValue(@filteredImage, forKey: "inputImage")
          begin
            @filteredImage = filter.outputImage
          rescue StandardError => e
            puts "Error apply filter: #{@filteredImage}"
          end
        end
      end

      Dispatch::Queue.main.sync do
        self.setNeedsDisplay      
      end
    end
  end
  
  def drawRect(rect)
    super(rect)
    return unless @filteredImage
    
    innerBounds = [[5, 5], [self.bounds.size.width - 10, self.bounds.size.height - 10]]
    UIImage.imageWithCIImage(@filteredImage).drawInRect(innerBounds)
  end
  
  def inputImage=(inputImage)
    @inputImage = inputImage
    self.reloadData
  end
end