class MainViewController < UIViewController
  extend FilterDetail

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
    @imageView.inputImage = UIImage.imageNamed("mountain.jpg")
    @imageView.frame = [[10, 54], [300, 158]]
    self.view.addSubview @imageView

    @tableView = UITableView.alloc.initWithFrame [[10, 220], [300, 240]], style: UITableViewStyleGrouped
    @tableView.delegate = self
    @tableView.dataSource = self
    self.view.addSubview @tableView
    
    @navBar = UINavigationBar.alloc.initWithFrame [[0,0], [320, 44]]
    item = UINavigationItem.alloc.init
    item.title = "Filtered Image"
    item.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Clear", style:UIBarButtonItemStylePlain, target:self, action: :"clearFilters:")
    @navBar.setItems([item], animated: false)
    self.view.addSubview @navBar
  end
  
  ## Actions
  
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
  
  ## Table View Datasource / Delegate
  
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
      Dispatch::Queue.concurrent.async do
        self.removeFilter(@availableFilters[indexPath.row])
      end
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryNone
    else
      Dispatch::Queue.concurrent.async do
        self.addFilter(@availableFilters[indexPath.row])
      end
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
    end
  end

end