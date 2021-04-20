public with sharing class ASI_MFM_CN_SearchPO_PopupCtrl {
  public ASI_MFM_PO__c po {get;set;} // new account to create
  public List<ASI_MFM_PO__c> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  
  public ASI_MFM_CN_SearchPO_PopupCtrl() {
    po = new ASI_MFM_PO__c();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    runSearch();  
  }
   
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
  
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
  
  // run the search and return the records found. 
  private List<ASI_MFM_PO__c> performSearch(string searchString) {
      //Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
      String soql = 'select id, name from ASI_MFM_PO__c';
      soql += ' WHERE RecordType.developerName LIKE \'%CN%\'';
      if(searchString != '' && searchString != null) {soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';}
      soql = soql + ' limit 25';
      System.debug(soql);
      return database.query(soql);
  }
  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
    
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
}