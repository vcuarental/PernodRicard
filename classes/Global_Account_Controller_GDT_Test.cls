@isTest
public class Global_Account_Controller_GDT_Test{

    public static testMethod void testAccountCreation() {
    
        
        Global_Account_Controller__c customSettings1 = new Global_Account_Controller__c(Name='1',Global_Account_Customized__c = true , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Role__c = 'ESN', Global_Account_Action__c = 'Read', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');
        Global_Account_Controller__c customSettings2 = new Global_Account_Controller__c(Name='2',Global_Account_Customized__c = false , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Action__c = 'Read', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');
        Global_Account_Controller__c customSettings3 = new Global_Account_Controller__c(Name='3',Global_Account_Customized__c = true , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Role__c = 'ESN', Global_Account_Action__c = 'Create', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');                                                     
        Global_Account_Controller__c customSettings4 = new Global_Account_Controller__c(Name='4',Global_Account_Customized__c = false , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Action__c = 'Create', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');
        Global_Account_Controller__c customSettings5 = new Global_Account_Controller__c(Name='5',Global_Account_Customized__c = true , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Role__c = 'ESN', Global_Account_Action__c = 'Edit', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');       
        Global_Account_Controller__c customSettings6 = new Global_Account_Controller__c(Name='6',Global_Account_Customized__c = false , Global_Account_Record_Type__c = 'GDT' ,
                                                             Global_Account_Action__c = 'Edit', Global_Account_Redirected_Page__c = '/apex/Global_Account_GDT');
       
        List<Global_Account_Controller__c> customList = new List<Global_Account_Controller__c> ();
        customList.add(customSettings1);
        customList.add(customSettings2);
        customList.add(customSettings3);
        customList.add(customSettings4);
        customList.add(customSettings5);
        customList.add(customSettings6);
       
        insert customList;
        
        Account Act = new Account();
        Act.recordTypeID = Global_RecordTypeCache.getRtId('AccountGDT');
        Act.Name='TestNewGlobalAccountName';
        
        insert Act;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Act);
        
        test.startTest();

        PageReference GlobalpageRef1 = new PageReference('/apex/Global_Account_View_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef1);
        Global_Account_View_Controller GlobaltestObjCON1 = new Global_Account_View_Controller(sc);
        GlobaltestObjCON1.redirect();
        
        PageReference GlobalpageRef2 = new PageReference('/apex/Global_Account_Edit_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef2);
        Global_Account_Edit_Controller GlobaltestObjCON2 = new Global_Account_Edit_Controller(sc);
        GlobaltestObjCON2.redirect();
        
        PageReference GlobalpageRef3 = new PageReference('/apex/Global_Account_Create_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef3);
        Global_Account_Create_Controller GlobaltestObjCON3 = new Global_Account_Create_Controller(sc);
        GlobaltestObjCON3.redirect();
        
        test.stopTest();
    }
    
    public static testMethod void testAccountCreation2() {
        
        Account Act = new Account();
        Act.recordTypeID = Global_RecordTypeCache.getRtId('AccountGDT');
        Act.Name='TestNewGlobalAccountName';
        
        insert Act;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Act);
        
        test.startTest();

        PageReference GlobalpageRef1 = new PageReference('/apex/Global_Account_View_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef1);
        Global_Account_View_Controller GlobaltestObjCON1 = new Global_Account_View_Controller(sc);
        GlobaltestObjCON1.redirect();
        
        PageReference GlobalpageRef2 = new PageReference('/apex/Global_Account_Edit_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef2);
        Global_Account_Edit_Controller GlobaltestObjCON2 = new Global_Account_Edit_Controller(sc);
        GlobaltestObjCON2.redirect();
        
        PageReference GlobalpageRef3 = new PageReference('/apex/Global_Account_Create_Controller?id=' + Act.Id);
        Test.setCurrentPageReference(GlobalpageRef3);
        Global_Account_Create_Controller GlobaltestObjCON3 = new Global_Account_Create_Controller(sc);
        GlobaltestObjCON3.redirect();
        
        test.stopTest();
    }
    


}