@isTest
public class EUR_CRM_BE_ObjectivePromoPageCtrlTest {
    public static string PROFILE_NAME_ADMIN         = 'EUR System Admin';
    public static string ROLE_NAME_EMEA             = 'EMEA';
    
    private static testMethod void test1(){
        
        User BE_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        System.runAs(BE_UserA)
        {
            EUR_CRM_Account__c euAccount = EUR_CRM_BE_TestClassHelper.createEUAccount('Testing');
            insert euAccount;
            
            EUR_CRM_OP_Action_List_Template__c opActionListTemplate = EUR_CRM_BE_TestClassHelper.createActionListTemplate();
            insert opActionListTemplate;
            
            EUR_CRM_ObjPromo_Action__c opAction = EUR_CRM_BE_TestClassHelper.createObjPromoAction();
            opAction.EUR_CRM_OP_Action_List_Template__c = opActionListTemplate.Id;
            insert opAction;
            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_BE_TestClassHelper.createObjPromo(1, 'EUR_BE_On_Trade_Promo_Kit_Activation', 'Testing', opActionListTemplate)[0];
            objPromo.EUR_CRM_Is_Quota__c = true;
            insert objPromo;
            objPromo.EUR_CRM_Status__c = 'Active';
            update objPromo;
            
            Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_BE_Objective_Volume_Target');
            EUR_CRM_ObjPromo_Target__c opTarget = new EUR_CRM_ObjPromo_Target__c();
            opTarget.RecordTypeId = recordtypeId;
            opTarget.EUR_CRM_ObjPromo__c = objPromo.Id;
            insert opTarget;
            
            Id recordtypeId2 = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_BE_Objective_Product');
            EUR_CRM_ObjPromo_Target__c opTarget2 = new EUR_CRM_ObjPromo_Target__c();
            opTarget2.RecordTypeId = recordtypeId2;
            opTarget2.EUR_CRM_ObjPromo__c = objPromo.Id;
            opTarget2.EUR_CRM_O_P_Target__c = opTarget.Id;
            insert opTarget2;
            
            Test.startTest();
            ApexPages.StandardController standardController = new ApexPages.StandardController(objPromo);
            EUR_CRM_BE_ObjectivePromoPageController controller = new EUR_CRM_BE_ObjectivePromoPageController(standardController);
            
            controller.getActions();
            controller.initTargets();
            controller.mapObject(opTarget);
            controller.mapObject(opTarget2);
            controller.getOPStatus();
            controller.getIsTargetsRendered();
            controller.getIsProductionSectionRendered();
            controller.getIsVolumnTargetRendered();
            controller.getIsSalesDrive();
            controller.getIsPromoKit();
            controller.getIsSpyder();
            controller.getIsOnSecondPlace();
            controller.getIsSize();
            controller.getIsSKU();
            controller.getIsQuality();
            controller.publishOP();
            controller.targetWraps[0].getHasChild();
            Test.stopTest();
        }   
    }
    
    public static User createUser(String profileName, String roleName, String userEmail, String userName, String lastName){
        System.Debug('@@@Create User:' + userName);
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
        UserRole r = [select id from UserRole where Developername =:roleName ];
        User u = new User(Alias = 'standt', Email=userEmail, userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        insert u;
        return u;
    }
}