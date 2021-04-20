public class ASI_CRM_SG_Submit_to_PRS_WholesalerCtrl {
    @AuraEnabled
    public static wrapResult getRecord(Id recordId){
        wrapResult wrp =  new wrapResult();
        try {
            ASI_KOR_Sales_Order_Request__c sor = [Select Id,ASI_CRM_Over_Credit_Limit__c, RecordType.Name, ASI_CRM_SG_Customer_Number__c,ASI_CRM_SG_Customer__c,
                                                  ASI_CRM_SG_Order_Date__c,ASI_CRM_Less_Than_Min_Order_Amount__c,ASI_CRM_Expected_Delivery_Date__c from ASI_KOR_Sales_Order_Request__c where Id = :recordId];
            List<ASI_KOR_Sales_Order_Transaction__c> detailRecords = [Select Id from ASI_KOR_Sales_Order_Transaction__c where ASI_KOR_Sales_Order_Request__c = :recordId ];            
            System.debug('@#debuggg123'+sor);
           if (detailRecords == null || detailRecords.size() <= 0) {
                wrp.msg = 'Please input Sales Order Request lines';
                return wrp;
            }
            // 20160711 add back date alert
            else if (sor.ASI_CRM_SG_Order_Date__c < date.TODAY() 
                     || sor.ASI_CRM_Expected_Delivery_Date__c < date.TODAY() 
                     || sor.ASI_CRM_Expected_Delivery_Date__c < sor.ASI_CRM_SG_Order_Date__c){
                wrp.msg = 'No back Order Date / Expected Delivery Date is allowed';
                return wrp;
            }
            // 20180710 CHM118615758
            // 20190424 CHG0030280
            
            else if (sor.RecordType.Name == 'ASI CRM SG Wholesaler Sales Order' 
                     && sor.ASI_CRM_Less_Than_Min_Order_Amount__c == true
                     && sor.ASI_CRM_SG_Customer_Number__c != '31057') {
                         wrp.msg = 'Minimum order amount must be SGD 5,000 and above.';
                         return wrp;
                     }
            // 20161229 Delivery Date cannot be later than Order Date for more than 2 days
            // CHG0030231 Remove the validation
            /*else if ({!ASI_KOR_Sales_Order_Request__c.ASI_CRM_Expected_Delivery_Date__c - ASI_KOR_Sales_Order_Request__c.ASI_CRM_SG_Order_Date__c > 2}){
alert("Your expected delivery date is more than 2 days from your order date. Please contact your Sales Manager in charge");
} */
            else {
                DateTime now = dateTime.now();
                if((now.hour()== 13 && now.minute() >0 ) || now.hour()>13){
                    wrp.msg = 'reminder';
                }
                wrp.sor = sor;
                return wrp;
            }
        }
        catch(exception e) {
            wrp.msg = e.getMessage();          
            return wrp;
        }
    }
        
    @AuraEnabled
    public static String updateRecord(Boolean addNextDay, Id recordId){
        try{
            ASI_KOR_Sales_Order_Request__c sorObj = new ASI_KOR_Sales_Order_Request__c();
            sorObj.Id = recordId;
            if(addNextDay){
                sorObj.ASI_CRM_SG_Order_Date__c  = date.today().addDays(1);
            }
            sorObj.ASI_CRM_Email_to_PRS__c  = true;
            sorObj.ASI_CRM_Submit_to_PRS__c  = true;
            update sorObj;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
        public class wrapResult{
           @AuraEnabled  public string msg{get;set;}
           @AuraEnabled  public ASI_KOR_Sales_Order_Request__c sor {get;set;}            
        }
}