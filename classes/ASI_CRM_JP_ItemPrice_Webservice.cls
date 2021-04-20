/*
 *********************************************************************************
 * Name: ASI_CRM_JP_ItemPrice_Webservice
 * Description: 
 * Related Test Class: ASI_CRM_JP_ItemPrice_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/04/2019       Wilken Lee              [WL 1.0] Use user uploaded RSP to update to Magento, if blank, uses Item Group RSP.
 */
global class ASI_CRM_JP_ItemPrice_Webservice {

    global ASI_CRM_JP_ItemPrice_Webservice(){
        
    }
    
    global class ItemPrice{
        webservice String SKUCode {get;set;}
        webservice Decimal RSP {get;set;}        
        webservice String ItemPriceId {get;set;}
        webservice List<CustGroupPrice> CustGroupPriceList {get;set;}
    }
    
    global class CustGroupPrice{
        webservice String CustGroup {get;set;}
        webservice Decimal ItemPrice {get;set;}
    }
    
    global class ItemPriceList{
        webservice List<ItemPrice> ItemPriceList {get;set;}
    }
    
    
    webservice static ItemPriceList getPriceList (String sys_date){
        System.debug('Start getting Item Price');
        ItemPriceList result = new ItemPriceList();
        List<ItemPrice> resultList = new List<ItemPrice>();
        Map<id, ASI_CRM_JP_Customer_Product_Price__c> ItemGroupPriceMap = new Map<id, ASI_CRM_JP_Customer_Product_Price__c>();
        
        /*
        // For Testing only                
        List<ASI_CRM_JP_Customer_Product_Price__c> basePriceList = [Select id, ASI_CRM_Customer_Group__c , ASI_Bottle_Price__c , ASI_CRM_RSP__c, ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Group_RSP__c , ASI_CRM_Customer_Group__r.name from ASI_CRM_JP_Customer_Product_Price__c where (id='aG0M0000000CbI7KAK'or id='aG0M0000000CbJ0KAK' or id='aG0M0000000CbHxKAK' or id='aG0M0000000CbI2KAK') order by LastModifiedDate desc];
        System.debug(basePriceList);
        */
        
        system.debug('Sys Date: ' + sys_date);
        Date input_date = Test.isRunningTest() == true? System.today(): Date.parse(sys_date);   // format: MM/dd/yyyy   
        List<ASI_CRM_JP_Customer_Product_Price__c> basePriceList = [Select id, ASI_CRM_Customer_Group__c , ASI_Bottle_Price__c , ASI_CRM_RSP__c, ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Group_RSP__c, ASI_CRM_Customer_Group__r.name from ASI_CRM_JP_Customer_Product_Price__c where recordtype.name like '%D&C%' and ASI_CRM_JP_Active__c = true and (ASI_Effective_Date__c <= :input_date and (ASI_Expiry_Date__c >= :input_date or ASI_Expiry_Date__c = null)) order by LastModifiedDate desc];
        
        Set<id> ItemGroupList = new Set<id>();
        for(ASI_CRM_JP_Customer_Product_Price__c itmPrice :basePriceList){
            ItemGroupList.add(itmPrice.ASI_MFM_Item_Group__c);
        }
        
        Map<String, id> SKUItemGroupMap = new Map<String, id>();
        for(ASI_MFM_SKU_Code__c sku: [Select id, ASI_MFM_SKU_Code__c, ASI_MFM_Item_Group__c, ASI_MFM_JDE_Short_Item_Number__c from ASI_MFM_SKU_Code__c where recordtype.developerName ='ASI_CRM_JP_SKU' and ASI_HK_CRM_Active__c = true and ASI_MFM_Item_Group__c IN: ItemGroupList]){
            SKUItemGroupMap.put(sku.ASI_MFM_JDE_Short_Item_Number__c , sku.ASI_MFM_Item_Group__c);    
        }
              
        Map<String, ItemPrice> skuMap = new Map<String, ItemPrice>();
       
        for(ASI_CRM_JP_Customer_Product_Price__c itemPrice: basePriceList){
            if(itemPrice.ASI_CRM_Customer_Group__c != null){
                for(String sku: SKUItemGroupMap.keySet()){
                    if(SKUItemGroupMap.get(sku) == itemPrice.ASI_MFM_Item_Group__c){
                        if(skuMap.get(sku) ==  null){
                            /*[WL 1.0] BEGIN*/
                            Decimal rspToUpdate;
                            
                            if (itemPrice.ASI_CRM_RSP__c != null)
                                rspToUpdate = itemPrice.ASI_CRM_RSP__c;
                            else if (itemPrice.ASI_MFM_Item_Group__r.ASI_CRM_Group_RSP__c != null)
                                rspToUpdate = itemPrice.ASI_MFM_Item_Group__r.ASI_CRM_Group_RSP__c;                         
                            /*[WL 1.0] END*/
                            
                            ItemPrice temp = new ItemPrice();
                            temp.SKUCode = sku;
                            
                            //temp.RSP = itemPrice.ASI_MFM_Item_Group__r.ASI_CRM_Group_RSP__c ; //WL 1.0
                            temp.RSP = rspToUpdate; //WL 1.0
                            
                            temp.ItemPriceId = itemPrice.id + ';';
                            
                            CustGroupPrice cust = new CustGroupPrice();                    
                            cust.ItemPrice = itemPrice.ASI_Bottle_Price__c;
                            cust.CustGroup = itemPrice.ASI_CRM_Customer_Group__r.name;
                            List<CustGroupPrice> tempList = new List<CustGroupPrice>();
                            tempList.add(cust);
                            temp.CustGroupPriceList = tempList;
                            skuMap.put(sku, temp);
                            
                        }else {
                            ItemPrice temp = skuMap.get(sku);
                            Boolean isExist = false;
                            for(CustGroupPrice cust:temp.CustGroupPriceList){
                                if(cust.CustGroup == itemPrice.ASI_CRM_Customer_Group__r.name)
                                    isExist = true;                            
                            }
                            if(!isExist){
                                temp.ItemPriceId = temp.ItemPriceId + itemPrice.id + ';';
                                
                                CustGroupPrice cust = new CustGroupPrice();                    
                                cust.ItemPrice = itemPrice.ASI_Bottle_Price__c;
                                cust.CustGroup = itemPrice.ASI_CRM_Customer_Group__r.name;
                                List<CustGroupPrice> tempList = new List<CustGroupPrice>();
                                tempList = temp.CustGroupPriceList;
                                tempList.add(cust);
                                temp.CustGroupPriceList = tempList;
                            }
                            skuMap.put(sku, temp);
                        }
                    }
                }
            }
            
        }
               
        resultList = skuMap.values();
        result.ItemPriceList = resultList;
        return result;
    }

}