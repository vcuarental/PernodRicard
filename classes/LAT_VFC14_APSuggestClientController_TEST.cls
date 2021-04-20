@isTest
private class LAT_VFC14_APSuggestClientController_TEST {

      @isTest static void LAT_VFC14_APSuggestClientControllerTest() {
        Test.startTest();
        LAT_AccountInAction__c Acc = crearAccountInAction();
        ApexPages.StandardController controller = new ApexPages.StandardController(acc);
        LAT_VFC14_APSuggestClientController acOnTC = new LAT_VFC14_APSuggestClientController(controller);  
        Test.stopTest();       
      }
    
    
      @isTest static void saveTest() {
        Test.startTest();
        LAT_AccountInAction__c Acc = crearAccountInAction();
        ApexPages.StandardController controller = new ApexPages.StandardController(acc);
        LAT_VFC14_APSuggestClientController acOnTC = new LAT_VFC14_APSuggestClientController(controller);
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('paid', Acc.LAT_PromotionalAction__c);
        PageReference p = acOnTC.save();
        Test.stopTest();
                
      }
        @isTest static void saveTest2() {
        Test.startTest();
        LAT_AccountInAction__c Acc = crearAccountInAction();
        ApexPages.StandardController controller = new ApexPages.StandardController(acc);
        LAT_VFC14_APSuggestClientController acOnTC = new LAT_VFC14_APSuggestClientController(controller);
        PageReference p = acOnTC.save();
        Test.stopTest();
                
      }
  
    public static Account crearAccount(){
          
      Account acco = new Account();
      acco.Name = 'AccountTest';
      acco.CNPJ__c = 'PAC120605V42';
      acco.Client_code_AN8__c = '123451236';
      acco.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
      insert acco;
      return acco;
    
    }
    
    public static LAT_PromotionalAction__c crearPromotionalAction() {
      
      LAT_PromotionalAction__c prom = new LAT_PromotionalAction__c();
      prom.name = 'promActionTest';
      prom.LAT_StartDate__c = DATE.Today();
      prom.LAT_EndDate__c = DATE.Today();
    
      insert prom;
      return prom;
    }
    
    public static LAT_AccountInAction__c crearAccountInAction() {
      LAT_AccountInAction__c acc = new LAT_AccountInAction__c();
      acc.LAT_PromotionalAction__c = crearPromotionalAction().id;
      acc.LAT_Account__c = crearAccount().id;
      return acc;
    }
    
}