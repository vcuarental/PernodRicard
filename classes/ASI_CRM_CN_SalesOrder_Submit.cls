@RestResource(UrlMapping='/ASI_CRM_CN_SalesOrder_Submit/*')
Global Without Sharing class ASI_CRM_CN_SalesOrder_Submit {

    global Class salesOrderClass{
        global list <salesOrderStructure> salesOrderlist{set;get;}    
    }
    
    /*
     *{"jsonString":"{\"salesOrderlist\":[{\"recordID\":\"a6mM000000013if\"}]}"}
     */
    
    @HttpPost
    Global Static String submitSalesOrder(String jsonString){
        
        salesOrderClass salesOrder = (salesOrderClass)JSON.deserialize(jsonString, salesOrderClass.class);
        Set<String> submitSOList = new Set<String>();
        
        for(salesOrderStructure obj : salesOrder.salesOrderlist){
            
            if(obj.recordID != '' && obj.recordID != NULL){

                submitSOList.add(obj.recordID);
            }
        }
        
        try{
            
            List<Approval.ProcessSubmitRequest> sr = new List<Approval.ProcessSubmitRequest>();
            
            for(String id : submitSOList){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(id);
                req1.setSubmitterId(UserInfo.getUserId());
                sr.add(req1);
                //Approval.ProcessResult result = Approval.process(req1);
            }
            
            List<Approval.ProcessResult> result = Approval.process(sr);
            
        }catch(dmlException dmle){
            
            return dmle.getMessage();
        }
        
        Return 'Success';
    }
    
    global Class salesOrderStructure{
        
        Global String recordID{Set; Get;}
        
    }
}