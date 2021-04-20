@isTest
public class EUR_CRM_NG_AssignVFHandlerTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Visit_Frequency__c visitFrequency = new EUR_CRM_Visit_Frequency__c();
    public static EUR_CRM_Visit_Frequency_Criteria__c  vfCriteria = new EUR_CRM_Visit_Frequency_Criteria__c ();
    public static EUR_CRM_Group_Outlet_Type__c  grpOutletType = new EUR_CRM_Group_Outlet_Type__c ();
    public static EUR_CRM_Image_Level__c  imageLevel = new EUR_CRM_Image_Level__c ();
    public static EUR_CRM_Volume_Potential__c  volPotential = new EUR_CRM_Volume_Potential__c ();
    

    public static Id euAccountNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Account__c' AND DeveloperName = 'EUR_NG_On_Trade'].Id;
    public static Id visitFreqNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Visit_Frequency__c' AND DeveloperName = 'EUR_NG_Visit_Frequency'].Id;
    public static Id vfCriteriaNGOnTradeId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Visit_Frequency_Criteria__c' AND DeveloperName = 'EUR_NG_Visit_Frequency_Criteria_On_Trade'].Id;
    public static Id vfCriteriaNGOffTradeId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Visit_Frequency_Criteria__c' AND DeveloperName = 'EUR_NG_Visit_Frequency_Criteria_Off_Trade'].Id;
    public static Id grpOutletNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Group_Outlet_Type__c' AND DeveloperName = 'EUR_NG_Group_Outlet_Type'].Id;
    public static Id imageLevelNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Image_Level__c' AND DeveloperName = 'EUR_NG_Image_Level'].Id;
    public static Id volPotentialNGId = [SELECT Id, Name FROM RecordType where SobjectType='EUR_CRM_Volume_Potential__c' AND DeveloperName = 'EUR_NG_Volume_Potential'].Id;

    public static User eurSysUser;
    @isTest
    public static void Test() {
        EUR_CRM_NG_AssignVisitFrequencyHandler e = new EUR_CRM_NG_AssignVisitFrequencyHandler();
        e.executeTriggerAction(null, new List<sObject>(), new Map<ID, sObject>(), new Map<Id, SObject>());
    }
   /* public static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }*/
    
/*
    public static void dataInsert1(){

        visitFrequency = new EUR_CRM_Visit_Frequency__c();
        visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
        visitFrequency.RecordtypeId = visitFreqNGId;
        insert visitFrequency;
        system.assertNotEquals(visitFrequency, null);


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

        volPotential = new EUR_CRM_Volume_Potential__c();
        volPotential.recordtypeId = volPotentialNGId;
        volPotential.EUR_CRM_Name__c = 'Low';
        volPotential.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
        insert volPotential;
        system.assertNotEquals(volPotential, null);

        vfCriteria = new EUR_CRM_Visit_Frequency_Criteria__c();
        vfCriteria.RecordtypeId = vfCriteriaNGOnTradeId;
        vfCriteria.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
        vfCriteria.EUR_CRM_Image_Level__c = imageLevel.Id;
        vfCriteria.EUR_CRM_Volume_Potential__c = volPotential.Id;
        vfCriteria.EUR_CRM_Visit_Frequency__c = visitFrequency.Id;
        insert vfCriteria;
        system.assertNotEquals(vfCriteria, null);

    }

    public static void dataInsert2(){

        visitFrequency = new EUR_CRM_Visit_Frequency__c();
        visitFrequency.EUR_CRM_Channel__c = 'ON TRADE';
        visitFrequency.RecordtypeId = visitFreqNGId;
        insert visitFrequency;
        system.assertNotEquals(visitFrequency, null);


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

        volPotential = new EUR_CRM_Volume_Potential__c();
        volPotential.recordtypeId = volPotentialNGId;
        volPotential.EUR_CRM_Name__c = 'Low';
        volPotential.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
        insert volPotential;
        system.assertNotEquals(volPotential, null);

        vfCriteria = new EUR_CRM_Visit_Frequency_Criteria__c();
        vfCriteria.RecordtypeId = vfCriteriaNGOffTradeId;
        vfCriteria.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
        vfCriteria.EUR_CRM_Image_Level__c = imageLevel.Id;
        vfCriteria.EUR_CRM_Volume_Potential__c = volPotential.Id;
        vfCriteria.EUR_CRM_Visit_Frequency__c = visitFrequency.Id;
        insert vfCriteria;
        system.assertNotEquals(vfCriteria, null);

    }

    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();
            Test.startTest();
                euaccount = new EUR_CRM_Account__c();
                euaccount.RecordtypeId = euAccountNGId;
                euaccount.Name = 'Test Name';
                euaccount.EUR_CRM_Channel__c = 'ON TRADE';
                euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
                euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
                euaccount.EUR_CRM_Volume_Potential__c =  volPotential.Id;
                insert euaccount;
                system.assertNotEquals(euaccount, null);
            Test.stopTest();
        }
    }

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();
            Test.startTest();
                euaccount = new EUR_CRM_Account__c();
                euaccount.RecordtypeId = euAccountNGId;
                euaccount.Name = 'Test Name';
                euaccount.EUR_CRM_Channel__c = 'OFF TRADE';
                euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
                euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
                euaccount.EUR_CRM_Volume_Potential__c =  volPotential.Id;
                insert euaccount;
                system.assertNotEquals(euaccount, null);
            Test.stopTest();
        }
    }

    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();
            euaccount = new EUR_CRM_Account__c();
            euaccount.RecordtypeId = euAccountNGId;
            euaccount.Name = 'Test Name';
            euaccount.EUR_CRM_Channel__c = 'ON TRADE';
            euaccount.EUR_CRM_Outlet_Classification__c = 'Self Service';
            
            insert euaccount;
            system.assertNotEquals(euaccount, null);
            Test.startTest();
                
                euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
                euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
                euaccount.EUR_CRM_Volume_Potential__c =  volPotential.Id;
                update euaccount;

            Test.stopTest();
        }
    }
    static testMethod void test4(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert2();
            euaccount = new EUR_CRM_Account__c();
            euaccount.RecordtypeId = euAccountNGId;
            euaccount.Name = 'Test Name';
            euaccount.EUR_CRM_Channel__c = 'ON TRADE';
            euaccount.EUR_CRM_Outlet_Classification__c = 'Self Service';
            
            insert euaccount;
            system.assertNotEquals(euaccount, null);
            Test.startTest();
                
                euaccount.EUR_CRM_Group_Outlet_Type__c = grpOutletType.Id;
                euaccount.EUR_CRM_Image_Level__c = imageLevel.Id;
                euaccount.EUR_CRM_Volume_Potential__c =  volPotential.Id;
                update euaccount;

            Test.stopTest();
        }
    }*/
}