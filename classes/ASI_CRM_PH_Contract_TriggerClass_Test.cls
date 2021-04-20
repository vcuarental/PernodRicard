/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_Contract_TriggerClass_Test
 * Description: Contains the test methods for ASI_CRM_PH_Contract_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-28       Calvin Chiu (LAPUTA)    Created
 * 2020-09-24       Wilken Lee              [WL 1.0] Bug fix for incorrect Contract Fiscal Year
 ****************************************************************************************************************************/
@isTest
public class ASI_CRM_PH_Contract_TriggerClass_Test {
    @isTest
    public static void test(){
        ASI_MFM_Exchange_Rate__c exRate = ASI_CRM_PH_Testfactory.createExchangeRate(Date.newInstance(Date.today().Year() - 1, 9, 1));
        insert exRate;
        
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = ASI_CRM_PH_Testfactory.createCustomers('MODERN OFF TRADE', true, true, 1);
        insert customerList;        
        
        /*[WL 1.0] BEGIN*/
        //List<ASI_TH_CRM_Contract__c> contractList = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        if (Date.today().Month() >= 7){
            contractList = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year(), 7, 1), Date.newInstance(Date.today().Year()+1, 6, 30), 1);
        }
        else {
            contractList = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        }       
        /*[WL 1.0] END*/
        contractList[0].ASI_CRM_Contract_Fund_Amount__c = 100;   
        contractList[0].ASI_CRM_Marketing_Support_Fund_Amount__c = 100;      
        contractList[0].ASI_CRM_Activation_Fund_Amount__c = 100;         
        contractList[0].ASI_CRM_Merchandise_Amount__c = 100;         
        contractList[0].ASI_CRM_Purchase_Incentive_Amount__c = 100;      
        contractList[0].ASI_CRM_Staff_Incentive_Amount__c = 100;         
        contractList[0].ASI_CRM_Bottle_Rebate_Amount__c = 100;
        contractList[0].ASI_CRM_Sales_Revenue_Target_Outlet__c = 100;
        contractList[0].ASI_CRM_SG_Net_Sales__c = 1000;
        insert contractList; 
        
        contractList[0].ASI_CRM_CN_Approval_Status__c = 'Approved';
        update contractList[0];
        
        /*[WL 1.0] BEGIN*/
        //List<ASI_TH_CRM_Contract__c> contractList2 = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        List<ASI_TH_CRM_Contract__c> contractList2 = new List<ASI_TH_CRM_Contract__c>();
        if (Date.today().Month() >= 7){
            contractList2 = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year(), 7, 1), Date.newInstance(Date.today().Year()+1, 6, 30), 1);
        }
        else {
            contractList2 = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        }
        /*[WL 1.0] END*/
        
        try{
            insert contractList2;         
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains(Label.ASI_CRM_CN_Contract_Date_Overlap));
        }
        
        contractList[0].recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract_Read_Only');
        update contractList[0];
        
        try{            
            delete contractList[0];
        }catch(Exception e){
            System.Assert(e.getMessage().contains(Label.ASI_CRM_PH_BlockDeleteContract));
        }
        
    }
}