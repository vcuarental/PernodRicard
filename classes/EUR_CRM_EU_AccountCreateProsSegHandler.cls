public without sharing class EUR_CRM_EU_AccountCreateProsSegHandler {
    
    public static boolean nonrecursiveAiAu=false ;
    public static Set<Id> proccessedAccounts = new Set<Id>();
   // static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.EUR_CRM_Pros_Segmentation__c;
   // static Map<String,Schema.RecordTypeInfo> ProsRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    
    public void createProsSegRecord(List<EUR_CRM_Account__c> EUAccountList){
        List<EUR_CRM_Pros_Segmentation__c> prosSegList = new List<EUR_CRM_Pros_Segmentation__c>();
        
        Set<Id> euAccIds = new Set<Id>();
        
        for (EUR_CRM_Account__c euAcc : EUAccountList){
              euAccIds.add(euAcc.id);     
        }
        
        Map<Id,EUR_CRM_Pros_Segmentation__c> euAccProsMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>();
        
        for(EUR_CRM_Pros_Segmentation__c pros: [select id, EUR_CRM_Account__c from EUR_CRM_Pros_Segmentation__c where EUR_CRM_Account__c in: euAccIds and EUR_CRM_Country_Code__c <> 'PRT']){
            euAccProsMap.put(pros.EUR_CRM_Account__c, pros);
        }
        
        for (EUR_CRM_Account__c euAcc : EUAccountList){             
             if ( !proccessedAccounts.contains(euAcc.id)  &&  euAccProsMap.get(euAcc.id)== null){
                 
                EUR_CRM_Pros_Segmentation__c ps = new EUR_CRM_Pros_Segmentation__c();
                ps.EUR_CRM_Account__c = euAcc.Id;
                ps.RecordTypeId = EUR_CRM_RecordTypeHelper.getAccountCreateProsSegHandler_RecordTypeId(euAcc.EUR_CRM_Country_Code__c);
                
                if(ps.RecordTypeId != null){
                    prosSegList.add(ps);       
                }
                 
                system.debug('prosSegList' + prosSegList.size());
                system.debug('prosSegList' + prosSegList);
            }
            proccessedAccounts.add(euAcc.Id);          
        }
        if (prosSegList.size() > 0){
            insert prosSegList;
        }
    }
    
}