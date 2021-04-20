/**********************************************************************************
 * Name : ASI_CRM_SG_PopulateCustomer
 * Created : DC @03/30/2016 2:43 PM
 * Revision History:
 * 1. 03/30/2016 - [DC 1.0] Created
 * 2. 2016-06-06 - [VL 1.0] Only show error for external user 
 * 3. 2016-06-13 - [HC 1.0] Set related outlet id to ship to field
 * 4. 2017-03-15 - [WL 1.0] Add Re-export SO for default Customer and Ship To
 * 5. 2017-07-07 - [WL 2.0] Change WS SO Default Customer to be 
 * 6. 2018-02-07 - [WL 3.0] Default WS SO and TBCN Notification receipient by WS
 * 7. 2018-03-06 - [WL 4.0] Bug fix for Non-selective query error on Customer object
 **********************************************************************************/

public with sharing class ASI_CRM_SG_PopulateCustomer extends ASI_CRM_SG_TriggerAbstract {
    /*[WL 2.0] BEGIN*/
    //private final static String CUSTOMER_RECORDTYPE_DEVNAME = 'ASI_CRM_SG_Wholesaler';
  private final static String CUSTOMER_RECORDTYPE_DEVNAME = 'ASI_CRM_SG_Outlet';
  /*[WL 2.0] END*/
    private final static String OUTLET_RECORDTYPE_DEVNAME = 'ASI_CRM_SG_Outlet';
    
    /* [WL 1.0] BEGIN */
    private final static String RE_EXPORT_CUSTOMER_RECORDTYPE_DEVNAME = 'ASI_CRM_SG_Re_Export_SO_Customer';
  private final static String RE_EXPORT_ERROR_MESSAGE_ON_NO_MATCH =
        'Missing Customer and Ship To configured. Please select it manually or contact system administrator.';
    /* [WL 1.0] END */
    
    private final static String ERROR_MESSAGE_ON_NO_MATCH =
        'Wholesaler does not exist. You cannot create Sales Order Request. Please contact your admin.';

    public ASI_CRM_SG_PopulateCustomer() {
        super('ASI_CRM_SG_PopulateCustomer');
    }

	/*[WL 3.0] BEGIN*/
	public static sObject createShareRule(sObject recordObject, String recordshare, String approverField, String accessLevel){
        sObject Access =  Schema.getGlobalDescribe().get(recordShare).newSObject();
        Access.put('ParentId',  recordObject.get('id')); //Which object record to have rights
        Access.put('UserOrGroupId', recordObject.get(approverField)); //Which user to get rights
        Access.put('AccessLevel', accessLevel); //What type of rights
        //Access.put('RowCause', Schema.ASI_KOR_Sales_Order_Request__share.rowCause.ASI_CRM_SG_Submitter_Share__c) ; //Reason to get rights
        return Access;
    }
	
	public static void assignRecordShare(List<ASI_KOR_Sales_Order_Request__c> trigger_new){
		List<sObject> shareList = new List<sObject>();
		
		for (ASI_KOR_Sales_Order_Request__c so:trigger_new){
			if (so.ASI_CRM_CN_Sys_Approver_1__c != null)
				shareList.add(createShareRule(so, 'ASI_KOR_Sales_Order_Request__share', 'ASI_CRM_CN_Sys_Approver_1__c', 'Edit'));
			if (so.ASI_CRM_CN_Sys_Approver_2__c != null)
				shareList.add(createShareRule(so, 'ASI_KOR_Sales_Order_Request__share', 'ASI_CRM_CN_Sys_Approver_2__c', 'Edit'));
			if (so.ASI_CRM_CN_Sys_Approver_3__c != null)
				shareList.add(createShareRule(so, 'ASI_KOR_Sales_Order_Request__share', 'ASI_CRM_CN_Sys_Approver_3__c', 'Edit'));
			if (so.ASI_CRM_CN_Sys_Approver_4__c != null)
				shareList.add(createShareRule(so, 'ASI_KOR_Sales_Order_Request__share', 'ASI_CRM_CN_Sys_Approver_4__c', 'Edit'));
				
			system.debug('shareList: ' + shareList.size() + ' ' + shareList);
					
			if (shareList.size() > 0){
				Database.SaveResult[] jobShareInsertResult = Database.insert(shareList,false);
				system.debug('shareList jobShareInsertResult: ' + jobShareInsertResult);
			}				
		}
	}
	/*[WL 3.0] END*/
	
    public override void executeTriggerAction(
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        /* [VL 1.0] BEGIN */
        // get user's profile
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String userProfileName = PROFILE[0].Name;
        /* [VL 1.0] END */

        Set<Id> setOwnerIds = new Set<Id>();
		Set<Id> setCustomerId = new Set<Id>();
        Set<String> setCompanyNames = new Set<String>();
        Set<String> setOutletNames = new Set<String>();
        Set<String> setReExportCustomerNames = new Set<String>();

        List<ASI_KOR_Sales_Order_Request__c> lstTriggerNew =
            (List<ASI_KOR_Sales_Order_Request__c>) sObjList;

        for(ASI_KOR_Sales_Order_Request__c requestIterator : lstTriggerNew) {
            setOwnerIds.add(requestIterator.ownerId);
            
            //20160803 Wilken: Default Delivery Instruction if blank
            system.debug('TBCN Before Insert, Delivery Instruction default. ' + requestIterator.ASI_KOR_Delivery_Instruction__c);
            if (requestIterator.recordtypeid == Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler')){
                if (requestIterator.ASI_KOR_Delivery_Instruction__c == null)
                    requestIterator.ASI_KOR_Delivery_Instruction__c = '#Warehouse To Deliver';
                    
                if (requestIterator.ASI_CRM_Expected_Delivery_Date__c == null)
                    requestIterator.ASI_CRM_Expected_Delivery_Date__c = System.Today().addDays(1);
                else if (requestIterator.ASI_CRM_Expected_Delivery_Date__c <= System.Today())
                    requestIterator.ASI_CRM_Expected_Delivery_Date__c = System.Today().addDays(1);
            }
            else if (requestIterator.recordtypeid == Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_TBCN')){
                if (requestIterator.ASI_KOR_Delivery_Instruction__c == null)
                    requestIterator.ASI_KOR_Delivery_Instruction__c = '#Warehouse To Collect';
            }
			
			/*[WL 4.0] BEGIN*/
			if (requestIterator.ASI_CRM_SG_Customer__c != null)
				setCustomerId.add(requestIterator.ASI_CRM_SG_Customer__c);
			/*[WL 4.0] END*/
        }

        Map<Id, User> mapRecordId_Owner = new Map<Id, User>(
            [SELECT Id
                  , ASI_Default_Order_Customer__c
                  /* [HC 1.0] BEGIN */
                  , ASI_Default_Order_Ship_To__c
                  /* [HC 1.0] END */
               FROM User
              WHERE Id IN : setOwnerIds]);

		system.debug('mapRecordId_Owner.values(): ' + mapRecordId_Owner.values());
		
        for(User ownerIterator : mapRecordId_Owner.values()) {
            setCompanyNames.add(ownerIterator.ASI_Default_Order_Customer__c);
            setOutletNames.add(ownerIterator.ASI_Default_Order_Ship_To__c);
            
            setReExportCustomerNames.add(ownerIterator.ASI_Default_Order_Customer__c);
            setReExportCustomerNames.add(ownerIterator.ASI_Default_Order_Ship_To__c);
        }

        List<ASI_CRM_AccountsAdditionalField__c> lstMatchingCustomers =
            [SELECT Id
                  , Name, ASI_CRM_MY_CustomerCode__c 
               FROM ASI_CRM_AccountsAdditionalField__c
              WHERE Name IN : setCompanyNames
                AND RecordType.DeveloperName = : CUSTOMER_RECORDTYPE_DEVNAME
           ORDER BY Name];

        /* [HC 1.0] BEGIN */
        List<ASI_CRM_AccountsAdditionalField__c> lstMatchOutlet = 
            [SELECT Id
                  , Name
               FROM ASI_CRM_AccountsAdditionalField__c
              WHERE Name IN : setOutletNames
                AND RecordType.DeveloperName = : OUTLET_RECORDTYPE_DEVNAME
           ORDER BY Name];
        /* [HC 1.0] END */
		
        /* [WL 3.0] BEGIN */
        List<ASI_CRM_AccountsAdditionalField__c> fullCustomerList = 
            [SELECT Id
                  , ASI_CRM_MY_CustomerCode__c
               FROM ASI_CRM_AccountsAdditionalField__c
              WHERE RecordType.DeveloperName = : OUTLET_RECORDTYPE_DEVNAME
			  /*[WL 4.0] BEGIN*/
			  AND Id in :setCustomerId
			  /*[WL 4.0] END*/
           ORDER BY Name];
		  
		Map<Id, String> customerIDCodeMap = new Map<Id, String>();
		
		for (ASI_CRM_AccountsAdditionalField__c c:fullCustomerList)
			customerIDCodeMap.put(c.Id, c.ASI_CRM_MY_CustomerCode__c);
        /* [WL 3.0] END */		

        /* [WL 1.0] BEGIN */
        List<ASI_CRM_AccountsAdditionalField__c> matchingReExportCustList = 
            [SELECT Id
                  , Name
               FROM ASI_CRM_AccountsAdditionalField__c
              WHERE Name IN : setReExportCustomerNames
                AND RecordType.DeveloperName = : RE_EXPORT_CUSTOMER_RECORDTYPE_DEVNAME
           ORDER BY Name];
        /* [WL 1.0] END */
        
        Boolean isNoMatch;
        /* [VL 1.0] BEGIN */
        Boolean isExternalUser = userProfileName == 'ASI SG External User' ? true : false;
        /* [VL 1.0] END */
		
		/*[WL 3.0] BEGIN*/
		List<ASI_CRM_SG_WS_SO_Approval__c> soApprovalList = ASI_CRM_SG_WS_SO_Approval__c.getAll().values();
		Map<String, Id> userMap = new Map<String, Id>();		
		Set<String> usernameSet = new Set<String>();
		String customerCode;
		
		for (ASI_CRM_SG_WS_SO_Approval__c setting:soApprovalList){
			usernameSet.add(setting.ASI_CRM_Handler_1__c);
			usernameSet.add(setting.ASI_CRM_Handler_2__c);
			usernameSet.add(setting.ASI_CRM_Handler_3__c);
			usernameSet.add(setting.ASI_CRM_Handler_4__c);
		}
		
		List<User> uList = [select Id, Username from User where Username in :usernameSet];
		
		for (User u:uList){
			userMap.put(u.Username, u.Id);
		}
		system.debug('userMap:' + userMap);
		/*[WL 3.0] END*/

        for(ASI_KOR_Sales_Order_Request__c requestIterator : lstTriggerNew) {
            
            isNoMatch = true;

            /* [HC 1.0] BEGIN */
            Id customerId;
            Id outletId;
            
            /* [WL 1.0] BEGIN */
            if (Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_CA') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_IN') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_LA') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_MM') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_MY') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_PH') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_VI') ||
                Global_RecordTypeCache.getRt(requestIterator.recordTypeId).developerName.contains('ASI_CRM_SG_VIDF')){
                
                system.debug('Re-export SO: Owner Default Customer: ' + mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Customer__c + ' Default Ship To: ' + mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Ship_To__c);
                
                //For Re-export SO
                for(ASI_CRM_AccountsAdditionalField__c customerIterator : matchingReExportCustList) {
                
                    if(customerIterator.Name.equalsIgnoreCase(
                        mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Customer__c
                    )) {
                        customerId = customerIterator.Id;
                        break;
                    }
                }
                
                for(ASI_CRM_AccountsAdditionalField__c customerIterator : matchingReExportCustList) {
                    if(customerIterator.Name.equalsIgnoreCase(
                        mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Ship_To__c
                    )) {
                        outletId = customerIterator.Id;
                        break;
                    }
                }
                
                system.debug('matchingReExportCustList size: ' + matchingReExportCustList.size() + ' CustID: ' + customerId + ' OutletId: ' + outletId + ' Request Customer: ' + requestIterator.ASI_CRM_SG_Customer__c + ' Request Ship To: ' + requestIterator.ASI_CRM_SG_Ship_To__c);
                if(customerId != null && outletId != null && requestIterator.ASI_CRM_SG_Customer__c == null && requestIterator.ASI_CRM_SG_Ship_To__c == null) {
                    requestIterator.ASI_CRM_SG_Customer__c = customerId;
                    requestIterator.ASI_CRM_SG_Ship_To__c = outletId;
                }
        
				if (requestIterator.ASI_CRM_SG_Customer__c != null || requestIterator.ASI_CRM_SG_Ship_To__c != null)
				  isNoMatch = false;
          
				if(isNoMatch == true) {
                    requestIterator.addError(RE_EXPORT_ERROR_MESSAGE_ON_NO_MATCH);
                }
            }
            else {
                //For WS SO and TBCN SO
				system.debug('lstMatchingCustomers: ' + lstMatchingCustomers);
                for(ASI_CRM_AccountsAdditionalField__c customerIterator : lstMatchingCustomers) {
                    system.debug('SO customerIterator Name: ' + customerIterator.Name);
					system.debug('Owner Default Order Customer: ' + mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Customer__c);
					system.debug('Owner Default Order Ship To: ' + mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Ship_To__c);
					
                    if(customerIterator.Name.equalsIgnoreCase(
                        mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Customer__c
                    )) {
                        customerId = customerIterator.Id;
						
						/*[WL 3.0] BEGIN*/						
						customerCode = customerIterator.ASI_CRM_MY_CustomerCode__c;
						/*[WL 3.0] END*/
                        break;
                    }
                }

				system.debug('Default Customer from Owner Setup: ' + customerCode + ' SO Request Customer: ' + requestIterator.ASI_CRM_SG_Customer__c);
				
                for(ASI_CRM_AccountsAdditionalField__c outletIterator : lstMatchOutlet) {

                    if(outletIterator.Name.equalsIgnoreCase(
                        mapRecordId_Owner.get(requestIterator.OwnerId).ASI_Default_Order_Ship_To__c
                    )) {
                        outletId = outletIterator.Id;
                        break;
                    }

                }
                
                if(customerId != null && outletId != null) {
                    requestIterator.ASI_CRM_SG_Customer__c = customerId;
                    requestIterator.ASI_CRM_SG_Ship_To__c = outletId;
						
                    isNoMatch = false;
                }
				
				/*[WL 3.0] BEGIN*/
				ASI_CRM_SG_WS_SO_Approval__c setting;
				if (customerCode != null)
					setting = ASI_CRM_SG_WS_SO_Approval__c.getValues(customerCode);
				else if (requestIterator.ASI_CRM_SG_Customer__c != null && customerIDCodeMap.get(requestIterator.ASI_CRM_SG_Customer__c) != null)
					setting = ASI_CRM_SG_WS_SO_Approval__c.getValues(customerIDCodeMap.get(requestIterator.ASI_CRM_SG_Customer__c));			
				
				system.debug('customerCode: ' + customerCode + ' requestIterator.ASI_CRM_SG_Customer__c: ' + requestIterator.ASI_CRM_SG_Customer__c + ' customerIDCodeMap.get(requestIterator.ASI_CRM_SG_Customer__c): ' + customerIDCodeMap.get(requestIterator.ASI_CRM_SG_Customer__c) + ' setting: ' + setting);
				
				if (setting != null){
					if (setting.ASI_CRM_Handler_1__c != null){
						requestIterator.ASI_CRM_CN_Sys_Approver_1__c = userMap.get(setting.ASI_CRM_Handler_1__c);
					}
					if (setting.ASI_CRM_Handler_2__c != null){
						requestIterator.ASI_CRM_CN_Sys_Approver_2__c = userMap.get(setting.ASI_CRM_Handler_2__c);
					}
					if (setting.ASI_CRM_Handler_3__c != null){
						requestIterator.ASI_CRM_CN_Sys_Approver_3__c = userMap.get(setting.ASI_CRM_Handler_3__c);
					}
					if (setting.ASI_CRM_Handler_4__c != null){
						requestIterator.ASI_CRM_CN_Sys_Approver_4__c = userMap.get(setting.ASI_CRM_Handler_4__c);
					}
					isNoMatch = false;
				}
				/*[WL 3.0] END*/
                
                /* [VL 1.0] BEGIN */
                /*
                if(isNoMatch == true) {
                    requestIterator.addError(ERROR_MESSAGE_ON_NO_MATCH);
                }
                */
                if(isNoMatch == true && isExternalUser) {
                    requestIterator.addError(ERROR_MESSAGE_ON_NO_MATCH);
                }
                /* [VL 1.0] END */
            }
            /* [HC 1.0] END */
            /* [WL 1.0] END */            
        }
    }
}