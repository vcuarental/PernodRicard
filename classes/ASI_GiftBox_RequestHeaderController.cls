public class ASI_GiftBox_RequestHeaderController {
    ApexPages.StandardController controller;
    
    public Boolean getEditForSales {get; set;}
    public Boolean getReadForSales {get; set;}
    public Boolean isHRUser {get; set;}
    public List<ASI_GiftBox_Inventory_Detail__c> searchItemDetails {get;set;}
    public List<ASI_GiftBox_Inventory_Master__c> searchItem {get;set;}
    public String selectedGiftBoxMaster {get; set;}
    public Id headerId;
	public ASI_GiftBox_Request_Header__c request;
	private String recordTypeName;   
    
    public ASI_GiftBox_RequestHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        headerId= (Id)stdcontroller.getId();
        request=[select RecordTypeId, RecordType.DeveloperName from ASI_GiftBox_Request_Header__c where Id=:headerId limit 1]; 
        
		//Wilken 20160321 - VN CRM - Add Record Type Name to identify GB or POSM Request
		if (request != null)
			recordTypeName = request.RecordType.DeveloperName;
		
        System.debug('Request Header Record Type Name: ' + recordTypeName + ' Header ID: ' + headerId);
		
//Check if current user is in FA public user group to display JDE interface fields and VAT fields
        isHRUser = checkIsInHRUserGroup(UserInfo.getUserId());
        
    }
    
    public boolean getEditForSales()
    {
      RecordType rt=  [select Id from RecordType where developerName = 'ASI_GiftBox_VN_Request_Read_Only' limit 1];
      if(request.RecordTypeId!=rt.Id && !isHRUser)
          return true;
      else
          return false;
    }
    
    public boolean getReadForSales ()
    {
        RecordType rt=  [select Id from RecordType where developerName = 'ASI_GiftBox_VN_Request_Read_Only' limit 1];
      if(request.RecordTypeId==rt.Id && !isHRUser)
          return true;
      else
          return false;
    }
    
    
    
    private static Boolean checkIsInHRUserGroup(Id userId){        
        Group userGroup = [Select Id From Group Where DeveloperName = 'ASI_Gift_Box_HR_Review_User'];
        List<GroupMember> hrGroupMember = [Select UserOrGroupId From GroupMember Where GroupId = :userGroup.Id and UserOrGroupId=:userId ];
        Boolean result = false;
        
        if(hrGroupMember.size()>0 ){
            result = true;
        }
        
        return result;
    }
    
    public PageReference runSearch() {
        System.debug('enter runSearch()');
        String itemName = Apexpages.currentPage().getParameters().get('itemName');
        System.debug('itemName='+itemName);

        try {
            searchItem = Database.query('select Id,ASI_GiftBox_Item_Brand__c,Name from ASI_GiftBox_Item__c where Name = \''+itemName+'\'');
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'sql 1'));
        }    
        //System.debug('searchItem.size()='+searchItem.size());     
        
        if(searchItem !=null && searchItem.size()>0){
            try {
                searchItemDetails = Database.query('select ASI_GiftBox_Item_Ava_Quantity__c,ASI_GiftBox_Item_Warehouse__c from Gift_Box_Item_Detail__c where ASI_GiftBox_Item_Id__c = \''+searchItem[0].Id +'\'');
            } 
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'sql 2'));
            } 
        }
        return null;
    }
    
    public void checkInventory(){
        System.debug('checkInventory selectedGiftBoxMaster: ' + selectedGiftBoxMaster);
        searchItemDetails = [select ASI_GiftBox_Item_Available_Quantity__c,ASI_GiftBox_Item_Warehouse__c from ASI_GiftBox_Inventory_Detail__c where ASI_GiftBox_Item_Id__c = :selectedGiftBoxMaster];
    }
    
    public List<selectOption> getGiftBoxList() {
List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
		
        for (ASI_GiftBox_Inventory_Master__c master : [SELECT Name, ASI_CRM_Category__c  FROM ASI_GiftBox_Inventory_Master__c where recordType.DeveloperName = 'ASI_GiftBox_VN_GiftBox_Master' order by Name]) {
			if (recordTypeName != null && recordTypeName.contains('ASI_GiftBox_VN') && master.ASI_CRM_Category__c == null){
				options.add(new selectOption(master.Id, master.Name)); //for VN Gift Box Master records found - add them to the picklist options
			}
			else if (recordTypeName != null && recordTypeName.contains('ASI_CRM_POSM_VN') && master.ASI_CRM_Category__c != null){
				options.add(new selectOption(master.Id, master.Name)); //for VN POSM Master records found - add them to the picklist options
			}
        }
        return options; //return the picklist options
    }
}