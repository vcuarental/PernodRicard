/*********************************************************************************
 * Name: ASI_CRM_JP_BillToAutoNumber
 * Description: Assign the bill to name by format {YY}{000000}-{Bill To Customer Name}
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_BillToAutoNumber extends ASI_CRM_JP_TriggerAbstract {
    
	private static final String BILL_TO_AUTO_NUMBER = 'ASI_CRM_JP_BillToName';
    
    public ASI_CRM_JP_BillToAutoNumber() {
        super('ASI_CRM_JP_BillToAutoNumber');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_Bill_To__c> billToList = (List<ASI_CRM_Bill_To__c>) sObjList;
        
        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_Bill_To__c billTo : billToList) {
            customerIdSet.add(billTo.ASI_CRM_Bill_To_Customer__c);
        }
        
       	Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c> (retrieveCustomerList(customerIdSet));
        
        for(ASI_CRM_Bill_To__c billTo : billToList) {
           	billTo.Name =  customerMap.get(billTo.ASI_CRM_Bill_To_Customer__c).Name;
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
    	String query = 'SELECT Id, Name ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE Id in :customerIdSet ';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
}