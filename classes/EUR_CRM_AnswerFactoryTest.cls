@isTest
public class EUR_CRM_AnswerFactoryTest {
    static testMethod void unitTest1(){
        
        EUR_CRM_AnswerManager Mgr = New EUR_CRM_AnswerManager('BG');
        Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            EUR_CRM_PRS_Question_Set__c QS = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('BG',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP);
            EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QS.Id,'BG');
        }

        EUR_CRM_PRS_Question__c question  = [SELECT Id,EUR_CRM_Country_Code__c,EUR_CRM_External_ID__c,
                                             EUR_CRM_PRS_Question_Set__c,EUR_CRM_Question_Sequence__c,
                                             EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                             FROM EUR_CRM_PRS_Question__c WHERE EUR_CRM_External_ID__c = 'BGPRSQ_0001'];
                
        List<EUR_CRM_PRS_Question_Criteria__c> QuestionC = [SELECT Id,
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Criteria_Picklist_Label__c,
                                                            EUR_CRM_Criteria_Picklist_Value__c,
                                                            EUR_CRM_Answer_Statement__c,
                                                            EUR_CRM_Criteria_Weight__c,
                                                            EUR_CRM_External_ID__c,
                                                            EUR_CRM_PRS_Question__c , 
                                                            EUR_CRM_Answer_Condition__c,
                                                            EUR_CRM_Criteria_Threshold_Currency__c,
                                                            EUR_CRM_Criteria_Threshold_Number__c
                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                            WHERE EUR_CRM_PRS_Question__c = :question.Id];
        EUR_CRM_AnswerFactory.IQuestionsInterface AnsFactory = Mgr.newClassInstance(rtBoolean);
        Id key = question.Id;
        String target = '{!answerSheet["'+key+'"]}';
        String value = '';
        try{
            AnsFactory.setQuestion(question,QuestionC);
            AnsFactory.getFieldSet();
            AnsFactory.getLabelSet();
            AnsFactory.calculateQuestion(50,QuestionC,'TRUE');
        }catch(Exception e){
            System.Debug('@@@Test1:'+e);
        }
        try{
        	AnsFactory.getQuestionComponent(question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test1:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id,question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test1:'+e);
        }
    }   
    static testMethod void unitTest2(){
        
        EUR_CRM_AnswerManager Mgr = New EUR_CRM_AnswerManager('BG');
        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            EUR_CRM_PRS_Question_Set__c QS = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('BG',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP);
            EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QS.Id,'BG');
        }

        EUR_CRM_PRS_Question__c question  = [SELECT Id,EUR_CRM_Country_Code__c,EUR_CRM_External_ID__c,
                                             EUR_CRM_PRS_Question_Set__c,EUR_CRM_Question_Sequence__c,
                                             EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                             FROM EUR_CRM_PRS_Question__c WHERE EUR_CRM_External_ID__c = 'BGPRSQ_0002'];
                
        List<EUR_CRM_PRS_Question_Criteria__c> QuestionC = [SELECT Id,
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Criteria_Picklist_Label__c,
                                                            EUR_CRM_Criteria_Picklist_Value__c,
                                                            EUR_CRM_Answer_Statement__c,
                                                            EUR_CRM_Criteria_Weight__c,
                                                            EUR_CRM_External_ID__c,
                                                            EUR_CRM_PRS_Question__c , 
                                                            EUR_CRM_Answer_Condition__c,
                                                            EUR_CRM_Criteria_Threshold_Currency__c,
                                                            EUR_CRM_Criteria_Threshold_Number__c
                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                            WHERE EUR_CRM_PRS_Question__c = :question.Id];
        
        EUR_CRM_AnswerFactory.IQuestionsInterface AnsFactory = Mgr.newClassInstance(rtCurrency);
        Id key = question.Id;
        String target = '{!answerSheet["'+key+'"]}';
        String value = '';
        try{
            AnsFactory.getFieldSet();
            AnsFactory.getLabelSet();
            AnsFactory.setQuestion(question,QuestionC);
            AnsFactory.calculateQuestion(50,QuestionC,'1');
        }catch(Exception e){
            System.Debug('@@@Test2:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test2:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id,question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test2:'+e);
        }
    }   
    static testMethod void unitTest3(){
        
        EUR_CRM_AnswerManager Mgr = New EUR_CRM_AnswerManager('BG');
        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            EUR_CRM_PRS_Question_Set__c QS = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('BG',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP);
            EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QS.Id,'BG');
        }

        EUR_CRM_PRS_Question__c question  = [SELECT Id,EUR_CRM_Country_Code__c,EUR_CRM_External_ID__c,
                                             EUR_CRM_PRS_Question_Set__c,EUR_CRM_Question_Sequence__c,
                                             EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                             FROM EUR_CRM_PRS_Question__c WHERE EUR_CRM_External_ID__c = 'BGPRSQ_0003'];
                
        List<EUR_CRM_PRS_Question_Criteria__c> QuestionC = [SELECT Id,
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Criteria_Picklist_Label__c,
                                                            EUR_CRM_Criteria_Picklist_Value__c,
                                                            EUR_CRM_Answer_Statement__c,
                                                            EUR_CRM_Criteria_Weight__c,
                                                            EUR_CRM_External_ID__c,
                                                            EUR_CRM_PRS_Question__c , 
                                                            EUR_CRM_Answer_Condition__c,
                                                            EUR_CRM_Criteria_Threshold_Currency__c,
                                                            EUR_CRM_Criteria_Threshold_Number__c
                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                            WHERE EUR_CRM_PRS_Question__c = :question.Id];
        
        EUR_CRM_AnswerFactory.IQuestionsInterface AnsFactory = Mgr.newClassInstance(rtNumber);
        Id key = question.Id;
        String target = '{!answerSheet["'+key+'"]}';
        String value = '';
        try{
            AnsFactory.getFieldSet();
            AnsFactory.getLabelSet();
            AnsFactory.setQuestion(question,QuestionC);
            AnsFactory.calculateQuestion(50,QuestionC,'1');
        }catch(Exception e){
            System.Debug('@@@Test3:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test3:'+e);
        }
        try{
        	AnsFactory.getQuestionComponent(EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id,question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test3:'+e);
        }
    }   
    static testMethod void unitTest4(){
        
        EUR_CRM_AnswerManager Mgr = New EUR_CRM_AnswerManager('BG');
        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        //Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            EUR_CRM_PRS_Question_Set__c QS = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('BG',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP);
            EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QS.Id,'BG');
        }

        EUR_CRM_PRS_Question__c question  = [SELECT Id,EUR_CRM_Country_Code__c,EUR_CRM_External_ID__c,
                                             EUR_CRM_PRS_Question_Set__c,EUR_CRM_Question_Sequence__c,
                                             EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                             FROM EUR_CRM_PRS_Question__c WHERE EUR_CRM_External_ID__c = 'BGPRSQ_0004'];
                
        List<EUR_CRM_PRS_Question_Criteria__c> QuestionC = [SELECT Id,
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Criteria_Picklist_Label__c,
                                                            EUR_CRM_Criteria_Picklist_Value__c,
                                                            EUR_CRM_Answer_Statement__c,
                                                            EUR_CRM_Criteria_Weight__c,
                                                            EUR_CRM_External_ID__c,
                                                            EUR_CRM_PRS_Question__c , 
                                                            EUR_CRM_Answer_Condition__c,
                                                            EUR_CRM_Criteria_Threshold_Currency__c,
                                                            EUR_CRM_Criteria_Threshold_Number__c
                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                            WHERE EUR_CRM_PRS_Question__c = :question.Id];
        
        EUR_CRM_AnswerFactory.IQuestionsInterface AnsFactory = Mgr.newClassInstance(rtPicklist);
        Id key = question.Id;
        String target = '{!answerSheet["'+key+'"]}';
        String value = '';
        try{
            AnsFactory.getFieldSet();
            AnsFactory.getLabelSet();
            AnsFactory.setQuestion(question,QuestionC);
            AnsFactory.calculateQuestion(50,QuestionC,'1');
        }catch(Exception e){
            System.Debug('@@@Test4:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test4:'+e);
        }
        try{
        	AnsFactory.getQuestionComponent(EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id,question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test4:'+e);
        }
    }   
    
    static testMethod void unitTest5(){
        EUR_CRM_AnswerManager Mgr = New EUR_CRM_AnswerManager('BG');
        //Id rtBoolean = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Boolean_Input' Limit 1].id;
        //Id rtCurrency = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Currency_Input' Limit 1].id;
        //Id rtNumber = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Number_Input' Limit 1].id;
        //Id rtPicklist = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Picklist_Input' Limit 1].id;
        Id rtText = [SELECT id FROM recordType WHERE DeveloperName = 'EUR_BG_PRS_Question_Text_Input' Limit 1].id;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            EUR_CRM_PRS_Question_Set__c QS = EUR_CRM_PRS_TestClassUtilityHelper.createQuestionSet('BG',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP);
            EUR_CRM_PRS_TestClassUtilityHelper.CreateAllQuestionType(QS.Id,'BG');
        }

        EUR_CRM_PRS_Question__c question  = [SELECT Id,EUR_CRM_Country_Code__c,EUR_CRM_External_ID__c,
                                             EUR_CRM_PRS_Question_Set__c,EUR_CRM_Question_Sequence__c,
                                             EUR_CRM_Question_Statement__c,EUR_CRM_Question_Weight__c 
                                             FROM EUR_CRM_PRS_Question__c WHERE EUR_CRM_External_ID__c = 'BGPRSQ_0005'];
        List<EUR_CRM_PRS_Question_Criteria__c> QuestionC = [SELECT Id,
                                                            EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Criteria_Picklist_Label__c,
                                                            EUR_CRM_Criteria_Picklist_Value__c,
                                                            EUR_CRM_Answer_Statement__c,
                                                            EUR_CRM_Criteria_Weight__c,
                                                            EUR_CRM_External_ID__c,
                                                            EUR_CRM_PRS_Question__c , 
                                                            EUR_CRM_Answer_Condition__c,
                                                            EUR_CRM_Criteria_Threshold_Currency__c,
                                                            EUR_CRM_Criteria_Threshold_Number__c
                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                            WHERE EUR_CRM_PRS_Question__c = :question.Id];
        
        EUR_CRM_AnswerFactory.IQuestionsInterface AnsFactory = Mgr.newClassInstance(rtText);
        Id key = question.Id;
        String target = '{!answerSheet["'+key+'"]}';
        String value = '';
        try{
            AnsFactory.setQuestion(question,QuestionC);
            AnsFactory.calculateQuestion(50,QuestionC,'TRUE');
            AnsFactory.getFieldSet();
            AnsFactory.getLabelSet();
        }catch(Exception e){
            System.Debug('@@@Test5:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test5:'+e);
        }
        
        try{
        	AnsFactory.getQuestionComponent(EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id,question,QuestionC,target,value);
        }catch(Exception e){
            System.Debug('@@@Test5:'+e);
        }
    }   
}