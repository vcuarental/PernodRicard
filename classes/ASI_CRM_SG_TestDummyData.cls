/**
*   Utility class used for generating Dummy Data for Test Methods
**/
@isTest
public class ASI_CRM_SG_TestDummyData
{

    /**
    * Variables
    **/

    private static Id RecordTypeId = null;
    private static final ASI_HK_CRM_AccountGenerator acctGen;
    //public static Integer businessRegistrationNumber = 123456789;


    /**
    *   Description : This method will generate List of Account with Dummy Data
    *
    *   Parameters :
    *   @totalRecords : How many Records you want to generate ?
    *   @withIds : Do you want returned records with generateId? If null then false
    **/
    public static List<Account> getAccounts(Integer totalRecords, Boolean withIds,String recordtypeDeveloperName,String SobjectType)
    {
        List<Account> acctList = new List<Account>();
        if(withIds == null)
            withIds = false;

        for(Integer i=0;i<totalRecords;i++)
        {
            Account a = new Account();
            a.name = constructTestString(20);
            a.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            //acctList.add(acctGen.generateAccount(recordtypeDeveloperName));
            acctList.add(a);
        }
        if(withIds)
            insert acctList;

        return acctList;
    }

    /**
    *   This method is used to generate Random String of supplied length
    */
    public static String constructTestString(Integer length) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return key.substring(0,length);
    }

    /**
    *   Description : This method will generate List of ASI_CRM_AccountsAdditionalField__c with Dummy Data
    *
    *   Parameters :
    *   @size : How many Records you want to generate ?
    *   @withIds : Do you want returned records with generateId? If null then false
    *   @accounts : List of parent Accounts 
    **/
    public static List<ASI_CRM_AccountsAdditionalField__c> generateCustomers(Integer size,List<Account> accounts,Boolean withIds,String recordtypeDeveloperName,String SobjectType){
        List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
        if(withIds == null)
            withIds = false;

        for(Integer i=0; i<size; i++){
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
            customer.Name = 'Test Customer'+i;
            customer.ASI_CRM_Account__c = accounts[i].Id;
            customer.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            // add Business Registration Number to pass validation
            //customer.ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber);
            customers.add(customer);
            //businessRegistrationNumber += 1;
        }

        if(withIds)
            insert customers;

        return customers;
    }

    public static List<ASI_HK_CRM_Promotion__c> getPromotions(Integer size,Boolean withIds,String recordtypeDeveloperName,String SobjectType,Date startDate, Date endDate){
        List<ASI_HK_CRM_Promotion__c> pmtList = new List<ASI_HK_CRM_Promotion__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i += 2) {
            ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c();
            promotion.name = 'PMT-'+i;
            promotion.ASI_HK_CRM_Promotion_Start_Date__c=startDate;
            promotion.ASI_HK_CRM_Promotion_End_Date__c = endDate;
            promotion.ASI_HK_CRM_Promotion_Name__c='Test Promotion'+i;
            promotion.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            pmtList.add(promotion);
        }
        if(withIds)
            insert pmtList;
        return pmtList;
    }

   
    /**
    *   Description : This method will get Record type Id's from RecordType
    *
    *   Parameters :
    *   @Developername : Recordtype DeveloperName
    **/
    public static Id getRecordTypeId(String Developername,String SobjectType){
        if(RecordTypeId==null)
            RecordTypeId = [Select Id from RecordType where Developername=:Developername and SobjectType=:SobjectType].Id;  
        return RecordTypeId;
    }
    
    public static List<ASI_HK_CRM_Visitation_Plan__c> getVisitationPlan(Integer size,Boolean withIds,String recordtypeDeveloperName,String SobjectType){
        List<ASI_HK_CRM_Visitation_Plan__c> visitationtionPlans = new List<ASI_HK_CRM_Visitation_Plan__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i ++) {
            ASI_HK_CRM_Visitation_Plan__c visitationtionPlan = new ASI_HK_CRM_Visitation_Plan__c();
            visitationtionPlan.name = 'PMT-'+i;
            visitationtionPlan.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            visitationtionPlans.add(visitationtionPlan);
        }
        
        if(withIds)
            insert visitationtionPlans;
        return visitationtionPlans;
    }

    public static List<ASI_HK_CRM_Visitation_Plan_Detail__c> getVisitationPlanDetails(Integer size,Boolean withIds,String recordtypeDeveloperName,String SobjectType, Id customerId,Id visitationtionPlanId){
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationtionPlanDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        if(withIds == null)
            withIds = false;
        for (Integer i = 0; i < size; i ++) {
            ASI_HK_CRM_Visitation_Plan_Detail__c visitationtionPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
            visitationtionPlanDetail.RecordTypeId = getRecordTypeId(recordtypeDeveloperName,SobjectType);
            visitationtionPlanDetail.ASI_CRM_MY_Customer__c = customerId;
            visitationtionPlanDetail.ASI_HK_CRM_Visitation_Plan__c = visitationtionPlanId;

            visitationtionPlanDetails.add(visitationtionPlanDetail);
        }
        if(withIds)
            insert visitationtionPlanDetails;
        return visitationtionPlanDetails;
    }

}