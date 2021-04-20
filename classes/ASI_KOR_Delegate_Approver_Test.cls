@isTest
public class ASI_KOR_Delegate_Approver_Test{

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
    
    
    public static testMethod void testDelegateApprover() {
       
         List<User> newUsers = new List<User>();
         for(Integer i=0;i<2;i++){
            User user = createUserWithProfile('user'+i, 'ASI KOR Standard Platform User');
            user.IsActive = true;
            if(i == 0){
                user.title = 'National Sales Director';
                
            }
            if(i == 1){
                UserRole role = [Select ID from UserRole where Name = 'Business Development (Admin)' Limit 1];
                user.UserRoleID = role.ID;
                Profile prof = [select id from profile where name='System Administrator' Limit 1];
                user.Profileid = prof.ID;
            }
            
            newUsers.add(user);
         }
        
        insert newUsers; 
          
        
        System.RunAs(newUsers.get(1)){
           
            ASI_KOR_NSD_Proposal_Header__c testHeader = new ASI_KOR_NSD_Proposal_Header__c();
            testHeader.ASI_KOR_Month__c = '2014';
            testHeader.ASI_KOR_Year__c = '8';
            testHeader.OwnerID = newUsers.get(0).ID;
            testHeader.ASI_KOR_Delegated_Approver__c = newUsers.get(1).ID;
            
            insert testHeader;  
            
            ASI_KOR_NSD_Payment_Settlement_Header__c testPayHeader = new ASI_KOR_NSD_Payment_Settlement_Header__c();
            testPayHeader.ASI_KOR_Month__c = '2014';
            testPayHeader.ASI_KOR_Year__c = '8';
            testPayHeader.OwnerID = newUsers.get(0).ID;
            testPayHeader.ASI_KOR_Delegated_Approver__c = newUsers.get(1).ID;
            
            insert testPayHeader;  
         
       
      
            test.startTest();
            
            
            ApexPages.StandardController sc = new ApexPages.standardController(testHeader);
            PageReference pageRef = new PageReference('/apex/ASI_KOR_NSD_Proposal_Delegate_Approver?id=' + testHeader.Id);
            Test.setCurrentPageReference(pageRef);
            ASI_KOR_Delegate_Approver_Controller testObjCON = new ASI_KOR_Delegate_Approver_Controller(sc);
            testObjCON.saveNSDProposal();
            
            ApexPages.StandardController sc2 = new ApexPages.standardController(testPayHeader);
            PageReference pageRef2 = new PageReference('/apex/ASI_KOR_NSD_Payment_Settlement_Delegate_Approver?id=' + testPayHeader.Id);
            Test.setCurrentPageReference(pageRef2);
            ASI_KOR_Delegate_Approver_Controller testObjCON2 = new ASI_KOR_Delegate_Approver_Controller(sc2);
            testObjCON2.saveNSDPayment();
            
            test.stopTest();
        }
    }
    
}