/*********************************************************************************
 * Name:ASI_CRM_TW_AccountCreateProsSegHandler
 * Description: Customer Trigger Handler for CRM TW
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/04/2015       Introv: Twinkle LI      Cloned from ASI_CRM_AccountCreateProsSegHandler
*********************************************************************************/

public with sharing class ASI_CRM_TW_AccountCreateProsSegHandler {
   
    public static boolean nonrecursiveAiAu=false ;
    
    public void createProsSegRecord(List<ASI_CRM_AccountsAdditionalField__c> ASIAccountList){
        List<Recordtype> accRecordTypes = Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c');
        Map<String,Id> accRecordTypesMap = new Map<String,Id>();
        Set<Id> setCustID = new Set<Id>();
        Map<id, ASI_CRM_AccountsAdditionalField__c> mapCust = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_AccountsAdditionalField__c> listCust = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        Boolean havePending = false;
        for(ASI_CRM_AccountsAdditionalField__c cust : ASIAccountList){
            if(cust.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                havePending = true;
                break;
            }
        }
        
        for(Recordtype rt : accRecordTypes ){
           accRecordTypesMap.put(rt.developername,rt.id);
        }
        
        for (ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){
            setCustID.add(asAcc.id);
        }
        
        
        listCust = [SELECT id, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Group_Outlet_Type__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id IN:setCustID];
        for (ASI_CRM_AccountsAdditionalField__c cust : listCust){
            mapCust.put(cust.id, cust);
        }        
        
        List<ASI_CRM_Pros_Segmentation__c> prosSegList = new List<ASI_CRM_Pros_Segmentation__c>();
        for (ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){                             
            ASI_CRM_Pros_Segmentation__c ps = new ASI_CRM_Pros_Segmentation__c();
            ps.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_TW_Pros_Segmentation'); 
            ps.ASI_CRM_SG_Customer__c = asAcc.Id;    
            ps.ASI_CRM_SG_Account__c = asAcc.ASI_CRM_Account__c;  
            ps.ASI_CRM_SG_Group_Outlet_Type__c = mapCust.get(asAcc.id).ASI_CRM_CN_Sub_Channel__r.ASI_CRM_Group_Outlet_Type__c;     
            prosSegList.add(ps);             
        }
                 
        if (prosSegList.size() > 0){
            insert prosSegList;
        } 
        
        if(havePending){
            ASI_CRM_TW_AccountAddressBatch batch = new ASI_CRM_TW_AccountAddressBatch();
            DataBase.executeBatch(batch, 20);
        }
    }
    
}