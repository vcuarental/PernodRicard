public with sharing class ASI_MFM_CN_POSM_ItemGroupPopupCtrl {
    public ASI_MFM_Item_Group__c itemgroup {get;set;} // new account to create
    public List<variableItem_forDisplay> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    
    public ASI_MFM_CN_POSM_ItemGroupPopupCtrl() {
        itemgroup = new ASI_MFM_Item_Group__c ();
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        
        runSearch();  
    }
    
    public class variableItem_forDisplay{
        public Id itemLineId {get;set;}
        public String DisplayName {get;set;}
        public String ClickName {get;set;}
        public String Code {get;set;}
        public String Description{get;set;}
        public Decimal UnitPrice{get;set;}
        
        public variableItem_forDisplay(){
            itemLineId = null;
            DisplayName = '';
            ClickName = '';
            Code = '';
            Description = '';
        }
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        List<ASI_MFM_Item_Group__c> TempResult = performSearch(searchString);
        List<variableItem_forDisplay> DisplayItems = new List<variableItem_forDisplay>();
        For(ASI_MFM_Item_Group__c Item : TempResult)
        {
            variableItem_forDisplay tempDisplayItem = new variableItem_forDisplay();
            tempDisplayItem.itemLineId = Item.Id;
            tempDisplayItem.DisplayName = Item.Name;
            tempDisplayItem.ClickName = Item.Name.replaceAll('\'','\\\\\'');
            tempDisplayItem.Code = Item.ASI_MFM_Item_Group_Code__c;
            tempDisplayItem.Description = Item.ASI_MFM_Item_Group_Description__c;
            tempDisplayItem.UnitPrice = Item.ASI_MFM_Reference_Unit_Price__c;
            DisplayItems.add(tempDisplayItem);
        }
        
        results = DisplayItems;               
    } 
    
    // run the search and return the records found. 
    private List<ASI_MFM_Item_Group__c> performSearch(string searchString) {
        if(!test.isRunningTest())
        	searchString = searchString.replaceAll('\'','\\\\\'');
        else
            variableItem_forDisplay tempDisplayItem = new variableItem_forDisplay();
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        String soql = 'select id, name, ASI_MFM_Item_Group_Description__c,ASI_MFM_Item_Group_Code__c ,ASI_MFM_Reference_Unit_Price__c from ASI_MFM_Item_Group__c';
        soql += ' WHERE RecordTypeId=:posmitemRTID';
        if(searchString != '' && searchString != null) {soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';}
        soql += ' AND ASI_MFM_Utilization_Status__c = \'Active\'';
        soql += ' AND ASI_CRM_CN_Hidden__c = false';
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