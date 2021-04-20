@isTest
private class ASI_KOR_SRPaymentValidationTest{
   static testMethod void testValidation1() {
       ASI_KOR_NSD_Payment_Settlement_Header__c testNSD = new ASI_KOR_NSD_Payment_Settlement_Header__c(ASI_KOR_Year__c = '2014', ASI_KOR_Month__c = '8');
       insert testNSD;
       try{
           ASI_KOR_SR_Payment_Settlement_Header__c testSR = new ASI_KOR_SR_Payment_Settlement_Header__c(ASI_KOR_Year__c = '2014', ASI_KOR_Month__c = '8');
           insert testSR;
       }catch(Exception e){
       
       }
   }
   
   static testMethod void testValidation2() {
      try{
           ASI_KOR_SR_Payment_Settlement_Header__c testSR = new ASI_KOR_SR_Payment_Settlement_Header__c(ASI_KOR_Year__c = '2014', ASI_KOR_Month__c = '8');
           insert testSR;
       }catch(Exception e){
       
       }
      
   }

}