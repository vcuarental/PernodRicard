/*
 * MultiselectController synchronizes the values of the hidden elements to the
 * SelectOption lists.
 * Copied from Pat Patterson 
 * source: https://developer.salesforce.com/blogs/developer-relations/2012/06/a-multiselect-picklist-visualforce-component.html
 */
public with sharing class EUR_CRM_MultiselectController {
    // SelectOption lists for public consumption
    public SelectOption[] leftOptionsX { get; set; }
    public SelectOption[] rightOptionsX { get; set; }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOptionsX, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(rightOptionsX, value);
        }
    }
}