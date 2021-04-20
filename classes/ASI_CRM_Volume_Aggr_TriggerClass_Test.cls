/*********************************************************************************
* Name: ASI_CRM_Volume_Aggr_TriggerClass_Test
* Description: Test Class for ASI_CRM_Volume_Aggregation_TriggerClass
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 27/05/2019       Rutuja Bardapurkar            Created
*/

@IsTest
public class ASI_CRM_Volume_Aggr_TriggerClass_Test {
    
 @TestSetup
    public static void setupData() {
         ASI_CRM_JP_TestHelper.createRunningNumber();
       
    }
    
    public static testMethod void testController() {
        
        
        RecordType rtrn = [SELECT Id, Name, DeveloperName, SobjectType
        FROM RecordType
        WHERE DeveloperName = 'ASI_CN_Running_Number'];

        ASI_HK_CRM_Running_Number__c rn = new ASI_HK_CRM_Running_Number__c();
        rn.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_Volume_Aggregation_Breakdown__c';
        rn.ASI_HK_CRM_Running_Number__c = 100;
        rn.RecordTypeId = rtrn.Id;
        rn.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1;
        rn.ASI_HK_CRM_Fiscal_Year__c = 2019;
        rn.ASI_HK_CRM_Format__c = '4{YY}{00000}';
        insert rn;
        
        
        List<ASI_CRM_Volume_Aggregation_Breakdown__c> aggregationBreakdowns = new List<ASI_CRM_Volume_Aggregation_Breakdown__c>();
        
        Set<Id> customerIds = ASI_CRM_CN_UtilPluck.pluckIds(ASI_CRM_Volume_Aggregation_Breakdown__c.ASI_CRM_Account__c, aggregationBreakdowns);
       
        Set<Id> contractIds = new Set<Id>();
        
       Id RecordTypeId1 = Schema.SObjectType.ASI_CRM_Volume_Aggregation_Breakdown__c.getRecordTypeInfosByName().get('HCO Outlets Affected by Volume Changes').getRecordTypeId();
        List<ASI_CRM_Volume_Aggregation_Breakdown__c> VolAggBlst = new list<ASI_CRM_Volume_Aggregation_Breakdown__c>();
        ASI_CRM_Volume_Aggregation_Breakdown__c VAB = new ASI_CRM_Volume_Aggregation_Breakdown__c();
       
        VAB.RecordTypeId = RecordTypeId1;
        VolAggBlst.add(VAB);
        insert VolAggBlst;
        
   
        
        ASI_CRM_Volume_Aggregation_TriggerClass.recalculateFI(aggregationBreakdowns);
    }
    

}