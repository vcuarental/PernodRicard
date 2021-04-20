/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test class for EUR_CRM_localeFormattedDate  class.
  @Author:      IPC
  @History:     JUL.7.2014 - Created
*/
@isTest
private class EUR_CRM_TestlocaleFormattedDate{
    
    static testMethod void testLocaleDate() {
        //English (United States) format
        List<User> userUpdate = new List<User>();
        userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'en_US'));
        update userUpdate;
        EUR_CRM_localeFormattedDate controller = new EUR_CRM_localeFormattedDate();
        controller.date_time = DateTime.valueOf('2007-01-01 2:35:21');
        String test_value = controller.getTimeZoneValue();
        System.assertEquals('1/1/2007', test_value); 
        
        //Arabic (Saudi Arabia) format
        userUpdate.clear();
        userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'ar_SA'));
        update userUpdate;
        controller.date_time = DateTime.valueOf('2005-03-07 5:02:21'); 
        test_value = controller.getTimeZoneValue(); 
        System.assertEquals('07/03/2005', test_value);

        //Chinese (Taiwan) format
        userUpdate.clear();
        userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'zh_TW'));
        update userUpdate;
        controller.date_time = DateTime.newInstance(2011, 1, 3, 12, 41, 15); 
        test_value = controller.getTimeZoneValue();
        System.assertEquals('2011/1/3', test_value);
        
        //test null
        userUpdate.clear();
        userUpdate.add(new User(Id = UserInfo.getUserId(), LocaleSidKey = 'zh_TW'));
        update userUpdate;
        controller.date_time = null; 
        test_value = controller.getTimeZoneValue();
        System.assertEquals(null, test_value);
    }
}