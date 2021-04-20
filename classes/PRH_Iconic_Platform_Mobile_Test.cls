@isTest (SeeAllData = false) 
public class PRH_Iconic_Platform_Mobile_Test{
    public static User createUserWithProfile(String alias, String profileName){
        Profile profile = new Profile();
        if(profileName != '')
            profile = [select id from profile where name=:profileName];
        else
            profile = [select id from profile where name='Standard User'];
            
        User user = new User(alias = alias, email=alias + '@dev.com', 
            emailencodingkey='UTF-8', firstname=alias, lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = profile.Id, 
            timezonesidkey='Europe/London', username=alias + '@esn.pernod-ricard.com');
        return user;
    }
    
    public static testMethod void testMobileEdit() {
        
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];
        
        System.runAS(loggedin){
            System.test.startTest();
            
            PRH_Brand_Luxury_Brand__c testBrand = new PRH_Brand_Luxury_Brand__c(name = 'testBrand' ,CURRENCYISOCODE='EUR',PRH_PRESENCE_CATEGORY__C='Martell',PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=True, PRH_Sequence__c = 'LCEB0005', PRH_PIM_ID__c = 'PIM0005');
            testBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert testBrand;       
            
            User user = createUserWithProfile('tester', 'System Administrator');
            insert user;
         
            PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.PRH_Owner_2__c = loggedIn.id; 
            testLux.ownerID = user.id;         
            insert testLux;
            
            PRH_Collect__c testColl = new PRH_Collect__c();
            testColl.PRH_Active__c=true; 
            testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
            testColl.PRH_Period_End__c= date.newInstance(2016, 06, 30);
            testColl.PRH_Iconic_Account__c=testLux.id;
            insert testColl;

            PRH_Collect__c testColl2 = new PRH_Collect__c();
            testColl2.PRH_Active__c=true; 
            testColl2.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl2.PRH_Period_Start__c= date.newInstance(2016, 07, 01);
            testColl2.PRH_Period_End__c= date.newInstance(2016, 10, 31);
            testColl2.PRH_Iconic_Account__c=testLux.id;
            insert testColl2;

            PRH_Collect__c testColl3 = new PRH_Collect__c();
            testColl3.PRH_Active__c=true; 
            testColl3.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl3.PRH_Period_Start__c= date.newInstance(2016, 07, 01);
            testColl3.PRH_Period_End__c= date.newInstance(2016, 10, 31);
            testColl3.PRH_Iconic_Account__c=testLux.id;
            insert testColl3;

            PRH_Collect__c testColl4 = new PRH_Collect__c();
            testColl4.PRH_Active__c=true; 
            testColl4.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl4.PRH_Period_Start__c= date.newInstance(2016, 07, 01);
            testColl4.PRH_Period_End__c= date.newInstance(2016, 10, 31);
            testColl4.PRH_Iconic_Account__c=testLux.id;
            insert testColl4;
            PRH_Iconic_Platform_Mobile_Controller testCon = new PRH_Iconic_Platform_Mobile_Controller();
            
            ApexPages.StandardController sc1 = new ApexPages.standardController(testLux);
            PageReference pageRef1 = new PageReference('/apex/PRH_Luxury_Account_Controller?id=' + testLux.Id);
            System.Test.setCurrentPageReference(pageRef1);
            PRH_Luxury_Account_Controller testObjCON1 = new PRH_Luxury_Account_Controller(sc1);
            testObjCON1.editAll();
            ApexPages.StandardController sc = new ApexPages.standardController(testLux);
            String input = '';
            decimal i = 0;

           PRH_Iconic_Platform_MM_Acc_Controller testObjCON2 = new PRH_Iconic_Platform_MM_Acc_Controller(sc);
            testObjCon2.customCancel();
            input = '';
             i = 0;
            while( i < 92){
             input+= 'true true true 3 3 ';
             i++;
            }
            PRH_Iconic_Platform_MM_Acc_Controller.submitPage(input , testLux.id);
            testObjCon2.savePage();
            input = '';
            i = 0;
            while( i < 40){
             if(i==0) input+='false false false 0 0 ';
             else input+= 'true true true 2 3 ';
             i++;
            }
            PRH_Iconic_Platform_MM_Acc_Controller.submitPage(input , testLux.id);
          
        System.Test.stopTest();}
    }
    
    public static testMethod void testMobileEdit2() {
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];
        System.runAS(loggedin){
           System.test.startTest();
            
           PRH_Brand_Luxury_Brand__c testBrand = new PRH_Brand_Luxury_Brand__c(name = 'testBrand' ,CURRENCYISOCODE='EUR', PRH_PRESENCE_CATEGORY__C='Martell', PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=True, PRH_Sequence__c = 'LCEB0005', PRH_PIM_ID__c = 'PIM0005');
           testBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
           insert testBrand;   

            User user = createUserWithProfile('tester', 'System Administrator');
            insert user;
       
            PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.PRH_Owner_2__c = loggedIn.id;
            testLux.ownerID = user.id; 
            insert testLux;
            
            testLux.ownerID = loggedIn.id;
            testLux.PRH_Owner_2__c =user.id;
            update testLux;
            PRH_Iconic_Platform_Mobile_Controller testCon = new PRH_Iconic_Platform_Mobile_Controller();  
            ApexPages.StandardController sc = new ApexPages.standardController(testLux);
            String input = '';
            decimal i = 0;           
            PRH_Iconic_Platform_MM_Acc_Controller testObjCON2 = new PRH_Iconic_Platform_MM_Acc_Controller(sc);
            testObjCon2.customCancel();
         
            while( i < 92){
             input+= 'true true true 3 3 ';
             i++;
            }
            PRH_Iconic_Platform_MM_Acc_Controller.submitPage(input , testLux.id);
            testObjCon2.savePage();
            
            input = '';
            i = 0;
            while( i < 40){
             if(i==0) input+='false false false 0 0 ';
             else input+= 'true true true 4 4 ';
             i++;
            }
            try{
                PRH_Iconic_Platform_MM_Acc_Controller.submitPage(input , testLux.id);
            }catch(Exception e){
            }
            System.test.stopTest();
        }
    }
    
    public static testMethod void testMobileEdit3() { 
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];
        System.runAS(loggedin){
           System.test.startTest();
            
           PRH_Brand_Luxury_Brand__c testBrand = new PRH_Brand_Luxury_Brand__c(name = 'testBrand' ,CURRENCYISOCODE='EUR', PRH_PRESENCE_CATEGORY__C='Rum', PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=True, PRH_Sequence__c = 'LCEB0005', PRH_PIM_ID__c = 'PIM0005');
           testBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
           insert testBrand;  
            
           PRH_Brand_Luxury_Brand__c testLCBPrensencePortfolio = new PRH_Brand_Luxury_Brand__c(name = 'testBrandPortfolio' ,CURRENCYISOCODE='EUR', PRH_PRESENCE_CATEGORY__C='Cognac', PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=True, PRH_Portfolio_Presence__c=True, PRH_Sequence__c = 'LCEB0055');
           testLCBPrensencePortfolio.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
           insert testLCBPrensencePortfolio; 
            
           PRH_Brand_Luxury_Brand__c testCompBrand = new PRH_Brand_Luxury_Brand__c(name = 'testCompBrand' ,CURRENCYISOCODE='EUR', PRH_PRESENCE_CATEGORY__C='Cognac', PRH_COMPETITOR_BRAND__C=True, PRH_Active__c=True, PRH_Sequence__c = 'COMP0055');
           testCompBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
           insert testCompBrand;   
                        
            User user = createUserWithProfile('tester', 'System Administrator');
            insert user;
           
            PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.PRH_Owner_2__c = loggedIn.id; 
            testLux.ownerID = user.id; 
            
            insert testLux;
            
            PRH_Luxury_Accounts__c testidlux = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Test Test') LIMIT 1];
            //Start Creation Collect active
            PRH_Collect__c testColl = new PRH_Collect__c();
            testColl.PRH_Active__c=true; 
            testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
            testColl.PRH_Period_End__c= date.newInstance(2016, 06, 30);
            testColl.PRH_Iconic_Account__c=testidlux.id;
            //End Creation Collect
            insert testColl;   
            //Start Creation Collect inactive
            PRH_Collect__c testColl1 = new PRH_Collect__c();
            testColl1.PRH_Active__c=false; 
            testColl1.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl1.PRH_Period_Start__c= date.newInstance(2015, 11, 01);
            testColl1.PRH_Period_End__c= date.newInstance(2016, 02, 28);
            testColl1.PRH_Iconic_Account__c=testidlux.id;
            insert testColl1;   
            
            PRH_Iconic_Platform_Mobile_Controller testCon = new PRH_Iconic_Platform_Mobile_Controller();
            
            ApexPages.StandardController sc1 = new ApexPages.standardController(testLux);
            PageReference pageRef1 = new PageReference('/apex/PRH_Luxury_Account_Controller?id=' + testLux.Id);
            System.Test.setCurrentPageReference(pageRef1);
            PRH_Luxury_Account_Controller testObjCON1 = new PRH_Luxury_Account_Controller(sc1);
            testObjCON1.editAll();
            
            ApexPages.StandardController sc = new ApexPages.standardController(testLux);
            PageReference pageRef = new PageReference('/apex/PRH_Iconic_Platform_Mass_Edit_Mobile?id=' + testLux.Id);
            System.Test.setCurrentPageReference(pageRef);
            PRH_Iconic_Platform_MM_Edit_Controller testObjCON = new PRH_Iconic_Platform_MM_Edit_Controller(sc);
            testObjCon.customCancel();

            String input = '';
            decimal i = 0;
            while( i < 92){
             input+= 'true true true 3 3 ';
             i++;
            }
            PRH_Iconic_Platform_MM_Edit_Controller.submitPage(input , testLux.id);
            
            List<PRH_Collect__c> fullLeCerclePortfolio = [SELECT /*PRH_Full_Active_Le_Cercle_Portfolio__c,*/ PRH_Number_of_Pernod_Ricard_products__c FROM PRH_Collect__c Where PRH_Iconic_Account__c=:testidlux.id and PRH_Active__c=true]; 
            System.debug('fullLeCerclePortfolio: ' + fullLeCerclePortfolio);
            //boolean test = fullLeCerclePortfolio[0].PRH_Full_Active_Le_Cercle_Portfolio__c;
			//System.assertEquals(true, test); 
            
            testObjCon.savePage();
            input = '';
            i = 0;
            while( i < 40){
             if(i==0) input+='false false false 2 2 ';
             else input+= 'true true true 6 6 ';
             i++;
            }
            try{
                PRH_Iconic_Platform_MM_Edit_Controller.submitPage(input , testLux.id);
            }catch(Exception e){
            
            }
            List<String> mobilebrandList = new List<String>();
            String mobilebrandNew ='{'+
                                  '"Id": "",'+
                                  '"IconicAccount": "'+testLux.Id+'",'+
                                  '"IconicBrand": "'+testCompBrand.Id+'",'+
                                  '"BrandName": "testCompBrand",'+
                                  '"Presence": "true",'+
                                  '"Volume": "5"'+
                                '}';

            mobilebrandList.add(mobilebrandNew);

            PRH_Iconic_Platform_MM_Edit_Controller.doMobileSave(mobilebrandList);
        
            System.test.stopTest();
          
        }
    }
    
     public static testMethod void testMobileEdit4() {
        System.test.startTest();
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];

        PRH_Brand_Luxury_Brand__c testBrand = new PRH_Brand_Luxury_Brand__c(name = 'testBrand' ,CURRENCYISOCODE='EUR',PRH_PRESENCE_CATEGORY__C='Martell',PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=True, PRH_Sequence__c = 'LCEB0005', PRH_PIM_ID__c = 'PIM0005');
        testBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
        insert testBrand;  
        
        PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.ownerID = loggedIn.id; 
            
            insert testLux;
         
            PRH_Luxury_Accounts__c testidlux = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Test Test') LIMIT 1];
            PRH_Collect__c testColl = new PRH_Collect__c();
            testColl.PRH_Active__c=true; 
            testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
            testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
            testColl.PRH_Period_End__c= date.newInstance(2016, 06, 30);
            testColl.PRH_Iconic_Account__c=testidlux.id;
            insert testColl;   
            System.test.stopTest();   
     }
	 
	public static testMethod void testMobileEdit5() {            
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];
        System.runAS(loggedin){
			PRH_Brand_Luxury_Brand__c iconicBrand1;
			PRH_Brand_Luxury_Brand__c iconicBrand2;
            System.test.startTest();
                                    
            User user = createUserWithProfile('tester', 'System Administrator');
            insert user;
            
            // Creation of 2 Iconic Brands		
			PRH_Brand_Luxury_Brand__c ib1 = new PRH_Brand_Luxury_Brand__c();
            ib1.Name = 'Martell XO';
			ib1.PRH_Competitor_Brand__c = false;
            ib1.PRH_Active__c = true;
			ib1.PRH_Sequence__c = 'LCEB0001';
            ib1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib1;
			
			PRH_Brand_Luxury_Brand__c ib2  = new PRH_Brand_Luxury_Brand__c();
            ib2.Name = 'Dom Perignon';
			ib2.PRH_Competitor_Brand__c = true;
            ib2.PRH_Active__c = true;
			ib2.PRH_Sequence__c = 'COMP0001';
            ib2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
            insert ib2 ;
			
			try {         
                iconicBrand1 = [SELECT Name, Id FROM PRH_Brand_Luxury_Brand__c WHERE (Name LIKE 'Martell%') LIMIT 1]; 
                iconicBrand2 = [SELECT Name, Id FROM PRH_Brand_Luxury_Brand__c WHERE (Name LIKE 'Dom%') LIMIT 1]; 
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
                      
            PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.PRH_Owner_2__c = loggedIn.id; 
            testLux.ownerID = user.id; 
            insert testLux;
            
            PRH_Luxury_Accounts__c testidlux = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Test Test') LIMIT 1];
			PRH_Collect__c c1 = [SELECT id, Name, PRH_Active__c FROM PRH_Collect__c WHERE PRH_Active__c=true LIMIT 1]; 
			// Create a new Competitor Brand linked with to the new created collect
			PRH_Competitor_Brands__c compBrand1 = new PRH_Competitor_Brands__c(PRH_Collect__c = c1.id, PRH_Iconic_Brand__c = iconicBrand2.id);
			insert compBrand1;
			
			// Create a new Le Cercle Brand linked with to the new created collect
			PRH_Brand_Criteria__c leCercleBrand1 = new PRH_Brand_Criteria__c(
				PRH_Brand__c = iconicBrand1.id,
				PRH_Collect__c = c1.id
			);
			insert leCercleBrand1;
			
            ApexPages.StandardController sc1 = new ApexPages.standardController(testLux);
            PageReference pageRef1 = new PageReference('/apex/PRH_Luxury_Account_Controller?id=' + testLux.Id);
            System.Test.setCurrentPageReference(pageRef1);
            PRH_Luxury_Account_Controller testObjCON1 = new PRH_Luxury_Account_Controller(sc1);
            testObjCON1.editAll();
        
            System.test.stopTest();
        }
    }
	
	public static testMethod void testMobileEdit6() {            
        ID userID = UserInfo.getUserid();
        User loggedIn = [Select id from user where id = :UserInfo.getUserid() limit 1];
        System.runAS(loggedin){
			PRH_Brand_Luxury_Brand__c iconicBrand1;
			PRH_Brand_Luxury_Brand__c iconicBrand2;
            System.test.startTest();
            
            PRH_Brand_Luxury_Brand__c testBrand = new PRH_Brand_Luxury_Brand__c(name = 'testBrand' ,CURRENCYISOCODE='EUR',PRH_PRESENCE_CATEGORY__C='Martell',PRH_COMPETITOR_BRAND__C=False, PRH_Active__c=true, PRH_Sequence__c = 'LCEB0005', PRH_PIM_ID__c = 'PIM0005');
            testBrand.RecordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert testBrand;  
                        
            User user = createUserWithProfile('tester', 'System Administrator');
            insert user;
            
            // Creation of 2 Iconic Brands		
			PRH_Brand_Luxury_Brand__c ib1 = new PRH_Brand_Luxury_Brand__c();
            ib1.Name = 'Martell XO';
			ib1.PRH_Competitor_Brand__c = false;
            ib1.PRH_Active__c = true;
			ib1.PRH_Sequence__c = 'LCEB0001';
            ib1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
            insert ib1;
			
			PRH_Brand_Luxury_Brand__c ib2  = new PRH_Brand_Luxury_Brand__c();
            ib2.Name = 'Dom Perignon';
            ib2.PRH_Active__c = true;
			ib2.PRH_Competitor_Brand__c = true;
			ib2.PRH_Sequence__c = 'COMP0001';
            ib2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
            insert ib2 ;
           			
			try {         
                iconicBrand1 = [SELECT Name, Id FROM PRH_Brand_Luxury_Brand__c WHERE (Name LIKE 'Martell%') LIMIT 1]; 
                iconicBrand2 = [SELECT Name, Id FROM PRH_Brand_Luxury_Brand__c WHERE (Name LIKE 'Dom%') LIMIT 1]; 
            } catch(DmlException e) { 
                System.debug('An unexpected error has occurred: ' + e.getMessage());  
            }
                      
            PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.PRH_Owner_2__c = loggedIn.id; 
            testLux.ownerID = user.id; 
            
            insert testLux;
            
            PRH_Luxury_Accounts__c testidlux = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Test Test') LIMIT 1];
            

			PRH_Collect__c c1 = [SELECT id, Name, PRH_Active__c FROM PRH_Collect__c WHERE PRH_Active__c=true LIMIT 1]; 
			// Create a new Competitor Brand linked with to the new created collect
			PRH_Competitor_Brands__c compBrand1 = new PRH_Competitor_Brands__c(
								PRH_Collect__c = c1.id,
								PRH_Iconic_Brand__c = iconicBrand2.id
							);
			insert compBrand1;
			
			// Create a new Le Cercle Brand linked with to the new created collect
			PRH_Brand_Criteria__c leCercleBrand1 = new PRH_Brand_Criteria__c(
				PRH_Brand__c = iconicBrand1.id,
				PRH_Collect__c = c1.id
			);
			insert leCercleBrand1;
			
            ApexPages.StandardController sc1 = new ApexPages.standardController(testLux);
            PageReference pageRef1 = new PageReference('/apex/PRH_Luxury_Account_Controller?id=' + testLux.Id);
            System.Test.setCurrentPageReference(pageRef1);
            PRH_Luxury_Account_Controller testObjCON1 = new PRH_Luxury_Account_Controller(sc1);
            testObjCON1.editAll();
        
            System.test.stopTest();
        }
    }

     static testMethod void testFive() {
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator');

        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u, 'Luxury Account - Ricard','France');
        
        PRH_Brand_Criteria__c queryBrandCriteria = [SELECT PRH_Presence__c,PRH_Volume__c,PRH_Collect__c,
                                                    PRH_Branded_Event__c,PRH_Number_of_Branded_Events__c 
                                                    FROM PRH_Brand_Criteria__c 
                                                    WHERE Id=:brandCriteria.Id];
          System.Test.startTest(); 
         
         system.runAs(u) {
         PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.ownerID = u.id; 
            
            insert testLux;       
         
                ApexPages.StandardController sc = new ApexPages.standardController(testLux);
                PRH_Iconic_Platform_MM_Edit_Controller con = new PRH_Iconic_Platform_MM_Edit_Controller(sc);
                con.savePage();

                brandCriteria.PRH_Branded_Event__c = false;
                brandCriteria.PRH_Number_of_Branded_Events__c = 10;
                update brandCriteria;
                con = new PRH_Iconic_Platform_MM_Edit_Controller(sc);
                con.savePage();

                //run mobile save with error
                String brandList = 'false true true 5 5';
                PRH_Iconic_Platform_MM_Edit_Controller.submitPage(brandList, testLux.Id);

                brandList = 'true true false 5 5';
                PRH_Iconic_Platform_MM_Edit_Controller.submitPage(brandList, testLux.Id);
            }
        System.Test.stopTest();
     }

     static testMethod void testSix() {
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator');

        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u, 'Luxury Account - Ricard','France');
        brandCriteria.PRH_Presence__c = false;
        brandCriteria.PRH_Volume__c = 1;
        
        system.runAs(u) {
            update brandCriteria;
        }

         PRH_Brand_Criteria__c queryBrandCriteria = [SELECT PRH_Presence__c,PRH_Volume__c,PRH_Collect__c FROM PRH_Brand_Criteria__c WHERE Id=:brandCriteria.Id];
        PRH_Collect__c queryCollect = [Select id,PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c from PRH_Collect__c where id = :queryBrandCriteria.PRH_Collect__c limit 1];
          
         system.Test.startTest();
            system.runAs(u) {  
         PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c();
            testLux.name = 'Test Test';
            testLux.PRH_City__c = 'Test City';
            testLux.PRH_Account_Type__c = 'Night Club';
            testLux.PRH_Account_Region__c = 'PR LATAM';
            testLux.ownerID = u.id; 
            
            insert testLux;       
        
      
                ApexPages.StandardController sc = new ApexPages.standardController(testLux);
                PRH_Iconic_Platform_MM_Edit_Controller con = new PRH_Iconic_Platform_MM_Edit_Controller(sc);
                system.debug('@@@updatedBrandCriteria: '+brandCriteria);
                con.savePage();
                
                String brandList = 'true true true 5 5';
                PRH_Iconic_Platform_MM_Edit_Controller.submitPage(brandList, testLux.Id);
            }
        System.Test.stopTest();
     }
    
    static testMethod void testSeven() {
         
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator');
        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u, 'Luxury Account - Ricard','France');
        PRH_Brand_Criteria__c queryBrandCriteria = [SELECT PRH_Presence__c,PRH_Volume__c,PRH_Collect__c FROM PRH_Brand_Criteria__c WHERE Id=:brandCriteria.Id];
         
	    PRH_Collect__c queryCollect = [Select id,PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c from PRH_Collect__c where id = :queryBrandCriteria.PRH_Collect__c limit 1];
        PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c(Id=queryCollect.PRH_Iconic_Account__c);
         
        
        System.Test.startTest();
            system.runAs(u) {
                ApexPages.StandardController sc = new ApexPages.standardController(testLux);
                PRH_Iconic_Platform_MM_Edit_Controller con = new PRH_Iconic_Platform_MM_Edit_Controller(sc);
                             
                con.savePage();
                con.getFiscalYrLabel();
                con.getFiscalYrNbActivation(); 
                PRH_Collect__c queryCollect2 = [Select id,PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c from PRH_Collect__c where id = :queryBrandCriteria.PRH_Collect__c limit 1];
        		System.assertEquals(queryCollect2.PRH_Number_of_Pernod_Ricard_products__c,1); 
                system.debug('Test PRH_Number_of_Pernod_Ricard_products__c: '+queryCollect2.PRH_Number_of_Pernod_Ricard_products__c);   
            }
        System.Test.stopTest();
         
     }

    static testMethod void testEight() {
         
        User u = PRH_TestClass_Utilities.createUser('France', 'System Administrator');
        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u, 'Luxury Account - Ricard','France');
        PRH_Brand_Criteria__c queryBrandCriteria = [SELECT PRH_Presence__c,PRH_Volume__c,PRH_Collect__c FROM PRH_Brand_Criteria__c WHERE Id=:brandCriteria.Id];
         
        PRH_Collect__c queryCollect = [Select id,PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c from PRH_Collect__c where id = :queryBrandCriteria.PRH_Collect__c limit 1];
        PRH_Luxury_Accounts__c testLux = new PRH_Luxury_Accounts__c(Id=queryCollect.PRH_Iconic_Account__c);
         
        System.Test.startTest();
            system.runAs(u) {
                ApexPages.StandardController sc = new ApexPages.standardController(testLux);
                PRH_Luxury_Account_Controller con = new PRH_Luxury_Account_Controller(sc);
                             
                con.getFiscalYrLabel();
                con.getFiscalYrNbActivation();                   
            }
        System.Test.stopTest();
         
    }
    
}