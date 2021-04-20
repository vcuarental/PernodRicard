public class ASI_CRM_SG_SOR_Submit_lightCtrl {
    @AuraEnabled
    
    public static String getRecord(Id recordId){
        try{
            List<ASI_KOR_Sales_Order_Transaction__c> transactionList = [Select Id from ASI_KOR_Sales_Order_Transaction__c where ASI_KOR_Sales_Order_Request__c = :recordId];
            if(transactionList != null && transactionList.size()>0){
                ASI_KOR_Sales_Order_Request__c sor = [Select Id,RecordType.Name,ASI_CRM_SG_Order_Date__c ,ASI_CRM_Expected_Delivery_Date__c ,
                                                      ASI_KOR_Order_Status__c from ASI_KOR_Sales_Order_Request__c where Id = :recordId];
                if(sor.RecordType.Name == 'ASI CRM SG Wholesaler Sales Order' && (sor.ASI_CRM_SG_Order_Date__c < date.today()
                                                                                  || sor.ASI_CRM_Expected_Delivery_Date__c < date.today() || sor.ASI_CRM_Expected_Delivery_Date__c < sor.ASI_CRM_SG_Order_Date__c)){
                                                                                      return 'No back Order Date / Expected Delivery Date is allowed.';                                                        
                                                                                  }else if(sor.ASI_KOR_Order_Status__c == 'Draft' || sor.ASI_KOR_Order_Status__c == 'Rejected' || sor.ASI_KOR_Order_Status__c == 'New'){
                                                                                      if(sor.RecordType.Name == 'ASI CRM SG Wholesaler Sales Order'){
                                                                                          update new ASI_KOR_Sales_Order_Request__c(Id= sor.Id, ASI_CRM_Sys_Allow_Submit_Approval__c = true);
                                                                                      }
                                                                                      return 'Success';
                                                                                  }else{
                                                                                      return null;
                                                                                  }
            }else{
                return 'No Sales Order Request lines! You cannot submit for approval';
            }
        }catch(Exception e){
            return e.getMessage();
        }
    } 
}