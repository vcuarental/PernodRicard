/**
Generic Utility Class for ZA CRM Project

History

aug.27.2015    created.
*/
public class EUR_CRM_ZA_UtilClass{
    
    
    public static List<User> retrieveOwners(List<EUR_CRM_Account__c> euAccounts){
        Set<Id> userIds = new Set<Id>();
        for(EUR_CRM_Account__c euAccount : euAccounts){
              userIds.add(euAccount.ownerId);
        }
        return [select id, name from User where id in: userIds];
    }


    public static List<EUR_CRM_Account__c> retrieveOPAccounts(EUR_CRM_ObjPromo__c objPromo, Map<String,String> filters, String fieldName, String sortOrder ){
        List<EUR_CRM_Account__c> euAccounts;
        
        if(objPromo == null) {
            return euAccounts;            
        }
            
        String prosQuery = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c,  EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
        ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, EUR_CRM_Company_Establishment__c '  + 
        'from EUR_CRM_Account__C where eur_crm_country_code__c = \'ZA\'';
            

        if(fieldName != null && sortOrder != null){
            prosQuery += ' ORDER BY ' + fieldName + ' ' + sortOrder;
        }

        List<EUR_CRM_Account__c>  temp = (List<EUR_CRM_Account__c>) Database.query(prosQuery);
        
        euAccounts = new List<EUR_CRM_Account__c>();            
        for(EUR_CRM_Account__c e : temp){
            String k = e.EUR_CRM_Image_Level_Name__c  + e.EUR_CRM_Group_Outlet_Type_Name__c;
            euAccounts.add(e);
        }           
            
        return euAccounts  == null ? new List<EUR_CRM_Account__c>() :euAccounts;
    }

    public static Map<Id, List<EUR_CRM_Contract_Product_Item__c>> retrieveContractProductLineItems(Id contractId){
        Set<Id> contractActivityItems = new Set<Id>();
        for(EUR_CRM_Contract_Activity_Item__c contractActivity : [SELECT Id FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c = :contractId]){
            contractActivityItems.add(contractActivity.Id);
        }

        System.debug('%%TESTIDS: '+contractActivityItems);

        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> contractLineItems = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();
        if (contractId != null && contractActivityItems.size() > 0){
            for(EUR_CRM_Contract_Product_Item__c cLineItem: [SELECT Id, Name,
                                                        EUR_CRM_Brand__c,
                                                        EUR_CRM_Brand_Quality__c,
                                                        EUR_CRM_Brand_Quality_Size__c,
                                                        EUR_CRM_Brand_Quality_Size_Name__c,
                                                        EUR_CRM_Contract_Activity_Item__c,
                                                        EUR_CRM_Description__c,
                                                        EUR_CRM_Exclusive__c,
                                                        EUR_CRM_Name_Reference__c,
                                                        EUR_CRM_Quantity__c,
                                                        EUR_CRM_Amount__c,
                                                        EUR_CRM_Amount_Spent__c,
                                                        EUR_CRM_Amount_Spent_Reference__c,
                                                        EUR_CRM_Unit__c,
                                                        EUR_CRM_SKU__c,
                                                        EUR_CRM_Discount_Rate__c,
                                                        EUR_CRM_Brand__r.Name,
                                                        EUR_CRM_Brand_Quality__r.Name,
                                                        EUR_CRM_Brand_Quality_Size__r.Name,
                                                        EUR_CRM_SKU__r.Name,
                                                        EUR_CRM_Brand_Name__c,
                                                        EUR_CRM_SKU_Name__c,
                                                        EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c,
                                                        EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c,
                                                        EUR_CRM_Brand_Quality__r.EUR_CRM_Cost_per_Bottle__c,
                                                        EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c,
                                                        EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c,
                                                        EUR_CRM_Marketing_Amount__c,
                                                        EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Qty_Buy__c,
                                                        EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Qty_Free__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic__r.Name,
                                                        EUR_CRM_Contract_activity_Item__r.EUR_CRM_Mechanic__r.EUR_CRM_Enable_Contract_Volume_Tracking__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Display_Order__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c
                                                        FROM EUR_CRM_Contract_Product_Item__c
                                                        WHERE EUR_CRM_Contract_Activity_Item__c IN :contractActivityItems
                                                        ORDER BY EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Display_Order__c
                                                        LIMIT 49999
                                                        ])
            {
                System.debug('%%TEST: '+cLineItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c);
                Id key = null;
                IF(cLineItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c!=null){
                    key = cLineItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c;
                }
                List<EUR_CRM_Contract_Product_Item__c> cLineItemList = (contractLineItems.containsKey(key))?contractLineItems.get(key):new List<EUR_CRM_Contract_Product_Item__c>();
                
                if (cLineItem.EUR_CRM_Brand_Quality_Size_Name__c == null){
                    cLineItem.EUR_CRM_Brand_Quality_Size_Name__c = cLineItem.EUR_CRM_Brand_Quality_Size__r.Name;
                }
                
                cLineItemList.add(cLineItem);
                contractLineItems.put(key, cLineItemList);
            }
        }
        System.debug('###CONTRACTLINEITEMS: '+contractLineItems);
        return contractLineItems;
    }

    public static Map<Id,EUR_CRM_Quality__c> retrieveBrandQualityItems(){
        
        Map<Id,EUR_CRM_Quality__c> bqItems = new Map<Id,EUR_CRM_Quality__c>();
            for(EUR_CRM_Quality__c bq: [SELECT Id, Name,
                                        EUR_CRM_Active__c,
                                        EUR_CRM_Brand__c,
                                        EUR_CRM_Enable_Account_Volume_Tracking__c,
                                        EUR_CRM_Contributive_Margin_BQ__c
                                        FROM EUR_CRM_Quality__c
                                        WHERE EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE
                                        ORDER BY Name
                                        LIMIT 49999
                                        ])
            {
                bqItems.put(bq.Id, bq);
            }
        return bqItems;
    }
    
    public static Map<Id,EUR_CRM_Size__c> retrieveBrandQualitySizeItems(){
        
        Map<Id,EUR_CRM_Size__c> bqsItems = new Map<Id,EUR_CRM_Size__c>();
            for(EUR_CRM_Size__c bqs: [SELECT Id, Name,
                                        EUR_CRM_Active__c,
                                        EUR_CRM_Brand__c,
                                        EUR_CRM_Enable_Account_Volume_Tracking__c,
                                        EUR_CRM_Contributive_Margin_BQS__c
                                        FROM EUR_CRM_Size__c
                                        WHERE EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE
                                        ORDER BY Name
                                        LIMIT 49999
                                        ])
            {
                bqsItems.put(bqs.Id, bqs);
            }
        return bqsItems;
    }
}