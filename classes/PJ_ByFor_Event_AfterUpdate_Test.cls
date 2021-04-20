@isTest
private class PJ_ByFor_Event_AfterUpdate_Test {
     
    // Update Event with right status (Confirmed)
    static testMethod void TestEventConfirmedOnCellarMasterCalendar() {
        // Test data setup
        // Create one or more clients by calling a utility method
        String status_Client = 'Friend'; 
        PJ_ByFor_Client__c[] contacts = PJ_ByFor_TestDataFactory.createClientsWithExp(1, 1, status_Client);
        
        System.debug('## >>> Create the Event related to a client  <<< ');
        // Create one or more events by calling a utility method
        String status_Event = 'Confirmed';
        String placeofExperience = 'Epernay';
        Event[] events = PJ_ByFor_TestDataFactory.createEvents(1, contacts, status_Event, placeofExperience);
        

        Test.startTest();
        System.debug('## >>> Perform test  <<< ');
        Database.SaveResult[] srList = Database.update(events, false);
        Test.stopTest();
        
        // Verify that the insertion should process by the trigger 
        // Iterate through each returned result
        System.debug('## >>> Check the Database update  <<< ');
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('The Trigger has been successfully proceed. Event ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Event fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}