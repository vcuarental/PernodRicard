/*********************************************************************************
 * Name:ASI_LUX_Converted_Lux
 * Description: Cater recordtypes that has been converted to LUX
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_Converted_Lux extends ASI_HK_CRM_TriggerAbstract {

    public ASI_LUX_Converted_Lux() {
        super('ASI_LUX_Converted_Lux');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<Account> validAccountList = new List<Account>();
        Map<ID, Account> accOldMap= (Map<ID, Account>) oldmap;
        
        for(Account acc : (List<Account>)sObjList) {
            // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
            if(acc.recordtypeID != accOldMap.get(acc.id).recordtypeID) {
                validAccountList.add(acc);
            }
        }
        
        if(validAccountList.size() > 0) {
            
            Set<ID> accIdSet = new Set<ID>();
            Set<ID> ctntIDSet = new Set<ID>();
            
            for(Account acc : validAccountList) {
                accIDSet.add(acc.id);
                ctntIdSet.add(acc.PersonContactId);
            }
            
            List<ASI_HK_CRM_Sales_Order_History__c> soHistoryList = (List<ASI_HK_CRM_Sales_Order_History__c>)queryAll(accIDSet, 'ASI_HK_CRM_Sales_Order_History__c', 'ASI_HK_CRM_Account_PA__c','');
            List<CampaignMember> cmpMemberList = (List<CampaignMember>)queryAll(ctntIdSet, 'CampaignMember', 'contactid','');
            
            List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
              
            triggerClasses.add(new ASI_LUX_CalculateScoreTrigger());
  
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, soHistoryList, null, null);
            }
            
            triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
            triggerClasses.add(new ASI_LUX_CalculateSegmentationTrigger());
            
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, cmpMemberList, null, null);
            }
            
        }
        
    }
    
    private List<sObject> queryAll(Set<ID> filterIDSet, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' IN : filterIDSet ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }
    
}