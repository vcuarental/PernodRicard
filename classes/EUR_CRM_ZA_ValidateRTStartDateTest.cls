@isTest
public class EUR_CRM_ZA_ValidateRTStartDateTest {


    public static EUR_CRM_Route_Template__c routeTemplate = new EUR_CRM_Route_Template__c();

    public static User eurSysUser;
    public static void setUser(){
        //Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin'];
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR ZA Standard On Trade User'];
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

     public static void dataInsert1(){

        routeTemplate = EUR_CRM_ZA_TestClassHelper.createRT(1,'Test ROUTE TEMPLATE').get(0);
        
        //system.assertNotEquals(routeTemplate, null);
    }

    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = null;
                try{
                    insert routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('Start Date is required')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2030,1,8);
                try{
                    insert routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('Please select a date which is a Monday')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }

    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2015,11,2);
                try{
                    insert routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('You cannot select a previous Monday')){
                        expectedExceptionThrown = true;
                    }

                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }

    static testMethod void test4(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2030,1,7);
                insert routeTemplate;
                try{
                    routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2030,1,8);
                    update routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('Please select a date which is a Monday')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }

    static testMethod void test5(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2030,1,7);
                insert routeTemplate;
                try{
                    routeTemplate.EUR_CRM_Start_Date__c = null;
                    update routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('Start Date is required')){
                        expectedExceptionThrown = true;
                    }
                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }

    static testMethod void test6(){
        setUser();
        System.runAs(eurSysUser){
            test.startTest();
                dataInsert1();

                routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2030,1,7);
                insert routeTemplate;
                try{
                    routeTemplate.EUR_CRM_Start_Date__c = date.newInstance(2015,11,2);
                    update routeTemplate;
                } catch(Exception e){
                    Boolean expectedExceptionThrown =  false;
                    if(e.getMessage().contains('You cannot select a previous Monday')){
                        expectedExceptionThrown = true;
                    }

                    System.AssertEquals(expectedExceptionThrown, true);
                }
                

            test.stopTest();
        }
    }
}