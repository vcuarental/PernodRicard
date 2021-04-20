/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailUpdatePlan
 * Description: Update Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 1/12/2015       Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_ClaimsDetailUpdatePlan extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailUpdatePlan() {
        super('ASI_TnE_ClaimsDetailUpdatePlan');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> poIdSet = new Set<Id>();
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Payment_Amount__c != null && detail.ASI_TnE_CAP_Plan__c != null){
                    poIdSet.add(detail.ASI_TnE_CAP_Plan__c);
                }   
            }
        }else if(sObjList !=null){
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if((detail.ASI_TnE_Payment_Amount__c != null &&
                       detail.ASI_TnE_Payment_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_Payment_Amount__c) ||
                       (detail.ASI_TnE_CAP_Plan__c != null &&
                       detail.ASI_TnE_CAP_Plan__c != detailOldMap.get(detail.Id).ASI_TnE_CAP_Plan__c)){
                    poIdSet.add(detail.ASI_TnE_CAP_Plan__c);    
                }
                if(detail.ASI_TnE_CAP_Plan__c != detailOldMap.get(detail.Id).ASI_TnE_CAP_Plan__c && detail.ASI_TnE_CAP_Plan__c == null){
                    poIdSet.add(detailOldMap.get(detail.Id).ASI_TnE_CAP_Plan__c); 
                }
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailOldMap.values()){
                poIdSet.add(detail.ASI_TnE_CAP_Plan__c);
            }
        }
        
        List<ASI_MFM_Plan__c> poList = [Select ASI_MFM_TnE_Amount__c,RecordType.DeveloperName, (Select ASI_TnE_Payment_Amount__c,ASI_TnE_CAP_Plan__c,ASI_TnE_MFM_PO__c,RecordType.DeveloperName From Travel_Entertainment_Claims_Detail__r) From ASI_MFM_Plan__c Where Id In :poIdSet];
        
        for(ASI_MFM_Plan__c po:poList){
            po.ASI_MFM_TnE_Amount__c = 0;
            for(ASI_TnE_ClaimDetail__c detail:po.Travel_Entertainment_Claims_Detail__r){
                if(!(detail.RecordType.DeveloperName.contains('TnE_HK') && detail.ASI_TnE_CAP_Plan__c != null && detail.ASI_TnE_MFM_PO__c != null && po.RecordType.DeveloperName.contains('MFM_CAP_Plan'))){
                    po.ASI_MFM_TnE_Amount__c += detail.ASI_TnE_Payment_Amount__c;
                }
            }
        }
        
        update poList;
    }
}