/*********************************************************************************
 * Name:ASI_CRM_TH_AccountCreateProsSegHandler
 * Description: Customer Trigger Handler for CRM TH
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_AccountCreateProsSegHandler
*********************************************************************************/

public with sharing class ASI_CRM_TH_AccountCreateProsSegHandler {
   
    public static boolean nonrecursiveAiAu=false ;
    
    public void createProsSegRecord(List<ASI_CRM_AccountsAdditionalField__c> ASIAccountList){
        List<Recordtype> accRecordTypes = Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c');
        Map<String,Id> accRecordTypesMap = new Map<String,Id>();
        Set<Id> setCustID = new Set<Id>();
        Set<Id> setCustwithProsSeg = new Set<Id>();
        Map<id, ASI_CRM_AccountsAdditionalField__c> mapCust = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_AccountsAdditionalField__c> listCust = new List<ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_Pros_Segmentation__c> listExistProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
        List<ASI_CRM_Pros_Segmentation__c> prosSegList = new List<ASI_CRM_Pros_Segmentation__c>();
        
        for(Recordtype rt : accRecordTypes ){
           accRecordTypesMap.put(rt.developername,rt.id);
        }
        
        for(ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){
            setCustID.add(asAcc.id);
        }
        
        listExistProsSeg = [SELECT id, ASI_CRM_SG_Customer__c FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c IN :setCustID];
        for(ASI_CRM_Pros_Segmentation__c ps : listExistProsSeg){
            setCustwithProsSeg.add(ps.ASI_CRM_SG_Customer__c);
        }
        
        listCust = [SELECT id, ASI_TH_CRM_OutletType__r.ASI_CRM_Group_Outlet_Type__c, ASI_CRM_AccountAdditionalField_EXID__c 
                    FROM ASI_CRM_AccountsAdditionalField__c WHERE id IN:setCustID];
        for(ASI_CRM_AccountsAdditionalField__c cust : listCust){
            mapCust.put(cust.id, cust);
        }        
        
        for (ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){    
            if(!setCustwithProsSeg.contains(asAcc.id)){                         
                ASI_CRM_Pros_Segmentation__c ps = new ASI_CRM_Pros_Segmentation__c();
                ps.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_TH_Pros_Segmentation');
                ps.ASI_CRM_SG_Customer__c = asAcc.Id;    
                ps.ASI_CRM_SG_Account__c = asAcc.ASI_CRM_Account__c;  
                ps.ASI_CRM_SG_Group_Outlet_Type__c = mapCust.get(asAcc.id).ASI_TH_CRM_OutletType__r.ASI_CRM_Group_Outlet_Type__c;   
                
                if(asAcc.ASI_CRM_AccountAdditionalField_EXID__c != null)
                    ps.ASI_CRM_External_ID__c = asAcc.ASI_CRM_AccountAdditionalField_EXID__c;
                      
                prosSegList.add(ps);      
            }       
        }
                 
        if (prosSegList.size() > 0){
            insert prosSegList;
        } 
    }
    
}