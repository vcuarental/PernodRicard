/*********************************************************************************
 * Name: ASI_CRM_SG_ChangeParentOutletHandler
 * Description: Update child outlets when change the parent outlet
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/04/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_SG_ChangeParentOutletHandler extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_ChangeParentOutletHandler() {
        super('ASI_CRM_SG_ChangeParentOutletHandler');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c >) newMap;
        Map<Id, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap;
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> filteredCustomerMap = filterCustomer(customerMap, oldCustomerMap);
        if(filteredCustomerMap != null) updateChildOutletType(filteredCustomerMap);

        updateGPSInfo(customerMap, oldCustomerMap);
    }
    
// customer gps module integration
    private void updateGPSInfo(Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap, Map<Id, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap)
    {
        if (customerMap == null)
        {
            return;
        }

        for (ASI_CRM_AccountsAdditionalField__c customer : customerMap.values())
        {
            ASI_CRM_AccountsAdditionalField__c oldCustomer = oldCustomerMap != null ? oldCustomerMap.get(customer.Id) : null;

            if (customer.ASI_CRM_MY_GeoConverStatus__c != 'Pending' && customer.ASI_CRM_JP_Address__c != null && (oldCustomer == null || customer.ASI_CRM_CN_GPS_info__Latitude__s == null || customer.ASI_CRM_JP_Address__c != oldCustomer.ASI_CRM_JP_Address__c))
            {
                customer.ASI_CRM_MY_GeoConverStatus__c = 'Pending';
            }
        }
    }

    private Map<Id, ASI_CRM_AccountsAdditionalField__c> filterCustomer(Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap, Map<Id, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap) {
    	if(oldCustomerMap == null) return customerMap;
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> filteredCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerMap.values()) {
            if(customer.ASI_CRM_CN_Parent_Outlet__c != oldCustomerMap.get(customer.Id).ASI_CRM_CN_Parent_Outlet__c && 
               String.isNotBlank(customer.ASI_CRM_CN_Parent_Outlet__c)) 
                filteredCustomerMap.put(customer.Id, customer);
        }
        
        return filteredCustomerMap;
    }

    private void updateChildOutletType(Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap) {
        Set<Id> parentOutletIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerMap.values()) {
            if(String.isNotBlank(customer.ASI_CRM_CN_Parent_Outlet__c)) 
                parentOutletIdSet.add(customer.ASI_CRM_CN_Parent_Outlet__c);
        }
        
       	Map<Id, ASI_CRM_AccountsAdditionalField__c> parentCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList(parentOutletIdSet));
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerMap.values()) {
            if(String.isNotBlank(customer.ASI_CRM_CN_Parent_Outlet__c))
            	customer.ASI_CRM_Outlet_Type__c = parentCustomerMap.get(customer.ASI_CRM_CN_Parent_Outlet__c).ASI_CRM_Outlet_Type__c;
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private static List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT Id, ASI_CRM_Outlet_Type__c  '
                     + 'FROM ASI_CRM_AccountsAdditionalField__c '
                     + 'WHERE Id in :customerIdSet ';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
}