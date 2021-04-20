@isTest

private class ASI_MFM_SG_CustomSettingTest {
    
    //Test Class for ASI_MFM_SG_CustomSettingController
  static testMethod void  SG_CustomSettinTest(){
      
        List<ASI_MFM_Setting__c> ItemList  = new List<ASI_MFM_Setting__c>();
        ASI_MFM_Setting__c d1 = new ASI_MFM_Setting__c(ASI_MFM_SG_Payment_Line_Tolerance__c=1);
        ItemList.add(d1);
       
        insert ItemList;
        
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_SG_CustomSettingPage');
        Test.setCurrentPage(pageRef);
        ASI_MFM_SG_CustomSettingController ext = new ASI_MFM_SG_CustomSettingController();
        ext.save();
        ext.init();
        ext.refresh();
        //ext.setting.insertSetting();
        test.stopTest();
    }
}