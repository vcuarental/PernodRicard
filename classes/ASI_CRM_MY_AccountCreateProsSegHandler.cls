/*********************************************************************************
 * Name:ASI_CRM_AccountCreateProsSegHandler
 * Description: Customer Trigger Handler for CRM MY
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/1/2018       Introv Limited           Created
*********************************************************************************/

public with sharing class ASI_CRM_MY_AccountCreateProsSegHandler {
    
    public static boolean nonrecursiveAiAu=false ;
    
   // static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.EUR_CRM_Pros_Segmentation__c;
   // static Map<String,Schema.RecordTypeInfo> ProsRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    
    public static void createProsSegRecord(List<ASI_CRM_AccountsAdditionalField__c> ASIAccountList){
            List<Recordtype> accRecordTypes = Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c');
            Map<String,Id> accRecordTypesMap = new Map<String,Id>();
            
            for(Recordtype rt : accRecordTypes ){
               accRecordTypesMap.put(rt.developername, rt.id);
            }
            
            List<ASI_CRM_Pros_Segmentation__c> prosSegList = new List<ASI_CRM_Pros_Segmentation__c>();

            for (ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){             
                if(asAcc.recordTypeId == accRecordTypesMap.get('ASI_CRM_MY_Outlet') ){
                    ASI_CRM_Pros_Segmentation__c ps = new ASI_CRM_Pros_Segmentation__c();
                    ps.ASI_CRM_SG_Customer__c = asAcc.Id;
                    ps.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_MY_PROS_Segmentation');
                    prosSegList.add(ps);                        
                    system.debug('prosSegList' + prosSegList);
                }
            }
            system.debug('prosSegList' + prosSegList.size());         
        
            if (prosSegList.size() > 0){
                insert prosSegList;
            } 
    }
    
}