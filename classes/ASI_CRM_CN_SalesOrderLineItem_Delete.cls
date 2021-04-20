@RestResource(UrlMapping='/ASI_CRM_CN_SalesOrderLineItem_Delete/*')
Global Without Sharing class ASI_CRM_CN_SalesOrderLineItem_Delete {

    global Class salesOrderLineItemClass{
        global list <salesOrderLineItemStructure> salesOrderLIlist{set;get;}    
    }
    
    /*
     *{"jsonString":"{\"salesOrderLIlist\":[{\"recordID\":\"a6nM00000000GkP\"}]}"} 
     */
    
    @HttpPost
    Global Static String deleteSalesOrderLI(String jsonString){
        
        salesOrderLineItemClass salesOrderLI = (salesOrderLineItemClass)JSON.deserialize(jsonString, salesOrderLineItemClass.class);
        List<ASI_KOR_Sales_Order_Transaction__c> DeleteSOLIList = new List<ASI_KOR_Sales_Order_Transaction__c>();
        
        for(salesOrderLineItemStructure obj : salesOrderLI.salesOrderLIlist){
            
            ASI_KOR_Sales_Order_Transaction__c tempSOLI = new ASI_KOR_Sales_Order_Transaction__c();
            
            if(obj.recordID != '' && obj.recordID != NULL){
                
                tempSOLI.Id = obj.recordID;
            }
            
            DeleteSOLIList.add(tempSOLI);
        }
        
        try{
            Delete DeleteSOLIList;
            
        }catch(dmlException dmle){
            
            return dmle.getMessage();
        }
        
        Return 'Success';
    }
    
    global Class salesOrderLineItemStructure{
        
        Global String recordID{Set; Get;}
        
    }
}