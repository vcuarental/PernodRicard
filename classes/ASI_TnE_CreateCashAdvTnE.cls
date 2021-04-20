/*********************************************************************************
 * Name:ASI_TnE_CreateCashAdvTnE
 * Description: Create TnE record when Cash Advance Pre-Approval is approved 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 16/12/2015        Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_TnE_CreateCashAdvTnE extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_CreateCashAdvTnE() {
        super('ASI_TnE_CreateCashAdvTnE');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_Cash_Advance_Pre_Approval__c> headerList = (List<ASI_TnE_Cash_Advance_Pre_Approval__c>)sObjList;
        if(oldMap == null){
        }else{
            Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c> oldClaimMap = (Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c>) oldMap;
            Map<Id, ASI_TnE_ClaimHeader__c> tneMap = new Map<Id, ASI_TnE_ClaimHeader__c>();
            Set<Id> headerIdSet = new Set<Id>();
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:headerList){
                if(header.ASI_TnE_Status__c == 'Approved' && header.ASI_TnE_Status__c != oldClaimMap.get(header.Id).ASI_TnE_Status__c){
                    ASI_TnE_ClaimHeader__c tne = new ASI_TnE_ClaimHeader__c();
                    tne.ownerid = header.ownerid;
                    tne.ASI_TnE_Type__c = 'Cash Advance';
                    tne.ASI_TnE_Currency__c = header.ASI_TnE_Required_Currency__c;
                    tne.ASI_TnE_Total_Amount_Approved__c = header.ASI_TnE_Required_Amount__c;
                    tne.ASI_TnE_FX_Rate__c = header.ASI_TnE_FX_Rate__c;
                    tne.ASI_TnE_Cash_Advance_Pre_Approval__c = header.Id;
                    tne.ASI_TnE_Payee_Employee__c = header.ASI_TnE_Requested_Employee__c;
                    tne.ASI_TnE_Remarks__c = header.ASI_TnE_Reason_for_Cash_Advance__c; //2016/05/09@IM58173
                    if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_SG')){
                        tne.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Cash_Advance_Header');
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TH')){
                        tne.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TH_Cash_Advance_Header');
                    }
                    tneMap.put(header.Id,tne); 
                    headerIdSet.add(header.Id);            
                }
            }
            List<ASI_TnE_Cash_Advance_Pre_Approval__c> newHeaderList = [Select Id,ASI_TnE_Claim_Header__c From ASI_TnE_Cash_Advance_Pre_Approval__c Where Id In:headerIdSet];
            if(tneMap.values().size() > 0){
                insert tneMap.values();
            }
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:newHeaderList){
                header.ASI_TnE_Claim_Header__c = tneMap.get(header.Id).Id;
            }
            if(newHeaderList.size() > 0){
                update newHeaderList;
            }
        }
    }
}