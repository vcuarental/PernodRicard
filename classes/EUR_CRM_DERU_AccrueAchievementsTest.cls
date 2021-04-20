@isTest
private class EUR_CRM_DERU_AccrueAchievementsTest {
    private static final String postalCode = '12345';
     
    public static void setupDataDE(){
        User onTradeUser = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        insert onTradeUser;
        System.runAs(onTradeUser) {
            EUR_CRM_Region__c testRegion = EUR_CRM_TestClassUtilityHelper.createRegion('region 1', onTradeUser.Id, 'EUR_DE_Region');
            insert testRegion;
            EUR_CRM_Territory__c offTradeTerritory = EUR_CRM_TestClassUtilityHelper.createTerritory('offTradeTerritory', onTradeUser.Id, testRegion.Id, 'EUR_DE_Territory');
            insert offTradeTerritory;
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', postalCode, offTradeTerritory.id, 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping');
            insert offTradeTerritoryMapping;
            EUR_CRM_Account__c accountEU = EUR_CRM_TestClassUtilityHelper.createAccountEU('euAccount ', postalCode, 'Lviv', 'Racne', 'CT', 'EUR_DE_OFF_STD', null);//EUR_DE_OFF_STD 
            insert accountEU;
            EUR_CRM_OP_Action_List_Template__c opalt = EUR_CRM_TestClassUtilityHelper.creaActionListTemplate('test323', 'DE_OFF_ALT_Sales_Drive', EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE);
            insert opalt;
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_TestClassUtilityHelper.createObjPromo(EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE, 'test', 'Ended');
            insert objPromo;
            EUR_CRM_ObjPromo_Target__c objPromoTarget = EUR_CRM_TestClassUtilityHelper.createOPTarget('EUR_DE_SR_Volume_Target', objPromo.Id, null);
            insert objPromoTarget;

            EUR_CRM_Visit__c visit = EUR_CRM_TestClassUtilityHelper.createVisit('EUR_DE_Off_Trade_Visit', accountEU.id);
            insert visit;

            List<EUR_CRM_Visit_Action__c> lstVisitAction = new List<EUR_CRM_Visit_Action__c>();
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('DE OFF Sales Drive SKU Bottles Sell-In Qty', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, null));
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('DE OFF Ad hoc Agreement To Buy', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, 'Yes'));
            lstVisitAction.add(EUR_CRM_TestClassUtilityHelper.createVisitAction('DE OFF 2nd Placement Sell In Qty - Theme', objPromo.Id, objPromoTarget.Id, visit.Id, accountEU.Id, 'Yes'));            
            insert lstVisitAction;
        }
    }
    
    static testMethod void testDEAccrueAchievements(){
    	setupDataDE();

    	System.runAs(new User(Id=UserInfo.getUserId())){
        Test.startTest();
            Database.executeBatch(new EUR_CRM_DERU_AccrueAchievements());
        Test.stopTest();
    	}
    }


    public static void setupDataRU() {
    	Profile eurSysProfile = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
       	
        UserRole managerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_CM_South_Stavropol_Krasnodar'];
        UserRole userRole = [select id from UserRole where Developername ='EUR_RU_SR_OFF_South_Krasnodar'];
        
        List<User> userList = new List<User>();
    	User regionalManager =  new User(Alias = 'regmgr', Email='userEmail112345ru@test.com', userroleid=managerRole.id,
    	EmailEncodingKey='UTF-8', LastName='userEmail112345rulastName', LanguageLocaleKey='en_US', 
    	LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
    	TimeZoneSidKey='America/Los_Angeles', UserName='userEmail112345ru@test.com');
        
    	User eurSysUser = new User(Alias = 'standt', Email='userEmail11234ru@test.com', userroleid=userRole.id,
    	EmailEncodingKey='UTF-8', LastName='userEmail11234rulastName', LanguageLocaleKey='en_US', 
    	LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
    	TimeZoneSidKey='America/Los_Angeles', UserName='userEmail11234ru@test.com');
    	userList.add(eurSysUser);
    	userList.add(regionalManager);
        insert userList;

    	regionalManager = [SELECT Id FROM User WHERE Email = 'userEmail112345ru@test.com'];
        
        System.runAs(new User(Id = eurSysUser.Id)) {
            EUR_CRM_Apex_Configuration__c apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
	        insert apexConfig;
            
            EUR_CRM_Account__c euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT');
            insert euaccount;
                
            EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
            insert template;
            // Create Promo
            List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
            List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
            List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
            for(EUR_CRM_ObjPromo__c p: promos){
                p.EUR_CRM_Status__c='Draft';
                promosToInsert.add(p);
            }
            insert promosToInsert;
            for(EUR_CRM_ObjPromo__c p :promosToInsert){
                p.EUR_CRM_Active_End_Date__c = Date.today()-1;  
                p.EUR_CRM_Status__c='Active';
                p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
                promosToUpdate.add(p);
            }
            update promosToUpdate;
                
            // put region
            EUR_CRM_Region__c region = EUR_CRM_RU_TestClassHelper.createRegion('testRegion', regionalManager.Id, 'EUR RU Region');
               
            List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount,promos[0]);
            List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
                m.EUR_CRM_Is_Active__c = true;
                m.EUR_CRM_Evaluation_Required__c = false;
                opMappingToInsert.add(m);
            }
            insert opMappingToInsert;
                
            EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
            objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
            insert objPromoAction;
                
            EUR_CRM_SKU__c sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_RU_SKU' );
               
            Id opTargetId = null;
            EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Objective Product',promosToUpdate[0].Id, opTargetId ).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            insert objTarget;
                
            EUR_CRM_ObjPromo_Target__c objTargetSub = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Manager POSM Target', promosToUpdate[0].Id, opTargetId ).get(0);
            objTargetSub.EUR_CRM_SKU__c = sku.id;
            objTargetSub.EUR_CRM_SKU__r = sku;
            objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
            insert objTargetSub;
            
            List<EUR_CRM_Visit_Action__c> visitActionList = new List<EUR_CRM_Visit_Action__c>();
            EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount,promos[0]);
            visitAction.EUR_CRM_Stage__c = 'Execution';
            visitAction.EUR_CRM_Status__c ='Participating';
            visitAction.EUR_CRM_Entitle_Achievement__c  = TRUE;
            visitAction.EUR_CRM_Is_Accrued__c = FALSE;
            visitAction.EUR_CRM_Status__c = 'Yes';
            visitAction.EUR_CRM_Promo_Kit_Quantity__c = '0.5';
            visitAction.EUR_CRM_ObjPromo_Target__c = objTargetSub.Id;
            visitAction.RecordTypeId = EUR_CRM_RU_TestClassHelper.getRecordTypeId('EUR_CRM_Visit_Action__c', 'EUR_RU_ON_Enter_Promo_Kit_Quantity');
            
            EUR_CRM_Visit_Action__c visitAction2 = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount,promos[0]);
            visitAction2.EUR_CRM_Stage__c = 'Execution';
            visitAction2.EUR_CRM_Status__c ='Participating';
            visitAction2.EUR_CRM_Entitle_Achievement__c  = TRUE;
            visitAction2.EUR_CRM_Is_Accrued__c = FALSE;
            visitAction2.EUR_CRM_ObjPromo_Target__c = objTargetSub.Id;
            visitAction2.RecordTypeId = EUR_CRM_RU_TestClassHelper.getRecordTypeId('EUR_CRM_Visit_Action__c', 'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement');
            
            visitActionList.add(visitAction);
            visitActionList.add(visitAction2);
            insert visitActionList;
        }
        
    }
    
    public static testmethod void testRUBatch() {
    	setupDataRU();

    	System.runAs(new User(Id=UserInfo.getUserId())){
        Test.startTest();
        	Database.executeBatch(new EUR_CRM_DERU_AccrueAchievements());
		Test.stopTest();
    	}
    }    

    static testMethod void testScheduleAccrueAchievements() {      
        String sched = '0 00 * * * ?';
        // Abort all CronTrigger records
        // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
        List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Accrue Germany and Russian Objective Achievements'];
        if(details  != null && details.size() > 0){
            CronJobDetail cd =details.get(0);
            CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
            if(d!=null)
        	    System.abortJob(d.Id);
        } 

        Test.startTest();  
			EUR_CRM_DERU_AccrueAchievements.schedule();
            //  String jobId = System.schedule('Accrue Finland Objective Achievements', sched, new EUR_CRM_FI_ScheduleAccrueAchievements());
        Test.stopTest();
    }
}