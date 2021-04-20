public class PRH_Iconic_Platform_Mobile_Controller {

    public List<PRH_Luxury_Accounts__c> luxAccList{get; set;}

    public PRH_Iconic_Platform_Mobile_Controller(){
        luxAccList = getVenue();
        
    }
   
  
    public List<PRH_Luxury_Accounts__c> getVenue(){
          Id loggedInUser=  Userinfo.getUserId();
     
          List<PRH_Luxury_Accounts__c> luxAccList = 
              [Select 
                   id ,PRH_Existing_Account__r.Name ,Name, PRH_Detailed_address__c ,PRH_City__c
               From 
                   PRH_Luxury_Accounts__c 
               Where 
                   (OwnerID = :loggedInUser Or PRH_Owner_2__c =:loggedInUser) AND PRH_Suppress_and_archive__c = FALSE
                   
               Order By Name
              ];
        
        return luxAccList;
    }


}