public with sharing class EUR_CRM_UpdateManagerOfOwnerOnAcc implements
                Database.Batchable<SObject>, Database.Stateful {


    private String countryCode;
    Map<String, Integer> countryAndBedAccSize = new Map<String, Integer>();

    Map <User, List<EUR_CRM_Account__c>> ownerWithoutManager = new Map <User, List<EUR_CRM_Account__c>>();
    List<String> errorUpdateMsg = new List<String>();

    public EUR_CRM_UpdateManagerOfOwnerOnAcc(String countryCode) {
        this.countryCode = countryCode;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,OwnerId, EUR_CRM_Manager_of_Account_Owner__c FROM EUR_CRM_Account__c WHERE EUR_CRM_Country_Code__c = :countryCode AND EUR_CRM_isManagerOfOwnerWrong__c = TRUE]);
    }
    public void execute(Database.BatchableContext bc, List <EUR_CRM_Account__c> allCountryAccounts) {
        List <EUR_CRM_Account__c> accountsForUpdate = new List<EUR_CRM_Account__c>();
        accountsForUpdate = getWrongOwnerManagerAccounts(allCountryAccounts, String.valueOf(countryCode));
        Integer i = 0;

        if (accountsForUpdate != null && !accountsForUpdate.isEmpty()) {
            Database.SaveResult[] result = Database.update(accountsForUpdate, false);
            for (Database.SaveResult res : result) {
                if (!res.isSuccess()) {
                    String error = 'Account Id => ' + accountsForUpdate.get(i).Id + ',';
                    for (Database.Error err : res.getErrors()) {
                        error = error + ' status code => ' + err.getStatusCode() + ', ' + err.getMessage() + ',' +
                                'account fields that affected this error => ' + err.getFields() ;
                    }
                    errorUpdateMsg.add(error);
                }
                i++;
            }
        }
    }

    private List<EUR_CRM_Account__c> getWrongOwnerManagerAccounts(List<EUR_CRM_Account__c> countryAcc, String countryCode) {
        System.debug('Country =>' + countryCode);
        List <User> countryUsers = new List<User>();
        List <EUR_CRM_Account__c> allCountryAccounts = countryAcc;
        List <EUR_CRM_Account__c> accountsForUpdate = new List<EUR_CRM_Account__c>();
        Set<Id> ownerIds = new Set<Id>();

        ownerIds = getOwnerIds(allCountryAccounts);
        countryUsers = [SELECT Id,Name,ManagerId FROM User WHERE Id IN :ownerIds];
        Map<Id, User>idUserMap = new Map<Id, User>(countryUsers);

        for (EUR_CRM_Account__c acc : allCountryAccounts) {
            Id accOwnerId = acc.OwnerId;
            User accOwner = idUserMap.get(accOwnerId);
            if (accOwner.ManagerId == null) {
                if (!ownerWithoutManager.containsKey(accOwner)) {
                    ownerWithoutManager.put(accOwner, new List<EUR_CRM_Account__c>());
                }
                ownerWithoutManager.get(accOwner).add(acc);
            } else if (accOwner.ManagerId != null && acc.EUR_CRM_Manager_of_Account_Owner__c != accOwner.ManagerId) {
                acc.EUR_CRM_Manager_of_Account_Owner__c = accOwner.ManagerId;
                accountsForUpdate.add(acc);
            }
        }
        countryAndBedAccSize.put(countryCode, accountsForUpdate.size());

        return accountsForUpdate;
    }

    public void finish(Database.BatchableContext param1) {
        System.debug('All bed size by country =>' + countryAndBedAccSize);
        System.debug('acc owner without manager size =>' + ownerWithoutManager.size());

        for (String errMsg : errorUpdateMsg) {
            System.debug('error msg =>' + errMsg);
        }
        sendEmail(errorUpdateMsg, ownerWithoutManager);
    }


    private Set<Id> getOwnerIds(List<EUR_CRM_Account__c>accounts) {
        Set<Id>ownerIds = new Set<Id>();
        for (EUR_CRM_Account__c acc : accounts) {
            ownerIds.add(acc.OwnerId);
        }
        return ownerIds;
    }
    private void sendEmail(List<String> errorUpdateMsgString, Map<User, List<EUR_CRM_Account__c>>ownerWithoutManager) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                UserInfo.getUserEmail(), 'Mykhailo.Pikh@ctdev.io'
        };
        String mainString = 'Errors and Accounts , which were not  updated due to an error: \r ';

        if (!errorUpdateMsgString.isEmpty()) {
            mainString = 'Update errors:  \r +AccountId,StatusCode,Message,Field \n';
            for (String err : errorUpdateMsgString) {
                mainString = mainString + err + '\n';
            }
            mainString +='\n\n';
        }
        if (!ownerWithoutManager.isEmpty()) {
            mainString +='Users  without manager and  accounts :  \r';
            for (User user : ownerWithoutManager.keySet()) {
                mainString +=user +': \r accounts \r';
                for (EUR_CRM_Account__c acc : ownerWithoutManager.get(user)) {
                    mainString += acc + '\r';
                }
                mainString +='\n';
            }
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(mainString);
        string csvname = 'Account.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        email.setToAddresses(toAddresses);
        email.setSubject('Update account owner manager batch Errors');
        email.setPlainTextBody(mainString);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                csvAttc
        });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
        System.debug('main string =>' +mainString);
    }
}