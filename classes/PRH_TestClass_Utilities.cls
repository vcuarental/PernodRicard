/*
    *Created By: Bryan Trinidad
    *Created Date: June 30,2014
    *
    *Description: Test class utilities
    *
    *       Updated By:             Date:               Description:        
    *       
    *
*/

public class PRH_TestClass_Utilities {
  
  //create user
  public static User createUser(String country,String profileName) {

    //to prevent duplicate username error
    String orgId = UserInfo.getOrganizationId();
       String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
    String uniqueName = orgId + dateString + randomInt;
      String randAlias= 't'+randomInt;

    User u = new User();
      u.FirstName = 'test user';
      u.LastName = 'test user';
      u.Alias = randAlias;
      u.Email = uniqueName+'@test'+orgid+'.org';
      u.Username = u.Email;  
      u.CommunityNickname = u.Alias;
      u.Country = country;
      u.ProfileId = [SELECT Id FROM Profile WHERE Name =:profileName][0].Id;
      u.TimeZoneSidKey = 'America/Chicago';
      u.LocaleSidKey = 'en_US';
      u.EmailEncodingKey = 'UTF-8';
      u.LanguageLocaleKey = 'en_US';
      insert u;
      return u;
  }

  //Create brand criteria
  public static PRH_Brand_Criteria__c createBrandCriteria(User u,String recordTypeName,String country) {

    PRH_Luxury_Accounts__c iconicAccount = new PRH_Luxury_Accounts__c();
        iconicAccount.Name = 'Iconic Account Test';
        iconicAccount.PRH_Account_Type__c = 'Low Energy Bar';
        iconicAccount.PRH_Account_Country__c = country;
        iconicAccount.PRH_City__c = 'test city';

        //PRH_Brand_Luxury_Brand__c iconicBrand = new PRH_Brand_Luxury_Brand__c(name='iconicBrand test', CURRENCYISOCODE='EUR', PRH_PRESENCE_CATEGORY__C='Martell', PRH_COMPETITOR_BRAND__C=true, PRH_Sequence__c='LCEB0005', PRH_Active__c=true);
        PRH_Brand_Luxury_Brand__c iconicBrand = new PRH_Brand_Luxury_Brand__c();
        iconicBrand.Name = 'iconicBrand test';
        iconicBrand.PRH_Sequence__c = 'LCEB0001';
        iconicBrand.PRH_PRESENCE_CATEGORY__C = 'Martell';
        iconicBrand.PRH_Competitor_Brand__c = false;
        iconicBrand.PRH_Active__c = true;
        iconicBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Ricard').getRecordTypeId();
      
        system.runAs(u) {
          insert iconicBrand;
        }
        system.runAs(u) {
          insert iconicAccount;
        }
      	System.debug('==> iconicAccount : '+ iconicAccount);
      
        PRH_Luxury_Accounts__c idIconicAccount = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Iconic Account Test') LIMIT 1];
        //Start Creation Collect
        PRH_Collect__c testColl = new PRH_Collect__c();
        testColl.PRH_Active__c=true; 
        //testColl.PRH_Full_Active_Le_Cercle_Portfolio__c=False;
        testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
        testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
        testColl.PRH_Period_End__c= date.newInstance(2016, 06, 30);
        testColl.PRH_Iconic_Account__c=idIconicAccount.id;
        //End Creation Collect
        system.runAs(u) {
          // insert testColl; 
        }
                 
        PRH_Collect__c idTestColl = [SELECT Id FROM PRH_Collect__c WHERE (PRH_Active__c = true and PRH_Iconic_Account__c=:idIconicAccount.id) LIMIT 1];     
        PRH_Brand_Criteria__c brandCriteria = new PRH_Brand_Criteria__c();
        brandCriteria.PRH_Presence__c = true;
        brandCriteria.PRH_Volume__c = 10;
        brandCriteria.PRH_Brand__c = iconicBrand.Id;
        brandCriteria.PRH_Collect__c = idTestColl.Id;
        brandCriteria.recordTypeId = Schema.SObjectType.PRH_Brand_Criteria__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        system.runAs(u) {
          insert brandCriteria;
        }

        return brandCriteria;
  }

  //Create competitor brands
  public static PRH_Competitor_Brands__c createCompetitorBrands(User u,String recordTypeName,String country) {

    PRH_Luxury_Accounts__c iconicAccount = new PRH_Luxury_Accounts__c();
        iconicAccount.Name = 'Iconic Account Test';
        iconicAccount.PRH_Account_Type__c = 'Low Energy Bar';
        iconicAccount.PRH_Account_Country__c = country;
        iconicAccount.PRH_City__c = 'test city';

        PRH_Brand_Luxury_Brand__c iconicBrand = new PRH_Brand_Luxury_Brand__c();
        iconicBrand.Name = 'Iconic Brand Test';
        iconicBrand.PRH_Sequence__c = 'COMP0005';
        iconicBrand.PRH_Competitor_Brand__c = true;
        iconicBrand.PRH_Active__c = true;
        iconicBrand.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        system.runAs(u) {
          insert iconicBrand;
        }
      system.runAs(u) {
          insert iconicAccount;
        }
       PRH_Luxury_Accounts__c idIconicAccount = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Iconic Account Test') LIMIT 1];
          //Start Creation Collect
            PRH_Collect__c testColl = new PRH_Collect__c();
            testColl.PRH_Active__c=true; 
            //testColl.PRH_Full_Active_Le_Cercle_Portfolio__c=False;
            testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
            testColl.PRH_Period_End__c= date.newInstance(2016, 06, 30);
            testColl.PRH_Iconic_Account__c=idIconicAccount.id;
            //End Creation Collect
            system.runAs(u) {
       insert testColl; 
      }
            
       PRH_Collect__c idTestColl = [SELECT Id FROM PRH_Collect__c WHERE (PRH_Active__c = true and PRH_Iconic_Account__c=:idIconicAccount.id) LIMIT 1];

        PRH_Competitor_Brands__c compBrand = new PRH_Competitor_Brands__c();
        compBrand.PRH_Presence__c = true;
        compBrand.PRH_Volume__c = 10;
      
        compBrand.PRH_Collect__c = idTestColl.Id;
        compBrand.PRH_Iconic_Brand__c = iconicBrand.Id;

        system.runAs(u) {
          insert compBrand;
      }

        return compBrand;

  }

  /*public static void addPermission(User userParam, String permissionsetName) {

    PermissionSet permission = [SELECT Id FROM PermissionSet 
                  WHERE Name=:permissionsetName LIMIT 1];

    PermissionSetAssignment permissionAssgn = [SELECT PermissionSetId,AssigneeId
                           FROM PermissionSetAssignment
                           WHERE PermissionSetId=:permission.Id];

    permissionAssgn.AssigneeId = userParam.Id;

    update PermissionSetAssignment;

  }*/
}