/*
    *Created By: Bryan Trinidad
    *Created Date: June 27,2014
    *   
    *       Updated By:             Date:               Description:        
    *       Bryan Trinidad          07312014            Added methods for PR Iconic Database for mobile.
    * 
    *  		Updated By:             Date:               Description:        
    *       CGI SR         			12282016            modification of core model (add collect) 
    * 
    *
*/

public with sharing class PRH_BrandCriteria_RelatedList {
    
    /*variables*/
    public PRH_Luxury_Accounts__c iconicAccount{get;set;}
    public List<PRH_Brand_Criteria__c> brandCriteriaList{get;set;}
    public List<BrandCriteriaWrapperClass> brandCriteriaWrapList {get;set;}
    
    /*constructor*/
    /*display brand and presence shown as custom related list in mobile*/
    public PRH_BrandCriteria_RelatedList(ApexPages.StandardController controller) {
        
        iconicAccount = (PRH_Luxury_Accounts__c)controller.getRecord();
        
        //add collect 
        PRH_Collect__c activeCollect;  
        
        //find the active collect for iconic account
        activeCollect = [select Id,PRH_Number_of_Pernod_Ricard_products__c              
				     	From PRH_Collect__c
						Where PRH_Iconic_Account__c= :iconicAccount.Id
						and PRH_Active__c=true
                    	Limit 1];
        
        System.debug('activeCollect : '+ activeCollect);
        
        if (activeCollect!= null) {
            
        brandCriteriaList = [SELECT id,PRH_Brand__c,PRH_Brand__r.Name,PRH_Presence__c
                             FROM PRH_Brand_Criteria__c
                             where PRH_Collect__c= :activeCollect.Id
                             ORDER BY PRH_Brand__r.PRH_Sequence__c ASC];
            
        System.debug('brandCriteriaList : '+ brandCriteriaList);
                             
        brandCriteriaWrapList = new List<BrandCriteriaWrapperClass>();
        
        if (!brandCriteriaList.isEmpty()) {
            Integer rowNo = 0;
            for (PRH_Brand_Criteria__c brand : brandCriteriaList) {
                rowNo++;
                 brandCriteriaWrapList.add(new BrandCriteriaWrapperClass(rowNo,brand.PRH_Brand__r.Name,brand.PRH_Presence__c));
            }
        }
        
    }
    }//end constructor

    public class BrandCriteriaWrapperClass {
        
        public String label {get;set;}
        public String brandName {get;set;}
        public Boolean presence {get;set;}
        
        public BrandCriteriaWrapperClass(Integer rowNoParam, String brandNameParam, Boolean presenceParam) {
            label = 'checkboxId_'+rowNoParam;
            brandName = brandNameParam;
            presence = presenceParam;
            
        }//end constructor wrapper class

    }//end wrapper class

    /*FOR PRH_Iconic_Database Page*/

    /*variables*/
    public Boolean iconicAccountRendered {get;set;}
    public Boolean dashboardRendered {get;set;}
    public Boolean leCerclePRRendered {get;set;}
    
    public PRH_BrandCriteria_RelatedList() {
        
       iconVisiblity();
        
    }//end PRH_BrandCriteria_RelatedList()

    //icon visibility through permission set
    public void iconVisiblity() {

        Set<String> permissionList = PRH_Competitor_Brand_Controller.setPermissionMethod(UserInfo.getUserId());

        //set visibility of le cercle account image link
        iconicAccountRendered = (permissionList.contains('PRH_Iconic_Platform_Mobile_Tab') || permissionList.contains('PRH_Iconic_Platform_PR_Holding_Admin')
                                 || permissionList.contains('PRH_Iconic_Platform_Regional_Directors') || permissionList.contains('PRH_Iconic_Platform_Sales_Directors')
                                 || permissionList.contains('PRH_Iconic_Platform_PR_Holding')) ? true : false;

        //set visibility of le cercle dashboard image link
        leCerclePRRendered = (permissionList.contains('PRH_Iconic_Platform_Mobile_Tab') || permissionList.contains('PRH_Iconic_Platform_PR_Holding_Admin')) ? true : false;

        //set visibility of le cercle by pernod image link
        dashboardRendered = (permissionList.contains('PRH_Iconic_Platform_PR_Holding_Admin') || permissionList.contains('PRH_Iconic_Platform_Regional_Directors')
                             || permissionList.contains('PRH_Iconic_Platform_Sales_Directors') || permissionList.contains('PRH_Iconic_Platform_PR_Holding')) ? true : false;

    }//end iconVisiblity()

    public String getgoToIconicAccountPage() {
        
        Schema.DescribeSObjectResult r = PRH_Luxury_Accounts__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();

        return '/'+keyPrefix+'/o';
        
    }//end getgoToIconicAccountPage()

    public String getgoToDashboardPage() {
        
        Schema.DescribeSObjectResult r = Dashboard.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();

        return '/'+keyPrefix+'/o';
        
    }//end getgoToDashboardPage()

    public String getgoToLeCerclePRPage() {

        return '/apex/PRH_Iconic_Platform_Mobile';
        
    }//end getgoToLeCerclePRPage()

}//end class