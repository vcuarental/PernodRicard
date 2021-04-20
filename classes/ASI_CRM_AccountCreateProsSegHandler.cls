/*********************************************************************************
 * Name:ASI_CRM_AccountCreateProsSegHandler
 * Description: Customer Trigger Handler for CRM SG
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/11/2014       Laputa: Alvin           Created
*********************************************************************************/

public with sharing class ASI_CRM_AccountCreateProsSegHandler {
    
    public static boolean nonrecursiveAiAu=false ;
    public static Set<Id> proccessedAccounts = new Set<Id>();
   // static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.EUR_CRM_Pros_Segmentation__c;
   // static Map<String,Schema.RecordTypeInfo> ProsRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    
    public void createProsSegRecord(List<ASI_CRM_AccountsAdditionalField__c> ASIAccountList){
            List<Recordtype> accRecordTypes = Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c');
            Map<String,Id> accRecordTypesMap = new Map<String,Id>();
            
            for(Recordtype rt : accRecordTypes ){
               accRecordTypesMap.put(rt.developername,rt.id);
            }
            
            List<ASI_CRM_Pros_Segmentation__c> prosSegList = new List<ASI_CRM_Pros_Segmentation__c>();

            for (ASI_CRM_AccountsAdditionalField__c asAcc : ASIAccountList){             
                     
                     ASI_CRM_Pros_Segmentation__c ps = new ASI_CRM_Pros_Segmentation__c();
                     ps.ASI_CRM_SG_Customer__c = asAcc.Id;
                     ps.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_SG_PROS_Segmentation');
                     
                     if(asAcc.recordTypeId == accRecordTypesMap.get('ASI_CRM_SG_Potential_Outlet') || asAcc.recordTypeId == accRecordTypesMap.get('ASI_CRM_SG_Outlet') || asAcc.recordTypeId == accRecordTypesMap.get('ASI_CRM_SG_Wholesaler') ){
                        prosSegList.add(ps);                        
                        system.debug('prosSegList' + prosSegList.size());
                        system.debug('prosSegList' + prosSegList);
                     }
                                               
                    proccessedAccounts.add(asAcc.Id); 
            }
                     
            if (prosSegList.size() > 0){
                insert prosSegList;
            } 
    }
    
}