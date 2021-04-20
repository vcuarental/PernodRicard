/*********************************************************************************
 * Name: ASI_CRM_JP_AdvancedSearchController
 * Description: Controller class for Advanced Search Page(Javascript).
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/02/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_AdvancedSearchController {

	//Field Map
	private final static Map<String, Schema.SObjectField> ADVANCED_SEARCH_FIELD_MAP    = Schema.SObjectType.ASI_CRM_JP_Advanced_Search__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP           = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();

    //COT User permission set
    private final static String COT_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Supply Chain Add-On';
    
    //Duty Free User permission set
    private final static String DUTY_FREE_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Duty Free User';
    
	//Parameter from VF Page Name
    private final static String DEFAULT_CUSTOMER_NAME  = 'defaultCustomerName';
	private final static String CUSTOMER_NAME          = 'customerName';
	private final static String TEMPLATE_ID            = 'templateId';

	//Sales Order Modification Page URL
	private final static String SALES_ORDER_PAGE_URL = '/apex/ASI_CRM_JP_ModifySO_Page';
    private final static String REDIRECT_PAGE_URL    = '/apex/ASI_CRM_JP_SORedirect_Page';

	//Advanced Search Records
	private Map<Id, ASI_CRM_JP_Advanced_Search__c> advancedSearchMap {get; set;}
	
    //Variable for VF Page
    public Boolean isDutyFree {get; set;}
    public Boolean isCOTUser  {get; set;}
    
    public String defaultCustomerName {get; set;}
    
	//JSON String for VF Page
	public String advancedSearchListJson{get {return toJsonString(advancedSearchMap.values());}}

	//Init function
	public ASI_CRM_JP_AdvancedSearchController() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
        if(params.containsKey(DEFAULT_CUSTOMER_NAME)) {
			defaultCustomerName = params.get(DEFAULT_CUSTOMER_NAME);
			advancedSearchMap = new Map<Id, ASI_CRM_JP_Advanced_Search__c>(retrieveAdvancedSearch(defaultCustomerName));
        } else {
            defaultCustomerName = '';
            advancedSearchMap = new Map<Id, ASI_CRM_JP_Advanced_Search__c>();
        }
        
        checkUserType();
	}

    private void checkUserType() {
        List<PermissionSetAssignment> permissionSetAssignment = [SELECT AssigneeId 
                                                                 FROM PermissionSetAssignment
                                                                 WHERE AssigneeId = :UserInfo.getUserId()
                                                                 AND PermissionSet.Label = :COT_USER_PERMISSION_SET_LABEL];
        if(permissionSetAssignment.size() > 0) {
    		isCOTUser = true;
        } else {
    		isCOTUser = false;
        }
        
        List<PermissionSetAssignment> dutyFreePermissionSetAssignment = [SELECT AssigneeId
                                                                         FROM PermissionSetAssignment
                                                                         WHERE AssigneeId = :UserInfo.getUserId()
                                                                         AND PermissionSet.Label = :DUTY_FREE_USER_PERMISSION_SET_LABEL];
    	
        if(dutyFreePermissionSetAssignment.size() > 0) {
            isDutyFree = true;
        } else {
            isDutyFree = false;
        }
    }
    
	/***************
	View Action Handler
	***************/
	public void search() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		String customerName        = params.get(CUSTOMER_NAME);

		if(String.isNotBlank(customerName)) {
			advancedSearchMap = new Map<Id, ASI_CRM_JP_Advanced_Search__c>(retrieveAdvancedSearch(customerName));
		}
	}

	public PageReference createNewSalesOrder() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		String customerName        = params.get(CUSTOMER_NAME);
        
        ASI_CRM_AccountsAdditionalField__c customer = retrieveCustomer(customerName);
        
        String recordType;
        if(isCOTUser) {
            recordType = 'ASI_CRM_JP_Normal_SO';
        } else if(isDutyFree) {
            recordType = 'ASI_CRM_JP_Duty_Free_SO';
        }
        
        PageReference pageRef;
        if(customer == null) {
            pageRef = new PageReference(SALES_ORDER_PAGE_URL + '?recordType=' + recordType);
        } else {
            pageRef = new PageReference(SALES_ORDER_PAGE_URL + '?recordType=' + recordType + '&ASI_CRM_Ship_To__c=' + customer.Id);
        }
		
	    pageRef.setRedirect(true);
	    return pageRef;
	}

	public PageReference selectSalesOrderTemplate() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		String templateId          = params.get(TEMPLATE_ID);
		
        String soldToId = advancedSearchMap.get(templateId).ASI_Sold_To_Customer__c;
        
        String recordType;
        if(isDutyFree) {
            recordType = 'ASI_CRM_JP_Duty_Free_SO';
        } else {
            recordType = 'ASI_CRM_JP_Normal_SO';
        }
        
		if(String.isNotBlank(templateId)) {
			PageReference pageRef = new PageReference(REDIRECT_PAGE_URL + '?templateId=' + templateId + '&RecordType=' + recordType + '&ASI_CRM_Sold_To__c=' + soldToId);
		    pageRef.setRedirect(true);
		    return pageRef;
		}

		return null;
	}

	/***************
	Data Retrievement Function
	***************/
	private List<ASI_CRM_JP_Advanced_Search__c> retrieveAdvancedSearch(String customerName) {
		String query = 'SELECT Id, ASI_Ship_To_Customer__c, ASI_Sold_To_Customer__c, ASI_Sub_Wholesaler__c, ASI_Transaction_Date__c' +
		               ', RecordType.DeveloperName, ASI_Ship_To_Customer__r.Name, ASI_Ship_To_Customer__r.ASI_CRM_CN_Address__c' + 
		               ', ASI_Sold_To_Customer__r.Name, ASI_Sub_Wholesaler__r.Name ' + 
		               'FROM ASI_CRM_JP_Advanced_Search__c ' + 
		               'WHERE ASI_Ship_To_Customer__r.Name LIKE \'%' + customerName + '%\' ' + 
		               'AND ASI_Ship_To_Customer__r.ASI_CRM_CN_Inactive_Flag__c = false ' + 
		               'AND ASI_Sold_To_Customer__r.ASI_CRM_CN_Inactive_Flag__c = false ' + 
		               'LIMIT 1000';
		return (List<ASI_CRM_JP_Advanced_Search__c>) Database.query(query);
 	}

    private ASI_CRM_AccountsAdditionalField__c retrieveCustomer(String customerName) {
		String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_AccountsAdditionalField__c ' + 
		               'Where Name = :customerName';
		List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
		return customerList.size() > 0 ? customerList.get(0) : null;
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

	private String toJsonString(Object obj) {
	    return System.JSON.serialize(obj);
	}

	private List<Object> fromJsonString(String jsonString, System.Type apexType) {
		if(String.isBlank(jsonString)) {
			return null;
	    }
	    return (List<Object>) System.JSON.deserialize(jsonString, apexType);
	}
}