/**
 * @name GDT_InitUser_Class_Test
 * @description
 * Apex Test Class link to GDT_InitUser_Class
 * 
 * @author Simon GAZIN
 */
@isTest(SeeAllData=false)
public class GDT_InitUser_Class_Test {

    /**
     * Variable Creation
     */
    public static void initialize() {
        /* Custom Settings */
        Boolean createCS = true;
        Boolean createRecord = true;

        GDT_GeneralConfig__c flagGDT = new GDT_GeneralConfig__c(name = 'GDT_InitUser_isActive', GDT_Value__c = 'true');
        insert flagGDT;



        //Instantiate a new controller with all parametres in the page
        GDT_CustomSettings_ADDomaine__c csADDomain = new GDT_CustomSettings_ADDomaine__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(csADDomain);
        GDT_InitUser_Controller iuc = new GDT_InitUser_Controller(sc);
        //Page Reference
        PageReference pageRef = Page.GDT_InitUser_Administration;
        Test.setCurrentPage(pageRef);

        iuc.refresh_CustomSettings_ADDomain();
        iuc.saveCustomSettings_ADDomain();
        
        for(GDT_CustomSettings_ADDomaine__c iu : iuc.listAll_csADDomain){
            if((iu.ADDomaine__c).contains('MMPJ')) {
                iu.AffiliateGroup__c = 'MMPJ';
                update iu;
            }
        }

        //List<GDT_CustomSettings_CompanyName__c> listTemp_csCompanyName = new List<GDT_CustomSettings_CompanyName__c>();
        GDT_CustomSettings_CompanyName__c csCompanyNameToInsert = new GDT_CustomSettings_CompanyName__c();
        csCompanyNameToInsert.CompanyNameUser__c = 'Pernod Ricard USA';
        csCompanyNameToInsert.CompanyName__c = 'Pernod Ricard USA';
        csCompanyNameToInsert.DefaultRoleToAssign__c = 'UsA_New_Users';
        csCompanyNameToInsert.Name = 'N9999';
        insert csCompanyNameToInsert;

        GDT_CustomSettings_ADDomaine__c csADDomainToInsert = new GDT_CustomSettings_ADDomaine__c();
        csADDomainToInsert.ADDomaine__c = 'PR-AMERICAS';
        csADDomainToInsert.AffiliateGroup__c = 'PERNOD-RICARD-AMERICAS';
        csADDomainToInsert.Name = 'PR-AMERICAS';
        insert csADDomainToInsert;

        /* Custom Setting: Permission Set */
        List<GDT_InitUser_ListPermissionSet__c> listPermssionSet = [SELECT Name, GDT_InitUser_PermissionSetAPIName__c FROM GDT_InitUser_ListPermissionSet__c];
        for(GDT_InitUser_ListPermissionSet__c lst : listPermssionSet) {
            if(lst.Name == 'PR_USA_Insite') { createCS = false; }
        }
        if(createCS == true) {
            /** SeeAllData = false (else duplication entry) */
            GDT_InitUser_ListPermissionSet__c recordPermSet = new GDT_InitUser_ListPermissionSet__c();
            recordPermSet.Name = 'PR_USA_Insite';
            recordPermSet.GDT_InitUser_PermissionSetAPIName__c = 'PR_USA_Insite';
            recordPermSet.GDT_InitUser_Affiliate_Group__c = 'PERNOD-RICARD-AMERICAS';
            recordPermSet.GDT_InitUser_Company_Name__c = 'Pernod Ricard USA';
            recordPermSet.GDT_Permission_Set_Id__c = '0PSD00000008trQ';
            insert recordPermSet;
        }

        /* Custom Setting: Chatter Group */
        List<GDT_InitUser_ListChatterGroup__c> listChatterGroup = [SELECT Name, GDT_InitUser_ChatterGroup__c, GDT_InitUser_CompanyName__c FROM GDT_InitUser_ListChatterGroup__c];
        for(GDT_InitUser_ListChatterGroup__c lst : listChatterGroup) {
            if(lst.Name == 'SFDC Team') { createCS = false; }
        }
        if(createCS == true) {
            /** SeeAllData = false (else duplication entry) */
            GDT_InitUser_ListChatterGroup__c recordChatterGroup = new GDT_InitUser_ListChatterGroup__c();
            recordChatterGroup.Name = 'GDT TEST CHATTER';
            recordChatterGroup.GDT_InitUser_ChatterGroup__c = 'GDT TEST CHATTER';
            recordChatterGroup.GDT_InitUser_CompanyName__c = 'Pernod Ricard USA';
            recordChatterGroup.GDT_Chatter_Group_Id__c = '0F90D00000004Il';
            insert recordChatterGroup;
        }
        
        /* Custom Setting: Pernod Ricard User */
        createCS = true;
        List<GDT_InitUser_PernodRicardUser__c> listPernodRicardUser =  [SELECT Name FROM GDT_InitUser_PernodRicardUser__c];
        for(GDT_InitUser_PernodRicardUser__c lst : listPernodRicardUser) {
            if(lst.Name == '@pernod-ricard.com') { createCS = false; }
        }
        if(createCS == true) {
            /** SeeAllData = false (else duplication entry) */
            GDT_InitUser_PernodRicardUser__c recordPRUser = new GDT_InitUser_PernodRicardUser__c();
            recordPRUser.Name = '@pernod-ricard.com';
            recordPRUser.Contains_UserName__c = '@pernod-ricard.com';
            insert recordPRUser;
        }

        /* Chatter Group */
        /* SeeAllData = false (else duplication entry) */
        try {
            CollaborationGroup recordCollaborationGroup = new CollaborationGroup();
            recordCollaborationGroup.Name = 'GDT TEST CHATTER';
            recordCollaborationGroup.CollaborationType = 'Public';
            insert recordCollaborationGroup;

        } catch(Exception e) {
            System.debug('Chatter Group already exists');
        }
            
        /* View */
        System.debug('INITIALIZE');
        System.debug('AD DOMAIN : ' + [SELECT Name, ADDomaine__c, AffiliateGroup__c FROM GDT_CustomSettings_ADDomaine__c]);
        System.debug('CHATTER GROUP : ' + [SELECT Name, GDT_InitUser_ChatterGroup__c, GDT_InitUser_CompanyName__c FROM GDT_InitUser_ListChatterGroup__c]);
        System.debug('PERM SET : ' + [SELECT Name, GDT_InitUser_PermissionSetAPIName__c FROM GDT_InitUser_ListPermissionSet__c]);
        System.debug('PR USER : ' + [SELECT Name FROM GDT_InitUser_PernodRicardUser__c]);
    }
    
    /**
     * Test method 01
     * NO Pernod Ricard employee
     */
    static testMethod void myUnitTest_InitUser01() {
        GDT_GeneralConfigDAO.getValueAsStringSet('USER_DEFAULT_PROFILE', ',', false);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User u = new User (
                alias = 'IUPR01', 
                ADDomainUser__c = 'PR-AMERICAS\\aa',
                email = 'initUserPernodRicard01@pernod-ricard.com', 
                emailencodingkey = 'UTF-8', 
                firstname = 'initUserPernodRicard01', 
                lastname = 'Testing', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US',
                timezonesidkey = 'Europe/London', 
                username = 'initUserPernodRicard01@pernod-ricard.com', 
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ESN SSO User'].Id, 
                UserRoleId = null, 
                CompanyName = 'Chatter Ext', 
                isActive = true
            );
            Test.startTest();
            method_InitUserTest(u);
            Test.stopTest();
        }
    }


    /**
     * Test method 01
     * NO Pernod Ricard employee
     */
    static testMethod void myUnitTest_InitUser05() {
        GDT_GeneralConfigDAO.getValueAsStringSet('USER_DEFAULT_PROFILE', ',', false);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User u = new User (
                alias = 'IUPR01', 
                ADDomainUser__c = 'PR-AMERICAS\\aa',
                email = 'initUserPernodRicard01@pernod-ricard.com', 
                emailencodingkey = 'UTF-8', 
                firstname = 'initUserPernodRicard01', 
                lastname = 'Testing', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US',
                timezonesidkey = 'Europe/London', 
                username = 'initUserPernodRicard01@pernod-ricard.com', 
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ESN SSO User'].Id, 
                UserRoleId = null, 
                CompanyName = 'Chatter Ext', 
                isActive = true
            );
            Test.startTest();
            method_InitUserTestAfter(u);
            Test.stopTest();
        }
    }
 

    static testMethod void myUnitTest_InitUser06() {
        GDT_GeneralConfig__c flagGDT = new GDT_GeneralConfig__c(name = 'GDT_InitUser_AutoFreeze_Execution', GDT_Value__c = UserInfo.getUserId());
        insert flagGDT;
        GDT_GeneralConfigDAO.getValueAsStringSet('USER_DEFAULT_PROFILE', ',', false);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User u = new User (
                alias = 'IUPR01', 
                ADDomainUser__c = 'PR-AMERICAS\\aa',
                email = 'initUserPernodRicard01@pernod-ricard.com', 
                emailencodingkey = 'UTF-8', 
                firstname = 'initUserPernodRicard01', 
                lastname = 'Testing', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US',
                timezonesidkey = 'Europe/London', 
                username = 'initUserPernodRicard01@pernod-ricard.com', 
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ESN SSO User'].Id, 
                UserRoleId = null, 
                CompanyName = 'Chatter Ext', 
                isActive = true
            );
            Test.startTest();
       
            method_AutoFreeze(u);
            Test.stopTest();
        }
    }



    /*
     * Tes method 02
     * USA Pernod Ricard employee
     */
    static testMethod void myUnitTest_InitUser02() {
        GDT_GeneralConfigDAO.getValueAsStringArray('USER_DEFAULT_PROFILE', ',', false);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User u = new User(
                ADDomainUser__c = 'PR-AMERICAS\\aa', 
                alias = 'IUPR02', 
                email = 'initUserPernodRicard02@pernod-ricard.com', 
                emailencodingkey = 'UTF-8', 
                firstname = 'initUserPernodRicard02', 
                lastname = 'Testing', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US', 
                timezonesidkey = 'Europe/London', 
                username = 'initUserPernodRicard02@pernod-ricard.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ESN SSO User'].Id, 
                UserRoleId = null, 
                CompanyName = 'Pernod Ricard USA', 
                isActive = true
            );
            Test.startTest();
            method_InitUserTest(u); 
            Test.stopTest();
        }
    }

    /*
     * Tes method 03
     * MMPJ Pernod Ricard employee
     */
    static testMethod void myUnitTest_InitUser03() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User u = new User(
                ADDomainUser__c ='MMPJ\\aa', 
                alias = 'IUPR03', 
                email = 'initUserPernodRicard03@pernod-ricard.com', 
                emailencodingkey = 'UTF-8', 
                firstname = 'initUserPernodRicard03', 
                lastname = 'Testing', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US', 
                timezonesidkey = 'Europe/London', 
                username = 'initUserPernodRicard03@pernod-ricard.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'ESN SSO User'].Id, 
                UserRoleId = null, 
                CompanyName = 'MARTELL & CO', 
                isActive = true
            );

            Test.startTest();

            method_InitUserTest(u);

            Test.stopTest();
        }
    }

    /**
     * Main
     * @param u User test
     */
    public static void method_InitUserTest(User u) {
        GDT_InitUser_Class_Test.initialize();
        
        System.debug('INITUSER BeforeInsert: ' + u);
            GDT_InitUser_Class thisUser = new GDT_InitUser_Class();
            thisUser.initTrigger();
            thisUser.InitUserBefore(new List<User>{u});
            thisUser.AssignChatterEmailSettings(new List<User>{u});
            insert u;
            thisUser.InitUserAfter(new Map<Id,User>{u.id=>u},new Map<Id,User>{u.id=>u});
        System.debug('INITUSER AfterInsert: ' + u);
    }


    /**
     * Main
     * @param u User test
     */
    public static void method_InitUserTestAfter(User u) {
        GDT_InitUser_Class_Test.initialize();
        
        System.debug('INITUSER AfterInsert: ' + u);
            GDT_InitUser_Class thisUser = new GDT_InitUser_Class();
            thisUser.initTrigger();
            thisUser.InitUserAfter(null, new MAp<Id, User>{u.id=>u});
            insert u;
            User u2 = u.clone();
            u2.isActive = false;
            thisUser.Autofollow_User(new MAp<Id, User>{u.id=>u2}, new MAp<Id, User>{u.id=>u});

        System.debug('INITUSER AfterInsert: ' + u);
    }

    /**
     * Main
     * @param u User test
     */
    public static void method_AutoFreeze(User u) {
        GDT_InitUser_Class_Test.initialize();
        
        System.debug('INITUSER AfterInsert: ' + u);
            GDT_InitUser_Class thisUser = new GDT_InitUser_Class();
            thisUser.initTrigger();
            thisUser.InitUserAfter(null, new MAp<Id, User>{u.id=>u});
            insert u;
            User u2 = u.clone();
            u.AutoFreeze__c = true;
            thisUser.autoFreeze(new MAp<Id, User>{u.id=>u2}, new MAp<Id, User>{u.id=>u});

            u2.AutoFreeze__c = true;
            u.AutoFreeze__c = false;
            thisUser.autoFreeze(new MAp<Id, User>{u.id=>u2}, new MAp<Id, User>{u.id=>u});

        System.debug('INITUSER AfterInsert: ' + u);
    }

    /**
     * Test method CompanyName
     * Excute Batch GDT_CS_CompanyName_Batch.cls
     */
    static testMethod void myUnitTest_CompanyName() {

        //Instantiate a new controller with all parametres in the page
        GDT_CustomSettings_CompanyName__c csCompanyName = new GDT_CustomSettings_CompanyName__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(csCompanyName);
        GDT_InitUser_Controller iuc = new GDT_InitUser_Controller(sc);
        //Page Reference
        PageReference pageRef = Page.GDT_InitUser_Administration;
        Test.setCurrentPage(pageRef);

        iuc.refresh_CustomSettings_CompanyName();
        iuc.saveCustomSettings_CompanyName();

        iuc.refresh_CustomSettings_CompanyName();

        for(GDT_CustomSettings_CompanyName__c iu : iuc.listAll_csCompanyName){
            if((iu.CompanyNameUser__c).contains('PR-USA')) {
                iu.CompanyName__c = 'PR-USA';
                update iu;
            }
        }
    }

    
    static testMethod void testInitUserOneTrigger() {
        GDT_InitUserTriggerHandler trHandler = new GDT_InitUserTriggerHandler();
        trHandler.run();
        trHandler.beforeInsert();
        trHandler.beforeUpdate();
        trHandler.beforeDelete();
        trHandler.afterInsert();
        trHandler.afterUpdate();
        trHandler.afterDelete();
        trHandler.afterUndelete();
        trHandler.andFinally();
        trHandler.runAllActions();

    }
    
    static testMethod void testInitGDT_TriggerHandler() {
        GDT_TriggerHandler trHandler = new GDT_TriggerHandler();
        trHandler.run();
        trHandler.beforeInsert();
        trHandler.beforeUpdate();
        trHandler.beforeDelete();
        trHandler.afterInsert();
        trHandler.afterUpdate();
        trHandler.afterDelete();
        trHandler.afterUndelete();
        trHandler.andFinally();
        trHandler.runAllActions();

    }
}