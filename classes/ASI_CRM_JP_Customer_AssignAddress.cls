/*********************************************************************************
 * Name: ASI_CRM_JP_Customer_AssignAddress
 * Description: Assign the customer address by postal code
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_Customer_AssignAddress extends ASI_CRM_JP_TriggerAbstract {
    
    //Field Schema Map
    private final static Map<String, Schema.SObjectField> POSTAL_CODE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Postal_Code__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    
    //Object API Name
    private final static String CUSTOMER_API_NAME = 'ASI_CRM_AccountsAdditionalField__c';
    
    //Record Type Id
    private final static String DIRECT_SALES_CUSTOMER_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId(CUSTOMER_API_NAME + 'ASI_CRM_JP_Inactive_Direct_Sales_Customer');
    private final static String DIRECT_SALES_SHIP_TO_RECORD_TYPE_ID  = Global_RecordTypeCache.getRtId(CUSTOMER_API_NAME + 'ASI_CRM_JP_Direct_Sales_Ship_To');
    private final static String DIRECT_SALES_BILL_TO_RECORD_TYPE_ID  = Global_RecordTypeCache.getRtId(CUSTOMER_API_NAME + 'ASI_CRM_JP_Direct_Sales_Bill_To');
    private final static String MARKETING_FOC_VENUE_RECORD_TYPE_ID  = Global_RecordTypeCache.getRtId(CUSTOMER_API_NAME + 'ASI_CRM_JP_Marketing_Venue');
    
    public ASI_CRM_JP_Customer_AssignAddress() {
        super('ASI_CRM_JP_TriggerAbstract');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) sObjList;

        if(oldMap == null) {
        	processAutoNumber(customerList);
            processPostalCode(customerList, null);
            processSalesmanCode(customerList);
        } else {
        	processPostalCode(customerList, (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap);
        }
    }
    @testVisible
    private void processAutoNumber(List<ASI_CRM_AccountsAdditionalField__c> customerList) {
        Map<Id, ASI_CRM_JP_AutoNumberAssignment> autoNumberRTIdMap = new Map<Id, ASI_CRM_JP_AutoNumberAssignment>();
        autoNumberRTIdMap.put(DIRECT_SALES_CUSTOMER_RECORD_TYPE_ID, new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Customer_Code_Direct_Sales'));
        autoNumberRTIdMap.put(DIRECT_SALES_SHIP_TO_RECORD_TYPE_ID, new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Customer_Code_ShipTo'));
        autoNumberRTIdMap.put(DIRECT_SALES_BILL_TO_RECORD_TYPE_ID, new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Customer_Code_BillTo'));
        autoNumberRTIdMap.put(MARKETING_FOC_VENUE_RECORD_TYPE_ID, new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Customer_Code_MarketingVenue'));
    
    	ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            if(autoNumberRTIdMap.containsKey(customer.RecordTypeId)) {
                customer.ASI_CRM_CN_CRM_Code__c = autoNumberRTIdMap.get(customer.RecordTypeId).nextAutoNumStr();
            }
        }
        
        for(Id recordTypeId : autoNumberRTIdMap.keySet()) {
            autoNumberRTIdMap.get(recordTypeId).writeToDB();
        }
    }
    @testVisible
    private void processPostalCode(List<ASI_CRM_AccountsAdditionalField__c> customerList, Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap) {
    	Set<String> postalCodeNameSet = new Set<String>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            Boolean needToAssign = false;
            if(customerMap == null) {
                needToAssign = needToAssignAddress(customer);
            } else {
                needToAssign = needToAssignAddress(customer, customerMap.get(customer.Id));
            }
            if(needToAssign) {
            	postalCodeNameSet.add(customer.ASI_CRM_PostalCode__c);
            }
        }
        
        Map<String, ASI_CRM_Postal_Code__c> postalCodeMap = retrievePostalCodeMap(postalCodeNameSet);
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            Boolean needToAssign = false;
            if(customerMap == null) {
                needToAssign = needToAssignAddress(customer);
                
            } else {
                needToAssign = needToAssignAddress(customer, customerMap.get(customer.Id));
                
            }
            
            if(needToAssign && postalCodeMap.containsKey(customer.ASI_CRM_PostalCode__c)) {
                
                ASI_CRM_Postal_Code__c postalCode          = postalCodeMap.get(customer.ASI_CRM_PostalCode__c);
                customer.ASI_CRM_JP_Prefecture_Japanese__c = postalCode.ASI_CRM_JP_Prefecture__c;
                customer.ASI_CRM_JP_Prefecture__c		   = postalCode.ASI_CRM_JP_Prefecture_EN__c;
                customer.ASI_CRM_JP_City_Ward__c           = postalCode.ASI_CRM_JP_City__c;
                customer.ASI_CRM_JP_Town__c                = postalCode.ASI_CRM_JP_Town__c;
                customer.ASI_CRM_JP_Prefecture__c          = postalCode.ASI_CRM_JP_Prefecture_EN__c;
            }
        }
    }
    @testVisible
    private void processSalesmanCode(List<ASI_CRM_AccountsAdditionalField__c> customerList) {
        List<ASI_CRM_AccountsAdditionalField__c> filteredCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        Set<Id> masterCustomerIdSet = new Set<Id>();
    	for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
        	if(customer.RecordTypeId == DIRECT_SALES_SHIP_TO_RECORD_TYPE_ID &&
               String.isBlank(customer.ASI_CRM_KR_Salesman__c)) {
          		filteredCustomerList.add(customer);
                masterCustomerIdSet.add(customer.ASI_CRM_Customer__c);
            }
        }
        
        if(filteredCustomerList.size() > 0) {
            system.debug('filteredCustomerList'+filteredCustomerList);
            Map<Id, ASI_CRM_AccountsAdditionalField__c> masterCustomerMap = retrieveCustomerMap(masterCustomerIdSet);
            Set<Id> masterCustomerOwnerIdSet = new Set<Id>();
            for(ASI_CRM_AccountsAdditionalField__c masterCustomer : masterCustomerMap.values()) {
            	masterCustomerOwnerIdSet.add(masterCustomer.OwnerId);
            }
            
            Map<Id, User> masterUserMap = retrieveUserMap(masterCustomerOwnerIdSet);
            for(ASI_CRM_AccountsAdditionalField__c customer : filteredCustomerList) {
                ASI_CRM_AccountsAdditionalField__c masterCustomer = masterCustomerMap.get(customer.ASI_CRM_Customer__c);
                if(masterCustomer == null) {
                	continue;
                } else {
                	User masterUser = masterUserMap.get(masterCustomer.OwnerId);
                    if(masterUser == null) {
                    	continue;
                    } else {
                    	customer.ASI_CRM_KR_Salesman__c = masterUser.ASI_TnE_Sub_Ledger__c;
                    }
                }
            }
        }
    }
    @testVisible
    private Boolean needToAssignAddress(ASI_CRM_AccountsAdditionalField__c customer) {
   		if(String.isNotBlank(customer.ASI_CRM_PostalCode__c)) {
        	return true;
        }
        return false;
    }
    @testVisible
    private Boolean needToAssignAddress(ASI_CRM_AccountsAdditionalField__c customer, ASI_CRM_AccountsAdditionalField__c oldCustomer) {
        if(String.isNotBlank(customer.ASI_CRM_PostalCode__c) &&
           customer.ASI_CRM_PostalCode__c != oldCustomer.ASI_CRM_PostalCode__c){
        	return true;
        }
        return false;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    @testVisible
    private Map<Id, ASI_CRM_AccountsAdditionalField__c> retrieveCustomerMap(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE Id in :customerIdSet ';
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>)Database.query(query);
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(customerList);
        return customerMap;
    }
     @testVisible
    private Map<String, ASI_CRM_Postal_Code__c> retrievePostalCodeMap(Set<String> postalCodeNameSet) {
        String query = 'SELECT ' + genQueryField(POSTAL_CODE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Postal_Code__c ' + 
                       'WHERE Name in :postalCodeNameSet ';
        
        Map<String, ASI_CRM_Postal_Code__c> postalCodeMap = new Map<String, ASI_CRM_Postal_Code__c>();
        for(ASI_CRM_Postal_Code__c postalCode : Database.query(query)) {
            postalCodeMap.put(postalCode.Name, postalCode);
        }
        return postalCodeMap;
    }
     @testVisible
    private Map<Id, User> retrieveUserMap(Set<Id> userIdSet) {
    	String query = 'SELECT Id, ASI_TnE_Sub_Ledger__c ' + 
                       'FROM User ' + 
                       'WHERE Id in :userIdSet ';
        List<User> userList = (List<User>)Database.query(query);
        Map<Id, User> userMap = new Map<Id, User>(userList);
        return userMap;
    }
    
    /***************
    Tools Function
    ***************/
    public String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
        queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }
}