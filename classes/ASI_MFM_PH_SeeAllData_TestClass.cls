@isTest


private class ASI_MFM_PH_SeeAllData_TestClass {
    
    static testMethod void NewPO_Test() {
        //Test : ASI_MFM_PH_PlanNewPORedirectCtrl
        
        //Insert Custom Setting : ASI MFM Field ID Mappings
        List<ASI_MFM_Field_ID_Mappings__c> FieldIDDateList  = new List<ASI_MFM_Field_ID_Mappings__c>();
        ASI_MFM_Field_ID_Mappings__c f1 = new ASI_MFM_Field_ID_Mappings__c(Name='1',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_ID__c='1');
        FieldIDDateList.add(f1);
        ASI_MFM_Field_ID_Mappings__c f2 = new ASI_MFM_Field_ID_Mappings__c(Name='2',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Prefix__c',ASI_MFM_Field_ID__c='2');
        FieldIDDateList.add(f2);// 
        ASI_MFM_Field_ID_Mappings__c f3 = new ASI_MFM_Field_ID_Mappings__c(Name='3',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_PO_Name__c',ASI_MFM_Field_ID__c='3');
        FieldIDDateList.add(f3);
        insert FieldIDDateList;
            
        //Create Plan
        ASI_MFM_Plan__c plan = ASI_MFM_PH_TestClassHelper.createPHDPPlanReadOnly();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_PH_TestClassHelper.createPHPlanLines1(plan);
        List<ASI_MFM_Plan_Line_Item__c> planLineSet = new List<ASI_MFM_Plan_Line_Item__c>();
        planLineSet.add(planLine);
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(planLineSet);
        
        PageReference inputPlanItemsPage = Page.ASI_MFM_PH_InputPlanItemsPage;
        Map<String, String> pageParams = inputPlanItemsPage.getParameters();
        Test.startTest();
        
        pageParams.put('id', plan.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);
        ASI_MFM_PH_PlanNewPORedirectCtrl MakePO  = new ASI_MFM_PH_PlanNewPORedirectCtrl(stdController);
        MakePO.redirect();
        
        test.stopTest(); 
    }
    
}