@isTest
public class EUR_CRM_NG_ShareEUAcctHandlerTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Region__c region = new EUR_CRM_Region__c();
    public static EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c();
    public static EUR_CRM_Image_Level__c  imageLevel = new EUR_CRM_Image_Level__c ();
    public static EUR_CRM_Group_Outlet_Type__c  grpOutletType = new EUR_CRM_Group_Outlet_Type__c ();

    public static Id euAccountNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Account__c' AND DeveloperName = 'EUR_NG_On_Trade'].Id;
    public static Id regionNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Region__c' AND DeveloperName = 'EUR_NG_Region'].Id;
    public static Id territoryNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Territory__c' AND DeveloperName = 'EUR_CRM_NG_Territory'].Id;
    public static Id grpOutletNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Group_Outlet_Type__c' AND DeveloperName = 'EUR_NG_Group_Outlet_Type'].Id;
    public static Id imageLevelNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Image_Level__c' AND DeveloperName = 'EUR_NG_Image_Level'].Id;
    

    public static User eurSysUser;
     @isTest
    public static void Test() {
        EUR_CRM_NG_ShareEUAccountHandler e = new EUR_CRM_NG_ShareEUAccountHandler();
        e.executeTriggerAction(null, new List<sObject>(), new Map<ID, sObject>(), new Map<Id, SObject>());
        EUR_CRM_NG_ShareEUAccountHandler.populateAccountEUShare(new List<EUR_CRM_Account__c>(), new Set<Id>(), true);
    }
    /*public static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='System Administrator']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

    public static User eurSysUser2;
    public static void setUser2(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='System Administrator']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser2 = new User(Alias = 'standt2', Email='userEmail1234aoke2@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke2@test.com');
        insert eurSysUser2;

    }

    public static void dataInsert1(){

        region = new EUR_CRM_Region__c();
        region.Name = 'Test Region';
        region.recordtypeId = regionNGId;
        region.EUR_CRM_Channel__c = 'ON TRADE';
        //region.EUR_CRM_Region_Owner__c = eurSysUser.Id;
        region.EUR_CRM_Region_Owner__c = UserInfo.getUserId();
        insert region;
        system.assertNotEquals(region, null);

        territory = new EUR_CRM_Territory__c();
        territory.Name = 'Test Territory';
        territory.recordtypeId = territoryNGId;
        territory.EUR_CRM_KD_Owner__c = eurSysUser.Id;
        territory.EUR_CRM_Off_Trade_Owner__c = eurSysUser.Id;
        territory.EUR_CRM_On_Trade_Owner__c = eurSysUser.Id;
        territory.EUR_CRM_Territory_Owner__c = eurSysUser.Id;
        /*territory.EUR_CRM_KD_Owner__c = UserInfo.getUserId();
        territory.EUR_CRM_Off_Trade_Owner__c = UserInfo.getUserId();
        territory.EUR_CRM_On_Trade_Owner__c = UserInfo.getUserId();
        territory.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        territory.EUR_CRM_Region__c = region.Id;
        insert territory;
        system.assertNotEquals(territory, null);

        grpOutletType = new EUR_CRM_Group_Outlet_Type__c();
        grpOutletType.recordtypeId = grpOutletNGId;
        grpOutletType.EUR_CRM_Name__c = 'Restaurant';
        insert grpOutletType;
        system.assertNotEquals(grpOutletType, null);

        imageLevel = new EUR_CRM_Image_Level__c();
        imageLevel.recordtypeId = imageLevelNGId;
        imageLevel.EUR_CRM_Name__c = 'Iconic';
        imageLevel.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
        insert imageLevel;
        system.assertNotEquals(imageLevel, null);

    }

    static testMethod void test1(){
        setUser();
        setUser2();
        System.runAs(eurSysUser){
            dataInsert1();
        }
        System.runAs(eurSysUser2){
            
            Test.startTest();
                euaccount = new EUR_CRM_Account__c();
                euaccount.RecordtypeId = euAccountNGId;
                euaccount.Name = 'Test Name';
                euaccount.EUR_CRM_Channel__c = 'ON TRADE';
                euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
                euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
                euaccount.EUR_CRM_Territory__c = territory.Id;
                try{
                    insert euaccount;
                    //system.assertNotEquals(euaccount, null);
                } catch (Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('insufficient access rights on cross-reference id')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                
            Test.stopTest();
        }
    }

    static testMethod void test2(){
        setUser();
        //setUser2();
        System.runAs(eurSysUser){
            dataInsert1();
            euaccount = new EUR_CRM_Account__c();
            euaccount.RecordtypeId = euAccountNGId;
            euaccount.Name = 'Test Name';
            euaccount.EUR_CRM_Channel__c = 'OFF TRADE';
            euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
            euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
            insert euaccount;
            system.assertNotEquals(euaccount, null);
        }

        //System.runAs(eurSysUser2){
            

            Test.startTest();
                
                euaccount.EUR_CRM_Channel__c = 'ON TRADE';
                euaccount.EUR_CRM_Territory__c = territory.Id;
                //update euaccount;
                try{
                    update euaccount;
                    //system.assertNotEquals(euaccount, null);
                } catch (Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('insufficient access rights on cross-reference id')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, false);
                }
                
            Test.stopTest();
        //}
    }
*/
}