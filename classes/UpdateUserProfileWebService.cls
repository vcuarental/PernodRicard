global class UpdateUserProfileWebService {            

    webService static Id modifyUserProfile(Id uid) {        
        //get the id of the user to change
        User endu = [SELECT Id, ProfileId FROM User where Id=:uid limit 1];        
        //get the profile to set up for the user => validate that at run-time, it is always valid
        Profile currProfile = [select Id, Name from Profile where Id = :endu.ProfileId ];
        
        // Parse the name of the current profile, to extract the target profile by delete the "NonAck"
        String currProfileName = currProfile.Name;
        currProfileName = currProfileName.replace(' Non-Ackn', '');
        System.debug('#### newprofile :'+currProfileName);
        
        // Get the ID of the new Profile
        Profile newProfile = [select Id from Profile where Name = :currProfileName ];
        
        endu.profileId = newProfile.Id; //check if the field is null        
        endu.ESNPolicyAcceptanceDate__c =  System.now();
        update endu;
        
        return endu.Id;    
    }
}