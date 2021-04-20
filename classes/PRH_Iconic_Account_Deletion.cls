// Le Cercle application - evolution LCS-84 - April 2017
public class PRH_Iconic_Account_Deletion implements Database.Batchable<sObject> {

    final String Query;
    String iconicAccountIDListToDelete;
    
    public PRH_Iconic_Account_Deletion(String iconicIds) {  
        iconicAccountIDListToDelete = iconicIds;
        Boolean firstId = True;
        String queryStringStart = '';
        String queryStringEnd = '';
        String[] iconicIdsTab = iconicIds.split(',');

        System.debug('=> PRH_Iconic_Account_Deletion : iconicIds = ' + iconicIds);
        // Prepare query for retrieving the list of collects linked to Iconic Account
        queryStringStart = 'SELECT Id FROM PRH_Luxury_Accounts__c WHERE Id = \'';

        firstId = True;
        for (String s : iconicIdsTab) { 
            System.debug(s); 
            if (firstId == True) {
                queryStringEnd = queryStringEnd + s + '\'';
                firstId = False;
            } else {
                queryStringEnd = queryStringEnd + ' OR Id = \'' + s + '\'';   
            }
        } 
        Query = queryStringStart + queryStringEnd;
        System.debug('=> PRH_Iconic_Account_Deletion : iconicAccountIDListToDelete = ' + iconicAccountIDListToDelete);
        System.debug('=> PRH_Iconic_Account_Deletion : Query = ' + Query);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<PRH_Luxury_Accounts__c> iconicAccList){
        List<PRH_Collect__c> collectsList;
        List<PRH_Brand_Criteria__c> LeCercleBRsToDeleteList;
        List<PRH_Competitor_Brands__c> competitorBRsToDeleteList;
        
        if (iconicAccList.size() > 0) {
            System.debug('PRH_Iconic_Account_Deletion, iconicAccList=' + iconicAccList);
            // Retrieve all IDs of collects linked with Iconic Account 
            collectsList = [SELECT id FROM PRH_Collect__c WHERE PRH_Iconic_Account__c IN :iconicAccList];
            System.debug('PRH_Iconic_Account_Deletion, there are ' + collectsList.size() + ' collects to delete');
            // Retrieve Competitor Brand or Le Cercle Brand linked to the collects
            LeCercleBRsToDeleteList = [SELECT id FROM PRH_Brand_Criteria__c WHERE PRH_Collect__c IN :collectsList]; 
            competitorBRsToDeleteList = [SELECT id FROM PRH_Competitor_Brands__c WHERE PRH_Collect__c IN :collectsList];
            
            System.debug('PRH_Iconic_Account_Deletion, there are ' + LeCercleBRsToDeleteList.size() + ' Le Cercle Brands and ' + competitorBRsToDeleteList.size() + ' Competitor Brands linked to the collects');
            // Delete of all Competitor/LeCercle brands, collects linked to the iconic account and of the iconic account itself
            if (competitorBRsToDeleteList.size() > 0) {
                System.debug('PRH_Iconic_Account_Deletion, Competitor Brands are going to be deleted');
                delete competitorBRsToDeleteList;
            }
            if (LeCercleBRsToDeleteList.size() > 0) {
                System.debug('PRH_Iconic_Account_Deletion, Le Cercle Brands are going to be deleted');
                delete LeCercleBRsToDeleteList;
            }  
            if (collectsList.size() > 0) {
                System.debug('PRH_Iconic_Account_Deletion, collects are going to be deleted');
                delete collectsList;
            }    
            System.debug('PRH_Iconic_Account_Deletion, iconic account(s) (' + iconicAccountIDListToDelete + ') is(are) going to be deleted');       
            delete iconicAccList;        
        }
    }

    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
        List<String> toAddresses = new List<String>();
        User current_user = [SELECT Email FROM User WHERE Id= :UserInfo.getUserId()] ;
        System.debug('PRH_Iconic_Account_Deletion, Email prepared for current_user=' + current_user.Email);  

        toAddresses.add(current_user.Email );

        mail.setToAddresses(toAddresses);
        //Email subject
        String mailingSubject = 'Iconic Account deletion';
        mail.setSubject(mailingSubject);
          
        //Email message  
        String mailingMessage  = 'Iconic Account(s) [' + iconicAccountIDListToDelete + '] has(have) been deleted.' + '\r\n'; 
        mail.setPlainTextBody(mailingMessage);
        mail.setEmailPriority('High');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
    }
}