@isTest
public with sharing class EUR_CRM_PRS_TestClassUtilityHelper {
    public Static String RECORD_TYPE_ANSWER_BP      = 'EUR_PRS_Answer_Business_Potential';
    public Static String RECORD_TYPE_ANSWER_BBP     = 'EUR_PRS_Answer_Brand_Building_Potential';
    public Static String RECORD_TYPE_ANSWER_IL      = 'EUR_PRS_Answer_Image_Level';
    public Static String RECORD_TYPE_ANSWER_VP      = 'EUR_PRS_Answer_Volume_Potential';
    public Static String RECORD_TYPE_PRS_ON         = 'EUR_PRS_Segmentation_On_Trade';
    public Static String RECORD_TYPE_PRS_OFF        = 'EUR_PRS_Segmentation_Off_Trade';
    public Static String RECORD_TYPE_PRS_AC_VP      = 'EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential';
    public Static String RECORD_TYPE_PRS_AC_IL      = 'EUR_PRS_Segmentation_Aspect_Criteria_Image_Level';
    public static String RECORD_TYPE_PRS_AC_BBP     = 'EUR_PRS_Segmentation_Aspect_Criteria_BBP';
    public static String RECORD_TYPE_PRS_AC_BP      = 'EUR_PRS_Segmentation_Aspect_Criteria_BP';
    
    public static string PROFILE_NAME_ADMIN         = 'EUR System Admin';
    public static string ROLE_NAME_EMEA             = 'EMEA';

    public Static String RECORD_TYPE_BE_ACC_ON        = 'EUR_BE_On_Trade';
    public Static String RECORD_TYPE_BE_ACC_OFF       = 'EUR_BE_Off_Trade';
    public Static String RECORD_TYPE_BE_PRS_QC_ON     = 'EUR_BE_PRS_Question_Criteria';
    public Static String RECORD_TYPE_BE_PRS_QC_OFF    = 'EUR_BE_PRS_Question_Criteria';
    public Static String RECORD_TYPE_BE_PRS_Q_VP      = 'EUR_BE_PRS_Question_Set_Volume_Potential';
    public Static String RECORD_TYPE_BE_PRS_Q_IL      = 'EUR_BE_PRS_Question_Set_Image_Level';
    //public Static String RECORD_TYPE_BE_PRS_Q_BP      = 'EUR_BE_PRS_Question_Set_Business_Potential';
    public Static String RECORD_TYPE_BE_PRS_Q_BBP      = 'EUR_BE_PRS_Question_Set_Brand_Building_Potential';
    public Static String RECORD_TYPE_BE_PRS_A_VP      = 'EUR_BE_PRS_Segmentation_Aspect_Volume_Potential';
    public Static String RECORD_TYPE_BE_PRS_A_IL      = 'EUR_BE_PRS_Segmentation_Aspect_Image_Level';
    //public Static String RECORD_TYPE_BE_PRS_A_BP      = 'EUR_BE_PRS_Segmentation_Aspect_BP';
    public Static String RECORD_TYPE_BE_PRS_A_BBP      = 'EUR_BE_PRS_Segmentation_Aspect_BBP';
    public Static String RECORD_TYPE_BE_VISIT_FREQUENCY = 'EUR_BE_Visit_Frequency';
    public Static String RECORD_TYPE_BE_REGION          = 'EUR_BE_Region';
    public Static String RECORD_TYPE_BE_TERRITORY           = 'EUR_BE_Territory';
    public Static String RECORD_TYPE_BE_CUST_TAX            = 'EUR_BE_Customer_Taxonomy';
    public Static String RECORD_TYPE_BE_QUESTION            = 'EUR_BE_PRS_Question_Boolean_Input';
    public Static String RECORD_TYPE_BE_QUESTION_C          = 'EUR_BE_PRS_Question_Criteria';
    
    //Static String RECORD_TYPE_BG_ACC_ON        = 'EUR_BG_On_Trade';
    public Static String RECORD_TYPE_BG_ACC_OFF_X       = 'EUR_BG_Modern_Off_Trade';
    public Static String RECORD_TYPE_BG_ACC_OFF       = 'EUR_BG_Traditional_Off_Trade';
    public Static String RECORD_TYPE_BG_PRS_QC_ON     = 'EUR_BG_PRS_Question_Criteria';
    public Static String RECORD_TYPE_BG_PRS_QC_OFF    = 'EUR_BG_PRS_Question_Criteria';
    public Static String RECORD_TYPE_BG_PRS_Q_BP      = 'EUR_BG_PRS_Question_Set_Business_Potential';
    public Static String RECORD_TYPE_BG_PRS_Q_BBP      = 'EUR_BG_PRS_Question_Set_Brand_Building_Potential';
    public Static String RECORD_TYPE_BG_PRS_A_BP      = 'EUR_BG_PRS_Segmentation_Aspect_BP';
    public Static String RECORD_TYPE_BG_PRS_A_BBP      = 'EUR_BG_PRS_Segmentation_Aspect_BBP';
    public Static String RECORD_TYPE_BG_VISIT_FREQUENCY  = 'EUR_BG_Visit_Frequency';
    public Static String RECORD_TYPE_BG_REGION              = 'EUR_BG_Region';
    public Static String RECORD_TYPE_BG_TERRITORY           = 'EUR_BG_Territory';
    public Static String RECORD_TYPE_BG_CUST_TAX            = 'EUR_BG_Wholesalers_Customer_Taxonomy'; //OFF Trade
    public Static String RECORD_TYPE_BG_QUESTION            = 'EUR_BG_PRS_Question_Boolean_Input';
    public Static String RECORD_TYPE_BG_QUESTION_C          = 'EUR_BG_PRS_Question_Criteria';
    
    public static Map<String,Id> rtMap         {get;set;}
    
    public static EUR_CRM_Region__c BE_Region  {get;set;}
    public static EUR_CRM_Region__c BG_Region  {get;set;}
    
    public static User BE_UserA                 {get;set;}
    public static User BE_UserB                 {get;set;}
    public static User BG_UserA                 {get;set;}
    public static User BG_UserB                 {get;set;}
    
    public static EUR_CRM_Territory__c BE_Territory                {get;set;}
    public static EUR_CRM_Territory__c BG_Territory                {get;set;}
    
    public static EUR_CRM_Customer_Taxonomy__c BE_Customer_Tax     {get;set;}
    public static EUR_CRM_Customer_Taxonomy__c BG_Customer_Tax     {get;set;}
    
    public static EUR_CRM_Account__c BE_On_Account                 {get;set;}
    public static EUR_CRM_Account__c BE_Off_Account                {get;set;}
    //static EUR_CRM_ACcount__c BG_On_Account                 {get;set;}
    public static EUR_CRM_Account__c BG_Off_Account                {get;set;}
    public static EUR_CRM_Account__c BG_Off_Account_2nd                {get;set;}
    
    public static EUR_CRM_PRS_Segmentation__c PRS_Seg              {get;set;}
    public static EUR_CRM_PRS_Question_Set__c PRS_QSet_IL          {get;set;}
    public static EUR_CRM_PRS_Question_Set__c PRS_QSet_VP          {get;set;}
    public static EUR_CRM_PRS_Question_Set__c PRS_QSet_BP          {get;set;}
    public static EUR_CRM_PRS_Question_Set__c PRS_QSet_BBP          {get;set;}
    
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_VP_LOW      {get;set;}
    //public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_VP_MID      {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_VP_HI       {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_IL_LOW      {get;set;}
    //public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_IL_MID      {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_IL_HI       {get;set;}
    
    
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BP_LOW      {get;set;}
    //public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BP_MID      {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BP_HI       {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BBP_LOW      {get;set;}
    //public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BBP_MID      {get;set;}
    public static EUR_CRM_PRS_Seg_Aspect__c PRS_SA_BBP_HI       {get;set;}
    
    
    //EUR_CRM_PRS_Seg_Aspect_Criteria__c
    
    public static List<EUR_CRM_Visit_Frequency__c> BE_VisitFeq_List;
    public static List<EUR_CRM_Visit_Frequency__c> BG_VisitFeq_List;
     
    public static EUR_CRM_PRS_Group_Outlet_Type__c      BG_GROUP_OT;
    public static EUR_CRM_PRS_Outlet_Type__c            BG_OT;

    public static EUR_CRM_PRS_Group_Outlet_Type__c      BE_GROUP_OT;
    public static EUR_CRM_PRS_Outlet_Type__c            BE_OT;
    
    public static List<EUR_CRM_PRS_Group_Outlet_Type__c> BG_GroupOutlet_List;
    public static List<EUR_CRM_PRS_Group_Outlet_Type__c> BE_GroupOutlet_List;




    
    public static void initRecordType()
    {
        rtMap = new Map<String,Id>();
        for(RecordType rt : [select id, developername from RecordType where developername in 
                             (
                                :RECORD_TYPE_ANSWER_BP,:RECORD_TYPE_ANSWER_BBP,:RECORD_TYPE_ANSWER_IL,:RECORD_TYPE_ANSWER_VP,
                                :RECORD_TYPE_PRS_ON,:RECORD_TYPE_PRS_OFF,
                                :RECORD_TYPE_PRS_AC_VP,:RECORD_TYPE_PRS_AC_IL,:RECORD_TYPE_PRS_AC_BBP,:RECORD_TYPE_PRS_AC_BP,
                                :PROFILE_NAME_ADMIN,
                                :ROLE_NAME_EMEA,
                                :RECORD_TYPE_BE_ACC_ON,:RECORD_TYPE_BE_ACC_OFF,
                                :RECORD_TYPE_BE_PRS_QC_ON,:RECORD_TYPE_BE_PRS_QC_OFF,
                                :RECORD_TYPE_BE_PRS_Q_VP,:RECORD_TYPE_BE_PRS_Q_IL,:RECORD_TYPE_BE_PRS_Q_BBP,
                                :RECORD_TYPE_BE_PRS_A_VP,:RECORD_TYPE_BE_PRS_A_IL,:RECORD_TYPE_BE_PRS_A_BBP,
                                :RECORD_TYPE_BE_VISIT_FREQUENCY,
                                :RECORD_TYPE_BE_REGION,
                                :RECORD_TYPE_BE_TERRITORY,
                                :RECORD_TYPE_BE_CUST_TAX,
                                :RECORD_TYPE_BE_QUESTION,
                                :RECORD_TYPE_BE_QUESTION_C,
                                :RECORD_TYPE_BG_ACC_OFF_X,:RECORD_TYPE_BG_ACC_OFF,
                                :RECORD_TYPE_BG_PRS_QC_ON,:RECORD_TYPE_BG_PRS_QC_OFF,
                                :RECORD_TYPE_BG_PRS_Q_BP,:RECORD_TYPE_BG_PRS_Q_BBP,
                                :RECORD_TYPE_BG_PRS_A_BP,:RECORD_TYPE_BG_PRS_A_BBP,
                                :RECORD_TYPE_BG_VISIT_FREQUENCY,
                                :RECORD_TYPE_BG_REGION,
                                :RECORD_TYPE_BG_TERRITORY,
                                :RECORD_TYPE_BG_CUST_TAX,
                                :RECORD_TYPE_BG_QUESTION,
                                :RECORD_TYPE_BG_QUESTION_C
                             )
                            ]){
            rtMap.put(rt.developername,rt.id);
        }
    }
    
    public static void testInitBE() {
        
        initRecordType();
        
        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BE_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        } else {
            BE_UserA = userA[0];
        }
        
        
        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BE_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BE');
        } else {
            BE_UserB = userB[0];
        }
        
        //BG_User = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'bg.user@mail.com','BG User','BG');  
        
        System.runAs(BE_UserA)
        {
            BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BE_VISIT_FREQUENCY);
            insert BE_VisitFeq_List;
            
            //CREATE Region
            BE_Region = createRegion('Test Region' ,BE_UserA.Id , RECORD_TYPE_BE_REGION);
            //BG_Region = createRegion('BG_Region' ,BG_User.Id , 'EUR_BG_Region');
            //CREATE Territory
            BE_Territory = createTerritory('Test Territory',BE_UserA.Id ,BE_Region.Id ,RECORD_TYPE_BE_TERRITORY);
            //BG_Territory = createTerritory('BG Territory',BG_User.Id ,BG_Region.ID ,'EUR_BG_Territory');
            
            //CREATE Customer Taxonomy
            BE_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BE_UserA.Id,RECORD_TYPE_BE_CUST_TAX);
            //BG_Customer_Tax = createCustomerTaxonomy('BG_Cust_Tax',BG_User.Id,'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy');
            //test.startTest();
            //Setup Account
            //BE_On_Account     = createBEAccount('BE On Trade Account', '00000',  RECORD_TYPE_ACC_ON, BE_Customer_Tax.Id);
            //System.Debug('####Testing Account 1:' + BE_On_Account);
            BE_Off_Account  = createBEAccount('Test Off Trade Account', '00000',  RECORD_TYPE_BE_ACC_OFF, BE_Customer_Tax.Id);
            System.Debug('####Testing Account 1:' + BE_Off_Account);



            
            
            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id]);*/
            
            //Create PRS Segmentation Aspect (EU)
            PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
            PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
            PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
            PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
            

            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            PRS_QSet_IL = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_VP));
            PRS_QSet_VP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_IL));
            QuestionSetList.add(PRS_QSet_IL);
            QuestionSetList.add(PRS_QSet_VP);
            
            insert QuestionSetList;
            //test.stopTest();
            
            List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
            //Id QuestionRecordType = [SELECT Id FROM RecordType where sObjectType = 'EUR_CRM_PRS_Question__c' and DeveloperName =: RECORD_TYPE_BE_QUESTION limit 1].id;
            Id QuestionRecordType =  Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + RECORD_TYPE_BE_QUESTION);

            //Create Question IL * 2 
            EUR_CRM_PRS_Question__c PRS_Q_IL_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_IL.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'IL Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_IL_0001' );
            
            EUR_CRM_PRS_Question__c PRS_Q_IL_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_IL.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'IL Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_IL_0002' );
            //Create Question VP * 2 
            EUR_CRM_PRS_Question__c PRS_Q_VP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_VP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'VP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_VP_0001' );
            
            EUR_CRM_PRS_Question__c PRS_Q_VP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_VP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'VP Question 2',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_VP_0002' );
            
            QuestionList.add(PRS_Q_IL_1);
            QuestionList.add(PRS_Q_IL_2);
            QuestionList.add(PRS_Q_VP_1);
            QuestionList.add(PRS_Q_VP_2);
            
            insert QuestionList;
            
            //Create PRS Question Criteria
            //Id QuestionCRecordType = [SELECT Id FROM RecordType where sObjectType = 'EUR_CRM_PRS_Question_Criteria__c' and DeveloperName = :RECORD_TYPE_BE_QUESTION_C limit 1].id;
            Id QuestionCRecordType = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question_Criteria__c' + RECORD_TYPE_BE_QUESTION_C);

            
            List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            EUR_CRM_PRS_Question_Criteria__c QC_IL_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0004');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0004');
            
            QuestionCList.add(QC_IL_1_1);
            QuestionCList.add(QC_IL_1_2);
            QuestionCList.add(QC_IL_2_1);
            QuestionCList.add(QC_IL_2_2);
            
            QuestionCList.add(QC_VP_1_1);
            QuestionCList.add(QC_VP_1_2);
            QuestionCList.add(QC_VP_2_1);
            QuestionCList.add(QC_VP_2_2);
            
            insert QuestionCList;
            //Create PRS Segmentation (EU)
            //Auto created when Account creation            
            
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id Limit 1].Id;
            /*Id Ans_IL_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_IL Limit 1].Id;
            Id Ans_VP_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_VP Limit 1].Id;*/


            Id Ans_IL_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_IL);
            Id Ans_VP_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_VP);

            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            EUR_CRM_PRS_Answer__c PRS_Q_IL_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_IL_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_IL_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_IL_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_VP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_VP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_VP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_VP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            answerList.Add(PRS_Q_IL_1_Ans);
            answerList.Add(PRS_Q_IL_2_Ans);
            answerList.Add(PRS_Q_VP_1_Ans);
            answerList.Add(PRS_Q_VP_2_Ans);
            
            insert answerList;
        }
    }

        //OFF Trade Testing BP BBP
    public static void testInitBE_OffTrade() {
        
        initRecordType();

        //CREATE User
        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BE_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        } else {
            BE_UserA = userA[0];
        }
        
        
        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BE_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BE');
        } else {
            BE_UserB = userB[0];
        }
        //BE_User = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'BE.user@mail.com','BE User','BE');  
        
        System.runAs(BE_UserA)
        {
            BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BE_VISIT_FREQUENCY);
            insert BE_VisitFeq_List;
            
            //CREATE Region
            BE_Region = createRegion('Test Region' ,BE_UserA.Id , RECORD_TYPE_BE_REGION);
            //CREATE Territory
            BE_Territory = createTerritory('Test Territory',BE_UserA.Id ,BE_Region.Id ,RECORD_TYPE_BE_TERRITORY);
            //CREATE Customer Taxonomy
            BE_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BE_UserA.Id,RECORD_TYPE_BE_CUST_TAX);

            
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            
            string ValueLow = 'Low';
            string ValueHigh = 'High';
            
            //PRS_SA_BP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BP));
            //PRS_SA_BP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BP));
            PRS_SA_BBP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BBP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BBP));
            PRS_SA_BBP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BBP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BBP));
            
            //PRS_SAList.Add(PRS_SA_BP_LOW);
            //PRS_SAList.Add(PRS_SA_BP_HI);
            PRS_SAList.Add(PRS_SA_BBP_LOW);
            PRS_SAList.Add(PRS_SA_BBP_HI);
            
            insert PRS_SAList;
            
            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            /*PRS_QSet_BP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_BP));*/
            PRS_QSet_BBP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BBP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_BBP));
            //QuestionSetList.add(PRS_QSet_BP);
            QuestionSetList.add(PRS_QSet_BBP);
            
            insert QuestionSetList;

            Test.startTest();
            
            BE_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            //(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName)
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT1 = createBEOffGOutletType(PRS_QSet_BBP.Id, null, 
                                                'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  );
            
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT2 = createBEOffGOutletType(PRS_QSet_BBP.Id, null, 
                                                'BE_GOT_CON', 'Convenience','BE Convenience',''  );
            BE_GroupOutlet_List.add(BE_GROUP_OT1);
            BE_GroupOutlet_List.add(BE_GROUP_OT2);
            
            insert BE_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + BE_GroupOutlet_List);
            
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_1 = createBEOffOutletType('Hypermarket',BE_GroupOutlet_List[0].id,'BE_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_2 = createBEOffOutletType('Supermarket',BE_GroupOutlet_List[0].id,'BE_OT_Supermarket');
            
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_1 = createBEOffOutletType('Convenience',BE_GroupOutlet_List[1].id,'BE_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_2 = createBEOffOutletType('Gas stations',BE_GroupOutlet_List[1].id,'BE_OT_Gas_stations');
            
            OutletTypeList.add(BE_GROUP_OT1_1);
            OutletTypeList.add(BE_GROUP_OT1_2);
            OutletTypeList.add(BE_GROUP_OT2_1);
            OutletTypeList.add(BE_GROUP_OT2_2);
            
            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);
            
            BE_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BE_GROUP_OT1.id,
                                                               EUR_CRM_BrandBuildPotQuestionSet__c = BE_GROUP_OT1.EUR_CRM_BrandBuildPotQuestionSet__c,
                                                                EUR_CRM_BusinessPotentialQuestionSet__c = BE_GROUP_OT1.EUR_CRM_BusinessPotentialQuestionSet__c,
                                                                EUR_CRM_External_ID__c = BE_GROUP_OT1.EUR_CRM_External_ID__c,
                                                                EUR_CRM_Group_Outlet_Type_Name__c = BE_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                                                                EUR_CRM_Name__c = BE_GROUP_OT1.EUR_CRM_Name__c,
                                                                EUR_CRM_PRS_Group_Outlet_Name__c = BE_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);
            

            BE_Off_Account  = createBEAccount('Test Off Trade Account', '00000',  RECORD_TYPE_BE_ACC_OFF, BE_Customer_Tax.Id);
            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id Limit 1];
            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id;
            update PRS_Seg;
            
            System.Debug('####Testing Account 1:' + BE_Off_Account);
            
            
            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account.Id]);*/
            /*System.Debug('@@Init Outlet:' + [SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Country_Code__c 
                                    FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE
                                    RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type'
                                   ]);*/
            
            
            
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACBBP = rtMap.get(RECORD_TYPE_PRS_AC_BBP);
            Id rtSACBP = rtMap.get(RECORD_TYPE_PRS_AC_BP);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC1 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC1);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC2 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_HI.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC2);
            /*EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC3 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         
              EUR_CRM_Minimum_Weight__c = 0,                            
              EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     
              EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id,  
              EUR_CRM_Is_Weight_Changed__c = false                     
            );
            ListSAC.add(SAC3);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC4 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         
              EUR_CRM_Minimum_Weight__c = 0.5,                            
              EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     
              EUR_CRM_Business_Potential__c = PRS_SA_BP_HI.Id,  
              EUR_CRM_Is_Weight_Changed__c = false                     
            );
            ListSAC.add(SAC4);*/
            Insert ListSAC;
           
            List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
            Id QuestionRecordType = rtMap.get(RECORD_TYPE_BE_QUESTION);
            //Create Question IL * 2 
            /*EUR_CRM_PRS_Question__c PRS_Q_BP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);*/
            //Create Question VP * 2 
            EUR_CRM_PRS_Question__c PRS_Q_BBP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BBP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 2',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            /*QuestionList.add(PRS_Q_BP_1);
            QuestionList.add(PRS_Q_BP_2);*/
            QuestionList.add(PRS_Q_BBP_1);
            QuestionList.add(PRS_Q_BBP_2);
            CreateAllQuestionType_BE(PRS_QSet_BBP.Id, 'PRSQ_BBP_');
            insert QuestionList;
            //test.stopTest();
            //Create PRS Question Criteria
            Id QuestionCRecordType = rtMap.get(RECORD_TYPE_BE_QUESTION_C);
            
            List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            /*EUR_CRM_PRS_Question_Criteria__c QC_BP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0004');*/
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0004');
            
            /*QuestionCList.add(QC_BP_1_1);
            QuestionCList.add(QC_BP_1_2);
            QuestionCList.add(QC_BP_2_1);
            QuestionCList.add(QC_BP_2_2);*/
            
            QuestionCList.add(QC_BBP_1_1);
            QuestionCList.add(QC_BBP_1_2);
            QuestionCList.add(QC_BBP_2_1);
            QuestionCList.add(QC_BBP_2_2);
            
            insert QuestionCList;
            //Create PRS Segmentation (EU)
            //Auto created when Account creation            
            
            
            
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id Limit 1].Id;
            //Id Ans_BP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BP);
            Id Ans_BBP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BBP);
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            /*EUR_CRM_PRS_Answer__c PRS_Q_BP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);*/
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            /*answerList.Add(PRS_Q_BP_1_Ans);
            answerList.Add(PRS_Q_BP_2_Ans);*/
            answerList.Add(PRS_Q_BBP_1_Ans);
            answerList.Add(PRS_Q_BBP_2_Ans);
            
            insert answerList;
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_AC_BBP);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 73;
            aspCriteria.EUR_CRM_Business_Potential__c = PRS_SA_BBP_LOW.Id;
            insert aspCriteria;
            
            BE_Off_Account.EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id;
            //BE_Off_Account.EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id;
            update BE_Off_Account;
            
//            EUR_CRM_Account__c BE_Off_Account2 = [SELECT Id, RecordTypeId, RecordType.DeveloperName,
//                            EUR_CRM_Force_Group_Outlet_Type__c,
//                            EUR_CRM_Force_Outlet_Type__c,
//                            EUR_CRM_Force_Business_potential__c,
//                            EUR_CRM_Force_Brand_Building_Potential__c,
//                            EUR_CRM_PRS_Group_Outlet_Type__c,
//                            EUR_CRM_PRS_Outlet_Type__c,
//                            EUR_CRM_Business_Potential__c,
//                            EUR_CRM_Brand_Building_Potential__c,
//                            EUR_CRM_PRS_Image_Level__c,
//                            EUR_CRM_PRS_Volume_Potential__c,
//                            EUR_CRM_Force_PRS_Image_Level__c,
//                            EUR_CRM_Force_PRS_Volume_Potential__c,
//                            EUR_CRM_PRS_Priority_Level_Criteria__c,
//                            EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Type_Name__c,
//                            EUR_CRM_PRS_Outlet_Type__r.EUR_CRM_PRS_Outlet_Type_Name__c,
//                            EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c,
//                            EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c,
//                            EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c,
//                            EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c,
//                            EUR_CRM_PRS_Priority_Level_Criteria__r.EUR_CRM_Priority_Level__c
//                     FROM EUR_CRM_Account__c
//                     Where id =: BE_Off_Account.Id];
//            System.Debug('@@@Account Test>>>'+ BE_Off_Account2);
            Test.stopTest();
        }
    }
    
    
  
    //OFF Trade Testing BP BBP
    public static void testInitBG() {
        
        initRecordType();

        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BG_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BG');
        } else {
            BG_UserA = userA[0];
        }
        
        
        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BG_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BG');
        } else {
            BG_UserB = userB[0];
        }
        //BG_User = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'bg.user@mail.com','BG User','BG');  
        
        System.runAs(BG_UserA)
        {
            BG_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BG_VISIT_FREQUENCY);
            insert BG_VisitFeq_List;
            
            //CREATE Region
            BG_Region = createRegion('Test Region' ,BG_UserA.Id , RECORD_TYPE_BG_REGION);
            //BG_Region = createRegion('BG_Region' ,BG_User.Id , 'EUR_BG_Region');
            //CREATE Territory
            BG_Territory = createTerritory('Test Territory',BG_UserA.Id ,BG_Region.Id ,RECORD_TYPE_BG_TERRITORY);
            //BG_Territory = createTerritory('BG Territory',BG_User.Id ,BG_Region.ID ,'EUR_BG_Territory');
            
            //CREATE Customer Taxonomy
            //BG_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BG_UserA.Id,RECORD_TYPE_BG_CUST_TAX);
            BG_Customer_Tax = createBGCustomerTaxonomy();
            //BG_Customer_Tax = createCustomerTaxonomy('BG_Cust_Tax',BG_User.Id,'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy');

            
            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            
            string ValueLow = 'Low';
            string ValueHigh = 'High';
            
            PRS_SA_BP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BP));
            PRS_SA_BP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BP));
            PRS_SA_BBP_LOW  = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BBP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BBP));
            PRS_SA_BBP_HI   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BBP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BBP));              
        	
            PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
        	PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
        	PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
        	PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
            
            PRS_SAList.Add(PRS_SA_BP_LOW);
            PRS_SAList.Add(PRS_SA_BP_HI);
            PRS_SAList.Add(PRS_SA_BBP_LOW);
            PRS_SAList.Add(PRS_SA_BBP_HI);
            PRS_SAList.Add(PRS_SA_VP_LOW);
            PRS_SAList.Add(PRS_SA_VP_HI);
            PRS_SAList.Add(PRS_SA_IL_LOW);
            PRS_SAList.Add(PRS_SA_IL_HI);
            
            insert PRS_SAList;
            
            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            PRS_QSet_BP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BG_PRS_Q_BP));
            PRS_QSet_BBP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BBP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BG_PRS_Q_BBP));
            QuestionSetList.add(PRS_QSet_BP);
            QuestionSetList.add(PRS_QSet_BBP);
            
            insert QuestionSetList;
            
            BG_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            //(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName)
            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT1 = createBGOffGOutletType(PRS_QSet_BBP.Id, PRS_QSet_BP.Id, 
                                                'BG_GOT_HYSUM', 'Hyper/Supermarket','BG Hyper/Supermarket',''  );
            
            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT2 = createBGOffGOutletType(PRS_QSet_BBP.Id, PRS_QSet_BP.Id, 
                                                'BG_GOT_CON', 'Convenience','BG Convenience',''  );
            BG_GroupOutlet_List.add(BG_GROUP_OT1);
            BG_GroupOutlet_List.add(BG_GROUP_OT2);
            
            insert BG_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + BG_GroupOutlet_List);
            
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_1 = createBGOffOutletType('Hypermarket',BG_GroupOutlet_List[0].id,'BG_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_2 = createBGOffOutletType('Supermarket',BG_GroupOutlet_List[0].id,'BG_OT_Supermarket');
            
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_1 = createBGOffOutletType('Convenience',BG_GroupOutlet_List[1].id,'BG_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_2 = createBGOffOutletType('Gas stations',BG_GroupOutlet_List[1].id,'BG_OT_Gas_stations');
            
            OutletTypeList.add(BG_GROUP_OT1_1);
            OutletTypeList.add(BG_GROUP_OT1_2);
            OutletTypeList.add(BG_GROUP_OT2_1);
            OutletTypeList.add(BG_GROUP_OT2_2);
            
            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);
            
            BG_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BG_GROUP_OT1.id,
                                                               EUR_CRM_BrandBuildPotQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BrandBuildPotQuestionSet__c,
                                                                EUR_CRM_BusinessPotentialQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BusinessPotentialQuestionSet__c,
                                                                EUR_CRM_External_ID__c = BG_GROUP_OT1.EUR_CRM_External_ID__c,
                                                                EUR_CRM_Group_Outlet_Type_Name__c = BG_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                                                                EUR_CRM_Name__c = BG_GROUP_OT1.EUR_CRM_Name__c,
                                                                EUR_CRM_PRS_Group_Outlet_Name__c = BG_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);


            Test.startTest();
            //Setup Account
            //BE_On_Account     = createBEAccount('BE On Trade Account', '00000',  RECORD_TYPE_ACC_ON, BE_Customer_Tax.Id);
            //System.Debug('####Testing Account 1:' + BE_On_Account);
            BG_Off_Account  = createBGAccount('Test Off Trade Account', '00000',  RECORD_TYPE_BG_ACC_OFF, BG_Customer_Tax.Id);
            //BG_Off_Account_2nd = createBGOffAccount('Test Off Trade Account 2',BG_GROUP_OT1.id, BG_GROUP_OT1_1.Id );
            
            /*PRS_Seg = new EUR_CRM_PRS_Segmentation__c();
            PRS_Seg.EUR_CRM_Account__c = BG_Off_Account.Id;
            PRS_Seg.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_OFF);
            insert PRS_Seg;*/
            
            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account.Id Limit 1];
            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id;
            update PRS_Seg;
            
            System.Debug('####Testing Account 1:' + BG_Off_Account);
            
            
            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account.Id]);*/
            /*System.Debug('@@Init Outlet:' + [SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Country_Code__c 
                                    FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE
                                    RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type'
                                   ]);*/
            
            
            
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACBBP = rtMap.get(RECORD_TYPE_PRS_AC_BBP);
            Id rtSACBP = rtMap.get(RECORD_TYPE_PRS_AC_BP);
            Id rtSACIL = rtMap.get(RECORD_TYPE_PRS_AC_IL);
            Id rtSACVP = rtMap.get(RECORD_TYPE_PRS_AC_VP);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC1 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC1);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC2 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_HI.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC2);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC3 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC3);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC4 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Business_Potential__c = PRS_SA_BP_HI.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC4);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC5 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            	RecordTypeId = rtSACIL,                         // Record Type
            	EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
            	EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
            	EUR_CRM_Image_Level__c = PRS_SA_IL_LOW.Id, 	 // Image Level
            	EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
        	);
            ListSAC.add(SAC5);
            
        	EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC6 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            	RecordTypeId = rtSACIL,                         // Record Type
            	EUR_CRM_Minimum_Weight__c = 50,                            // Minimum Weight
            	EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
            	EUR_CRM_Image_Level__c = PRS_SA_IL_HI.Id, 	 // Image Level
            	EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
        	);
        ListSAC.add(SAC6);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC7 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            	RecordTypeId = rtSACVP,                         // Record Type
            	EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
            	EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
            	EUR_CRM_Volume_Potential__c = PRS_SA_VP_LOW.Id,
            	EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
        	);
        ListSAC.add(SAC7);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC8 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            	RecordTypeId = rtSACVP,                         // Record Type
            	EUR_CRM_Minimum_Weight__c = 50,                            // Minimum Weight
            	EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
            	EUR_CRM_Volume_Potential__c = PRS_SA_VP_HI.Id,
            	EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
        	);
        ListSAC.add(SAC8);
        

        Insert ListSAC;

//            Test.startTest();
            
            List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
            Id QuestionRecordType = rtMap.get(RECORD_TYPE_BG_QUESTION);
            //Create Question IL * 2 
            EUR_CRM_PRS_Question__c PRS_Q_BP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            //Create Question VP * 2 
            EUR_CRM_PRS_Question__c PRS_Q_BBP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BBP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 2',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            QuestionList.add(PRS_Q_BP_1);
            QuestionList.add(PRS_Q_BP_2);
            QuestionList.add(PRS_Q_BBP_1);
            QuestionList.add(PRS_Q_BBP_2);
            CreateAllQuestionType(PRS_QSet_BBP.Id, 'PRSQ_BBP_');
            insert QuestionList;
            
            //Create PRS Question Criteria
            Id QuestionCRecordType = rtMap.get(RECORD_TYPE_BG_QUESTION_C);
            
            List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0004');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0004');
            
            QuestionCList.add(QC_BP_1_1);
            QuestionCList.add(QC_BP_1_2);
            QuestionCList.add(QC_BP_2_1);
            QuestionCList.add(QC_BP_2_2);
            
            QuestionCList.add(QC_BBP_1_1);
            QuestionCList.add(QC_BBP_1_2);
            QuestionCList.add(QC_BBP_2_1);
            QuestionCList.add(QC_BBP_2_2);
            
            insert QuestionCList;
            //Create PRS Segmentation (EU)
            //Auto created when Account creation            
            
            
            
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account.Id Limit 1].Id;
            Id Ans_BP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BP);
            Id Ans_BBP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BBP);
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            answerList.Add(PRS_Q_BP_1_Ans);
            answerList.Add(PRS_Q_BP_2_Ans);
            answerList.Add(PRS_Q_BBP_1_Ans);
            answerList.Add(PRS_Q_BBP_2_Ans);
            
            insert answerList;
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_AC_BP);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 73;
            aspCriteria.EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id;
            insert aspCriteria;
            
            BG_Off_Account.EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id;
            BG_Off_Account.EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id;
            update BG_Off_Account;

            Test.stopTest();
            
//            EUR_CRM_Account__c BG_Off_Account2 = [SELECT Id, RecordTypeId, RecordType.DeveloperName,
//                            EUR_CRM_Force_Group_Outlet_Type__c,
//                            EUR_CRM_Force_Outlet_Type__c,
//                            EUR_CRM_Force_Business_potential__c,
//                            EUR_CRM_Force_Brand_Building_Potential__c,
//                            EUR_CRM_PRS_Group_Outlet_Type__c,
//                            EUR_CRM_PRS_Outlet_Type__c,
//                            EUR_CRM_Business_Potential__c,
//                            EUR_CRM_Brand_Building_Potential__c,
//                            EUR_CRM_PRS_Image_Level__c,
//                            EUR_CRM_PRS_Volume_Potential__c,
//                            EUR_CRM_Force_PRS_Image_Level__c,
//                            EUR_CRM_Force_PRS_Volume_Potential__c,
//                            EUR_CRM_PRS_Priority_Level_Criteria__c,
//                            EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Type_Name__c,
//                            EUR_CRM_PRS_Outlet_Type__r.EUR_CRM_PRS_Outlet_Type_Name__c,
//                            EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c,
//                            EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c,
//                            EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c,
//                            EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c,
//                            EUR_CRM_PRS_Priority_Level_Criteria__r.EUR_CRM_Priority_Level__c
//                     FROM EUR_CRM_Account__c
//                     Where id =: BG_Off_Account.Id];
//            System.Debug('@@@Account Test>>>'+ BG_Off_Account2);
        }
    }
    
    public static void testInitBG_2nd() {
        
        initRecordType();

		//test.startTest();
        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BG_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BG');
        } else {
            BG_UserA = userA[0];
        }
        
        
        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BG_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BG');
        } else {
            BG_UserB = userB[0];
        }
        //BG_User = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'bg.user@mail.com','BG User','BG');  
        
        System.runAs(BG_UserA)
        {
            BG_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BG_VISIT_FREQUENCY);
            insert BG_VisitFeq_List;
            
            //CREATE Region
            BG_Region = createRegion('Test Region' ,BG_UserA.Id , RECORD_TYPE_BG_REGION);
            //BG_Region = createRegion('BG_Region' ,BG_User.Id , 'EUR_BG_Region');
            //CREATE Territory
            BG_Territory = createTerritory('Test Territory',BG_UserA.Id ,BG_Region.Id ,RECORD_TYPE_BG_TERRITORY);
            //BG_Territory = createTerritory('BG Territory',BG_User.Id ,BG_Region.ID ,'EUR_BG_Territory');
            
            //CREATE Customer Taxonomy
            //BG_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BG_UserA.Id,RECORD_TYPE_BG_CUST_TAX);
            BG_Customer_Tax = createBGCustomerTaxonomy();
            //BG_Customer_Tax = createCustomerTaxonomy('BG_Cust_Tax',BG_User.Id,'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy');

            
            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            
            string ValueLow = 'Low';
            string ValueHigh = 'High';
            
            PRS_SA_BP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BP));
            PRS_SA_BP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BP));
            PRS_SA_BBP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BBP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BBP));
            PRS_SA_BBP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BBP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BG_PRS_A_BBP));
            
            PRS_SAList.Add(PRS_SA_BP_LOW);
            PRS_SAList.Add(PRS_SA_BP_HI);
            PRS_SAList.Add(PRS_SA_BBP_LOW);
            PRS_SAList.Add(PRS_SA_BBP_HI);
            
            insert PRS_SAList;
            
            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            PRS_QSet_BP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BG_PRS_Q_BP));
            PRS_QSet_BBP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BG_PRS_Q_BBP));
            QuestionSetList.add(PRS_QSet_BP);
            QuestionSetList.add(PRS_QSet_BBP);
            
            insert QuestionSetList;
            
            BG_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            //(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName)
            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT1 = createBGOffGOutletType(PRS_QSet_BBP.Id, PRS_QSet_BP.Id, 
                                                'BG_GOT_HYSUM', 'Hyper/Supermarket','BG Hyper/Supermarket',''  );
            
            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT2 = createBGOffGOutletType(PRS_QSet_BBP.Id, PRS_QSet_BP.Id, 
                                                'BG_GOT_CON', 'Convenience','BG Convenience',''  );
            BG_GroupOutlet_List.add(BG_GROUP_OT1);
            BG_GroupOutlet_List.add(BG_GROUP_OT2);
            
            insert BG_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + BG_GroupOutlet_List);
            
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_1 = createBGOffOutletType('Hypermarket',BG_GroupOutlet_List[0].id,'BG_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_2 = createBGOffOutletType('Supermarket',BG_GroupOutlet_List[0].id,'BG_OT_Supermarket');
            
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_1 = createBGOffOutletType('Convenience',BG_GroupOutlet_List[1].id,'BG_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_2 = createBGOffOutletType('Gas stations',BG_GroupOutlet_List[1].id,'BG_OT_Gas_stations');
            
            OutletTypeList.add(BG_GROUP_OT1_1);
            OutletTypeList.add(BG_GROUP_OT1_2);
            OutletTypeList.add(BG_GROUP_OT2_1);
            OutletTypeList.add(BG_GROUP_OT2_2);
            
            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);
            
            BG_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BG_GROUP_OT1.id,
                                                               EUR_CRM_BrandBuildPotQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BrandBuildPotQuestionSet__c,
                                                                EUR_CRM_BusinessPotentialQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BusinessPotentialQuestionSet__c,
                                                                EUR_CRM_External_ID__c = BG_GROUP_OT1.EUR_CRM_External_ID__c,
                                                                EUR_CRM_Group_Outlet_Type_Name__c = BG_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                                                                EUR_CRM_Name__c = BG_GROUP_OT1.EUR_CRM_Name__c,
                                                                EUR_CRM_PRS_Group_Outlet_Name__c = BG_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);
            
            
            //Setup Account
            //BE_On_Account     = createBEAccount('BE On Trade Account', '00000',  RECORD_TYPE_ACC_ON, BE_Customer_Tax.Id);
            //System.Debug('####Testing Account 1:' + BE_On_Account);
            //BG_Off_Account  = createBGAccount('Test Off Trade Account', '00000',  RECORD_TYPE_BG_ACC_OFF, BG_Customer_Tax.Id);
            BG_Off_Account_2nd = createBGOffAccount('Test Off Trade Account 2',BG_GROUP_OT1.id, BG_GROUP_OT1_1.Id );
            
            BG_Off_Account = [SELECT Id,RecordTypeId,EUR_CRM_Channel__c ,Name ,EUR_CRM_Sub_Channel__c ,EUR_CRM_Business_Type__c , EUR_CRM_Status__c ,EUR_CRM_Delivery_Type__c ,EUR_CRM_Country__c , EUR_CRM_Force_GOT_OT_by_CT__c FROM EUR_CRM_Account__c WHERE Id =: BG_Off_Account_2nd.Id];

            try{
                PRS_Seg = [SELECT Id,Name,EUR_CRM_Account__c,EUR_CRM_PRS_Group_Outlet_Type__c ,EUR_CRM_PRS_Outlet_Type__c,RecordType.DeveloperName FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account_2nd.Id];
                
                PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT1.Id;
                PRS_Seg.EUR_CRM_PRS_Outlet_Type__c= BG_GROUP_OT1_1.Id;
                update PRS_Seg;
                System.Debug('@@@Account PRS Check Update:' + PRS_Seg);
                
            } catch (Exception e) {
                PRS_Seg = new EUR_CRM_PRS_Segmentation__c();
                PRS_Seg.EUR_CRM_Account__c = BG_Off_Account_2nd.Id;
                PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT1.Id;
                PRS_Seg.EUR_CRM_PRS_Outlet_Type__c= BG_GROUP_OT1_1.Id;
                PRS_Seg.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_OFF);
                insert PRS_Seg;
                System.Debug('@@@Account PRS Check Insert:' + PRS_Seg);
            }          
            //GDT                        
            
            System.Debug('####Testing Account 1:' + BG_Off_Account_2nd);
         
            
            /*System.Debug('@@@Account PRS Check:' + [    SELECT Id,Name,EUR_CRM_Account__c,EUR_CRM_PRS_Group_Outlet_Type__c ,EUR_CRM_PRS_Outlet_Type__c,RecordType.DeveloperName 
                                                        FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account_2nd.Id]);*/
            
            
            
            
            
            //update PRS_Seg;
            
            
            System.Debug('@@Init Outlet:' + [SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Country_Code__c 
                                    FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE
                                    RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type'
                                   ]);
            
            
            
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACBBP = rtMap.get(RECORD_TYPE_PRS_AC_BBP);
            Id rtSACBP = rtMap.get(RECORD_TYPE_PRS_AC_BP);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC1 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC1);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC2 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_HI.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC2);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC3 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC3);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC4 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
              RecordTypeId = rtSACBP,                         // Record Type
              EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
              EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id,     // Group Outlet Type
              EUR_CRM_Business_Potential__c = PRS_SA_BP_HI.Id,  // Brand Building Potential
              EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC4);
            Insert ListSAC;

            Test.startTest();
            
            
            List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
            Id QuestionRecordType = rtMap.get(RECORD_TYPE_BG_QUESTION);
            //Create Question IL * 2 
            EUR_CRM_PRS_Question__c PRS_Q_BP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            //Create Question VP * 2 
            EUR_CRM_PRS_Question__c PRS_Q_BBP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_BBP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_BBP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'BBP Question 2',
                                                                                EUR_CRM_Question_Weight__c = 0.5,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_BBP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            QuestionList.add(PRS_Q_BP_1);
            QuestionList.add(PRS_Q_BP_2);
            QuestionList.add(PRS_Q_BBP_1);
            QuestionList.add(PRS_Q_BBP_2);
            CreateAllQuestionType(PRS_QSet_BBP.Id, 'PRSQ_BBP_');
            insert QuestionList;
            
            //Create PRS Question Criteria
            Id QuestionCRecordType = rtMap.get(RECORD_TYPE_BG_QUESTION_C);
            
            List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BP_0004');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_BBP_0004');
            
            QuestionCList.add(QC_BP_1_1);
            QuestionCList.add(QC_BP_1_2);
            QuestionCList.add(QC_BP_2_1);
            QuestionCList.add(QC_BP_2_2);
            
            QuestionCList.add(QC_BBP_1_1);
            QuestionCList.add(QC_BBP_1_2);
            QuestionCList.add(QC_BBP_2_1);
            QuestionCList.add(QC_BBP_2_2);
            
            insert QuestionCList;
            //Create PRS Segmentation (EU)
            //Auto created when Account creation            
            
            
            
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account_2nd.Id Limit 1].Id;
            Id Ans_BP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BP);
            Id Ans_BBP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_BBP);
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_BBP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            answerList.Add(PRS_Q_BP_1_Ans);
            answerList.Add(PRS_Q_BP_2_Ans);
            answerList.Add(PRS_Q_BBP_1_Ans);
            answerList.Add(PRS_Q_BBP_2_Ans);
            
            insert answerList;
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_AC_BP);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = BG_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 73;
            aspCriteria.EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id;
            insert aspCriteria;
            
            BG_Off_Account_2nd.EUR_CRM_Brand_Building_Potential__c = PRS_SA_BBP_LOW.Id;
            BG_Off_Account_2nd.EUR_CRM_Business_Potential__c = PRS_SA_BP_LOW.Id;
            update BG_Off_Account_2nd;
            test.stopTest();
            
        }
    }

    public static void testInitBE_OnTrade() {
        
        initRecordType();
  
        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BE_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        } else {
            BE_UserA = userA[0];
        }
        
        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BE_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BE');
        } else {
            BE_UserB = userB[0];
        }

        Test.startTest();
        
        System.runAs(BE_UserA)
        {
            BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BE_VISIT_FREQUENCY);
            insert BE_VisitFeq_List;
            
            //CREATE Region
            BE_Region = createRegion('Test Region' ,BE_UserA.Id , RECORD_TYPE_BE_REGION);
            
            //CREATE Territory
            BE_Territory = createTerritory('Test Territory',BE_UserA.Id ,BE_Region.Id ,RECORD_TYPE_BE_TERRITORY);
            
            //CREATE Customer Taxonomy
            BE_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BE_UserA.Id,RECORD_TYPE_BE_CUST_TAX);
            
            //Setup Account
            BE_On_Account     = createBEAccount('BE On Trade Account', '00000', RECORD_TYPE_BE_ACC_ON, BE_Customer_Tax.Id);
            System.Debug('####Testing Account 1:' + BE_On_Account);
         
            
            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id]);*/
            
            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
        	PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
        	PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Mainstream',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
        	PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
            
            PRS_SAList.Add(PRS_SA_VP_LOW);
            PRS_SAList.Add(PRS_SA_VP_HI);
            PRS_SAList.Add(PRS_SA_IL_LOW);
            PRS_SAList.Add(PRS_SA_IL_HI);
            
            insert PRS_SAList;
            
            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            PRS_QSet_IL = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_IL));
            PRS_QSet_VP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP',
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_VP));
            QuestionSetList.add(PRS_QSet_IL);
            QuestionSetList.add(PRS_QSet_VP);
            
            insert QuestionSetList;
            
            //Create Group Outlet List
            BE_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT1 = createBEOnGOutletType(PRS_QSet_IL.Id, PRS_QSet_VP.Id, 
                                                'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  );
            
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT2 = createBEOnGOutletType(PRS_QSet_IL.Id, PRS_QSet_VP.Id, 
                                                'BE_GOT_CON', 'Convenience','BE Convenience',''  );
            BE_GroupOutlet_List.add(BE_GROUP_OT1);
            BE_GroupOutlet_List.add(BE_GROUP_OT2);
            
            insert BE_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + BE_GroupOutlet_List);
            
            //Create Outlet Type List
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_1 = createBEOnOutletType('Hypermarket',BE_GroupOutlet_List[0].id,'BE_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_2 = createBEOnOutletType('Supermarket',BE_GroupOutlet_List[0].id,'BE_OT_Supermarket');
            
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_1 = createBEOnOutletType('Convenience',BE_GroupOutlet_List[1].id,'BE_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_2 = createBEOnOutletType('Gas stations',BE_GroupOutlet_List[1].id,'BE_OT_Gas_stations');
            
            OutletTypeList.add(BE_GROUP_OT1_1);
            OutletTypeList.add(BE_GROUP_OT1_2);
            OutletTypeList.add(BE_GROUP_OT2_1);
            OutletTypeList.add(BE_GROUP_OT2_2);
            
            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);
            
            BE_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BE_GROUP_OT1.id,
                                                                EUR_CRM_Image_Level_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Image_Level_Question_Set__c,
                                                                EUR_CRM_Volume_Potential_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Volume_Potential_Question_Set__c,
                                                                EUR_CRM_External_ID__c = BE_GROUP_OT1.EUR_CRM_External_ID__c,
                                                                EUR_CRM_Group_Outlet_Type_Name__c = BE_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                                                                EUR_CRM_Name__c = BE_GROUP_OT1.EUR_CRM_Name__c,
                                                                EUR_CRM_PRS_Group_Outlet_Name__c = BE_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);
            
            
            
            //Create Segmentation
            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_On_Account.Id Limit 1];
            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id;
            update PRS_Seg;
            
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACIL = rtMap.get(RECORD_TYPE_PRS_AC_IL);
            Id rtSACVP = rtMap.get(RECORD_TYPE_PRS_AC_VP);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC5 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     	 // Group Outlet Type
                EUR_CRM_Image_Level__c = PRS_SA_IL_LOW.Id, 				 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC5);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC6 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Image_Level__c = PRS_SA_IL_HI.Id, 	 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC6);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC7 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = PRS_SA_VP_LOW.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC7);
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC8 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = PRS_SA_VP_HI.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC8);
            insert ListSAC;
            
            List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
            Id QuestionRecordType = rtMap.get(RECORD_TYPE_BE_QUESTION);
            EUR_CRM_PRS_Question__c PRS_Q_IL_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_IL.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'IL Question 1',
                                                                                EUR_CRM_Question_Weight__c = 50,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_IL_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_IL_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_IL.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'IL Question 1',
                                                                                EUR_CRM_Question_Weight__c = 50,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_IL_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            //Create Question VP * 2 
            EUR_CRM_PRS_Question__c PRS_Q_VP_1 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_VP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'VP Question 1',
                                                                                EUR_CRM_Question_Weight__c = 50,
                                                                                EUR_CRM_Question_Sequence__c = 1,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_VP_0001',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            
            EUR_CRM_PRS_Question__c PRS_Q_VP_2 = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = PRS_QSet_VP.Id,
                                                                                recordTypeId = QuestionRecordType,
                                                                                EUR_CRM_Question_Statement__c = 'VP Question 2',
                                                                                EUR_CRM_Question_Weight__c = 50,
                                                                                EUR_CRM_Question_Sequence__c = 2,
                                                                                EUR_CRM_External_ID__c = 'PRSQ_VP_0002',
                                                                                EUR_CRM_Weight_Has_Changed__c = true);
            QuestionList.add(PRS_Q_IL_1);
            QuestionList.add(PRS_Q_IL_2);
            QuestionList.add(PRS_Q_VP_1);
            QuestionList.add(PRS_Q_VP_2);
            insert QuestionList;
            
            //Create PRS Question Criteria
            Id QuestionCRecordType = rtMap.get(RECORD_TYPE_BE_QUESTION_C);
            
            List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            EUR_CRM_PRS_Question_Criteria__c QC_IL_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_IL_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_IL_0004');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_VP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = 'PRSPA_VP_0004');
            
            QuestionCList.add(QC_IL_1_1);
            QuestionCList.add(QC_IL_1_2);
            QuestionCList.add(QC_IL_2_1);
            QuestionCList.add(QC_IL_2_2);
            
            QuestionCList.add(QC_VP_1_1);
            QuestionCList.add(QC_VP_1_2);
            QuestionCList.add(QC_VP_2_1);
            QuestionCList.add(QC_VP_2_2);
            
            insert QuestionCList;
			//Create PRS Segmentation (EU)
            //Auto created when Account creation            
            
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_On_Account.Id Limit 1].Id;
            Id Ans_IL_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_IL);
            Id Ans_VP_RecordTypeId = rtMap.get(RECORD_TYPE_ANSWER_VP);
            
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            EUR_CRM_PRS_Answer__c PRS_Q_IL_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_IL_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_IL_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 50);
            
            EUR_CRM_PRS_Answer__c PRS_Q_IL_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_IL_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_IL_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 50);
            
            EUR_CRM_PRS_Answer__c PRS_Q_VP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_VP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_VP_1.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 50);
            
            EUR_CRM_PRS_Answer__c PRS_Q_VP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_VP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_VP_2.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 50);
            answerList.Add(PRS_Q_IL_1_Ans);
            answerList.Add(PRS_Q_IL_2_Ans);
            answerList.Add(PRS_Q_VP_1_Ans);
            answerList.Add(PRS_Q_VP_2_Ans);
            
            insert answerList;
            
            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = rtMap.get(RECORD_TYPE_PRS_AC_IL);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 50;
            aspCriteria.EUR_CRM_Image_Level__c = PRS_SA_IL_LOW.Id;
            insert aspCriteria;
            
            BE_On_Account.EUR_CRM_PRS_Image_Level__c = PRS_SA_IL_LOW.Id;
            BE_On_Account.EUR_CRM_PRS_Volume_Potential__c = PRS_SA_VP_LOW.Id;
            update BE_On_Account;
        }
        Test.stopTest();
            
    }

    public static void testInitBE_OnTradeGut() {

        initRecordType();

        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            BE_UserA = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        } else {
            BE_UserA = userA[0];
        }

        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
        if (userB.size() == 0){
            BE_UserB = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BE');
        } else {
            BE_UserB = userB[0];
        }

        System.runAs(BE_UserA)
        {
            BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,RECORD_TYPE_BE_VISIT_FREQUENCY);
            insert BE_VisitFeq_List;

            //CREATE Region
            BE_Region = createRegion('Test Region' ,BE_UserA.Id , RECORD_TYPE_BE_REGION);

            //CREATE Territory
            BE_Territory = createTerritory('Test Territory',BE_UserA.Id ,BE_Region.Id ,RECORD_TYPE_BE_TERRITORY);

            //CREATE Customer Taxonomy
            BE_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BE_UserA.Id,RECORD_TYPE_BE_CUST_TAX);

            //Setup Account
            BE_On_Account     = createBEAccount('BE On Trade Account', '00000', RECORD_TYPE_BE_ACC_ON, BE_Customer_Tax.Id);
            System.Debug('####Testing Account 1:' + BE_On_Account);


            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id]);*/

            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
            PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_VP));
            PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Mainstream',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));
            PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_IL));

            PRS_SAList.Add(PRS_SA_VP_LOW);
            PRS_SAList.Add(PRS_SA_VP_HI);
            PRS_SAList.Add(PRS_SA_IL_LOW);
            PRS_SAList.Add(PRS_SA_IL_HI);

            insert PRS_SAList;

            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            PRS_QSet_IL = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_IL));
            PRS_QSet_VP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_VP));
            QuestionSetList.add(PRS_QSet_IL);
            QuestionSetList.add(PRS_QSet_VP);

            insert QuestionSetList;

            //Create Group Outlet List
            BE_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT1 = createBEOnGOutletType(PRS_QSet_IL.Id, PRS_QSet_VP.Id,
                'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  );

            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT2 = createBEOnGOutletType(PRS_QSet_IL.Id, PRS_QSet_VP.Id,
                'BE_GOT_CON', 'Convenience','BE Convenience',''  );
            BE_GroupOutlet_List.add(BE_GROUP_OT1);
            BE_GroupOutlet_List.add(BE_GROUP_OT2);

            insert BE_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + BE_GroupOutlet_List);

            //Create Outlet Type List
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_1 = createBEOnOutletType('Hypermarket',BE_GroupOutlet_List[0].id,'BE_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_2 = createBEOnOutletType('Supermarket',BE_GroupOutlet_List[0].id,'BE_OT_Supermarket');

            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_1 = createBEOnOutletType('Convenience',BE_GroupOutlet_List[1].id,'BE_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_2 = createBEOnOutletType('Gas stations',BE_GroupOutlet_List[1].id,'BE_OT_Gas_stations');

            OutletTypeList.add(BE_GROUP_OT1_1);
            OutletTypeList.add(BE_GROUP_OT1_2);
            OutletTypeList.add(BE_GROUP_OT2_1);
            OutletTypeList.add(BE_GROUP_OT2_2);

            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);

            BE_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BE_GROUP_OT1.id,
                EUR_CRM_Image_Level_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Image_Level_Question_Set__c,
                EUR_CRM_Volume_Potential_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Volume_Potential_Question_Set__c,
                EUR_CRM_External_ID__c = BE_GROUP_OT1.EUR_CRM_External_ID__c,
                EUR_CRM_Group_Outlet_Type_Name__c = BE_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                EUR_CRM_Name__c = BE_GROUP_OT1.EUR_CRM_Name__c,
                EUR_CRM_PRS_Group_Outlet_Name__c = BE_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);



            //Create Segmentation
            //EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_On_Account.Id Limit 1];
            //PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = BE_GROUP_OT.Id;
            //update PRS_Seg;
        }
    }
    
    
    //CREATE USER
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
    //CREATE REGION
    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner,  String recordtypename){
        System.Debug('@@@Create Region');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Region__c',recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner);
        insert region;
        return region;
    }
    //CREATE Territory
    public static EUR_CRM_Territory__c createTerritory(String name, Id territoryOwner, Id regionId, String recordtypename){
        System.Debug('@@@Create Territory');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Territory__c',recordtypename);
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = regionId, recordtypeid=recordtypeId,name = name,
        EUR_CRM_Territory_Owner__c = territoryOwner);
        system.debug('@territory'+territory);
        insert territory;
        return territory;
    }   
    //CREATE EUR_CRM_Postal_Code_Territory_Mapping__c
    public static EUR_CRM_Postal_Code_Territory_Mapping__c createPostalCodeMapping(String name, String postalCode, Id territoryid, String recordtypename){
        System.Debug('@@@Create Postal Code');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Postal_Code_Territory_Mapping__c',recordtypename);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c
        (EUR_CRM_Postal_Code__c = postalCode, recordtypeid=recordtypeId,name = name,
        EUR_CRM_Territory__c = territoryid);
        insert postalCodeTerritoryMapping;
        return postalCodeTerritoryMapping;
    }
    //CREATE EUR_CRM_Customer_Taxonomy__c
    public static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name,   Id ownerId, String recordtypename){
        System.Debug('@@@Create Customer Taxonomy');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',recordtypename);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c
        (recordtypeid=recordtypeId,name = name,
        ownerid  = ownerId );
        insert customerTaxonomy;
        return customerTaxonomy;
    }
    
    public static EUR_CRM_Customer_Taxonomy__c createBGCustomerTaxonomy(){
        List<EUR_CRM_Customer_Taxonomy__c> CustomerTaxonomys = New List<EUR_CRM_Customer_Taxonomy__c>();
        id rtIdWholesalers = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_BG_Wholesalers_Customer_Taxonomy');
        id rtIdBGOffTrade = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_BG_Traditional_Off_Trade_Customer_Taxonomy');
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy1 = New EUR_CRM_Customer_Taxonomy__c(Name = 'BG_OFF_Wholesalers',
                                                                                          EUR_CRM_External_ID__c = 'BG_OFF_Wholesalers',
                                                                                          RecordTypeId = rtIdWholesalers, 
                                                                                          EUR_CRM_Level_1__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_2__c = 'Wholesalers');
        
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy2 = New EUR_CRM_Customer_Taxonomy__c(Name = 'BG_Traditional',
                                                                                          EUR_CRM_External_ID__c = 'BG_Traditional',
                                                                                          RecordTypeId = rtIdBGOffTrade, 
                                                                                          EUR_CRM_Level_1__c = 'Traditional',
                                                                                          EUR_CRM_Level_2__c = 'Traditional');
        CustomerTaxonomys.add(CustomerTaxonomy1);
        CustomerTaxonomys.add(CustomerTaxonomy2);
        

        insert CustomerTaxonomys;
        return CustomerTaxonomys[0];
    }

    //CREATE EUR_CRM_Account__c
    public static EUR_CRM_Account__c createBEAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy){
        System.Debug('@@@Create BE Account');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = postalCode,
            recordtypeid=recordtypeId,
            name = name,
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy,
            EUR_CRM_Business_Type__c = 'Outlet',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Visit_Frequency__c = BE_VisitFeq_List[0].Id,
            EUR_CRM_Delivery_Type__c = 'Direct'
        );
        insert euAccount;
        return euAccount;
    }
    
    
    public static EUR_CRM_Account__c createBGAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy){
        System.Debug('@@@Create BG Account');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        //Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Account__c' + recordtypename);

        EUR_CRM_PRS_Group_Outlet_Type__c goutletType = new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_Name__c='Online');
        insert goutletType;
        EUR_CRM_PRS_Outlet_Type__c outletType = new EUR_CRM_PRS_Outlet_Type__c(EUR_CRM_PRS_Outlet_Type_Name__c='e-shop', EUR_CRM_PRS_Group_Outlet_Type__c=goutletType.Id);
        insert outletType;
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = goutletType.Id,
            EUR_CRM_PRS_Outlet_Type__c = outletType.Id,
            EUR_CRM_Postal_Code__c = postalCode,
            recordtypeid=recordtypeId,
            name = name,
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy,
            EUR_CRM_Business_Type__c = 'Outlet',
            EUR_CRM_Status__c = 'Active',
            EUR_CRM_Visit_Frequency__c = BG_VisitFeq_List[0].Id,
            EUR_CRM_Delivery_Type__c = 'Indirect',
            EUR_CRM_Channel__c = 'OFF TRADE',
            EUR_CRM_Sub_Channel__c = 'Traditional Off-Trade',
            EUR_CRM_Force_GOT_OT_by_CT__c = false
        );
        
        System.Debug('@@@BG Account :' + euAccount);
        insert euAccount;
        return euAccount;
        /*
        Id rtId = [select id from recordtype where developername = 'EUR_BG_Wholesaler' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        EUR_CRM_Group_Outlet_Type__c goutletType = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c='Restaurant');
        insert goutletType;
        EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Name__c='Restaurant', EUR_CRM_Group_Outlet_Type__c=goutletType.Id);
        insert outletType;
        EUR_CRM_Account__c acct = new EUR_CRM_Account__c(Name='GB test on trade Supplier account');
        acct.EUR_CRM_Group_Outlet_Type__c = goutletType.Id;
        acct.EUR_CRM_Outlet_Type__c = outletType.Id;
        acct.recordtypeid = rtId;
        acct.EUR_CRM_Status__c = 'Inactive';
        //acct.EUR_JB_Customer_Taxonomy__c = CunstomerTaxonomy.Id;
        insert acct;
        return acct;
        */

    }
    
    
    public static EUR_CRM_Account__c createBGOffAccount(String name, Id goutletType, Id outletType){
        System.Debug('@@@Create BG Account');
        //Id recordtypeId = [SELECT Id FROM recordType where DeveloperName = 'EUR_BG_Modern_Off_Trade' LIMIT 1 ].Id;
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Account__c' + 'EUR_BG_Modern_Off_Trade');

        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
              RecordTypeId = recordtypeId,                  // Record Type
              EUR_CRM_Channel__c = 'OFF TRADE',                  // Channel
              Name = 'BG Account Test',                    // Account Name
              EUR_CRM_Sub_Channel__c = 'Modern Off-Trade',       // Sub Channel
              EUR_CRM_Business_Type__c = 'Head Office',          // Business Type
              EUR_CRM_Status__c = 'Active',                      // Status
              EUR_CRM_Delivery_Type__c = 'Direct',               // Delivery Type
              EUR_CRM_Country__c = 'Bulgaria',                   // Country
              EUR_CRM_Force_GOT_OT_by_CT__c = false,             // Force GroupOutletType/OutletType by CT
              EUR_CRM_Postal_Code__c = '123456'
        );
        
        System.Debug('@@@BG Off Account :' + euAccount);
        insert euAccount;
        return euAccount;
    }
    
    public static EUR_CRM_PRS_Group_Outlet_Type__c createBGOffGOutletType(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName){
        //EUR_BE_PRS_On_Trade_Group_Outlet_Type
        //EUR_BE_PRS_Off_Trade_Group_Outlet_Type
        //EUR_BG_PRS_Off_Trade_Group_Outlet_Type
        //ID rtId = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Off_Trade_Group_Outlet_Type' LIMIT 1].id;
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Group_Outlet_Type__c' + 'EUR_BG_PRS_Off_Trade_Group_Outlet_Type');
        EUR_CRM_PRS_Group_Outlet_Type__c GOT = new EUR_CRM_PRS_Group_Outlet_Type__c(
                                                recordTypeId = rtId,
                                                EUR_CRM_BrandBuildPotQuestionSet__c = BBPQSId,
                                                EUR_CRM_BusinessPotentialQuestionSet__c = BPQSId,
                                                EUR_CRM_External_ID__c = ExtId,
                                                EUR_CRM_Group_Outlet_Type_Name__c = GOTName,
                                                EUR_CRM_Name__c = Name,
                                                EUR_CRM_PRS_Group_Outlet_Name__c = GOName
                                                ); 
        return GOT;
    }
    
    
    
    public static EUR_CRM_PRS_Outlet_Type__c createBGOffOutletType(String Name, Id GroupOutletType, String ExtID){
        //ID rtId = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Off_Trade_Outlet_Type' LIMIT 1].id;
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Outlet_Type__c' + 'EUR_BG_PRS_Off_Trade_Outlet_Type');
          EUR_CRM_PRS_Outlet_Type__c sobj = new EUR_CRM_PRS_Outlet_Type__c(
                                                  RecordTypeId = rtId,                      // Record Type
                                                  EUR_CRM_PRS_Outlet_Type_Name__c = Name,       // PRS Outlet Type Name
                                                  EUR_CRM_PRS_Group_Outlet_Type__c = GroupOutletType,  // PRS Group Outlet Type
                                                  EUR_CRM_Active__c = true,                              // Active
                                                  EUR_CRM_External_ID__c = ExtID          // External ID
                                            );
        
        return sobj;
    }

    public static EUR_CRM_PRS_Group_Outlet_Type__c createBEOffGOutletType(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName){
        //EUR_BE_PRS_On_Trade_Group_Outlet_Type
        //EUR_BE_PRS_Off_Trade_Group_Outlet_Type
        //EUR_BG_PRS_Off_Trade_Group_Outlet_Type
        //ID rtId = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Off_Trade_Group_Outlet_Type' LIMIT 1].id;
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Group_Outlet_Type__c' + 'EUR_BE_PRS_Off_Trade_Group_Outlet_Type');
        EUR_CRM_PRS_Group_Outlet_Type__c GOT = new EUR_CRM_PRS_Group_Outlet_Type__c(
                                                recordTypeId = rtId,
                                                EUR_CRM_BrandBuildPotQuestionSet__c = BBPQSId,
                                                EUR_CRM_BusinessPotentialQuestionSet__c = BPQSId,
                                                EUR_CRM_External_ID__c = ExtId,
                                                EUR_CRM_Group_Outlet_Type_Name__c = GOTName,
                                                EUR_CRM_Name__c = Name,
                                                EUR_CRM_PRS_Group_Outlet_Name__c = GOName
                                                ); 
        return GOT;
    }
    
    public static EUR_CRM_PRS_Group_Outlet_Type__c createBEOnGOutletType(Id ILQSId, Id VPQSId, String ExtId, String GOTName, String Name, String GOName){
        //EUR_BE_PRS_On_Trade_Group_Outlet_Type
        //EUR_BE_PRS_Off_Trade_Group_Outlet_Type
        //EUR_BG_PRS_Off_Trade_Group_Outlet_Type
        //ID rtId = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Off_Trade_Group_Outlet_Type' LIMIT 1].id;
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Group_Outlet_Type__c' + 'EUR_BE_PRS_On_Trade_Group_Outlet_Type');
        EUR_CRM_PRS_Group_Outlet_Type__c GOT = new EUR_CRM_PRS_Group_Outlet_Type__c(
                                                recordTypeId = rtId,
                                                EUR_CRM_Image_Level_Question_Set__c = ILQSId,
                                                EUR_CRM_Volume_Potential_Question_Set__c = VPQSId,
                                                EUR_CRM_External_ID__c = ExtId,
                                                EUR_CRM_Group_Outlet_Type_Name__c = GOTName,
                                                EUR_CRM_Name__c = Name,
                                                EUR_CRM_PRS_Group_Outlet_Name__c = GOName
                                                ); 
        return GOT;
    }
    
    public static EUR_CRM_PRS_Outlet_Type__c createBEOffOutletType(String Name, Id GroupOutletType, String ExtID){
        //ID rtId = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Off_Trade_Outlet_Type' LIMIT 1].id;
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Outlet_Type__c' + 'EUR_BE_PRS_Off_Trade_Outlet_Type');
          EUR_CRM_PRS_Outlet_Type__c sobj = new EUR_CRM_PRS_Outlet_Type__c(
                                                  RecordTypeId = rtId,                      // Record Type
                                                  EUR_CRM_PRS_Outlet_Type_Name__c = Name,       // PRS Outlet Type Name
                                                  EUR_CRM_PRS_Group_Outlet_Type__c = GroupOutletType,  // PRS Group Outlet Type
                                                  EUR_CRM_Active__c = true,                              // Active
                                                  EUR_CRM_External_ID__c = ExtID          // External ID
                                            );
        
        return sobj;
    }
    
    public static EUR_CRM_PRS_Outlet_Type__c createBEOnOutletType(String Name, Id GroupOutletType, String ExtID){
        ID rtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Outlet_Type__c' + 'EUR_BE_PRS_On_Trade_Outlet_Type');
          EUR_CRM_PRS_Outlet_Type__c sobj = new EUR_CRM_PRS_Outlet_Type__c(
                                                  RecordTypeId = rtId,                      // Record Type
                                                  EUR_CRM_PRS_Outlet_Type_Name__c = Name,       // PRS Outlet Type Name
                                                  EUR_CRM_PRS_Group_Outlet_Type__c = GroupOutletType,  // PRS Group Outlet Type
                                                  EUR_CRM_Active__c = true,                              // Active
                                                  EUR_CRM_External_ID__c = ExtID          // External ID
                                            );
        
        return sobj;
    }
        
    
    Public static EUR_CRM_PRS_Question_Set__c createQuestionSet(String ExtId ,String rtDeveloperName){
        EUR_CRM_PRS_Question_Set__c PRS_QSet = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = ExtId,
                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(), 
                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',rtDeveloperName));
        insert PRS_QSet;
        return PRS_QSet;
    }
    
    public static List<EUR_CRM_PRS_Question__c> CreateAllQuestionType(Id QuestionSet,String ExtIdPrefix){
        List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
        //Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'RecordTypeName');

        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;

        Id rtBoolean = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BG_PRS_Question_Boolean_Input');
        Id rtCurrency = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BG_PRS_Question_Currency_Input');
        Id rtNumber = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BG_PRS_Question_Number_Input');
        Id rtPicklist = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BG_PRS_Question_Picklist_Input');
        Id rtText = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BG_PRS_Question_Text_Input');




        EUR_CRM_PRS_Question__c PRS_Q_Boolean = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtBoolean,
                                                                         EUR_CRM_Question_Statement__c = 'Question 1',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 1,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0001' );
        EUR_CRM_PRS_Question__c PRS_Q_Currency = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtCurrency,
                                                                         EUR_CRM_Question_Statement__c = 'Question 2',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 2,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0002' );
        EUR_CRM_PRS_Question__c PRS_Q_Number = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtNumber,
                                                                         EUR_CRM_Question_Statement__c = 'Question 3',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 3,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0003' );
        EUR_CRM_PRS_Question__c PRS_Q_Picklist = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtPicklist,
                                                                         EUR_CRM_Question_Statement__c = 'Question 4',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 4,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0004' );
        EUR_CRM_PRS_Question__c PRS_Q_Text = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtText,
                                                                         EUR_CRM_Question_Statement__c = 'Question 5',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 4,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0005' );
        QuestionList.add(PRS_Q_Boolean);
        QuestionList.add(PRS_Q_Currency);
        QuestionList.add(PRS_Q_Number);
        QuestionList.add(PRS_Q_Picklist);
        QuestionList.add(PRS_Q_Text);
        insert QuestionList;
        
        //Create PRS Question Criteria
        //
        //EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
        //EUR_CRM_Answer_Condition__c = 'Less Then(<)',
                                                                                                
        //Id QuestionCRecordType = [SELECT Id FROM RecordType where sObjectType = 'EUR_CRM_PRS_Question_Criteria__c' and DeveloperName = :RECORD_TYPE_BG_QUESTION_C limit 1].id;
        Id QuestionCRecordType = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question_Criteria__c' + RECORD_TYPE_BG_QUESTION_C);


        List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 1,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0002');
            String Cur = '10';
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Currency__c =  Decimal.valueOf(Cur),
                                                                                                EUR_CRM_Answer_Condition__c = 'Less Than (<)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Currency__c = Decimal.valueOf(Cur),
                                                                                                EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0004');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_1 = New EUR_CRM_PRS_Question_Criteria__c( EUR_CRM_PRS_Question__c = PRS_Q_Number.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Number__c = 1,
                                                                                                EUR_CRM_Answer_Condition__c = 'Less Than (<)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_2 = New EUR_CRM_PRS_Question_Criteria__c( EUR_CRM_PRS_Question__c = PRS_Q_Number.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Number__c = 1,
                                                                                                EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0004');
        
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_3_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Text.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = '',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0005');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_3_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Text.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = '',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0006');
            
            QuestionCList.add(QC_BP_1_1);
            QuestionCList.add(QC_BP_1_2);
            QuestionCList.add(QC_BP_2_1);
            QuestionCList.add(QC_BP_2_2);
            
            QuestionCList.add(QC_BBP_1_1);
            QuestionCList.add(QC_BBP_1_2);
            QuestionCList.add(QC_BBP_2_1);
            QuestionCList.add(QC_BBP_2_2);
            QuestionCList.add(QC_BBP_3_1);
            QuestionCList.add(QC_BBP_3_2);
            
            insert QuestionCList;
        
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BG_Off_Account.Id Limit 1].Id;
            //Id Ans_BP_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_BP Limit 1].Id;
            //Id Ans_BBP_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_BBP Limit 1].Id;
            Id Ans_BP_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_BP);
            Id Ans_BBP_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_BBP);
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Number.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            answerList.Add(PRS_Q_BP_1_Ans);
            answerList.Add(PRS_Q_BP_2_Ans);
            answerList.Add(PRS_Q_BBP_1_Ans);
            answerList.Add(PRS_Q_BBP_2_Ans);
            
            insert answerList;
        return QuestionList;
    }

    public static List<EUR_CRM_PRS_Question__c> CreateAllQuestionType_BE(Id QuestionSet,String ExtIdPrefix){
        List<EUR_CRM_PRS_Question__c> QuestionList = new List<EUR_CRM_PRS_Question__c>();
        //Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'RecordTypeName');

        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;

        Id rtBoolean = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BE_PRS_Question_Boolean_Input');
        Id rtCurrency = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BE_PRS_Question_Currency_Input');
        Id rtNumber = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BE_PRS_Question_Number_Input');
        Id rtPicklist = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BE_PRS_Question_Picklist_Input');
        Id rtText = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question__c' + 'EUR_BE_PRS_Question_Text_Input');




        EUR_CRM_PRS_Question__c PRS_Q_Boolean = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtBoolean,
                                                                         EUR_CRM_Question_Statement__c = 'Question 1',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 1,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0001' );
        EUR_CRM_PRS_Question__c PRS_Q_Currency = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtCurrency,
                                                                         EUR_CRM_Question_Statement__c = 'Question 2',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 2,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0002' );
        EUR_CRM_PRS_Question__c PRS_Q_Number = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtNumber,
                                                                         EUR_CRM_Question_Statement__c = 'Question 3',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 3,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0003' );
        EUR_CRM_PRS_Question__c PRS_Q_Picklist = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtPicklist,
                                                                         EUR_CRM_Question_Statement__c = 'Question 4',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 4,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0004' );
        EUR_CRM_PRS_Question__c PRS_Q_Text = New EUR_CRM_PRS_Question__c(   EUR_CRM_PRS_Question_Set__c = QuestionSet,
                                                                         recordTypeId = rtText,
                                                                         EUR_CRM_Question_Statement__c = 'Question 5',
                                                                         EUR_CRM_Question_Weight__c = 0.2,
                                                                         EUR_CRM_Question_Sequence__c = 4,
                                                                         EUR_CRM_External_ID__c = ExtIdPrefix+'PRSQ_0005' );
        QuestionList.add(PRS_Q_Boolean);
        QuestionList.add(PRS_Q_Currency);
        QuestionList.add(PRS_Q_Number);
        QuestionList.add(PRS_Q_Picklist);
        QuestionList.add(PRS_Q_Text);
        insert QuestionList;
        
        //Create PRS Question Criteria
        //
        //EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
        //EUR_CRM_Answer_Condition__c = 'Less Then(<)',
                                                                                                
        //Id QuestionCRecordType = [SELECT Id FROM RecordType where sObjectType = 'EUR_CRM_PRS_Question_Criteria__c' and DeveloperName = :RECORD_TYPE_BG_QUESTION_C limit 1].id;
        Id QuestionCRecordType = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Question_Criteria__c' + RECORD_TYPE_BG_QUESTION_C);


        List<EUR_CRM_PRS_Question_Criteria__c> QuestionCList = new List<EUR_CRM_PRS_Question_Criteria__c>();
            /*EUR_CRM_PRS_Question_Criteria__c QC_BP_1_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 1,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_1_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0002');
            String Cur = '10';
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Currency__c =  Decimal.valueOf(Cur),
                                                                                                EUR_CRM_Answer_Condition__c = 'Less Than (<)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Currency__c = Decimal.valueOf(Cur),
                                                                                                EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BP_0004');*/
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_1 = New EUR_CRM_PRS_Question_Criteria__c( EUR_CRM_PRS_Question__c = PRS_Q_Number.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Number__c = 1,
                                                                                                EUR_CRM_Answer_Condition__c = 'Less Than (<)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0001');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_1_2 = New EUR_CRM_PRS_Question_Criteria__c( EUR_CRM_PRS_Question__c = PRS_Q_Number.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Threshold_Number__c = 1,
                                                                                                EUR_CRM_Answer_Condition__c = 'Greater Than or Equal (>=)',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0002');
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'TRUE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0003');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_2_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = 'FALSE',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0004');
        
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_3_1 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Text.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'Yes',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = '',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0005');     
            
            EUR_CRM_PRS_Question_Criteria__c QC_BBP_3_2 = New EUR_CRM_PRS_Question_Criteria__c(  EUR_CRM_PRS_Question__c = PRS_Q_Text.Id, 
                                                                                                recordTypeId = QuestionCRecordType,
                                                                                                EUR_CRM_Criteria_Picklist_Label__c = 'No',
                                                                                                EUR_CRM_Criteria_Picklist_Value__c = '',
                                                                                                EUR_CRM_Criteria_Weight__c = 0.5,
                                                                                                EUR_CRM_External_ID__c = ExtIdPrefix + 'PRSPA_BBP_0006');
            
            /*QuestionCList.add(QC_BP_1_1);
            QuestionCList.add(QC_BP_1_2);
            QuestionCList.add(QC_BP_2_1);
            QuestionCList.add(QC_BP_2_2);*/
            
            QuestionCList.add(QC_BBP_1_1);
            QuestionCList.add(QC_BBP_1_2);
            QuestionCList.add(QC_BBP_2_1);
            QuestionCList.add(QC_BBP_2_2);
            QuestionCList.add(QC_BBP_3_1);
            QuestionCList.add(QC_BBP_3_2);
            
            insert QuestionCList;
        
            Id PRSSegmentId = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id Limit 1].Id;
            //Id Ans_BP_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_BP Limit 1].Id;
            //Id Ans_BBP_RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_PRS_Answer__c' AND developerName = :RECORD_TYPE_ANSWER_BBP Limit 1].Id;
            //Id Ans_BP_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_BP);
            Id Ans_BBP_RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + RECORD_TYPE_ANSWER_BBP);
            //Create Answer
            List<EUR_CRM_PRS_Answer__c> answerList = New List<EUR_CRM_PRS_Answer__c>();
            
            /*EUR_CRM_PRS_Answer__c PRS_Q_BP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Currency.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Number.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);*/
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_1_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Boolean.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            
            EUR_CRM_PRS_Answer__c PRS_Q_BBP_2_Ans = New EUR_CRM_PRS_Answer__c(EUR_CRM_PRS_Segmentation__c = PRSSegmentId,
                                                                             recordTypeId = Ans_BBP_RecordTypeId,
                                                                             EUR_CRM_PRS_Question__c = PRS_Q_Picklist.Id,
                                                                             EUR_CRM_Answer__c = 'TRUE',
                                                                             EUR_CRM_Weight__c = 0.5);
            /*answerList.Add(PRS_Q_BP_1_Ans);
            answerList.Add(PRS_Q_BP_2_Ans);*/
            answerList.Add(PRS_Q_BBP_1_Ans);
            answerList.Add(PRS_Q_BBP_2_Ans);
            
            insert answerList;
        return QuestionList;
    }
    
    static void testUpdateQuestionCriteriaBE(){

         
        testInitBE();
         
        System.runAs(BE_UserB)
        {

            List<EUR_CRM_PRS_Question_Criteria__c> PRS_QCs = [   SELECT Id,EUR_CRM_Criteria_Weight__c 
                                                                FROM EUR_CRM_PRS_Question_Criteria__c 
                                                                WHERE EUR_CRM_External_ID__c 
                                                                in ('PRSPA_IL_0001','PRSPA_IL_0002','PRSPA_VP_0001','PRSPA_VP_0002') Limit 1];

            /*EUR_CRM_PRS_Question_Criteria__c QC_IL1 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_IL_0001' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_IL2 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_IL_0002' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_VP1 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_VP_0001' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_VP2 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_VP_0002' Limit 1];*/
            
            Decimal Weight = 0.8;
            For(EUR_CRM_PRS_Question_Criteria__c QC : PRS_QCs){
                If(Weight == 0.8){
                    Weight = 0.2;
                }else{
                    Weight = 0.8;
                }

                QC.EUR_CRM_Criteria_Weight__c = Weight;
            }

            /*QC_IL1.EUR_CRM_Criteria_Weight__c = 0.2;
            QC_IL2.EUR_CRM_Criteria_Weight__c = 0.8;
            QC_VP1.EUR_CRM_Criteria_Weight__c = 0.2;
            QC_VP2.EUR_CRM_Criteria_Weight__c = 0.8;
    
            List<EUR_CRM_PRS_Question_Criteria__c> updateList = New List<EUR_CRM_PRS_Question_Criteria__c>();
            updateList.add(QC_IL1);
            updateList.add(QC_IL2);
            updateList.add(QC_VP1);
            updateList.add(QC_VP2);*/
            
            update PRS_QCs;
            
            List<EUR_CRM_PRS_Question__c> PRS_Qs = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                                    FROM EUR_CRM_PRS_Question__c  
                                                    WHERE EUR_CRM_External_ID__c 
                                                    in ('PRSQ_IL_0001','PRSQ_IL_0002','PRSQ_VP_0001','PRSQ_VP_0002')];
            
            /*EUR_CRM_PRS_Question__c Q_IL1 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_IL_0001'];
            EUR_CRM_PRS_Question__c Q_IL2 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_IL_0002'];
            EUR_CRM_PRS_Question__c Q_VP1 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_VP_0001'];
            EUR_CRM_PRS_Question__c Q_VP2 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_VP_0002'];*/

            For(EUR_CRM_PRS_Question__c Q : PRS_Qs){
                If(Weight == 0.8){
                    Weight = 0.2;
                }else{
                    Weight = 0.8;
                }

                Q.EUR_CRM_Question_Weight__c = Weight;
            }
            
            /*Q_IL1.EUR_CRM_Question_Weight__c = 0.2;
            Q_IL2.EUR_CRM_Question_Weight__c = 0.8;
            Q_VP1.EUR_CRM_Question_Weight__c = 0.2;
            Q_VP2.EUR_CRM_Question_Weight__c = 0.8;
            
            List<EUR_CRM_PRS_Question__c > updateList2 = New List<EUR_CRM_PRS_Question__c >();
            updateList2.add(Q_IL1);
            updateList2.add(Q_IL2);
            updateList2.add(Q_VP1);
            updateList2.add(Q_VP2);*/

            
            update PRS_Qs; 
        }  
    }
   
    static void testUpdateQuestionCriteriaBG(){
        testInitBG();
         
        System.runAs(BG_UserB)
        {

            List<EUR_CRM_PRS_Question_Criteria__c> PRS_QCs = [  SELECT Id,EUR_CRM_Criteria_Weight__c 
                                                                FROM EUR_CRM_PRS_Question_Criteria__c 
                                                                WHERE EUR_CRM_External_ID__c 
                                                                in ('PRSPA_IL_0001','PRSPA_IL_0002','PRSPA_VP_0001','PRSPA_VP_0002') Limit 1];

            /*EUR_CRM_PRS_Question_Criteria__c QC_IL1 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_BP_0001' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_IL2 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_BP_0002' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_VP1 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_BBP_0001' Limit 1];
            EUR_CRM_PRS_Question_Criteria__c QC_VP2 = [SELECT Id,EUR_CRM_Criteria_Weight__c FROM EUR_CRM_PRS_Question_Criteria__c WHERE EUR_CRM_External_ID__c = 'PRSPA_BBP_0002' Limit 1];*/
            
            
            Decimal Weight = 0.8;
            For(EUR_CRM_PRS_Question_Criteria__c QC : PRS_QCs){
                If(Weight == 0.8){
                    Weight = 0.2;
                }else{
                    Weight = 0.8;
                }

                QC.EUR_CRM_Criteria_Weight__c = Weight;
            }

            /*QC_IL1.EUR_CRM_Criteria_Weight__c = 0.2;
            QC_IL2.EUR_CRM_Criteria_Weight__c = 0.8;
            QC_VP1.EUR_CRM_Criteria_Weight__c = 0.2;
            QC_VP2.EUR_CRM_Criteria_Weight__c = 0.8;
    
            List<EUR_CRM_PRS_Question_Criteria__c> updateList = New List<EUR_CRM_PRS_Question_Criteria__c>();
            updateList.add(QC_IL1);
            updateList.add(QC_IL2);
            updateList.add(QC_VP1);
            updateList.add(QC_VP2);
            
            update updateList;*/
            update PRS_QCs;
            
            /*EUR_CRM_PRS_Question__c Q_IL1 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_BP_0001'];
            EUR_CRM_PRS_Question__c Q_IL2 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_BP_0002'];
            EUR_CRM_PRS_Question__c Q_VP1 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_BBP_0001'];
            EUR_CRM_PRS_Question__c Q_VP2 = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c  WHERE EUR_CRM_External_ID__c = 'PRSQ_BBP_0002'];*/

            List<EUR_CRM_PRS_Question__c> PRS_Qs = [SELECT Id,EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                        FROM EUR_CRM_PRS_Question__c  
                                        WHERE EUR_CRM_External_ID__c 
                                        in ('PRSQ_IL_0001','PRSQ_IL_0002','PRSQ_VP_0001','PRSQ_VP_0002')];
            
            /* Q_IL1.EUR_CRM_Question_Weight__c = 0.2;
            Q_IL2.EUR_CRM_Question_Weight__c = 0.8;
            Q_VP1.EUR_CRM_Question_Weight__c = 0.2;
            Q_VP2.EUR_CRM_Question_Weight__c = 0.8;
            
            List<EUR_CRM_PRS_Question__c > updateList2 = New List<EUR_CRM_PRS_Question__c >();
            updateList2.add(Q_IL1);
            updateList2.add(Q_IL2);
            updateList2.add(Q_VP1);
            updateList2.add(Q_VP2);*/

            For(EUR_CRM_PRS_Question__c Q : PRS_Qs){ 
                If(Weight == 0.8){
                    Weight = 0.2;
                }else{
                    Weight = 0.8;
                }

                Q.EUR_CRM_Question_Weight__c = Weight;
            }
            
            //update updateList2; 
            update PRS_Qs;
        }  
    }
}