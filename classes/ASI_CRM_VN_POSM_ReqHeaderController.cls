/*********************************************************************************
     * Name: ASI_CRM_VN_GiftBox_ReqHeaderController 
     * Description: Controller for displaying GiftBox list
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    -------------------------------------------------------
     * 19/10/2015       Laputa: Neha             Created
     * 21/11/2018       Laputa: Andy Zhang       Change label 'Lum Sum' to 'CS' 
     * 18/12/2018		Laputa: Calvin Chiu		 Added isContracted flag to hide Contract Available Balance for non-contract
*********************************************************************************/
public class ASI_CRM_VN_POSM_ReqHeaderController {
    
    private class ShowFieldWrapper {
    	private String fieldAPIName {get; set;}
        private Boolean isRequired  {get; set;}
        private Integer width       {get; set;}
        private String readMode     {get; set;}
        
        private ShowFieldWrapper(String fieldAPIName, Boolean isRequired, Integer width, String readMode) {
        	this.fieldAPIName = fieldAPIName;
            this.isRequired   = isRequired;
            this.width        = width;
            this.readMode     = readMode;
        }
        
        private String combineStr() {
        	String str = fieldAPIName;
            
            if(isRequired != null) {
                str += '&req=';
            	str += isRequired ? 'T' : 'F';
            }
            
            if(width != null) {
            	str += '&width=';
                str += String.valueOf(width) + 'px';
            }
            
            if(readMode != null) {
            	str += '&read=';
                str += readMode;
            }
            
            return str;
        }
    }
    
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static String POSM_REQUEST_ITEM = 'ASI_CRM_VN_POSM_Request_Item';
    private final static String FOC_REQUEST_ITEM  = 'ASI_CRM_VN_FOC_Request_Item';
    private final static String DISPLAY_LISTING_REQUEST_ITEM = 'ASI_CRM_VN_Display_Listing_Request_Item';
    
    ApexPages.StandardController controller;
    public Boolean isHRUser {get; set;}
    public List<ASI_GiftBox_Inventory_Detail__c> searchItemDetails {get;set;}
    public List<ASI_GiftBox_Inventory_Master__c> searchItem {get;set;}
    public String selectedGiftBoxMaster {get; set;}
    public Id headerId;
	public ASI_GiftBox_Request_Header__c request;
	private String recordTypeName;
    public Map<String, Decimal> contractAvailableBalanceMap {get; set;}
    public Map<String, Decimal> contractAvailableBalanceVNDMap {get; set;}
    public String childRecordType {get; set;}
    public String showFieldStr {get; set;}
    public List<ShowFieldWrapper> showFieldWrapperList = new List<ShowFieldWrapper>();
    public Boolean isContracted {get; set;}
    
    public ASI_CRM_VN_POSM_ReqHeaderController(ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        headerId = (Id) Apexpages.currentPage().getParameters().get('id');
        request = [select ASI_CRM_VN_Contract__c, RecordTypeId, RecordType.DeveloperName from ASI_GiftBox_Request_Header__c where Id=:headerId limit 1]; 
		
		isContracted = request.ASI_CRM_VN_Contract__c != null? true: false;
		
		//Wilken 20160321 - VN CRM - Add Record Type Name to identify GB or POSM Request
		if (request != null)
			recordTypeName = request.RecordType.DeveloperName;
		
        contractAvailableBalanceMap = new Map<String, Decimal>();
        contractAvailableBalanceVNDMap = new Map<String, Decimal>();
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = retrieveContractExpenditureList(request.ASI_CRM_VN_Contract__c);
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            if(contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c == 'USD') {
                if(contractExpenditure.ASI_CRM_VN_Item__c == 'Lump Sum')
                {
                    contractExpenditure.ASI_CRM_VN_Item__c = 'CS';
                }
            	contractAvailableBalanceMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure.ASI_CRM_Balance_Amount__c);
            	contractAvailableBalanceVNDMap.put(contractExpenditure.ASI_CRM_VN_Item__c, 
                                                   contractExpenditure.ASI_CRM_Balance_Amount__c * 
                                                   contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c);
            } else {
                if(contractExpenditure.ASI_CRM_VN_Item__c == 'Lump Sum')
                {
                    contractExpenditure.ASI_CRM_VN_Item__c = 'CS';
                }
                contractAvailableBalanceVNDMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure.ASI_CRM_Balance_Amount__c);
            	contractAvailableBalanceMap.put(contractExpenditure.ASI_CRM_VN_Item__c,
                                                contractExpenditure.ASI_CRM_Balance_Amount__c *
                                                contractExpenditure.ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c);
            }
        }
        System.debug(contractAvailableBalanceMap.keySet());
        System.debug('Request Header Record Type Name: ' + recordTypeName + ' Header ID: ' + headerId);
		
		//Check if current user is in FA public user group to display JDE interface fields and VAT fields
        isHRUser = checkIsInHRUserGroup(UserInfo.getUserId());
        
        if(request.RecordType.DeveloperName == 'ASI_CRM_POSM_VN_Request' || 
           request.RecordType.DeveloperName == 'ASI_CRM_POSM_VN_Request_Read_Only') {
        	childRecordType = POSM_REQUEST_ITEM;
            
            if(getEditForSales()) {
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item__c', true, 160, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Item_Limit__c', null, 60, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Item_Delivered__c', null, 60, 'a'));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Item_Balance__c', null, 40, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Purpose__c', true, 120, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Other_Purpose__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Quantity__c', true, 100, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Amount__c', false, 100, 'a'));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Delivery_Instruction__c', null, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Remark__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Category__c', false, 80, 'a'));
            }
             
        } else if(request.RecordType.DeveloperName == 'ASI_CRM_VN_FOC_Request' || 
                  request.RecordType.DeveloperName == 'ASI_CRM_VN_FOC_Request_Read_Only') {
        	childRecordType = FOC_REQUEST_ITEM;
            
            if(getEditForSales()) {
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item__c', true, 160, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Purpose__c', true, 120, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Other_Purpose__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Quantity__c', true, 100, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Amount__c', false, 100, 'a'));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Delivery_Instruction__c', null, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Remark__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Category__c', false, 80, 'a'));
            }
            
        } else {
            childRecordType = DISPLAY_LISTING_REQUEST_ITEM;
            
        	if(getEditForSales()) {
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item__c', true, 160, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Other_Purpose__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Quantity__c', true, 100, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Amount__c', false, 100, 'a'));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Delivery_Instruction__c', null, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Remark__c', false, 200, null));
            	showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Category__c', false, 80, 'a'));
            }
        }
        
       	if(getReadForSales()) {
        	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item__c', true, 160, 'a'));
           	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Purpose__c', true, 120, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Other_Purpose__c', false, 200, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Quantity__c', true, 100, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Amount__c', false, 100, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Delivery_Instruction__c', false, 200, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Remark__c', false, 200, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Category__c', false, 80, 'a'));
      	}
            
        if(isHRUser) {
        	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item__c', true, 80, null));
           	showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Purpose__c', true, 120, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Other_Purpose__c', false, 200, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Quantity__c', true, 100, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Amount__c', false, 100, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Delivery_Instruction__c', false, 200, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Remark__c', false, 200, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_CRM_Category__c', false, 80, 'a'));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Warehouse__c', true, 80, null));
            showFieldWrapperList.add(new ShowFieldWrapper('ASI_GiftBox_Request_Item_Date__c', null, 80, null));
    	}
        
        showFieldStr = '';
        for(ShowFieldWrapper showFieldWrap : showFieldWrapperList) {
        	showFieldStr += showFieldWrap.combineStr() + ',';
        }
        showFieldStr = showFieldStr.removeEnd(',');
    }
    
    public boolean getEditForSales()
    {
      RecordType rt=  [select Id from RecordType where developerName = 'ASI_CRM_POSM_VN_Request_Read_Only' limit 1];
      if(request.RecordTypeId!=rt.Id && !isHRUser)
          return true;
      else
          return false;
    }
    
    public boolean getReadForSales ()
    {
        RecordType rt=  [select Id from RecordType where developerName = 'ASI_CRM_POSM_VN_Request_Read_Only' limit 1];
      if(request.RecordTypeId==rt.Id && !isHRUser)
          return true;
      else
          return false;
    }
    
    
    
    private static Boolean checkIsInHRUserGroup(Id userId){        
        Group userGroup = [Select Id From Group Where DeveloperName = 'ASI_CRM_VN_HR_Manager'];
        List<GroupMember> hrGroupMember = [Select UserOrGroupId From GroupMember Where GroupId = :userGroup.Id and UserOrGroupId=:userId ];
        Boolean result = false;
        
        if(hrGroupMember.size()>0 ){
            result = true;
        }
        
        return result;
    }
    
    public PageReference runSearch() {
        String itemName = Apexpages.currentPage().getParameters().get('itemName');

        try {
            searchItem = Database.query('select Id,ASI_GiftBox_Item_Brand__c,Name from ASI_GiftBox_Item__c where Name = \''+itemName+'\'');
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'sql 1'));
        }    
        
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
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c ' + 
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'Where ASI_CRM_VN_Contract__c = :contractId';
        
    	return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
  	}
    
    /***************
  	Tools Function
  	***************/
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      	String queryField = '';
      	for(String fields : fieldMap.keySet()) {
       		queryField += fields + ',';
   		}
    	return queryField.subString(0, queryField.length() - 1);
    }
}