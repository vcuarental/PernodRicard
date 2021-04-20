/*********************************************************************************
 * Name: ASI_CRM_JP_SOReview_Controller
 * Description: Controller class for JP Sales Order Review Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/02/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOReview_Controller {

	//Inner class for storing the so customer credit limit
	private class CustomerSOWrapper {
		private ASI_CRM_AccountsAdditionalField__c customer {get; set;}
		private List<ASI_CRM_JP_Sales_Order__c> soList      {get; set;}
		private Decimal soTotalPrice                        {get; set;}
		private Boolean isOverLimit                         {get; set;}

		private CustomerSOWrapper(ASI_CRM_AccountsAdditionalField__c customer) {
			this.customer = customer;
			isOverLimit   = false;
			soTotalPrice  = 0;
            soList        = new List<ASI_CRM_JP_Sales_Order__c>();
		}

		private void addSO(ASI_CRM_JP_Sales_Order__c so) {
			soList.add(so);

			for(ASI_CRM_JP_Sales_Order_Item__c soItem : so.Sales_Order_Items__r) {
            	if(soItem.ASI_CRM_Status__c != '980-Cancelled') {
					soTotalPrice += (soItem.ASI_CRM_Quantity__c == null ? 0 : soItem.ASI_CRM_Quantity__c)
                                  * (soItem.ASI_CRM_Unit_Price__c == null ? 0 : soItem.ASI_CRM_Unit_Price__c);
                }
			}
            if(so.RecordType.DeveloperName == 'ASI_CRM_JP_Normal_SO_Locked' ||
               (so.RecordType.DeveloperName == 'ASI_CRM_JP_Duty_Free_SO_Locked' && so.ASI_CRM_Order_Type__c == 'Normal SO')) {
                if(String.isNotBlank(customer.ASI_CRM_JP_Customer_Parent__c)) {
                    if((customer.ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Credit_Balance__c == null ? 
                        0 : customer.ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Credit_Balance__c) - soTotalPrice < 0) {
                        isOverLimit = true;
                    }
                } else if((customer.ASI_CRM_JP_Credit_Balance__c == null ? 0 : customer.ASI_CRM_JP_Credit_Balance__c) - soTotalPrice < 0) {
					isOverLimit = true;
				}
            }
		}
        
        private Map<String, Boolean> genSOOverLimitMap() {
        	Map<String, Boolean> soOverLimit = new Map<String, Boolean>();
            for(ASI_CRM_JP_Sales_Order__c so : soList) {
                soOverLimit.put(so.Id, isOverLimit);
            }
            return soOverLimit;
        }
 	}

	//Inner class for storing the so item availability
	private class ItemSOWrapper {
		private ASI_CRM_JP_Item_Availability__c itemAvailability {get; set;}
		private List<ASI_CRM_JP_Sales_Order_Item__c> soItemList  {get; set;}
		private Decimal soItemTotalQuantity                      {get; set;}
		private Boolean isOverLimit                              {get; set;}

		private ItemSOWrapper(ASI_CRM_JP_Item_Availability__c itemAvailability) {
			this.itemAvailability = itemAvailability;
			isOverLimit           = false;
			soItemTotalQuantity   = 0;
            soItemList            = new List<ASI_CRM_JP_Sales_Order_Item__c>();
		}

		private void addSOItem(ASI_CRM_JP_Sales_Order_Item__c soItem) {
            if(soItem.ASI_CRM_Status__c != '980-Cancelled') {
                soItemList.add(soItem);

                soItemTotalQuantity += soItem.ASI_CRM_Quantity__c == null ? 0 : soItem.ASI_CRM_Quantity__c;
                if((itemAvailability.ASI_Quantity_Availability__c == null ? 0 : itemAvailability.ASI_Quantity_Availability__c) - soItemTotalQuantity < 0) {
                    isOverLimit = true;
                }
            }
		}
        
        private Map<String, Boolean> genSOItemOverLimitMap() {
        	Map<String, Boolean> soItemOverLimitMap = new Map<String, Boolean>();
            for(ASI_CRM_JP_Sales_Order_Item__c soItem : soItemList) {
                soItemOverLimitMap.put(soItem.Id, isOverLimit);
            }
            return soItemOverLimitMap;
        }
	}

	//Inner class for storing the exception
	private class ExceptionWrapper {
		private Integer lineNumber            {get; set;}
		private String errorMessage           {get; set;}
		private List<String> fieldAPINameList {get; set;}

		private ExceptionWrapper(Integer lineNumber, String errorMessage) {
			this.lineNumber = lineNumber;
			this.errorMessage = errorMessage;
		}

		private ExceptionWrapper(Integer lineNumber, String errorMessage, List<String> fieldAPINameList) {
			this(lineNumber, errorMessage);
			this.fieldAPINameList = fieldAPINameList;
		}
	}

	//Field Map
	private final static Map<String, Schema.SObjectField> SALES_ORDER_FIELD_MAP        = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> SALES_ORDER_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_JP_Sales_Order_Item__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> ITEM_AVAILABILITY_FIELD_MAP  = Schema.SObjectType.ASI_CRM_JP_Item_Availability__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP           = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();

	//Object Prefix
	private final static String SALES_ORDER_OBJECT_PREFIX = ASI_CRM_JP_Sales_Order__c.sObjectType.getDescribe().getKeyPrefix();

	//SO Status
	private final static String SO_STATUS_REQUESTED   = 'Requested';
    private final static String SO_STATUS_APPROVED    = 'Approved';
    private final static String SO_STATUS_AC_VERIFIED = 'AC Verified';
    private final static String SO_STATUS_FINAL       = 'Final';
    private final static String SO_STATUS_REJECTED    = 'Rejected';

    //Payment Option
    private final static Set<String> APPROVED_STATUS_PAYMENT_OPTION = new Set<String> {
    	'COD',
        'Invoice'
    };
    private final static Set<String> AC_VERIFIED_STATUS_PAYMENT_OPTION = new Set<String> {
    	'Advanced Payment'
    };
    
	//Object API Name
	private final static String SALES_ORDER_OBJECT_NAME      = 'ASI_CRM_JP_Sales_Order__c';
	private final static String SALES_ORDER_ITEM_OBJECT_NAME = 'ASI_CRM_JP_Sales_Order_Item__c'; 

	//Parameter from VF Page Name
	private final static String SO_RECORD_TYPE              = 'soRecordType';
    private final static String SO_OWNER_NAME               = 'ownerName';
    private final static String SHIP_TO_NAME                = 'shipToName';
    private final static String SOLD_TO_NAME                = 'soldToName';
	private final static String WAREHOUSE_FILTER_VALUE      = 'warehouseFilterValue';
	private final static String REQUESTED_DATE_FILTER_VALUE = 'requestedDateFilterValue';
    private final static String IS_SHOW_WARNING_ONLY        = 'isShowWarningOnly';
	private final static String SO_TYPE_FILTER_VALUE        = 'soTypeFilterValue';
	private final static String CANCEL_SO_ITEM_LIST_JSON    = 'cancelSOItemListJson';
	private final static String CONFIRM_SO_LIST_JSON        = 'confirmSOListJson';
	private final static String REJECT_SO_LIST_JSON         = 'rejectSOListJson';
	private final static String SO_LIST_JSON                = 'soListJson';

	//SO Record
	private List<ASI_CRM_JP_Sales_Order__c> soList {get; set;}

	//SO Filter
	private String recordType            {get; set;}
    private String ownerName             {get; set;}
    private String shipToName            {get; set;}
    private String soldToName            {get; set;}
	private String warehouseLocation     {get; set;}
	private Date requestedDate           {get; set;}
	private String soType                {get; set;}

	//Field API & Id Map
  	private Map<String, Id> fieldIdMap {get; set;}
    
    //COT User permission set
    private final static String COT_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Supply Chain Add-On';
    
    //Duty Free User permission set
    private final static String DUTY_FREE_USER_PERMISSION_SET_LABEL = 'ASI CRM JP Duty Free User';

	//Picklist Value
    private Map<String, String> soTypeValueList          {get; set;}
    private Map<String, String> reasonCodeValueList      {get; set;}
    private Map<String, String> editControlCodeValueList {get; set;}
    private Map<String, String> uomValueList             {get; set;}
    private Map<String, String> freightCodeValueMap      {get; set;} 

  	//Variable for VF Page
    public Boolean isDutyFree                           {get; set;}
    public Boolean isCOTUser                            {get; set;}
  	public Boolean hasError                             {get; set;}
  	public List<ExceptionWrapper> exceptionList         {get; set;}
  	public Map<Integer, String> soFieldPrivilegeMap     {get; set;}
  	public Map<Integer, String> soItemFieldPrivilegeMap {get; set;}
    public Map<String, Boolean> soOverLimitMap          {get; set;}
    public Map<String, Boolean> soItemOverLimitMap      {get; set;}

	//JSON String for VF Page
  	public String soListJson                  {get {return toJsonString(soList);}}
  	public String exceptionListJson           {get {return toJsonString(exceptionList);}}
  	public String fieldIdMapJson              {get {return toJsonString(fieldIdMap);}}
	public String soTypeValueListJson         {get {return toJsonString(soTypeValueList);}}
    public String reasonCodeValueListJson     {get {return toJsonString(reasonCodeValueList);}}
    public String ediControlCodeValueListJson {get {return toJsonString(editControlCodeValueList);}}
    public String uomValueListJson            {get {return toJsonString(uomValueList);}}
    public String freightCodeValueMapJson     {get {return toJsonString(freightCodeValueMap);}}
	public String soFieldPrivilegeMapJson     {get {return toJsonString(soFieldPrivilegeMap);}}
	public String soItemFieldPrivilegeMapJson {get {return toJsonString(soItemFieldPrivilegeMap);}}
	public String soOverLimitMapJson          {get {return toJsonString(soOverLimitMap);}}
	public String soItemOverLimitMapJson      {get {return toJsonString(soItemOverLimitMap);}}

	public ASI_CRM_JP_SOReview_Controller() {
		checkUserType();
		soList     = retrieveSalesOrderList(recordType, ownerName, shipToName, soldToName, warehouseLocation, requestedDate, soType);
		fieldIdMap = retrieveFieldId();
		
		soTypeValueList          = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Order_Type__c.getDescribe());
        reasonCodeValueList      = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Reason_Code__c.getDescribe());
        editControlCodeValueList = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Business_Reason__c.getDescribe());
        freightCodeValueMap      = retrievePicklistValues(ASI_CRM_JP_Sales_Order__c.ASI_CRM_Freight_Code__c.getDescribe());
        uomValueList             = retrievePicklistValues(ASI_CRM_JP_Sales_Order_Item__c.ASI_CRM_UOM__c.getDescribe());

		soFieldPrivilegeMap     = retrieveFieldPrivilegeMap(SALES_ORDER_OBJECT_NAME);
		soItemFieldPrivilegeMap = retrieveFieldPrivilegeMap(SALES_ORDER_ITEM_OBJECT_NAME);
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
    	
        if(isCOTUser) {
			recordType = 'ASI_CRM_JP_Normal_SO_Locked';
        } else if(isDutyFree) {
			recordType = 'ASI_CRM_JP_Duty_Free_SO_Locked';
        }
    }
    
	/***************
	View Action Handler
	***************/
	public void searchSO() {
		Map<String, String> params   = ApexPages.currentPage().getParameters();
		recordType                   = params.get(SO_RECORD_TYPE);
        ownerName                    = params.get(SO_OWNER_NAME);
        shipToName                   = params.get(SHIP_TO_NAME);
        soldToName                   = params.get(SOLD_TO_NAME);
		warehouseLocation            = params.get(WAREHOUSE_FILTER_VALUE);
		soType                       = params.get(SO_TYPE_FILTER_VALUE);
		String requestedDateInString = params.get(REQUESTED_DATE_FILTER_VALUE);
        Boolean isShowWarningOnly    = Boolean.valueOf(params.get(IS_SHOW_WARNING_ONLY));

		if(String.isNotBlank(recordType) || 
           String.isNotBlank(ownerName) || 
           String.isNotBlank(shipToName) || 
           String.isNotBlank(soldToName) ||
           String.isNotBlank(warehouseLocation) || 
           String.isNotBlank(requestedDateInString) || 
           String.isNotBlank(soType)) {
			if(String.isNotBlank(requestedDateInString)) {
                try {
                    List<String> requestedDateStringList = requestedDateInString.split('/');
					requestedDate = Date.newInstance(Integer.valueOf(requestedDateStringList[0]), Integer.valueOf(requestedDateStringList[1]), Integer.valueOf(requestedDateStringList[2]));
                } catch(Exception e) {
                	requestedDate = null;
                }
			} else {
                requestedDate = null;
            }
		
			soList = retrieveSalesOrderList(recordType, ownerName, shipToName, soldToName, warehouseLocation, requestedDate, soType);
            if(isShowWarningOnly) {
            	calculateAllocation(soList);
                List<ASI_CRM_JP_Sales_Order__c> overLimitedSOList = new List<ASI_CRM_JP_Sales_Order__c>();
               	for(ASI_CRM_JP_Sales_Order__c so : soList) {
                   	Boolean isChildOverLimit = false;
                   	for(ASI_CRM_JP_Sales_Order_Item__c soItem : so.Sales_Order_Items__r) {
                    	if(soItemOverLimitMap.containsKey(soItem.Id) &&
                           soItemOverLimitMap.get(soItem.Id)) {
                            isChildOverLimit = true;
                        }
                    }
                    
                    if((soOverLimitMap.containsKey(so.Id) &&
                       soOverLimitMap.get(so.Id)) ||
                       isChildOverLimit) {
                        overLimitedSOList.add(so);
                    }
                }
                soList = overLimitedSOList;
            }
		} 
        
		soFieldPrivilegeMap     = retrieveFieldPrivilegeMap(SALES_ORDER_OBJECT_NAME);
		soItemFieldPrivilegeMap = retrieveFieldPrivilegeMap(SALES_ORDER_ITEM_OBJECT_NAME);
	}

	public void massConfirmSO() {
        hasError = false;
		Map<String, String> params   = ApexPages.currentPage().getParameters();
		String cancelSOItemListJson  = params.get(CANCEL_SO_ITEM_LIST_JSON);
		String confirmSOListJson     = params.get(CONFIRM_SO_LIST_JSON);

		System.Savepoint databaseSavepoint = Database.setSavepoint();
	    try {
			List<String> cancelSOItemIdList = (List<String>) fromJsonString(cancelSOItemListJson, List<String>.class);
			List<String> confirmSOIdList    = (List<String>) fromJsonString(confirmSOListJson, List<String>.class);
			cancelSOItemBeforeProcess(cancelSOItemIdList);
			updateSOStatus(confirmSOIdList, SO_STATUS_FINAL);
		} catch(Exception e) {
            System.debug(e);
	      	exceptionList = new List<ExceptionWrapper>();
	      	if(e.getTypeName() == 'System.DmlException') {
	      		DmlException dmlException = (DmlException) e;
	      		for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
	      			ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
	      			exceptionList.add(exceptionWrapper);
	      		}
	      	} else {
	      		ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
	      		exceptionList.add(exceptionWrapper);
	      	}
	      	hasError = true;
	      	Database.rollback(databaseSavepoint);
	    }
        
        soList = retrieveSalesOrderList(recordType, ownerName, shipToName, soldToName, warehouseLocation, requestedDate, soType);
	}

	public void massRejectSO() {
        hasError = false;
		Map<String, String> params   = ApexPages.currentPage().getParameters();
		String cancelSOItemListJson  = params.get(CANCEL_SO_ITEM_LIST_JSON);
		String rejectSOListJson      = params.get(REJECT_SO_LIST_JSON);

		System.Savepoint databaseSavepoint = Database.setSavepoint();
	    try {
			List<String> cancelSOItemIdList = (List<String>) fromJsonString(cancelSOItemListJson, List<String>.class);
			List<String> rejectSOIdList     = (List<String>) fromJsonString(rejectSOListJson, List<String>.class);
			cancelSOItemBeforeProcess(cancelSOItemIdList);
			updateSOStatus(rejectSOIdList, SO_STATUS_REJECTED);
		} catch(Exception e) {
	      	if(e.getTypeName() == 'System.DmlException') {
	      		DmlException dmlException = (DmlException) e;
	      		for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
	      			ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
	      			exceptionList.add(exceptionWrapper);
	      		}
	      	} else {
	      		ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
	      		exceptionList.add(exceptionWrapper);
	      	}
	      	hasError = true;
	      	Database.rollback(databaseSavepoint);
	    }
        
        soList = retrieveSalesOrderList(recordType, ownerName, shipToName, soldToName, warehouseLocation, requestedDate, soType);
	}

    /*
	public void calculateAllocation() {
        hasError = false;
		Map<String, String> params  = ApexPages.currentPage().getParameters();
		String cancelSOItemListJson = params.get(CANCEL_SO_ITEM_LIST_JSON);
		String soListJson           = params.get(SO_LIST_JSON);

        System.Savepoint databaseSavepoint = Database.setSavepoint();
	    try {
	    	List<String> cancelSOItemIdList          = (List<String>) fromJsonString(cancelSOItemListJson, List<String>.class);
			List<ASI_CRM_JP_Sales_Order__c> soList   = (List<ASI_CRM_JP_Sales_Order__c>) fromJsonString(soListJson, List<ASI_CRM_JP_Sales_Order__c>.class);
			cancelSOItemBeforeProcess(cancelSOItemIdList);
			calculateAllocation(soList);
		} catch(Exception e) {
            System.debug(e);
	      	exceptionList = new List<ExceptionWrapper>();
	      	if(e.getTypeName() == 'System.DmlException') {
	      		DmlException dmlException = (DmlException) e;
	      		for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
	      			ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
	      			exceptionList.add(exceptionWrapper);
	      		}
	      	} else {
	      		ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
	      		exceptionList.add(exceptionWrapper);
	      	}
	      	hasError = true;
	      	Database.rollback(databaseSavepoint);
	    }
	}
    */

	public void save() {
        hasError = false;
		Map<String, String> params   = ApexPages.currentPage().getParameters();
		String cancelSOItemListJson  = params.get(CANCEL_SO_ITEM_LIST_JSON);
		String soListJson            = params.get(SO_LIST_JSON);
		
		System.Savepoint databaseSavepoint = Database.setSavepoint();
	    try {
	    	List<String> cancelSOItemIdList          = (List<String>) fromJsonString(cancelSOItemListJson, List<String>.class);
			List<ASI_CRM_JP_Sales_Order__c> soList   = (List<ASI_CRM_JP_Sales_Order__c>) fromJsonString(soListJson, List<ASI_CRM_JP_Sales_Order__c>.class);
			cancelSOItemBeforeProcess(cancelSOItemIdList);
			save(soList);
		} catch(Exception e) {
            System.debug(e);
	      	exceptionList = new List<ExceptionWrapper>();
	      	if(e.getTypeName() == 'System.DmlException') {
	      		DmlException dmlException = (DmlException) e;
	      		for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
	      			ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
	      			exceptionList.add(exceptionWrapper);
	      		}
	      	} else {
	      		ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
	      		exceptionList.add(exceptionWrapper);
	      	}
	      	hasError = true;
	      	Database.rollback(databaseSavepoint);
	    }
        
		soList = retrieveSalesOrderList(recordType, ownerName, shipToName, soldToName, warehouseLocation, requestedDate, soType);
	}

	public PageReference cancel() {
		PageReference pageRef = new PageReference('/' + SALES_ORDER_OBJECT_PREFIX);
	    pageRef.setRedirect(true);
	    return pageRef;
	}

	private void updateSOStatus(List<String> soIdList, String status) {
		//Update so record status
	    if(soIdList != null && soIdList.size() > 0) {
	    	List<ASI_CRM_JP_Sales_Order__c> updateSOList = new List<ASI_CRM_JP_Sales_Order__c>();
	    	for(String soId : soIdList) {
	    		updateSOList.add(new ASI_CRM_JP_Sales_Order__c(Id = soId, ASI_CRM_Status__c = status));
	    	}
	    	Database.update(updateSOList);
	    }
	}

	private void cancelSOItemBeforeProcess(List<String> cancelSOItemIdList) {
		//Mark delete the so detail records
	    if(cancelSOItemIdList != null && cancelSOItemIdList.size() > 0) {
	    	List<ASI_CRM_JP_Sales_Order_Item__c> cancelSOItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
	    	for(String cancelSOItemId : cancelSOItemIdList) {
	    		cancelSOItemList.add(new ASI_CRM_JP_Sales_Order_Item__c(Id = cancelSOItemId, ASI_CRM_Status__c = '980-Cancelled'));
	    	}
	    	Database.update(cancelSOItemList);
	    }
	}

	private void calculateAllocation(List<ASI_CRM_JP_Sales_Order__c> soList) {
		if(soList != null && soList.size() > 0) {
			//Get customer id from so record
			//Get item availability id from so item record
			Set<Id> customerIdSet         = new Set<Id>();
			Set<Id> itemAvailabilityIdSet = new Set<Id>();
			for(ASI_CRM_JP_Sales_Order__c so : soList) {
				customerIdSet.add(so.ASI_CRM_Sold_To__c);
				for(ASI_CRM_JP_Sales_Order_Item__c soItem : so.Sales_Order_Items__r) {
					itemAvailabilityIdSet.add(soItem.ASI_CRM_SKU_Item__c);
				}
			}
			Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap      = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList(customerIdSet));
			Map<Id, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap = new Map<Id, ASI_CRM_JP_Item_Availability__c>(retrieveItemAvailabilityList(itemAvailabilityIdSet));
			
			//Check the customer credit limit
			//Check the SO Item Quantity and Item Availability Quantity
			Map<Id, CustomerSOWrapper> customerSOWrapperMap = new Map<Id, CustomerSOWrapper>();
			Map<Id, ItemSOWrapper> itemSOWrapperMap         = new Map<Id, ItemSOWrapper>();
			for(ASI_CRM_JP_Sales_Order__c so : soList) {
                if(customerMap.containsKey(so.ASI_CRM_Sold_To__c)) {
					CustomerSOWrapper customerSOWrapper = customerSOWrapperMap.get(so.ASI_CRM_Sold_To__c);
                    if(customerSOWrapper == null) customerSOWrapper = new CustomerSOWrapper(customerMap.get(so.ASI_CRM_Sold_To__c));
                    customerSOWrapper.addSO(so);
                    customerSOWrapperMap.put(so.ASI_CRM_Sold_To__c, customerSOWrapper);
                }

				for(ASI_CRM_JP_Sales_Order_Item__c soItem : so.Sales_Order_Items__r) {
                    if(itemAvailabilityMap.containsKey(soItem.ASI_CRM_SKU_Item__c)) {
                        ItemSOWrapper itemSOItemWrapper = itemSOWrapperMap.get(soItem.ASI_CRM_SKU_Item__c);
                        if(itemSOItemWrapper == null) itemSOItemWrapper = new ItemSOWrapper(itemAvailabilityMap.get(soItem.ASI_CRM_SKU_Item__c));
                        itemSOItemWrapper.addSOItem(soItem);
                        itemSOWrapperMap.put(soItem.ASI_CRM_SKU_Item__c, itemSOItemWrapper);
                    }
				}
			}
            
            soOverLimitMap     = new Map<String, Boolean>();
            soItemOverLimitMap = new Map<String, Boolean>();
            for(Id customerId : customerSOWrapperMap.keySet()) {
                soOverLimitMap.putAll(customerSOWrapperMap.get(customerId).genSOOverLimitMap());
            }
            for(Id itemId : itemSOWrapperMap.keySet()) {
            	soItemOverLimitMap.putAll(itemSOWrapperMap.get(itemId).genSOItemOverLimitMap());
            }
            
            System.debug(soOverLimitMap);
            System.debug(soItemOverLimitMap);
            
		}
	}

	private void save(List<ASI_CRM_JP_Sales_Order__c> soList) {
		//Save the so header and item records
		if(soList != null && soList.size() > 0) {
			List<ASI_CRM_JP_Sales_Order_Item__c> soItemList = new List<ASI_CRM_JP_Sales_Order_Item__c>();
			for(ASI_CRM_JP_Sales_Order__c so : soList) {
				soItemList.addAll(so.Sales_Order_Items__r);
			}
			if(soItemList.size() > 0) {
	    		Database.upsert(soItemList);
            }
	    	Database.upsert(soList);
		}
	}

	/***************
	Data Retrievement Function
	***************/
	private List<ASI_CRM_JP_Sales_Order__c> retrieveSalesOrderList(String recordType, String ownerName, String shipToName, String soldToName, String businessUnit, Date requestedDate, String soType) {
		String query = 'SELECT ' + genQueryField(SALES_ORDER_FIELD_MAP) + 
		               ', RecordType.DeveloperName, ASI_CRM_Ship_To__r.Name' + 
                       ', ASI_CRM_Sold_To__r.Name, Owner.Name, ASI_CRM_Sold_To__r.ASI_CRM_JP_Credit_Balance__c' + 
                       ', ASI_CRM_Sold_To__r.ASI_CRM_JP_Customer_Parent__c, ASI_CRM_Sold_To__r.ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Credit_Balance__c' +
		               ', (SELECT ' + genQueryField(SALES_ORDER_DETAIL_FIELD_MAP) + ', ASI_CRM_SKU__r.Name, ASI_CRM_SKU_Item__r.Name, ASI_CRM_SKU_Item__r.ASI_Quantity_Availability__c ' +  
                       'FROM Sales_Order_Items__r ' + 
                       'ORDER BY ASI_CRM_Sorting_Number__c) ' +
		               'FROM ASI_CRM_JP_Sales_Order__c ' + 
                       'WHERE RecordType.DeveloperName = :recordType ';
        
        if(recordType == 'ASI_CRM_JP_Normal_SO_Locked' ||
           recordType == 'ASI_CRM_JP_Employee_Sales_Locked' ||
           recordType == 'ASI_CRM_JP_Duty_Free_SO_Locked') {
        	query += 'AND ASI_CRM_Status__c = :SO_STATUS_REQUESTED ';
        }
        
        if(recordType == 'ASI_CRM_JP_Marketing_FOC_Locked' || 
           recordType == 'ASI_CRM_JP_Entertainment_Sales_Locked' ||
           recordType == 'ASI_CRM_JP_Sample_Sales_Locked') {
            query += 'AND ASI_CRM_Status__c = :SO_STATUS_APPROVED ';
        }
        
        if(recordType == 'ASI_CRM_JP_Direct_Sales_Locked') {
            query += 'AND ((ASI_CRM_Payment_Option__c in : APPROVED_STATUS_PAYMENT_OPTION AND ASI_CRM_Status__c = :SO_STATUS_APPROVED) ';
            query += 'OR (ASI_CRM_Payment_Option__c in : AC_VERIFIED_STATUS_PAYMENT_OPTION AND ASI_CRM_Status__c = :SO_STATUS_AC_VERIFIED))';
        }
        
        if(String.isNotBlank(ownerName))
            query += 'AND Owner.Name LIKE \'%' + ownerName + '%\' ';
        if(String.isNotBlank(shipToName))
            query += 'AND ASI_CRM_Ship_To__r.Name LIKE \'%' + shipToName + '%\' ';
        if(String.isNotBlank(soldToName))
            query += 'AND ASI_CRM_Sold_To__r.Name LIKE \'%' + soldToName + '%\' ';
		if(String.isNotBlank(businessUnit)) 
            query += 'AND ASI_CRM_Branch_Plant__c = :businessUnit ';
		if(requestedDate != null)          
            query += 'AND ASI_CRM_Requested_Date__c <= :requestedDate ';
		if(String.isNotBlank(soType) && recordType == 'ASI_CRM_JP_Duty_Free_SO_Locked' &&
           String.isNotBlank(soType))       
            query += 'AND ASI_CRM_Order_Type__c = :soType ';
		
        query += 'LIMIT 200';
        
		return (List<ASI_CRM_JP_Sales_Order__c>) Database.query(query);
	}

	private List<ASI_CRM_JP_Item_Availability__c> retrieveItemAvailabilityList(Set<Id> itemAvailabilityIdSet) {
		String query = 'SELECT ' + genQueryField(ITEM_AVAILABILITY_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_JP_Item_Availability__c ' + 
		               'WHERE Id in : itemAvailabilityIdSet';
		return (List<ASI_CRM_JP_Item_Availability__c>) Database.query(query);
	}

	private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdList) {
		String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', ASI_CRM_JP_Customer_Parent__r.ASI_CRM_JP_Credit_Balance__c ' + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_AccountsAdditionalField__c ' + 
		               'Where Id in :customerIdList';
		return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
	}

	private Map<String, String> retrievePicklistValues(Schema.DescribeFieldResult fieldResult) {
  		Map<String, String> picklistValueMap = new Map<String, String>();

  		List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
  		for(Schema.PicklistEntry picklistEntry : picklistEntryList) {
    		picklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
    	}

    	return picklistValueMap;
  	}

  	private Map<Integer, String> retrieveFieldPrivilegeMap(String sObjectName) {
  		Map<Integer, String> tempFIeldPrivilegeMap = new Map<Integer, String>();
  		List<ASI_CRM_JP_Field_Privilege__c> fieldPrivilegeList = ASI_CRM_JP_Field_Privilege__c.getAll().values();
  		for(ASI_CRM_JP_Field_Privilege__c fieldPrivilege : fieldPrivilegeList) {
            if(fieldPrivilege.ASI_CRM_JP_Page_Name__c == 'ASI_CRM_JP_SOReview_Page') {
                if(String.isBlank(fieldPrivilege.ASI_CRM_JP_Record_Type_Name__c) ||
                   fieldPrivilege.ASI_CRM_JP_Record_Type_Name__c.contains(recordType)) {
                    if(fieldPrivilege.ASI_CRM_JP_Object_Name__c == sObjectName) {
                        Boolean matchCriteria = false;
                        if(String.isNotBlank(fieldPrivilege.ASI_CRM_JP_Other_Criteria__c)) {
                            List<String> valueList = fieldPrivilege.ASI_CRM_JP_Other_Criteria__c.split('/');
                            for(String value : valueList) {
                                if(soType == value) {
                                    matchCriteria = true;
                                }
                            }
                        }
                        if(matchCriteria == true || String.isBlank(fieldPrivilege.ASI_CRM_JP_Other_Criteria__c)) {
                            System.debug(fieldPrivilege.Name);
                            String key = '';
                            if(fieldPrivilege.ASI_CRM_JP_Privilege__c == 'Read Only') {
                                key = fieldPrivilege.ASI_CRM_JP_Field_Name__c + '_ReadOnly';
                            } else if(fieldPrivilege.ASI_CRM_JP_Privilege__c == 'Null Value') {
                                key = fieldPrivilege.ASI_CRM_JP_Field_Name__c + '_Null';
                            } else if(fieldPrivilege.ASI_CRM_JP_Privilege__c == 'Full Access') {
                                key = fieldPrivilege.ASI_CRM_JP_Field_Name__c;
                            }
                            tempFIeldPrivilegeMap.put(fieldPrivilege.ASI_CRM_JP_Display_Order__c.intValue(), key);
                        }
                    }
                }
            }
  		}
  		return tempFIeldPrivilegeMap;
  	}

	private Map<String, Id> retrieveFieldId() {
  		Map<String, String> tempFieldIdMap = new Map<String, String>();
  		List<ASI_CRM_Field_ID_Mappings__c> fieldIdMappingList = ASI_CRM_Field_ID_Mappings__c.getAll().values();
  		for(ASI_CRM_Field_ID_Mappings__c fieldIdMapping : fieldIdMappingList) {
  			tempFieldIdMap.put(fieldIdMapping.ASI_CRM_Field_Name__c, fieldIdMapping.ASI_CRM_Field_ID__c.subString(0, 15));
  		}
  		return tempFieldIdMap;
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

  	private void throwException(String errorMessage, String[] parameterArray) {
  		if(parameterArray != null) {
  			errorMessage = String.format(errorMessage, parameterArray);
  		}
  		throw new VisualforceException(errorMessage);
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