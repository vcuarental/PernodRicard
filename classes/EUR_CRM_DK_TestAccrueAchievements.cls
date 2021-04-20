@isTest
public class EUR_CRM_DK_TestAccrueAchievements {
   	public static RecordType visitActionRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and DeveloperName = 'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles'];
   	public static RecordType opTargetRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo_Target__c' and DeveloperName = 'EUR_DK_SR_Volume_Target'];
   	public static RecordType accountOnTradeRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_DK_On_Trade'];
    //public static RecordType accountBERecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_BE_Wholesaler'];
   	public static RecordType outletTypeRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Outlet_Type__c' and DeveloperName = 'EUR_DK_Outlet_Type'];
   	public static RecordType groupOutletTypeRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Group_Outlet_Type__c' and DeveloperName = 'EUR_DK_Group_Outlet'];
   	public static RecordType imageLevelRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Image_Level__c' and DeveloperName = 'EUR_DK_Image_Level'];
   	public static RecordType volumePotentialRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Volume_Potential__c' and DeveloperName = 'EUR_DK_Volume_Potential'];    
    
    public static testmethod void testAccrueAchievements() {
        EUR_CRM_Account__c acc = EUR_CRM_DK_TestClassHelper.createEUAccountsDKOFF('Testing');
		insert acc;
        
        EUR_CRM_OP_Action_List_Template__c opActionListTemplate = EUR_CRM_DK_TestClassHelper.createActionListTemplate();
        insert opActionListTemplate;
            
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DK_TestClassHelper.createObjPromo(1, 'EUR_DK_Off_Trade_Leaflet_Campaign', 'Testing', opActionListTemplate)[0];
        objPromo.EUR_CRM_Is_Quota__c = true;
        insert objPromo;
            
        EUR_CRM_ObjPromo_Target__c opTarget = new EUR_CRM_ObjPromo_Target__c();
        opTarget.RecordTypeId = opTargetRecordType.Id;
        opTarget.EUR_CRM_ObjPromo__c = objPromo.Id;
        opTarget.EUR_CRM_Target_Owner__c = UserInfo.getUserId();
        insert opTarget;
            
        EUR_CRM_Visit_Action__c visitAction = EUR_CRM_DK_TestClassHelper.createVisitAction(acc, objPromo);
        visitAction.RecordTypeId = visitActionRecordType.Id;
        visitAction.EUR_CRM_Is_Accrued__c = false;
        visitAction.EUR_CRM_Sell_In_Volume_SKUs__c = 100;
        insert visitAction;
        
        Test.startTest();
        	Database.executeBatch(new EUR_CRM_DK_AccrueAchievements());
        Test.stopTest();
    }
    
    public static testmethod void testListingTemplateHandler() {
        EUR_CRM_Group_Outlet_Type__c groupOutletType = new EUR_CRM_Group_Outlet_Type__c();
        groupOutletType.RecordTypeId = groupOutletTypeRecordType.Id;
        insert groupOutletType;
        
        EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c();
        outletType.RecordTypeId = outletTypeRecordType.Id;
        outletType.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        insert outletType;
        
        EUR_CRM_Image_Level__c imageLevel = new EUR_CRM_Image_Level__c();
        imageLevel.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        imageLevel.RecordTypeId = imageLevelRecordType.Id;
        insert imageLevel;
        
        EUR_CRM_Volume_Potential__c volumePotential = new EUR_CRM_Volume_Potential__c();
        volumePotential.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        volumePotential.RecordTypeId = volumePotentialRecordType.Id;
        insert volumePotential;
        
        Test.startTest();
        EUR_CRM_Account__c acc = EUR_CRM_DK_TestClassHelper.createEUAccountsDKOFF('Testing');
        acc.EUR_CRM_Chain__c = 'AIBE';
        acc.EUR_CRM_Taxonomy_Level_1__c = 'Supermarket';
        acc.EUR_CRM_Taxonomy_Level_2__c = 'Hypermarket';
        
        EUR_CRM_Account__c acc2 = new EUR_CRM_Account__c();
        acc2.Name = 'Testing';
        acc2.RecordTypeId = accountOnTradeRecordType.Id;
        acc2.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
        acc2.EUR_CRM_Outlet_Type__c = outletType.Id;
        acc2.EUR_CRM_Image_Level__c = imageLevel.Id;
        acc2.EUR_CRM_Volume_Potential__c = volumePotential.Id;
        
        //EUR_CRM_Account__c acc3 = new EUR_CRM_Account__c();
        //acc3.Name = 'Testing';
        //acc3.RecordTypeId = accountBERecordType.Id;
        
        List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
        accountList.add(acc);
        accountList.add(acc2);
        //accountList.add(acc3);
        insert accountList;
        Test.stopTest();
    }
    
}