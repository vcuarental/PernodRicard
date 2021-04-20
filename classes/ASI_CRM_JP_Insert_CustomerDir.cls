/*********************************************************************************
 * Name:ASI_CRM_JP_Insert_CustomerDir
 * Description: Insert Customer Directory
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_Insert_CustomerDir extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_Insert_CustomerDir() {
        super('ASI_CRM_JP_Insert_CustomerDir');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        List<ASI_CRM_Customer_Directory__c> cusDirList = new List<ASI_CRM_Customer_Directory__c>();
        Map<ID,RecordType> rtMap = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'ASI_CRM_AccountsAdditionalField__c']);
        List<ASI_CRM_Customer_Directory__c> dirList = [Select Id, ASI_CRM_Chain_Type__c From ASI_CRM_Customer_Directory__c Where recordtypeid = : Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Directory__cASI_CRM_JP_Chain_Customer') AND (ASI_CRM_Chain_Type__c = 'MOT' OR ASI_CRM_Chain_Type__c = 'TOT' )];
        Map<String, Id> dirMap = new Map<String, Id>();
        for(ASI_CRM_Customer_Directory__c dir:dirList){
            dirMap.put(dir.ASI_CRM_Chain_Type__c, dir.Id);
        }
        if (oldMap == null) {
            for (ASI_CRM_AccountsAdditionalField__c customer : customerList) {
                //Create ASI_CRM_Customer_Directory__c
                ASI_CRM_Customer_Directory__c cusDir = new ASI_CRM_Customer_Directory__c();
                if(customer.OwnerId != null){
                    cusDir.OwnerId = customer.OwnerId;
                }
                cusDir.Name = customer.Name;
                cusDir.ASI_CRM_Customer_Code__c = customer.ASI_CRM_CN_CRM_Code__c;
                cusDir.ASI_CRM_Customer__c = customer.id;
                cusDir.ASI_CRM_Record_Type__c = rtMap.get(customer.recordtypeid).Name;
                if(Global_RecordTypeCache.getRt(customer.recordtypeId).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') && (customer.ASI_CRM_VN_Channel__c == 'MOT' || customer.ASI_CRM_VN_Channel__c == 'TOT')){
                    cusDir.ASI_CRM_Customer_Chain__c = dirMap.get(customer.ASI_CRM_VN_Channel__c);
                }
                for (RecordType rc : Global_RecordTypeCache.getRtList('ASI_CRM_Customer_Directory__c')){
                    if (rc.developerName == 'ASI_CRM_JP_Customer'){
                        cusDir.RecordTypeId = rc.id;
                    }
                }
                cusDirList.add(cusDir);
            }
            insert cusDirList;
        }
        Boolean havePending = false;
        for (ASI_CRM_AccountsAdditionalField__c customer : customerList) {
           if(customer.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                havePending = true;
                break;
            }     
        }
        
        if(havePending){
            ASI_CRM_JP_AccountAddressSched sch = new ASI_CRM_JP_AccountAddressSched();
            sch.executeBatch();    
        }
    }
    
}