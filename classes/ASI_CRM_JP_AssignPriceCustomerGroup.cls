/*********************************************************************************
 * Name : ASI_CRM_JP_AssignPriceCustomerGroup
 * Test Class: ASI_CRM_JP_ItemPrice_Test
 * Description : Auto assign the customer group id to price record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/03/2017       Hugo Cheung             Created          
 * 30/03/2020       Wilken Lee              [WL 1.0] Add "Customer Group not found" validation
*/
public class ASI_CRM_JP_AssignPriceCustomerGroup extends ASI_CRM_JP_TriggerAbstract {
    public ASI_CRM_JP_AssignPriceCustomerGroup() {
    super('ASI_CRM_JP_AssignCustomProductPriceName');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Customer_Product_Price__c> priceList = (List<ASI_CRM_JP_Customer_Product_Price__c>) sObjList;
        
        Set<String> customerGroupNameSet = new Set<String>();
        for(ASI_CRM_JP_Customer_Product_Price__c price : priceList) {
            if(String.isNotBlank(price.ASI_CRM_JP_Customer_Group_Name__c)) {
              customerGroupNameSet.add(price.ASI_CRM_JP_Customer_Group_Name__c);
            }
        }
        
        Map<String, Id> customerGroupNameMap = retrieveCustomerGroupNameMap(customerGroupNameSet);
        
        for(ASI_CRM_JP_Customer_Product_Price__c price : priceList) {
            if(String.isNotBlank(price.ASI_CRM_JP_Customer_Group_Name__c)){  
               if(customerGroupNameMap.containsKey(price.ASI_CRM_JP_Customer_Group_Name__c)) {
                   price.ASI_CRM_Customer_Group__c = customerGroupNameMap.get(price.ASI_CRM_JP_Customer_Group_Name__c);
               }
               else{    
                   price.addError('Customer Group not found'); //WL 1.0
               }
            }
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private Map<String, Id> retrieveCustomerGroupNameMap(Set<String> customerGroupNameSet) {
      String query = 'SELECT Id, Name' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Customer_Group__c ' + 
                       'Where Name in :customerGroupNameSet';
            
        List<ASI_CRM_Customer_Group__c> customerGroupList = (List<ASI_CRM_Customer_Group__c>) Database.query(query);
        Map<String, Id> customerGroupNameMap = new Map<String, Id>();
        for(ASI_CRM_Customer_Group__c customerGroup : customerGroupList) {
          customerGroupNameMap.put(customerGroup.Name, customerGroup.Id);
        }
        return customerGroupNameMap;
  }
}