@isTest(seeAllData=false)
private class PJ_ByFor_Batch_DeleteAttach_Schedul_TEST {
  
  static testMethod void PJ_ByFor_Batch_DeleteAttach_Schedul_TEST(){
    Test.startTest();
    
    System.schedule('batchDeleteAttachSchedule', '0 0 3 * * ?', new PJ_ByFor_Batch_DeleteAttachments_Schedul());
    
    Test.stopTest();
  }
}