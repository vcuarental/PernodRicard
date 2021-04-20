/*********************************************************************************
 * Name:EUR_CRM_TestEnablePriceCheckBatch
 * Desc:Test Class For EUR_CRM_EnablePriceCheckBatch
 * 		Batch Jop Query:
 *String q ='SELECT Id, EUR_CRM_Price_Check__c, EUR_CRM_Price_Check_Frequency__c, ';
 *       q += 'EUR_CRM_Price_Check_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c, EUR_CRM_Price_Check_Frequency__r.EUR_CRM_Frequency_Span_Days__c ';
 *       q += 'FROM EUR_CRM_Account__c ';
 *       q += 'WHERE EUR_CRM_Price_Check__c = FALSE ';
 *       q += 'AND EUR_CRM_Price_Check_Frequency__c != null ';
 *       // set of valid recordtypes
 *       q += 'AND RecordType.DeveloperName IN (\'EUR_DK_Off_Trade\', \'EUR_RU_Direct_Off_Trade\', \'EUR_RU_Direct_Type_2_Off_Trade\', \'EUR_RU_Indirect_Off_Trade\')';
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/09/2016       Laputa: Jay             First Draft
*********************************************************************************/

@isTest
public class EUR_CRM_TestEnablePriceCheckBatch {

    public static testmethod void testBatch() {
        
        EUR_CRM_Apex_Configuration__c apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        EUR_CRM_Apex_Configuration__c apexConfig1 = EUR_CRM_RU_TestClassHelper.createApexConfig();
        apexConfig1.EUR_CRM_Account_RecordType_DevName__c = 'EUR_RU_Direct_Off_Trade';
        insert apexConfig1;
        
        EUR_CRM_Apex_Configuration__c apexConfig2 = EUR_CRM_RU_TestClassHelper.createApexConfig();
        apexConfig2.EUR_CRM_Account_RecordType_DevName__c = 'EUR_RU_Direct_Type_2_Off_Trade';
        insert apexConfig2;
        
        EUR_CRM_Apex_Configuration__c apexConfig3 = EUR_CRM_RU_TestClassHelper.createApexConfig();
        apexConfig3.EUR_CRM_Account_RecordType_DevName__c = 'EUR_RU_Indirect_Off_Trade';
        insert apexConfig3;

        
        String q ='SELECT Id, EUR_CRM_Price_Check__c, EUR_CRM_Price_Check_Frequency__c, ';
             q += 'EUR_CRM_Price_Check_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c, EUR_CRM_Price_Check_Frequency__r.EUR_CRM_Frequency_Span_Days__c ';
             q += 'FROM EUR_CRM_Account__c ';
             q += 'WHERE EUR_CRM_Price_Check__c = FALSE ';
             q += 'AND EUR_CRM_Price_Check_Frequency__c != null ';
                // set of valid recordtypes
             q += 'AND RecordType.DeveloperName IN (\'EUR_DK_Off_Trade\', \'EUR_RU_Direct_Off_Trade\', \'EUR_RU_Direct_Type_2_Off_Trade\', \'EUR_RU_Indirect_Off_Trade\')';
        
        Id rtId2 = [select id from recordtype where developername IN ('EUR_RU_Direct_Off_Trade') and sobjecttype = 'eur_crm_account__c' limit 1].id;

        //Create Price Check Feq
        EUR_CRM_Price_Check_Frequency__c pcf = new EUR_CRM_Price_Check_Frequency__c(name='pcf',
            																	  EUR_CRM_No_of_Visits_Within_Interval__c = 1,
                                                                                  EUR_CRM_Frequency_Span_Days__c = 1);
        System.Debug('@@Create Price_Check_feq');
        insert pcf;
        
        Id pcfId = [select id from EUR_CRM_Price_Check_Frequency__c where name = 'pcf' limit 1].id;
        System.Debug('@@Create Price_Check_feq:' + pcfId);
        
        //Create Account
        User u = [Select Id, ManagerId From User Where UserType = 'Standard' and IsActive = true and ManagerId != null limit 1];
        EUR_CRM_Account__c acct2 = new EUR_CRM_Account__c(name='test acct2', ownerId = u.Id, recordtypeid=rtId2, EUR_CRM_Price_Check__c=False,EUR_CRM_Price_Check_Frequency__c=pcfId  );
        acct2.EUR_CRM_Postal_Code__c = '112233';
        System.Debug('@@Create Acc');
        insert acct2;
        System.Debug('@@Create Acc Done');
        
        //Create Account Field History
        EUR_CRM_Account__History history = new EUR_CRM_Account__History(ParentId = acct2.Id, Field='EUR_CRM_Price_Check__c');
		insert history;

        Database.executeBatch(new EUR_CRM_EnablePriceCheckBatch());
    }
    
}