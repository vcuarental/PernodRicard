/*
    *Created By: Bryan Trinidad
    *Created Date: June 30,2014
    *
    *Description: Test class for PRH_Competitor_Brand_Controller controller
    *
    *       Updated By:             Date:               Description:        
    *       
    *
*/
@isTest
private class PRH_Competitor_Brand_ControllerTest {

    static testMethod void testOne() {
    
        // MODIFIED BY GDT***
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        List<PermissionSet> listPs = [select id, name
                                      from PermissionSet
                                      where name = 'PRH_Iconic_Platform_Pernod'];
        if (listPS.size() > 0) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.assigneeId = u.Id;
            psa.PermissionSetId = listPS[0].Id;
            Database.SaveResult resInsert = Database.insert(psa);
        }
        
        PRH_Brand_Luxury_Brand__c iconicBrand = new PRH_Brand_Luxury_Brand__c();
        iconicBrand.Name = 'Iconic Brand Test';
        iconicBrand.PRH_Sequence__c = 'COMP0005';
        iconicBrand.PRH_PIM_ID__c = 'PIMC005';
        iconicBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
        iconicBrand.PRH_Competitor_Brand__c = true;
        iconicBrand.PRH_Active__c = true;  // LCS-153       
        system.runAs(u) {
            insert iconicBrand;
        }
        
        PRH_Luxury_Accounts__c iconicAccount = new PRH_Luxury_Accounts__c();
        iconicAccount.Name = 'Iconic Account Test';
        iconicAccount.PRH_Account_Type__c = 'Low Energy Bar';
        iconicAccount.PRH_City__c = 'test city';
        system.runAs(u) {
            insert iconicAccount;
        }
        
        PRH_Luxury_Accounts__c idIconicAccount = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Iconic Account Test') LIMIT 1];
        // Start Creation Collect
        PRH_Collect__c testColl = new PRH_Collect__c();
        testColl.PRH_Active__c = true; 
        //testColl.PRH_Full_Active_Le_Cercle_Portfolio__c = False;
        testColl.PRH_Number_of_Pernod_Ricard_products__c = 0;
        testColl.PRH_Period_Start__c = date.newInstance(2016, 03, 01);
        testColl.PRH_Period_End__c = date.newInstance(2016, 06, 30);
        testColl.PRH_Iconic_Account__c = idIconicAccount.id;
        // End Creation Collect
        system.runAs(u) {
            insert testColl; 
        }

        system.Test.startTest();
            system.runAs(u) {
                PRH_Competitor_Brand_Controller con = new PRH_Competitor_Brand_Controller();
                con.doSave();

                PRH_Competitor_Brands__c compBrand = [SELECT Id
                                                      FROM PRH_Competitor_Brands__c
                                                      WHERE PRH_Iconic_Brand__c=:iconicBrand.Id];
                system.assertEquals(compBrand != null,true);
            }
        system.Test.stopTest();
    }

    static testMethod void testTwo() {
        // MODIFIED BY GDT***
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        PRH_Competitor_Brands__c compBrand = PRH_TestClass_Utilities.createCompetitorBrands(u, 'Luxury Account - Competitor', 'France');
        compBrand.PRH_Presence__c = true;
        compBrand.PRH_Volume__c = 5;

        system.runAs(u) {
            update compBrand;
        }

        PRH_Competitor_Brands__c iconicAccount = [SELECT Id, PRH_Iconic_Account__c, PRH_Iconic_Brand__c FROM PRH_Competitor_Brands__c WHERE Id=:compBrand.Id];

        system.assertEquals(iconicAccount != null, true);

        PageReference p = Page.PRH_Luxury_Account;
        p.getParameters().put('id', iconicAccount.PRH_Iconic_Account__c);

        List<String> mobilebrandList = new List<String>();
        String mobilebrandNew ='{'+
                                  '"Id": "",'+
                                  '"IconicAccount": "'+iconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+iconicAccount.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "true",'+
                                  '"Volume": "5"'+
                                '}';

        String mobileBrandEdit = '{'+
                                  '"Id": "'+iconicAccount.Id+'",'+
                                  '"IconicAccount": "'+iconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+iconicAccount.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "true",'+
                                  '"Volume": "5"'+
                                '}';

        mobilebrandList.add(mobilebrandNew);

        system.Test.startTest();
        system.Test.setCurrentPage(p);         
        system.runAs(u) {
            PRH_Competitor_Brand_Controller con = new PRH_Competitor_Brand_Controller();

            con.doSave();
            con.doCancel();
            //insert
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);
            PRH_Competitor_Brand_Controller.setLastModifiedByInAccount(u.Id, iconicAccount.PRH_Iconic_Account__c);
            //update
            mobilebrandList.clear();
            mobilebrandList.add(mobileBrandEdit);
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);              
        }
        system.Test.stopTest();
    }

    static testMethod void testThree() {
        // MODIFIED BY GDT***
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        PRH_Competitor_Brands__c compBrand = PRH_TestClass_Utilities.createCompetitorBrands(u, 'Luxury Account - Competitor', 'France');

        compBrand.PRH_Presence__c = false;
        compBrand.PRH_Volume__c = 5;

        system.runAs(u) {
            update compBrand;
        }

        PRH_Competitor_Brands__c querycollect = [SELECT Id,PRH_Collect__c, PRH_Iconic_Brand__c FROM PRH_Competitor_Brands__c WHERE Id=:compBrand.Id];
        
        PRH_Collect__c	queryiconicAccount =[SELECT Id,PRH_Iconic_Account__c FROM PRH_Collect__c WHERE Id=:querycollect.PRH_Collect__c];

        system.assertEquals(queryiconicAccount != null, true);

        PageReference p = Page.PRH_Luxury_Account;
        p.getParameters().put('id', queryiconicAccount.PRH_Iconic_Account__c);

        List<String> mobilebrandList = new List<String>();
        String mobilebrandNew ='{'+
                                  '"Id": "",'+
                                  '"IconicAccount": "'+queryiconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+querycollect.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "false",'+
                                  '"Volume": "5"'+
                                '}';

        String mobileBrandEdit = '{'+
                                  '"Id": "'+querycollect.Id+'",'+
                                  '"IconicAccount": "'+queryiconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+querycollect.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "false",'+
                                  '"Volume": "5"'+
                                '}';

        mobilebrandList.add(mobilebrandNew);

        //run error messages
        system.Test.startTest();
        system.Test.setCurrentPage(p);         
        system.runAs(u) {
            PRH_Competitor_Brand_Controller con = new PRH_Competitor_Brand_Controller();
            con.doSave();
            con.doCancel();
            //insert
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);
            PRH_Competitor_Brand_Controller.setLastModifiedByInAccount(u.Id, queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.setNumberOfPRProducts(queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.setLCBPresence(queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.countOfPresenceBrandCriteria(queryiconicAccount.PRH_Iconic_Account__c);
            //update
            mobilebrandList.clear();
            mobilebrandList.add(mobileBrandEdit);
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);              
        }
        system.Test.stopTest();
    }

static testMethod void testFour() {
        // MODIFIED BY GDT***
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        PRH_Competitor_Brands__c compBrand = PRH_TestClass_Utilities.createCompetitorBrands(u,'Luxury Account - Competitor','France');
        compBrand.PRH_Presence__c = true;
        compBrand.PRH_Volume__c = 5;
        system.runAs(u) {
            update compBrand;
        }

        PRH_Brand_Criteria__c lecercleBrand = PRH_TestClass_Utilities.createBrandCriteria(u,'Luxury Account - Ricard','France');
        lecercleBrand.PRH_Presence__c = true;
        lecercleBrand.PRH_Volume__c = 3;
        system.runAs(u) {
            update lecercleBrand;
        }

        PRH_Competitor_Brands__c querycollect = [SELECT Id,PRH_Collect__c, PRH_Iconic_Brand__c FROM PRH_Competitor_Brands__c WHERE Id=:compBrand.Id];      
        PRH_Collect__c  queryiconicAccount = [SELECT Id,PRH_Iconic_Account__c FROM PRH_Collect__c WHERE Id=:querycollect.PRH_Collect__c];
        system.assertEquals(queryiconicAccount != null, true);

        PageReference p = Page.PRH_Luxury_Account;
        p.getParameters().put('id', queryiconicAccount.PRH_Iconic_Account__c);

        List<String> mobilebrandList = new List<String>();
        String mobilebrandNew ='{'+
                                  '"Id": "",'+
                                  '"IconicAccount": "'+queryiconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+querycollect.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "false",'+
                                  '"Volume": "5"'+
                                '}';

        String mobileBrandEdit = '{'+
                                  '"Id": "'+querycollect.Id+'",'+
                                  '"IconicAccount": "'+queryiconicAccount.PRH_Iconic_Account__c+'",'+
                                  '"IconicBrand": "'+querycollect.PRH_Iconic_Brand__c+'",'+
                                  '"BrandName": "Iconic Brand Test",'+
                                  '"Presence": "false",'+
                                  '"Volume": "5"'+
                                '}';

        mobilebrandList.add(mobilebrandNew);

        //run error messages
        system.Test.startTest();
        system.Test.setCurrentPage(p);         
        system.runAs(u) {
            PRH_Competitor_Brand_Controller con = new PRH_Competitor_Brand_Controller();
            con.doSave();
            con.doCancel();
            //insert
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);
            PRH_Competitor_Brand_Controller.setLastModifiedByInAccount(u.Id, queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.setNumberOfPRProducts(queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.setLCBPresence(queryiconicAccount.PRH_Iconic_Account__c);
            PRH_Competitor_Brand_Controller.countOfPresenceBrandCriteria(queryiconicAccount.PRH_Iconic_Account__c);
            //update
            mobilebrandList.clear();
            mobilebrandList.add(mobileBrandEdit);
            PRH_Competitor_Brand_Controller.doMobileSave(mobilebrandList);              
        }
        system.Test.stopTest();
    }
}