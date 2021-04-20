global without sharing class ASI_CRM_CN_IGCPUpdate_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Date todayDate = date.today();
        Date todayDate2 = date.today().addDays(-183);//20180809 Introv
        String soqlQuery = 'SELECT id, ASI_CRM_New_Price_BT_with_VAT__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c, ASI_CRM_Promotion_Code__c, ASI_CRM_Item_Group_Description__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c, ASI_CRM_Price_And_Discount__c,ASI_CRM_Price_And_Discount__r.RecordType.Name FROM ASI_CRM_Price_And_Discount_Detail__c WHERE ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c <=: todayDate AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >=: todayDate2 AND ( ASI_CRM_Price_And_Discount__r.recordType.DeveloperName = \'ASI_CRM_CN_Customer_Price_and_Discount_Request\' OR ASI_CRM_Price_And_Discount__r.recordType.DeveloperName = \'ASI_CRM_CN_Customer_Price_and_Discount_Request_RO\' OR ASI_CRM_Price_And_Discount__r.recordType.DeveloperName LIKE \'ASI_CTY_CN_WS_Customer_Price_and_Discount_Request%\' ) AND ( ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = \'Approved\' OR ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = \'Completed\' ) AND recordType.DeveloperName = \'ASI_CRM_CN_Price_And_Discount_Detail\' ORDER BY ASI_CRM_Price_And_Discount__r.ASI_CRM_Approved_Date__c desc';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        Map<String, ASI_CRM_Price_And_Discount_Detail__c> mapPrice = new Map<String, ASI_CRM_Price_And_Discount_Detail__c>();
        Set<Id> itemGroupSet = new Set<Id>();//20171211 Introv
        Set<Id> customerSetId = new Set<Id>();
        
        List<ASI_CRM_Price_And_Discount_Detail__c> pndDetail = (List<ASI_CRM_Price_And_Discount_Detail__c>) scope;
            
            for(ASI_CRM_Price_And_Discount_Detail__c detailObj : pndDetail){
                
                itemGroupSet.add(detailObj.ASI_CRM_Item_Group_Description__c);//20171211 Introv
                
                customerSetId.add(detailObj.ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c);
                if(!mapPrice.containsKey(detailObj.ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c + '' + detailObj.ASI_CRM_Item_Group_Description__c))
                    mapPrice.put(detailObj.ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c + '' + detailObj.ASI_CRM_Item_Group_Description__c, detailObj);
            }
        
        List<ASI_CRM_Item_Group_Customer_Price__c> igcpList = new List<ASI_CRM_Item_Group_Customer_Price__c>([SELECT id
                                                                                                              , ASI_CRM_Customer__c
                                                                                                              , ASI_CRM_Item_Group__c
                                                                                                              , ASI_CRM_Promotion_Code__c//20161122 Elufa
                                                                                                              , ASI_CRM_Promotion_Expiration_Date__c//20161122 Elufa
                                                                                                              , ASI_CRM_Price_And_Discount__c//20161122 Elufa
                                                                                                              , ASI_CRM_Effective_Date_To__c//20161122 Elufa
                                                                                                              , ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c//20161122 Elufa
                                                                                                              , ASI_CTY_CN_WS_Trade_a_p_Discount__c //20200730 Alex-BLS
                                                                                                              , ASI_CTY_CN_WS_AD_Discount__c //20200730 Alex-BLS
                                                                                                              , ASI_CTY_CN_WS_Normal_Discount__c //20200730 Alex-BLS
                                                                                                              FROM ASI_CRM_Item_Group_Customer_Price__c
                                                                                                              WHERE ASI_CRM_Customer__c IN : customerSetId
                                                                                                              AND ASI_CRM_Item_Group__c IN : itemGroupSet//20171211 Introv
                                                                                                             ]);
        
        List<ASI_CRM_Item_Group_Customer_Price__c> igcpUpdateList = new List<ASI_CRM_Item_Group_Customer_Price__c>();
        
        for(ASI_CRM_Item_Group_Customer_Price__c obj : igcpList){
            if(mapPrice.containsKey(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c)){
                //20161122 Elufa
                if(mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Promotion_Code__c !=  obj.ASI_CRM_Promotion_Code__c 
                   || (obj.ASI_CRM_Promotion_Code__c != Null && (mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c !=  obj.ASI_CRM_Promotion_Expiration_Date__c
                                                                 || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c !=  obj.ASI_CRM_Price_And_Discount__c
                                                                )
                      )
                   || (obj.ASI_CRM_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c && ( mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c !=  obj.ASI_CRM_Effective_Date_To__c 
                                                                                || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c !=  obj.ASI_CRM_Promotion_Expiration_Date__c
                                                                               )
                      )
                   || (mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) && 
                        (obj.ASI_CTY_CN_WS_Trade_a_p_Discount__c == null || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c !=  obj.ASI_CTY_CN_WS_Trade_a_p_Discount__c 
                          || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c != obj.ASI_CRM_Effective_Date_To__c )
                      ) 
                   || (mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) && 
                        (obj.ASI_CTY_CN_WS_Normal_Discount__c == null || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c !=  obj.ASI_CTY_CN_WS_Normal_Discount__c 
                          || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c != obj.ASI_CRM_Effective_Date_To__c )
                      ) 
                   || (mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD) && 
                        (obj.ASI_CTY_CN_WS_AD_Discount__c == null || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__c !=  obj.ASI_CTY_CN_WS_AD_Discount__c 
                          || mapPrice.get(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c).ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c != obj.ASI_CRM_Effective_Date_To__c )
                      ) 
                  ){
                      igcpUpdateList.add(obj);
                  }
            }
        }
        update igcpUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        
        //20180710 Introv, execute receipt generation logic after Item group customer price batch job since there are too much schedule job in Production
        database.executebatch(new ASI_MFM_CN_ReceiptGeneration_Batch());
    }
}