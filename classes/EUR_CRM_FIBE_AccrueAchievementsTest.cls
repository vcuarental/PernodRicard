@isTest
private class EUR_CRM_FIBE_AccrueAchievementsTest {
    private final String ADDITIONAL_LOGIC = 'ADDITIONAL_LOGIC';
    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String rtDevName, String externalId) {
        Id rtId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', rtDevName);
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name',
        	EUR_CRM_External_ID__c = externalId,
        	RecordTypeId = rtId
        );
    }

    public static EUR_CRM_Account__c createEUAccount(String name, Id rtId, Id ownID){
        return new EUR_CRM_Account__c(Name = name, recordtypeid = rtId, OwnerId = ownId, EUR_CRM_Postal_Code__c = 'UA');
    }

    static testMethod void testBE() {
        Id userid = UserInfo.getUserId();

        //Create Action List Template
        EUR_CRM_OP_Action_List_Template__c actionListTemp = new EUR_CRM_OP_Action_List_Template__c(name = 'Promo Action List Template 1', EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation');
        insert actionListTemp;

        //Create Action List
        EUR_CRM_ObjPromo_Action__c promoAction = new EUR_CRM_ObjPromo_Action__c(EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_CRM_OFF_Follow_Up', EUR_CRM_OP_Action_List_Template__c = actionListTemp.Id);
        insert promoAction;

        //Create AccList
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();

        //Create EUAccount
        EUR_CRM_Account__c acc = EUR_CRM_BE_TestClassHelper.createEUAccount('Tester1');
        insert acc;

        //Create objPromoList

        EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c();
        objAndProm.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_On_Trade_Promo_Kit_Activation');
        objAndProm.Name = 'TestObjPromo';
        objAndProm.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-1);
        objAndProm.EUR_CRM_Active_End_Date__c = Date.Today().addDays(360);
        objAndProm.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20);

        insert objAndProm;

        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = EUR_CRM_BE_TestClassHelper.createobjPromoAccMapping('EUR_BE_O_P_Account_Mapping', acc.Id, objAndProm.Id);

        objPromoAccMapping.EUR_CRM_Is_Active__c = true;
        objPromoAccMapping.EUR_CRM_Evaluation_Required__c = false;
        insert objPromoAccMapping;

        objAndProm.Name = 'Test1';
        objAndProm.EUR_CRM_Status__c = 'Published';

        EUR_CRM_Brand__c testBrand = new EUR_CRM_Brand__c();
        testBrand.Name = 'TestBrand';
        insert testBrand;

        EUR_CRM_SKU__c testSku = new EUR_CRM_SKU__c(Name = 'test', EUR_CRM_Bottles_per_Case__c = 10);
        insert testSku;

        EUR_CRM_Quality__c testBrandQuality = new EUR_CRM_Quality__c();
        testBrandQuality.EUR_CRM_Brand__c = testBrand.Id;
        insert testBrandQuality;
        Test.startTest();
        RecordType targetRt1 = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_Objective_Volume_Target');
        EUR_CRM_ObjPromo_Target__c testTargetParent = new EUR_CRM_ObjPromo_Target__c();
        testTargetParent.RecordTypeId = targetRt1.Id;
        testTargetParent.EUR_CRM_ObjPromo__c = objAndProm.Id;
        testTargetParent.EUR_CRM_Target_Owner__c = userid;
        testTargetParent.EUR_CRM_Brand__c = testBrand.Id;
        testTargetParent.EUR_CRM_BQ__c = testBrandQuality.Id;
        insert testTargetParent;

        RecordType targetRt2 = Global_RecordTypeCache.getRtRec('EUR_CRM_ObjPromo_Target__c' + 'EUR_BE_SR_Volume_Target');
        List<EUR_CRM_ObjPromo_Target__c> targets = new List<EUR_CRM_ObjPromo_Target__c>();
        EUR_CRM_ObjPromo_Target__c testTarget = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = targetRt2.Id,
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_O_P_Target__c = testTargetParent.Id,
                EUR_CRM_Target_Owner__c = null,
                EUR_CRM_Brand__c = testBrand.Id,
                EUR_CRM_BQ__c = testBrandQuality.Id);
        targets.add(testTarget);
        EUR_CRM_ObjPromo_Target__c testTarget2 = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = targetRt2.Id,
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_O_P_Target__c = testTargetParent.Id,
                EUR_CRM_Target_Owner__c = null,
                EUR_CRM_SKU__c = testSku.Id);
        targets.add(testTarget2);
        insert targets;


        List<EUR_CRM_Visit_Action__c> listVisit = new List<EUR_CRM_Visit_Action__c>();
        RecordType visitAction = Global_RecordTypeCache.getRtRec('EUR_CRM_Visit_Action__c' + 'EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty');
        EUR_CRM_Visit_Action__c newVisit = new EUR_CRM_Visit_Action__c(
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_Stage__c = 'Execution',
                EUR_CRM_Status__c = 'Yes',
                RecordType = visitAction,
                EUR_CRM_Is_Accrued__c = false,
                EUR_CRM_Account__c = acc.id,
                EUR_CRM_Brand__c = testBrand.Id,
                EUR_CRM_Brand_Quality__c = testBrandQuality.Id,
                EUR_CRM_Sell_In_Volume_Bottles__c = 50);
        listVisit.add(newVisit);
        EUR_CRM_Visit_Action__c newVisit2 = new EUR_CRM_Visit_Action__c(
                EUR_CRM_ObjPromo__c = objAndProm.Id,
                EUR_CRM_Stage__c = 'Execution',
                EUR_CRM_Status__c = 'Yes',
                RecordType = visitAction,
                EUR_CRM_Is_Accrued__c = false,
                EUR_CRM_Account__c = acc.id,
                EUR_CRM_SKU__c = testSku.Id,
                EUR_CRM_Sell_In_Volume_Displays__c = 1);
        listVisit.add(newVisit2);

        upsert objAndProm;
        insert listVisit;

        EUR_CRM_FIBE_AccrueAchievements batch1 = new EUR_CRM_FIBE_AccrueAchievements();
        Id job1 = Database.executeBatch(batch1, 200);
        EUR_CRM_FIBE_AccrueAchievements.accrueBE(listVisit);
        Test.stopTest();
    }

    /**
        EUR_CRM_FI_CreateVisitActionFollowUps
    */
    static User eurSysUser;
    static User eurSalesRep;
    static EUR_CRM_Size__c bqs;
    static EUR_CRM_Quality__c bq;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
    static void setSalesRep() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR FI IT Admin User'];
        UserRole r = [SELECT Id FROM UserRole WHERE Developername = 'EUR_FI'];
        eurSalesRep = new User(Alias = 'eursr', Email='userEmail5678fi@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail5678filastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail5678fi@test.com');
        insert eurSalesRep;
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleSR
    *   test accruing multiple visit actions belonging to an OP from different SR
    *
    */
    static testMethod void testFIAccrueAchievementsMultipleSR() {
        setUser();
        setSalesRep();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = createEUAccount('test', fiOnAccountRecordTypeId, UserInfo.getUserId());
            EUR_CRM_Account__c account2 =createEUAccount('test2', fiOnAccountRecordTypeId, eurSalesRep.Id);
            insert new List<EUR_CRM_Account__c>{ account, account2};

            Test.startTest();

        	EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        	insert listTemplate;
        	            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            insert opTargetObjCommitment;
           
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetSRCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id,
                EUR_CRM_O_P_Target__c = opTargetObjCommitment.Id,
                EUR_CRM_Target_Owner__c = eurSalesRep.Id,
                EUR_CRM_Visit_Targets__c = 4,
                EUR_CRM_Is_Quota__c = false
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetSRCommitment, opTargetSRCommitment2};
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account2.Id,
                EUR_CRM_Account__r = account2,
                EUR_CRM_objPromo__c = op.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FIBE_AccrueAchievements.accrueFI(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(1, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);
            
            opTargetSRCommitment2 = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment2.Id];
            System.assertEquals(1, opTargetSRCommitment2.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }        
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleVisitActions
    *   test accruing multiple visit actions belonging to the same SR
    */
    static testMethod void testFIAccrueAchievementsMultipleVisitActions() {
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = createEUAccount('test', fiOnAccountRecordTypeId, UserInfo.getUserId());
            insert account;

        	EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        	insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            insert opTargetObjCommitment;
            
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            insert opTargetSRCommitment;
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Account__r = account,
                EUR_CRM_objPromo__c = op.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            Test.startTest();
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FIBE_AccrueAchievements.accrueFI(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(2, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }         
    }
    
    /**
    *   testMethod: testAccrueAchievementsMultipleOP
    *   test accruing multiple visit actions belonging to multiple OP from the same SR
    */
    static testMethod void testFIAccrueAchievementsMultipleOP() {
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
          
            //Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            RecordType visitActionConfirmParticipationRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_Visit_Action__c' and Developername = 'EUR_FI_Confirm_Participation'];
            
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = createEUAccount('test', fiOnAccountRecordTypeId, UserInfo.getUserId());
            insert account;
        	
        	EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        	insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            EUR_CRM_ObjPromo__c op2 = new EUR_CRM_ObjPromo__c(
                recordTypeId = fiOnObjPromoRecordTypeId,
                name = 'test OP 2',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                EUR_CRM_Product_Hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c = 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            //List<EUR_CRM_ObjPromo__c> testOP = new List<EUR_CRM_ObjPromo__c>{op, op2};
            insert new List<EUR_CRM_ObjPromo__c>{op, op2};
            
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 4
            );
            EUR_CRM_ObjPromo_Target__c opTargetObjCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                RecordTypeId = opTargetObjCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op2.id,
                EUR_CRM_Is_Quota__c = true,
                EUR_CRM_Visit_Targets__c = 4
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetObjCommitment, opTargetObjCommitment2};
            System.assertNotEquals(opTargetObjCommitment2.Id, null);
            System.assertNotEquals(opTargetObjCommitment.Id, null);
            
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 4,
                 EUR_CRM_Is_Quota__c = false
            );
            EUR_CRM_ObjPromo_Target__c opTargetSRCommitment2 = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetSRCommitmentRecordTypeId,
                EUR_CRM_ObjPromo__c = op2.Id,
                EUR_CRM_O_P_Target__c = opTargetObjCommitment2.Id,
                EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                EUR_CRM_Visit_Targets__c = 4,
                EUR_CRM_Is_Quota__c = false
            );
            insert new List<EUR_CRM_ObjPromo_Target__c>{opTargetSRCommitment, opTargetSRCommitment2};
            
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 //recordTypeId =   visitActionConfirmParticipationRecordTypeId,
                 recordTypeId = visitActionConfirmParticipationRecordType.Id,
                 recordType = visitActionConfirmParticipationRecordType,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_Account__r = account,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
            );
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation2 = new EUR_CRM_Visit_Action__c(
                recordTypeId = visitActionConfirmParticipationRecordType.Id,
                recordType = visitActionConfirmParticipationRecordType,
                EUR_CRM_Account__c = account.Id,
                EUR_CRM_Account__r = account,
                EUR_CRM_objPromo__c = op2.Id,
                EUR_CRM_Status__c = 'Participating'
            );
            insert new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            System.assertNotEquals(null, visitActionConfirmParticipation.recordTypeId);
            System.assertNotEquals(null, visitActionConfirmParticipation2.recordTypeId);

            Test.startTest();
            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>{visitActionConfirmParticipation, visitActionConfirmParticipation2};
            EUR_CRM_FIBE_AccrueAchievements.accrueFI(visitActions);
            
            
            opTargetSRCommitment = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment.Id];
            System.assertEquals(1, opTargetSRCommitment.EUR_CRM_Actual_Number_of_Commitments__c);
            
            opTargetSRCommitment2 = [SELECT EUR_CRM_Actual_Number_of_Commitments__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id = :opTargetSRCommitment2.Id];
            System.assertEquals(1, opTargetSRCommitment2.EUR_CRM_Actual_Number_of_Commitments__c);

            Test.stopTest();
        }
    }
    
    //EUR_CRM_FI_AccrueAchievements
    static testMethod  void testFIAccrueAchievements(){
        setUser();
        System.runAs(eurSysUser){ 
            Id fiOnAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','EUR_FI_Direct_On_Trade');
            Id bqRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Quality__c','EUR_FI_Quality');
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
              
            Id opTargetObjCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Commitment_Target');
            Id opTargetObjVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_Objective_Volume_Target');
            Id opTargetSRCommitmentRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Commitment_Target');
            Id opTargetSRVolumeRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_CRM_SR_Volume_Target');
          
            Id visitActionConfirmParticipationRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Confirm_Participation');
            Id visitActionSellInVolumeRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Enter_Sell_In_Volume_Estimate');
            Id visitActionFollowUpType1RecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c','EUR_FI_Follow_Up_Type_1');
             Id visitSubActionActionIndivRecordTypeId =  EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Sub_Action__c','FI_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Add_BQ');
       
            bq = new EUR_CRM_Quality__c(recordtypeid=bqRecordTypeId,name = 'testBQ');
            insert bq ;
            
            EUR_CRM_Account__c account = createEUAccount('test', fiOnAccountRecordTypeId, UserInfo.getUserId());
            insert account;
        
        	EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_FI_O_P_Action_List_Template', 'FI_Type_02');
        	insert listTemplate;

            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Active',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            ); 
            insert op;
            
               EUR_CRM_ObjPromo_Target__c opTargetObjCommitment = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Is_Quota__c = true,
                 EUR_CRM_Visit_Targets__c = 1
             );
             insert opTargetObjCommitment;
             EUR_CRM_ObjPromo_Target__c opTargetSRCommitment= new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRCommitmentRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjCommitment.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_Visit_Targets__c = 1,
                 EUR_CRM_Is_Quota__c = true

             );
             insert opTargetSRCommitment;
             EUR_CRM_ObjPromo_Target__c opTargetObjVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetObjVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_BQ__c = bq.id
             );
             insert opTargetObjVolume ;
             EUR_CRM_ObjPromo_Target__c opTargetSRVolume = new EUR_CRM_ObjPromo_Target__c(
                 recordTypeId = opTargetSRVolumeRecordTypeId,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_O_P_Target__c = opTargetObjVolume.id,
                 EUR_CRM_Target_Owner__c = UserInfo.getUserId(),
                 EUR_CRM_BQ__c = bq.id
             );
             insert opTargetSRVolume; 
            EUR_CRM_Visit_Action__c visitActionConfirmParticipation= new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionConfirmParticipationRecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Participating'
                 );
                 insert visitActionConfirmParticipation ; 
            EUR_CRM_Visit_Action__c visitActionSellInVolume = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionSellInVolumeRecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id
                 ); 
                 insert visitActionSellInVolume ; 
            
            EUR_CRM_Visit_Sub_Action__c visitSubAction= new EUR_CRM_Visit_Sub_Action__c(
                 recordtypeid =   visitSubActionActionIndivRecordTypeId , 
                 EUR_CRM_Visit_Action__c = visitActionSellInVolume.id,
                 EUR_CRM_Brand_Quality__c = bq.id,
                 EUR_CRM_Number_of_Bottles__c = 1
                 );
                 insert visitSubAction;

            EUR_CRM_Visit_Action__c visitActionFolloUpType1 = new EUR_CRM_Visit_Action__c(
                 recordtypeid =   visitActionFollowUpType1RecordTypeId,
                 EUR_CRM_Account__c = account.id,
                 EUR_CRM_ObjPromo__c = op.id,
                 EUR_CRM_Status__c = 'Evaluation: Successful'
                 );
                 insert visitActionFolloUpType1 ; 

            Test.startTest();
            visitActionConfirmParticipation = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionConfirmParticipation.id ];
             visitActionSellInVolume = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionSellInVolume.id ];
               
            
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
            visitActions.add(visitActionConfirmParticipation);
            visitActions.add(visitActionSellInVolume ); 
            EUR_CRM_FIBE_AccrueAchievements.accrueFI(visitActions);
              op.EUR_CRM_Status__c = 'Under Evaluation';
              update op;
               visitActionFolloUpType1 = [select id,EUR_CRM_Is_Accrued__c, EUR_CRM_ObjPromo__c,
             recordType.developername,EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_Account__r.OwnerId, EUR_CRM_Visit_ID__c,EUR_CRM_Status__c, EUR_CRM_Stage__c,EUR_CRM_Remarks__c,OwnerId, EUR_CRM_Stage_Sequence_Order__c,  EUR_CRM_Activation_End_Date__c,EUR_CRM_Account__c, EUR_CRM_Product_Toolkit__c, EUR_CRM_Active__c, EUR_CRM_End_Datetime__c from EUR_CRM_Visit_Action__c where id =:visitActionFolloUpType1.id ];
          
            visitActions = new List<EUR_CRM_Visit_Action__c>(); 
            visitActions.add(visitActionFolloUpType1 );
            
            
            EUR_CRM_FIBE_AccrueAchievements.accrueFI(visitActions);
            Test.stopTest();
        }
    }

    static testMethod void testScheduleAccrueAchievements() {      
        String sched = '0 00 * * * ?';
        // Abort all CronTrigger records
        // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
        List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Accrue Finland and Belgium Objective Achievements'];
        if(details  != null && details.size() > 0){
            CronJobDetail cd =details.get(0);
            CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
            if(d!=null)
        	    System.abortJob(d.Id);
        } 

        Test.startTest();  
			EUR_CRM_FIBE_AccrueAchievements.schedule();
            //  String jobId = System.schedule('Accrue Finland Objective Achievements', sched, new EUR_CRM_FI_ScheduleAccrueAchievements());
        Test.stopTest();
    }
}