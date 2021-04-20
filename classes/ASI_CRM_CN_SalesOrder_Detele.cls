@RestResource(UrlMapping='/ASI_CRM_CN_SalesOrder_Detele/*')
Global Without Sharing class ASI_CRM_CN_SalesOrder_Detele {

    global Class salesOrderClass{
        global list <salesOrderStructure> salesOrderlist{set;get;}    
    }
    
    /*
     *{"jsonString":"{\"salesOrderlist\":[{\"recordID\":\"a6mM0000000Dm44\"}]}"}
     */
    
    @HttpPost
    Global Static String DeleteSalesOrder(String jsonString){
        
        salesOrderClass salesOrder = (salesOrderClass)JSON.deserialize(jsonString, salesOrderClass.class);
        List<ASI_KOR_Sales_Order_Request__c> DeleteSOList = new List<ASI_KOR_Sales_Order_Request__c>();
        
        for(salesOrderStructure obj : salesOrder.salesOrderlist){
            
            ASI_KOR_Sales_Order_Request__c tempSO = new ASI_KOR_Sales_Order_Request__c();
            
            if(obj.recordID != '' && obj.recordID != NULL){

                tempSO.Id = obj.recordID;
            }
            
            DeleteSOList.add(tempSO);
        }
        
        try{
            Delete DeleteSOList;
            
        }catch(dmlException dmle){
            
            return dmle.getMessage();
        }
        
        Return 'Success';
    }
    
    global Class salesOrderStructure{
        
        Global String recordID{Set; Get;}
        
    }
}