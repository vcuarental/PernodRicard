@isTest
public class PJ_ByFor_ProjectEdit_Test {

        static testmethod void PJ_ByFor_ProjectEdit_Test1() {
        
        Test.startTest();
        
        PJ_ByFor_Experience__c experience = new PJ_ByFor_Experience__c();
        PageReference pageRef1 = Page.PJ_ByFor_ProjectEdit;
        Test.setCurrentPage(pageRef1);
        List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1,'Prospect');
        experience = [select Id, Name, PJ_ByFor_Countries__c, PJ_ByFor_Status__c, PJ_ByFor_Client__c, PJ_ByFor_Effectiveclientreception__c, PJ_ByFor_Arrival_time__c, PJ_ByFor_Departure_time__c, PJ_ByFor_Client_reception_date__c, PJ_ByFor_Shipping_date__c, PJ_ByFor_Estimated_timing_delivery__c, PJ_ByFor_Dispatch_date__c, PJ_ByFor_InvoiceSendDate__c, PJ_ByFor_Preference__c, PJ_ByFor_Step_Number__c, CreatedDate, ownerId, PJ_ByFor_Subsidiary__c, PJ_ByFor_Experience_Owner_Email__c, PJ_ByFor_Copy_Billing_Address__c, PJ_ByFor_Wishedexperiencedate__c, PJ_ByFor_Billing_Country__c, PJ_ByFor_Shipping_Country__c from PJ_ByFor_Experience__c where PJ_ByFor_Client__c=:clientList[0].Id limit 1];
        System.debug('__----__----_ Experience: ' + experience);
		
        PJ_ByFor_ProjectEdit myPage = new PJ_ByFor_ProjectEdit(new ApexPages.StandardController(experience));
        myPage.init();
            
        //myPage.client.Name = 'Test';
        myPage.deliveryDate = '10/10/2016';
        myPage.experience.PJ_ByFor_InvoiceSendDate__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Shipping_date__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Dispatch_date__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Client_reception_date__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Effectiveclientreception__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Arrival_time__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_Departure_time__c = Date.newInstance(2016, 05, 12);    
        
            
        //myPage.arrivalDate = '01/05/2016';
        //myPage.departureDate = '01/05/2016';
            
        myPage.experience.PJ_ByFor_Shipping_date__c = Date.newInstance(2016, 05, 12);
        myPage.experience.PJ_ByFor_PlaceoftheExperience__c = 'Epernay';
        myPage.client.PJ_ByFor_Client_Date_of_birth__c = Date.newInstance(2016, 05, 05);

        myPage.experience.PJ_ByFor_Estimated_timing_delivery__c = Date.newInstance(2016, 05, 05);
        myPage.experience.PJ_ByFor_Wishedexperiencedate__c = Date.newInstance(2016, 05, 12);
            
        myPage.init();

        //List<PJ_ByFor_Client__c> clientsTmp = PJ_ByFor_TestDataFactory.createClientsWithExp(1,0);
        //myPage.xpDateFromCalendar = clientsTmp[0].Id;
        myPage.arrivaltimeDate = '01/05/2016';
        myPage.departuretimeDate = '01/05/2016';
        myPage.save();
            
        myPage.arrivaltimeDate = '';
        myPage.departuretimeDate = '';
        //myPage.client.PJ_ByFor_Client_Date_of_birth__c =Date.newInstance(2016, 05, 12);
       
        myPage.experience.PJ_ByFor_Preference__c ='Rosé';
		myPage.save(); 
        myPage.init();

		//ID myFileId = [select id, Name, Folder.id, Folder.Name from Document where Folder.Developername='PJ_ByFor_Template' and Developername='Conditions_Generales_de_Vente' limit 1].id;           
        //myPage.getEstimate();
        //myPage.getEstimateTemplate();
        myPage.filename = 'toto';
            
        Attachment []  att = PJ_ByFor_TestDataFactory.createAttachments(1);
        myPage.filename = att[0].name;   
        myPage.blobValue = att[0].body ;
        myPage.contentType =att[0].ContentType;
	                   
        myPage.upload();
        myPage.getEstimateTemplate(); 
        myPage.getIsAdmin();
        myPage.getCountries();
        myPage.getExperienceHistory();
        myPage.getWineList();
            
        myPage.experience.id = null;
        
           
    
		myPage.save(); 
        Test.stopTest();
    }
    
    
    

}