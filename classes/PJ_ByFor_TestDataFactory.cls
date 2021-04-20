public with sharing class PJ_ByFor_TestDataFactory {
    
    // Creation of 'Event' object method 
    // String status :  'Friend'/'Prospect' 
    public static List<Event> createEvents(Integer numEvents, PJ_ByFor_Client__c[] client, String status, String Place ) {
        PJ_ByFor_Experience__c Exp = 
            [select Id, Name, PJ_ByFor_Countries__c, PJ_ByFor_Status__c, CreatedDate, PJ_ByFor_Client__c from PJ_ByFor_Experience__c where PJ_ByFor_Client__c=:client[0].Id order by CreatedDate desc limit 1];
        List<Event> events = new List<Event>();
        
        for(Integer i=0;i<numEvents;i++) {
            
            Event ev = new Event(
                //OwnerId = opEvent.CreatedById,
                WhatId = Exp.id,
                StartDateTime = System.today(),
                EndDateTime = System.today(),
                isAllDayEvent = true,
                PJ_ByFor_Country__c = 'FR',
                PJ_ByFor_Place_of_the_experience__c = Place,
                
                
                //ActivityDateTime = opEvent.StartDate__c, //add this line
                Subject = 'Go test' + i,
                PJ_ByFor_Status__c = status,
                OwnerId=System.Label.PJ_ByFor_CellarMasterCalendar_Id,
                recordTypeId =System.Label.PJ_ByFor_recordType_Id
            );

            //Event ev = new Event(, DurationInMinutes=12);
            events.add(ev);
        }
        //insert all event accts;
        insert events;
        System.Debug('##### insertedDate =' + [select StartDateTime from Event where Id=:events[0].Id].StartDateTime);
        return events;
    }
    
    // Create Client Clients with experience Lists 
    public static List<PJ_ByFor_Client__c> createClientsWithExp(Integer numContacts, Integer numExpsPerContact, String status) {
        List<PJ_ByFor_Client__c> contacts = new List<PJ_ByFor_Client__c>();
        
        for(Integer i=0;i<numContacts;i++) {
            PJ_ByFor_Client__c c = new PJ_ByFor_Client__c(Name='TestFirstName' + i,
                                                         PJ_ByFor_Salutation__c ='Mr.',
                                                          PJ_ByFor_First_name__c = 'TestLastName' + i,
                                                          PJ_ByFor_Email__c = 'bmark@frenchamb.fr',
                                                          PJ_ByFor_First_Contact_Date__c = System.today(),
                                                          PJ_ByFor_Country_residence__c = 'TH',
                                                          PJ_ByFor_Status__c = status,
                                                          PJ_ByFor_Client_Date_of_birth__c = System.today(),
                                                          PJ_ByFor_Latest_Situation_Update_Date__c = System.today()
                                                         );
            contacts.add(c);
        }
        insert contacts;
        
        List<PJ_ByFor_Experience__c> xps = new List<PJ_ByFor_Experience__c>();
        for (PJ_ByFor_Client__c c : contacts){
            // For each account just inserted, add opportunities
            for (Integer k=0;k<numExpsPerContact;k++) {
                xps.add(new PJ_ByFor_Experience__c(Name=c.Name + ' Experience ' + k, 
                                       PJ_ByFor_Client__c = c.Id,
                                       
                    				   PJ_ByFor_Status__c='Open',
                                       //PJ_ByFor_number_of_persons__c = 1,
                                       
                                       PJ_ByFor_BillingCity__c= 'Paris',
                                       PJ_ByFor_ShippingCity__c = 'Paris',
                                                   
                                       PJ_ByFor_Billing_Country__c = 'FR',
                                       PJ_ByFor_Shipping_Country__c ='FR',
                                                   
                                       PJ_ByFor_BillingStateProvince__c = 'Ile-de-France',
                                       PJ_ByFor_Shipping_State_Province__c ='Ile-de-France', 
                                                   
                                       PJ_ByFor_BillingStreet__c = '29 Rue La Quintinie',
                                       PJ_ByFor_ShippingStreet__c ='29 Rue La Quintinie',
                                                   
                                       PJ_ByFor_BillingZipPostalCode__c = '75015',
                                       PJ_ByFor_ShippingZipPostalCode__c='75015'));

                                       //CloseDate=System.today().addMonths(1),
                                       //AccountId=acct.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert xps;
        
        return contacts;
    }
    
    

    
    public static List<PJ_ByFor_Administration__c> createAdminRessources(Integer numAdmins, String typeofResources) {
        List<PJ_ByFor_Administration__c> admins = new List<PJ_ByFor_Administration__c>();
        List<Attachment> Att_List = new List<Attachment>();
        Map<String,Id> rtMap = new Map<String,Id>(); 
        
        RecordType[] rtList = [select id, DeveloperName from RecordType where SobjectType='PJ_ByFor_Administration__c'];
        
        
        for (RecordType tr : rtList) {
            rtMap.put(tr.DeveloperName , tr.Id);
        }
        
        if (typeofResources=='Presentation') {
            
            //RecordType rt = [select id, DeveloperName from RecordType where SobjectType='PJ_ByFor_Administration__c' and DeveloperName='PJ_ByFor_DocumentRT' Limit 1];
            
            
            for(Integer i=0;i<numAdmins;i++) {
                PJ_ByFor_Administration__c ad = new PJ_ByFor_Administration__c(PJ_ByFor_Title__c='TestPresentation' + i,
                                                                             PJ_ByFor_URL_image__c='https://pernod-ricard--mmpjsb2dev--c.cs81.content.force.com/servlet/servlet.FileDownload?file=015260000005hod',
                                                                             PJ_ByFor_Description__c='Test Description' + i, 
                                                                             recordTypeId=rtMap.get('PJ_ByFor_DocumentRT'));
                admins.add(ad);
        	}
        }
        else if(typeofResources=='Brochure') {
            
            //RecordType rt = [select id, DeveloperName from RecordType where SobjectType='PJ_ByFor_Administration__c' and DeveloperName='PJ_ByFor_Brochure' Limit 1];
            
            
            
            for(Integer i=0;i<numAdmins;i++) {
                PJ_ByFor_Administration__c ad = new PJ_ByFor_Administration__c(PJ_ByFor_Title__c='TestBrochure' + i, 
                                                                              recordTypeId=rtMap.get('PJ_ByFor_Brochure'));
                admins.add(ad);
        	}
        }
        
        else if (typeofResources=='Video') {
            
            //RecordType rt = [select id, DeveloperName from RecordType where SobjectType='PJ_ByFor_Administration__c' and DeveloperName='PJ_ByFor_VideoRT' Limit 1];
            for(Integer i=0;i<numAdmins;i++) {
                PJ_ByFor_Administration__c ad = new PJ_ByFor_Administration__c(PJ_ByFor_Title__c='Testvideo' + i,
                                                                             PJ_ByFor_URL_video__c='https://player.vimeo.com/video/169672355',
                                                                              recordTypeId=rtMap.get('PJ_ByFor_VideoRT'));
                admins.add(ad);
        	}
            
        }
        
        if(admins.size()>0) {
            insert admins;
        }
        
        
        if(typeofResources=='Brochure') {
            for(PJ_ByFor_Administration__c ad : admins) {

                Attachment attach=new Attachment();    
		        attach.Name='Unit Test Attachment';
				Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');

        		attach.body=bodyBlob;

        		attach.ParentId=ad.id;
				Att_List.add(attach);
                
                //List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
                //System.assertEquals(1, attachments.size());
        	}
        }
        
        
        if(typeofResources=='Presentation') {
            for(PJ_ByFor_Administration__c ad : admins) {

                Attachment attach=new Attachment();    
		        attach.Name='Unit Test Attachment';
				Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');

        		attach.body=bodyBlob;

        		attach.ParentId=ad.id;
				Att_List.add(attach);
                
                //List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
                //System.assertEquals(1, attachments.size());
        	}
        }
        
        
        
        if(Att_List.size()>0) {
            System.debug('');
            
            insert Att_List;
        }

        return admins;
    }
    
    
    
    public static List<Attachment> createAttachments(Integer numAtt) {
        List<Attachment> Att_List = new List<Attachment>();
		Account ac = new Account(Name='Test');
        insert ac;
        
        
        for(Integer i=0;i<numAtt;i++)  {
            
             Attachment attach=new Attachment();    
		        attach.Name='Unit Test Attachment';
				Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');

        		attach.body=bodyBlob;

        		attach.ParentId=ac.id;
				Att_List.add(attach);
                
                //List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
                //System.assertEquals(1, attachments.size());
            
            
        }
        
        //insert att_List;
        return att_List;
        
    }
}