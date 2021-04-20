@isTest
public class EUR_CRM_FI_SelectOPPROSSegCtrlTest {

    public static EUR_CRM_ObjPromo__c objectivesAndPromotions;

    public static User eurSysUser;
    public static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

    public static void dataInsert1(){

        
        objectivesAndPromotions = EUR_CRM_FI_TestClassHelper.createObjAndProms(1).get(0);
        insert objectivesAndPromotions;


    }    
    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_FI_SelectOPPROSSegment'));
            System.currentPageReference().getParameters().put('objPromoId', objectivesAndPromotions.Id);
            EUR_CRM_FI_SelectOPPROSSegmentCtrl prosSegmentCtrl = new EUR_CRM_FI_SelectOPPROSSegmentCtrl();
            prosSegmentCtrl.obProId = objectivesAndPromotions.Id;
            prosSegmentCtrl.init();
            prosSegmentCtrl.opWrapList.get(0).isSelected = true;
            prosSegmentCtrl.saveOPProsContinue();
        }
    }

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_FI_SelectOPPROSSegment'));
            System.currentPageReference().getParameters().put('objPromoId', objectivesAndPromotions.Id);
            EUR_CRM_FI_SelectOPPROSSegmentCtrl prosSegmentCtrl = new EUR_CRM_FI_SelectOPPROSSegmentCtrl();
            prosSegmentCtrl.obProId = objectivesAndPromotions.Id;
            prosSegmentCtrl.init();
            prosSegmentCtrl.save();
        }
    }

    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            dataInsert1();

            Test.setCurrentPageReference(new PageReference('Page.EUR_CRM_FI_SelectOPPROSSegment'));
            System.currentPageReference().getParameters().put('objPromoId', objectivesAndPromotions.Id);
            EUR_CRM_FI_SelectOPPROSSegmentCtrl prosSegmentCtrl = new EUR_CRM_FI_SelectOPPROSSegmentCtrl();
            prosSegmentCtrl.obProId = objectivesAndPromotions.Id;
            prosSegmentCtrl.init();
            prosSegmentCtrl.cancel();
        }
    }

}