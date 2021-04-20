/*********************************************************************************
 * Name:ASI_CRM_JP_UpdateCustomerDirAndAcc
 * Description: Update Customer Directory and Account when Customer name changes for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/12/2014       Laputa: Hank          Created
*********************************************************************************/

public without sharing class ASI_CRM_JP_UpdateCustomerDirAndAcc extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_UpdateCustomerDirAndAcc() {
        super('ASI_CRM_JP_UpdateCustomerDirAndAcc');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_AccountsAdditionalField__c> detailList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        Set<Id> customerIdSet = new Set<Id>();
        Set<Id> customerUdIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_AccountsAdditionalField__c detail : detailList) {
                
            }
        }
        else {
            Map<ID, ASI_CRM_AccountsAdditionalField__c> oldDetailMap = (Map<ID, ASI_CRM_AccountsAdditionalField__c>) oldMap;
            for (ASI_CRM_AccountsAdditionalField__c detail: detailList) {
                if (detail.Name != oldDetailMap.get(detail.id).Name || detail.recordtypeid != oldDetailMap.get(detail.id).recordtypeid || detail.ASI_CRM_CN_CRM_Code__c != oldDetailMap.get(detail.id).ASI_CRM_CN_CRM_Code__c ) {
                    customerIdSet.add(detail.Id);
                    accIdSet.add(detail.ASI_CRM_Account__c);
                    customerUdIdSet.add(detail.Id);
                }
            }
        }
        
        List<Account> accList = [Select Id, Name, ASI_KOR_Customer_Code__c From Account Where Id In :accIdSet];
        List<ASI_CRM_Customer_Directory__c> cusDirList = [Select Id, Name, ASI_CRM_Customer__c, ASI_CRM_Customer_Code__c, ASI_CRM_Record_Type__c From ASI_CRM_Customer_Directory__c Where ASI_CRM_Customer__c In :customerIdSet];
        List<ASI_CRM_AccountsAdditionalField__c> cusList = [Select Id From ASI_CRM_AccountsAdditionalField__c Where Id In :customerUdIdSet];
        Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select Id, Name From RecordType Where sobjecttype = 'ASI_CRM_AccountsAdditionalField__c']);
        
        if (oldMap == null) {
            for (ASI_CRM_AccountsAdditionalField__c detail : detailList) {
                
            }
        }
        else {
            Map<ID, ASI_CRM_AccountsAdditionalField__c> oldDetailMap = (Map<ID, ASI_CRM_AccountsAdditionalField__c>) oldMap;
            for (ASI_CRM_AccountsAdditionalField__c detail: detailList) {
                if (detail.Name != oldDetailMap.get(detail.id).Name || detail.recordtypeid != oldDetailMap.get(detail.id).recordtypeid || detail.ASI_CRM_CN_CRM_Code__c != oldDetailMap.get(detail.id).ASI_CRM_CN_CRM_Code__c ) {
                    for (Account a:accList) {
                        if (a.id == detail.ASI_CRM_Account__c) {
                            a.Name = detail.Name;
                            //a.ASI_KOR_Customer_Code__c = detail.ASI_CRM_CN_CRM_Code__c;
                        }
                    }
            
                    for (ASI_CRM_Customer_Directory__c dir:cusDirList) {
                        if (dir.ASI_CRM_Customer__c == detail.Id) {
                            dir.Name = detail.Name;
                            dir.ASI_CRM_Record_Type__c = rtMap.get(detail.recordtypeid).name;
                            dir.ASI_CRM_Customer_Code__c = detail.ASI_CRM_CN_CRM_Code__c;
                        }
                    }
            
                }
            }
        }
        
        Boolean havePending = false;
        for (ASI_CRM_AccountsAdditionalField__c detail : detailList) {
           if(detail.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                havePending = true;
                break;
            }     
        }
        
        if(havePending){
            ASI_CRM_JP_AccountAddressSched sch = new ASI_CRM_JP_AccountAddressSched();
            sch.executeBatch();    
        }
        
        
        update cusDirList;
        update accList;
        //update cusList;
    }
    
}