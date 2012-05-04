module FilterDetail
  def deriveEditableAttributesForFilter(filter)
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

  def configureFilter(filter)
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
      end
    end
  end  
end
