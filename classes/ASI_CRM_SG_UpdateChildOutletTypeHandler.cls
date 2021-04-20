/*********************************************************************************
 * Name: ASI_CRM_SG_UpdateChildOutletTypeHandler
 * Description: Update child outlets when change outlet type field
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/04/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_SG_UpdateChildOutletTypeHandler extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_UpdateChildOutletTypeHandler() {
        super('ASI_CRM_SG_UpdateChildOutletTypeHandler');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c >) newMap;
        Map<Id, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap;
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> filteredCustomerMap = filterCustomer(customerMap, oldCustomerMap);
        updateChildOutletType(filteredCustomerMap);
    }
    
    private Map<Id, ASI_CRM_AccountsAdditionalField__c> filterCustomer(Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap, Map<Id, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap) {
    	if(oldCustomerMap == null) return customerMap;
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> filteredCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerMap.values()) {
            if(customer.ASI_CRM_Outlet_Type__c != oldCustomerMap.get(customer.Id).ASI_CRM_Outlet_Type__c) 
                filteredCustomerMap.put(customer.Id, customer);
        }
        
        return filteredCustomerMap;
    }

    private void updateChildOutletType(Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap) {
       	List<ASI_CRM_AccountsAdditionalField__c> childCustomerList = retrieveCustomerList(customerMap.keySet());
        
        for(ASI_CRM_AccountsAdditionalField__c childCustomer : childCustomerList) {
            childCustomer.ASI_CRM_Outlet_Type__c = customerMap.get(childCustomer.ASI_CRM_CN_Parent_Outlet__c).ASI_CRM_Outlet_Type__c;
        }
        
        if(childCustomerList.size() > 0)
            update childCustomerList;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private static List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c  '
                     + 'FROM ASI_CRM_AccountsAdditionalField__c '
                     + 'WHERE ASI_CRM_CN_Parent_Outlet__c in :customerIdSet ';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
}