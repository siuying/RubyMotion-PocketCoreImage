class MainViewController < UIViewController
  FILTER_CELL_ID = "filterCell"
  attr_accessor :filtersToApply

  def loadView
    @filtersToApply = []
    @availableFilters = ["CIColorInvert", "CIColorControls", "CIGammaAdjust", "CIHueAdjust"]

    @view = UIView.alloc.init
    @view.backgroundColor = UIColor.whiteColor
    self.view = @view
    
    @imageView = FilteredImageView.alloc.init
    @imageView.datasource = self
    @imageView.inputImage = UIImage.imageNamed("LakeDonPedro2.jpg")
    @imageView.frame = [[10, 54], [300, 158]]
    self.view.addSubview @imageView

    @tableView = UITableView.alloc.initWithFrame [[10, 220], [300, 240]], style: UITableViewStyleGrouped
    @tableView.delegate = self
    @tableView.dataSource = self
    self.view.addSubview @tableView
  end
  
  ## 
  
  def clearFilters(sender)
    @filtersToApply.clear
    @imageView.reloadData
    @tableView.reloadData
  end
  
  def addFilter(name)
    newFilter = CIFilter.filterWithName(name)
    return unless newFilter

    newFilter.setDefaults
    MainViewController.configureFilter(newFilter)
    @filtersToApply << newFilter
    @imageView.reloadData
  end
  
  def removeFilter(name)
    filterToRemove = @filtersToApply.find(){|filter| filter.name == name }
    @filtersToApply.delete(filterToRemove)
    @imageView.reloadData
  end
  
  ## Table View
  
  def numberOfSectionsInTableView(tableView)
    1
  end
  
  def tableView(tableView, numberOfRowsInSection: section)
    @availableFilters.size
  end
  
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(FILTER_CELL_ID)
    unless cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: FILTER_CELL_ID)
    end
        
    cell.textLabel.text = @availableFilters[indexPath.row]
    cell.accessoryType  = UITableViewCellAccessoryNone
    
    @filtersToApply.each do |filter|
      if filter.name == @availableFilters[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryCheckmark      
      end 
    end
    
    cell
  end
  
  def tableView(tableView, titleForHeaderInSection:section)
    "Select a Filter"
  end
  
  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    selectedCell = tableView.cellForRowAtIndexPath(indexPath)
    filterIsCurrentlyApplied = false
    
    @filtersToApply.each do |filter|
      if filter.name == selectedCell.textLabel.text
        filterIsCurrentlyApplied = true
      end
    end
    if filterIsCurrentlyApplied
      self.removeFilter(@availableFilters[indexPath.row])
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryNone
    else
      self.addFilter(@availableFilters[indexPath.row])
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
    end
  end
  
  ##

  def self.deriveEditableAttributesForFilter(filter)
    editableAttributes = {}
    filterAttributes = filter.attributes
    
    filterAttributes.each do |key, value|
      case key
      when "CIAttributeFilterCategories", "CIAttributeFilterDisplayName", "inputImage", "outputImage"
      else
        if value.is_a?(NSDictionary)
          editableAttributes[key] = value
        end
      end
    end
    
    editableAttributes
  end

  def self.configureFilter(filter)
    editableAttributes = self.deriveEditableAttributesForFilter(filter)
    editableAttributes.each do |key, attributeDictionary|
      if attributeDictionary[KCIAttributeClass] == "NSNumber"
        case attributeDictionary[KCIAttributeType]
        when KCIAttributeTypeBoolean
          randomValue = rand(2)
          filter[key] = randomValue
        when KCIAttributeTypeScalar, KCIAttributeTypeAngle, KCIAttributeTypeDistance
          maximumValue = attributeDictionary[KCIAttributeSliderMax]
          minimumValue = attributeDictionary[KCIAttributeSliderMin]
          # Opps: Sad that this doesnt work on MacRuby
          # randomValue = rand(minimumValue..maximumValue)
          randomValue = rand() * (maximumValue - minimumValue) + minimumValue
          filter[key] = randomValue
        else
          maximumValue = attributeDictionary[KCIAttributeMax]
          minimumValue = attributeDictionary[KCIAttributeMin]
          # Opps: Sad that this doesnt work on MacRuby
          # randomValue = rand(minimumValue..maximumValue)
          randomValue = rand(maximumValue-minimumValue) + minimumValue
          filter[key] = randomValue
        end
      else
        puts "attributeDictionary[KCIAttributeClass]: #{attributeDictionary[KCIAttributeClass]}"
      end
    end
    
    puts "config fitler: #{filter}, #{editableAttributes}"
  end
end