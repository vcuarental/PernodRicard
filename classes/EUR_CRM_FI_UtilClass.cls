/**
Generic Utility Class for Finland CRM Project

History

apr.20.2015    created.
*/
public class EUR_CRM_FI_UtilClass{
    
    /**
        apr 20.2015-created
        retrieve all related account depending objective promo input
        filter example.
        recordType.developername => 'EUR_FI_On_Trade';
        returns all accounts. if no match found, returns an empty list.
        jul 24.2015
            commented out.
    */
    /*
    public static List<EUR_CRM_Account__c> retrieveOPAccounts(EUR_CRM_ObjPromo__c objPromo, Map<String,String> filters ){
        List<EUR_CRM_Account__c> euAccounts;
        
        if(objPromo == null)        
            return euAccounts;
        if(objPromo.EUR_CRM_Account_Selection_Type__c == 'PROS'){
            Set<String> images = new Set<String>();
            Set<String> outlets = new Set<String>();
            Set<String> combo = new Set<String>();
            for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c ps: [SELECT Id, Name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c WHERE EUR_CRM_ObjPromo__c = :objPromo.id]){
                 images.add(ps.EUR_CRM_Image_Level__c);
                 outlets.add(ps.EUR_CRM_Group_Outlet_Type__c);
                 combo.add(ps.EUR_CRM_Image_Level__c + ps.EUR_CRM_Group_Outlet_Type__c);
            }
            List<EUR_CRM_Account__c>  temp  = [select id,ownerid, owner.name,  name,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c   from EUR_CRM_Account__c where eur_crm_country_code__c = 'FI' and 
            EUR_CRM_Image_Level_Name__c in: images and EUR_CRM_Group_Outlet_Type_Name__c in:outlets];            
            euAccounts = new List<EUR_CRM_Account__c>();            
            for(EUR_CRM_Account__c e : temp){
                String k = e.EUR_CRM_Image_Level_Name__c  + e.EUR_CRM_Group_Outlet_Type_Name__c;
                if(combo.contains(k))
                    euAccounts.add(e);
            }           
            
        }else if(objPromo.EUR_CRM_Account_Selection_Type__c == 'Customer Taxonomy'){
            euAccounts = [select id,ownerid, owner.name,  name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in(select EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objPromo.id)];
        }
        return euAccounts  == null ? new List<EUR_CRM_Account__c>() :euAccounts;
    }
    */
    public static List<User> retrieveOwners(List<EUR_CRM_Account__c> euAccounts){
        Set<Id> userIds = new Set<Id>();
        for(EUR_CRM_Account__c euAccount : euAccounts){
              userIds.add(euAccount.ownerId);
        }
        return [select id, name from User where id in: userIds];
    }


    public static List<EUR_CRM_Account__c> retrieveOPAccounts(EUR_CRM_ObjPromo__c objPromo, Map<String,String> filters, String fieldName, String sortOrder ){
        List<EUR_CRM_Account__c> euAccounts;
        
        if(objPromo == null)        
            return euAccounts;
        if(objPromo.EUR_CRM_Account_Selection_Type__c == 'PROS'){
            Set<String> images = new Set<String>();
            Set<String> outlets = new Set<String>();
            Set<String> combo = new Set<String>();
            for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c ps: [SELECT Id, Name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c WHERE EUR_CRM_ObjPromo__c = :objPromo.id]){
                 images.add(ps.EUR_CRM_Image_Level__c);
                 outlets.add(ps.EUR_CRM_Group_Outlet_Type__c);
                 combo.add(ps.EUR_CRM_Image_Level__c + ps.EUR_CRM_Group_Outlet_Type__c);
            }
            
           // List<EUR_CRM_Account__c>  temp  = [select id,ownerid, owner.name,  name,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c   from EUR_CRM_Account__c where eur_crm_country_code__c = 'FI' and 
            //EUR_CRM_Image_Level_Name__c in: images and EUR_CRM_Group_Outlet_Type_Name__c in:outlets];
           
            String prosQuery = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c,  EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
            ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, EUR_CRM_Company_Establishment__c '  + 
            'from EUR_CRM_Account__C where eur_crm_country_code__c = \'FI\' and ' + 
            'EUR_CRM_Image_Level_Name__c in: images and EUR_CRM_Group_Outlet_Type_Name__c in:outlets';

            if(fieldName != null && sortOrder != null){
                prosQuery += ' ORDER BY ' + fieldName + ' ' + sortOrder;
            }

            List<EUR_CRM_Account__c>  temp = (List<EUR_CRM_Account__c>) Database.query(prosQuery);

            euAccounts = new List<EUR_CRM_Account__c>();            
            for(EUR_CRM_Account__c e : temp){
                String k = e.EUR_CRM_Image_Level_Name__c  + e.EUR_CRM_Group_Outlet_Type_Name__c;
                if(combo.contains(k))
                    euAccounts.add(e);
            }           
            
        }else if(objPromo.EUR_CRM_Account_Selection_Type__c == 'Customer Taxonomy'){
            Id opId = objPromo.id;
           // euAccounts = [select id,ownerid, owner.name,  name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in(select EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objPromo.id)];
        

            String cusTaxQuery = 'select id,ownerid,EUR_CRM_No_of_Active_Contracts__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, owner.name, EUR_CRM_Company_Establishment__c , EUR_CRM_City__c , name ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c  from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in(select EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: opId)';

            if(fieldName != null && sortOrder != null){
                cusTaxQuery += ' ORDER BY ' + fieldName + ' ' + sortOrder;
            }
            euAccounts = (List<EUR_CRM_Account__c>) Database.query(cusTaxQuery);
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
                                                        EUR_CRM_Profit_Btl__c,
                                                        EUR_CRM_Profit__c,
                                                        EUR_CRM_CM_NS__c,
                                                        EUR_CRM_Description__c,
                                                        EUR_CRM_Exclusive__c,
                                                        EUR_CRM_Name_Reference__c,
                                                        EUR_CRM_Quantity__c,
                                                        EUR_CRM_Volume_Btl__c,
                                                        EUR_CRM_Gross_SalesBtl__c,
                                                        EUR_CRM_Amount__c,
                                                        EUR_CRM_Amount_Spent__c,
                                                        EUR_CRM_Amount_Spent_Reference__c,
                                                        EUR_CRM_Unit__c,
                                                        EUR_CRM_SKU__c,
                                                        EUR_CRM_Brand__r.Name,
                                                        EUR_CRM_Brand_Quality__r.Name,
                                                        EUR_CRM_Brand_Quality_Size__r.Name,
                                                        EUR_CRM_SKU__r.Name,
                                                        EUR_CRM_Brand_Name__c,
                                                        EUR_CRM_SKU_Name__c,
                                                        EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c,
                                                        EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c,
                                                        EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c,
                                                        EUR_CRM_Brand_Quality__r.EUR_CRM_Gross_Sales_per_Liters__c,
                                                        EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c,
                                                        EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Gross_sales_Btl__c,
                                                        EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c,
                                                        EUR_CRM_SKU__r.EUR_CRM_Gross_sales_Btl__c,
                                                        EUR_CRM_Marketing_Amount__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                        EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c,
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
                
                //Set default values
                //cLineItem.EUR_CRM_Total_Value_Reference__c = cLineItem.EUR_CRM_Total_Value__c;
                //cLineItem.EUR_CRM_Mechanic_Name__c = (cLineItem.EUR_CRM_Contract_Mechanic__c!=null)?cLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.Name:null;
                
                cLineItemList.add(cLineItem);
                contractLineItems.put(key, cLineItemList);
            }
        }
        return contractLineItems;
    }

    public static String getThousandSep(){
        Decimal value = 1000.10;
        String formattedValue = value.format();
        return formattedValue.substring(1,2);  
    }

    public static String getDecimalSep(){
        Decimal value = 1000.10;
        String formattedValue = value.format(); 
        return formattedValue.substring(5,6); 
    }
}