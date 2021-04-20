@isTest
public class ASI_MFM_CAP_InputPlanLinManageAllExtTest {
    @testSetup 
    static void testSetupMethod(){
        Group fakeGroup = new Group(Name = 'ASI MFM CAP All Users');
        insert fakeGroup;
        User u = ASI_MFM_CAP_HK_TestClassHelper.createUser(userInfo.getUserRoleId());
        GroupMember fakeMember = new GroupMember(GroupId = fakeGroup.id, UserOrGroupId = u.id);
        insert fakeMember;          
    }
    private static TestMethod void testDraftPlan() {

        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlan();
        testPlanInstance.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__c' + 'ASI_MFM_CAP_TW_Plan');

        testPlanInstance.ASI_MFM_Status__c = 'Draft';
        update testPlanInstance;

        System.Test.startTest();

          PageReference pageRef = Page.ASI_MFM_CAP_InputPlanLineManageAllPage;
          pageRef.getParameters().put('id', testPlanInstance.Id);
          pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);
          pageRef.getParameters().put('isQuickSave', 'true');
          
          ASI_MFM_Plan__c upsertPlan = ASI_MFM_CAP_TestClassHelper.createPlan();
          List <ASI_MFM_Plan_Line_Item__c> upsertPli = [select id, ASI_MFM_AP_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: upsertPlan.id];
          
          pageRef.getParameters().put('upsertPlanLineItemListJson', System.JSON.serialize(upsertPli)); 
         
          List <ASI_MFM_Plan_Line_Item__c> removePli = [select id, ASI_MFM_AP_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: testPlanInstance.id];
          if(removePli.size() >0){
              String removeJsonString = System.JSON.serialize(new List<String>{removePli[0].id});
        	pageRef.getParameters().put('deletePlanLineItemIdListJson', removeJsonString); 
    	  }
          List<ASI_MFM_Plan__c> testPlanList = [SELECT Id
                                                FROM ASI_MFM_Plan__c
                                                WHERE Id = :testPlanInstance.Id
                                                LIMIT 1];
          
          System.Test.setCurrentPage(pageRef);
          ApexPages.StandardSetController stdController = 
              new ApexPages.StandardSetController(testPlanList);
          
          ASI_MFM_CAP_InputPlanLineManageAllExt controllerInstance = 
              new ASI_MFM_CAP_InputPlanLineManageAllExt(stdController);
			
          Id id = controllerInstance.PLAN_LINE_ITEM_RECORD_TYPE_ID;
          ASI_MFM_CAP_InputPlanItemsHelper.findList('nullObj', '', '', 1); //test return null
          ASI_MFM_CAP_InputPlanItemsHelper.findList('Account', 'Name like \'test%\'', '', 1); //test is not empty filter
          
          Boolean isReadOnly = controllerInstance.isReadOnly;
          controllerInstance.savePlanLineItem();
          controllerInstance.cancel();
          ASI_MFM_Plan_Line_Item__c pli = controllerInstance.planLineItem;
          String planLineItemJSON = controllerInstance.planLineItemJSON;
          String apCodeMap = controllerInstance.apCodeMapJson;
          String buCodeMap = controllerInstance.buCodeMapJson;
          String quotationMap = controllerInstance.quotationJson;
          String supplierListJson = controllerInstance.supplierListJson;
        System.Test.stopTest();
    }

    private static TestMethod void testFinalPlan() {
        
        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlanOpex();

        testPlanInstance.ASI_MFM_Status__c = 'Final';
        try{
            update testPlanInstance;
        }catch(Exception e){
            system.Debug(e.getMessage());
        }
        

        System.Test.startTest();

            PageReference pageRef = Page.ASI_MFM_CAP_InputPlanLineManageAllPage;
            pageRef.getParameters().put('id', testPlanInstance.Id);
            pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);
        	pageRef.getParameters().put('isQuickSave', 'false');

            List<ASI_MFM_Plan__c> testPlanList = [SELECT Id
                                                    FROM ASI_MFM_Plan__c
                                                   WHERE Id = :testPlanInstance.Id
                                                   LIMIT 1];

			System.Test.setCurrentPage(pageRef);
          		ApexPages.StandardSetController stdController = 
              		new ApexPages.StandardSetController(testPlanList);
          
          		ASI_MFM_CAP_InputPlanLineManageAllExt controllerInstance = 
              		new ASI_MFM_CAP_InputPlanLineManageAllExt(stdController);
          	Boolean isReadOnly = controllerInstance.isReadOnly;
        System.Test.stopTest();
    }
    
     private static TestMethod void testSubmittedPlan() {
        
        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlanOpex();

        testPlanInstance.ASI_MFM_Status__c = 'Submitted';
        update testPlanInstance;

        System.Test.startTest();

            PageReference pageRef = Page.ASI_MFM_CAP_InputPlanLineManageAllPage;
            pageRef.getParameters().put('id', testPlanInstance.Id);
            pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);
        	pageRef.getParameters().put('isQuickSave', 'false');

            List<ASI_MFM_Plan__c> testPlanList = [SELECT Id
                                                    FROM ASI_MFM_Plan__c
                                                   WHERE Id = :testPlanInstance.Id
                                                   LIMIT 1];

			System.Test.setCurrentPage(pageRef);
          		ApexPages.StandardSetController stdController = 
              		new ApexPages.StandardSetController(testPlanList);
          
          		ASI_MFM_CAP_InputPlanLineManageAllExt controllerInstance = 
              		new ASI_MFM_CAP_InputPlanLineManageAllExt(stdController);
          	Boolean isReadOnly = controllerInstance.isReadOnly;
        System.Test.stopTest();
    }
}