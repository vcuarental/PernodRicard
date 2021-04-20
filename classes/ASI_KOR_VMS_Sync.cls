public class ASI_KOR_VMS_Sync implements Database.Batchable<sObject>{

   final String Query;
   final Date InputDate;
   final String PromotionMonth;
   final Map<String,String> BranchCode;
   public String test {get;set;}
   

   public ASI_KOR_VMS_Sync(String q , Date d, String m, Map<String,String> b){

      Query=q; InputDate = d; PromotionMonth = m; BranchCode = b;
   }

   public Database.QueryLocator start(Database.BatchableContext BC){

      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){

        List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentDetails =
             (List<ASI_KOR_SR_Payment_Settlement_Detail__c>) scope;
        List<ASI_KOR_VMS_Interface_File__c> vmsInterface = 
             new List<ASI_KOR_VMS_Interface_File__c>();
             
       List<Account> tempAccount = new List<Account> ();      
       for(ASI_KOR_SR_Payment_Settlement_Detail__c paymentDetail : paymentDetails){
            Account temp = new Account();
            temp.ID = paymentDetail.ASI_KOR_Venue_Name__c;  
            tempAccount.add(temp);
       }  
             
       List<Account> Accts = 
           [Select 
               (Select ASI_KOR_Wholesaler_Code__c 
                From Venue_Suppliers__r
               ) ,               
               (Select ID 
                From ASI_KOR_SR_Payment_Settlement_Details__r 
                Where ID in :paymentDetails
               ) 
            From 
                Account
            Where 
                ID in :tempAccount
            ];
       
       tempAccount.clear();
       Map<String,String> detailSupplierMap = new Map<String,String>();
       for(Account acct : Accts){
           if(Acct.ASI_KOR_SR_Payment_Settlement_Details__r.size()>0){
               if(Acct.Venue_Suppliers__r.size()>0){
                   for(ASI_KOR_SR_Payment_Settlement_Detail__c temp : Acct.ASI_KOR_SR_Payment_Settlement_Details__r){
                       detailSupplierMap.put(temp.ID , Acct.Venue_Suppliers__r.get(0).ASI_KOR_Wholesaler_Code__c);
                   }
               }else{
                    for(ASI_KOR_SR_Payment_Settlement_Detail__c temp : Acct.ASI_KOR_SR_Payment_Settlement_Details__r){
                       detailSupplierMap.put(temp.ID ,'');
                   }
               }
           }
       }

       for(ASI_KOR_SR_Payment_Settlement_Detail__c paymentDetail : paymentDetails){
           ASI_KOR_VMS_Interface_File__c vms = new ASI_KOR_VMS_Interface_File__c();
           vms.ASI_KOR_Branch_Code__c = BranchCode.get(paymentDetail.ASI_KOR_SR_Payment_Settlement__c);
           vms.ASI_KOR_VMS_Product_Code__c = paymentDetail.ASI_KOR_Brand__r.ASI_KOR_Brand_Code__c;
           vms.ASI_KOR_VMS_Brand_Code__c = paymentDetail.ASI_KOR_Brand__r.ASI_KOR_VMS_Brand_Code__c;
           vms.ASI_KOR_Venue_Code__c = paymentDetail.ASI_KOR_Venue_Code__c;
           vms.ASI_KOR_CA_Amount__c = paymentDetail.ASI_KOR_Final_CA_Amount_excl_Basic__c;
           vms.ASI_KOR_SR_Code__c = paymentDetail.ASI_KOR_Venue_Name__r.ASI_KOR_Salesman_Code__c;
           vms.ASI_KOR_Capacity_ml__c = '';
           vms.ASI_KOR_Input_Date__c = InputDate;
           vms.ASI_KOR_Input_Method__c = 'C';
           vms.ASI_KOR_Keyman_Code__c = paymentDetail.ASI_KOR_Keyman_Name__c;
           vms.ASI_KOR_Remark__c = 'CA settlement';
           vms.ASI_KOR_Promotion_Month__c = promotionMonth;
           vms.ASI_KOR_WS_Code__c = detailSupplierMap.get(paymentDetail.ID);
           vms.ASI_KOR_Volume__c = '0';
           
           vmsInterface.add(vms);
           
       }
       insert vmsInterface; 
   }

   public void finish(Database.BatchableContext BC){
  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     
      List<String> toAddresses = new List<String>();
      User current_user=[SELECT Email FROM User WHERE Id= :UserInfo.getUserId()] ;
      toAddresses.add(current_user.Email );

      mail.setToAddresses(toAddresses);
      //Mailing Subject
      String mailingSubject = 'VMS Data Ready';
      mail.setSubject(mailingSubject);
      
      //Mailing Message
        
      String mailingMessage  = 'VMS Interface Data for '+ promotionMonth.left(4) +'-' + promotionMonth.subString(4,promotionMonth.length()) + ' has been uploaded.' +'\r\n\r\n'; 
      mailingMessage  += 'Thanks.'+  '\r\n';
      mail.setPlainTextBody(mailingMessage);
      mail.setEmailPriority('High');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
   }
}