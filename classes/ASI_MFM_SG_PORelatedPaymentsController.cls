public class ASI_MFM_SG_PORelatedPaymentsController {
    
    
    public Class Payment{
        public Decimal ASI_MFM_Payment_Amount {get; set;}
        public String Name {get; set;}
        public String ASI_MFM_Supplier_Name {set;get;}
        public String ASI_MFM_PaymentOwner {set;get;}
        
        public String ASI_MFM_Currency {set;get;}
        public String ASI_MFM_Status {set;get;}
        public String PaymentId {set;get;}
    }
    
    public List<Payment> payments {get; set;}
    
    public ASI_MFM_SG_PORelatedPaymentsController(ApexPages.StandardController controller){
        
        Set<ID>paymentIDSet = new Set<ID>();  
        
        ASI_MFM_PO__c po = (ASI_MFM_PO__c) controller.getRecord();
        
        List<ASI_MFM_Payment_Line_Item__c> pyList =  [Select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_Payment_Amount__c,
                                                      ASI_MFM_Payment__r.id,ASI_MFM_Payment__r.Name,ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_Payment__r.ASI_MFM_Currency__c,
                                                      ASI_MFM_Payment__r.Owner.Name, ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment__r.ASI_MFM_Payment_Amount__c 
                                                      from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :po.Id];
        
        Map<ID,Payment> PaymentMap = new Map<ID,Payment>();
        
        for (ASI_MFM_Payment_Line_Item__c paymentLine :pyList){
            
            if(PaymentMap.containsKey(paymentLine.ASI_MFM_Payment__c)){
                PaymentMap.get(paymentLine.ASI_MFM_Payment__c).ASI_MFM_Payment_Amount=PaymentMap.get(paymentLine.ASI_MFM_Payment__c).ASI_MFM_Payment_Amount+paymentLine.ASI_MFM_Payment_Amount__c;
            }else{
                Payment tempay= new Payment();
                tempay.Name=paymentLine.ASI_MFM_Payment__r.Name;
                tempay.PaymentId=String.valueOf(paymentLine.ASI_MFM_Payment__c);
                tempay.ASI_MFM_Payment_Amount=paymentLine.ASI_MFM_Payment_Amount__c;
                tempay.ASI_MFM_Supplier_Name=paymentLine.ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name;
                tempay.ASI_MFM_PaymentOwner=paymentLine.ASI_MFM_Payment__r.Owner.Name;
                tempay.ASI_MFM_Status=paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c;
                tempay.ASI_MFM_Currency=paymentLine.ASI_MFM_Payment__r.ASI_MFM_Currency__c;
                PaymentMap.put(paymentLine.ASI_MFM_Payment__c,tempay );
            }//paymentIDSet.add(paymentLine.ASI_MFM_Payment__c);
            
        }//End of for loop
        payments= new List<Payment>();
        for(string k: PaymentMap.keySet()){
            payments.add(PaymentMap.get(k));
        }//payments = [select Name, ASI_MFM_Status__c, ASI_MFM_Currency__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id = :paymentIDSet];
        
    }
}