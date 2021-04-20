@RestResource(UrlMapping='/ASI_CRM_CN_SalesOrderLineItem_Upsert/*')
Global Without Sharing class ASI_CRM_CN_SalesOrderLineItem_Upsert {

    global Class salesOrderLineItemClass{
        global list <salesOrderLineItemStructure> salesOrderLIlist{set;get;}    
    }
    
    /*
     *{"jsonString":"{\"salesOrderLIlist\":[{\"recordID\":\"\",\"SOHeader\":\"a6mM0000000Dm44\",\"OrderQty\":\"100\",\"recordTypeID\":\"012M00000000kAj\",\"itemGroup\":\"a7GM00000008SawMAE\",\"UOM\":\"CA\"}]}"} 
     */
    
    @HttpPost
    Global Static String UpsertSalesOrderLI(String jsonString){
        
        salesOrderLineItemClass salesOrderLI = (salesOrderLineItemClass)JSON.deserialize(jsonString, salesOrderLineItemClass.class);
        List<ASI_KOR_Sales_Order_Transaction__c> insertSOLIList = new List<ASI_KOR_Sales_Order_Transaction__c>();
        
        for(salesOrderLineItemStructure obj : salesOrderLI.salesOrderLIlist){
            
            ASI_KOR_Sales_Order_Transaction__c tempSOLI = new ASI_KOR_Sales_Order_Transaction__c();
            
            if(obj.recordID != '' && obj.recordID != NULL){
                
                tempSOLI.Id = obj.recordID;
            }else{
                
                if(obj.recordTypeID != NULL && obj.recordTypeID != '' )
                    tempSOLI.RecordTypeId = obj.recordTypeID;
                
                if(obj.SOHeader != NULL && obj.SOHeader != ''){
                    
                    tempSOLI.ASI_KOR_Sales_Order_Request__c = obj.SOHeader;
                }
                
                tempSOLI.Id = NULL;
            }
            
            if(obj.itemGroup != NULL && obj.itemGroup != ''){
                tempSOLI.ASI_CRM_CN_Product_Name__c = obj.itemGroup;
            }
            
            tempSOLI.ASI_KOR_Order_Qty__c = obj.OrderQty;
            
            tempSOLI.ASI_CRM_UOM_Text__c = obj.UOM;
            
            insertSOLIList.add(tempSOLI);
        }
        
        try{
            Upsert insertSOLIList;
            
        }catch(dmlException dmle){
            
            return dmle.getMessage();
        }
        
        Return 'Success';
    }
    
    global Class salesOrderLineItemStructure{
        
        Global String recordTypeID{Set; Get;}
        Global String recordID{Set; Get;}
        Global String SOHeader{Set; Get;}
        Global Integer OrderQty{Set; Get;}
        Global String UOM{Set; Get;}
        Global String itemGroup{Set; Get;}
        
    }
}