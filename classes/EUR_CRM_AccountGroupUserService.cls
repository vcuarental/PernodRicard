public class EUR_CRM_AccountGroupUserService {

    public static final Integer FIELD_CAPACITY = 255;
    public static final Integer PREFIX_LENGTH = 3;
    public static final String SEPARATOR = ',';
    public static final String EDIT = 'Edit';
    public static final String USER_PREFIX = '005';
    public static final String EMPTY = '';
    public static final String ALREADY_CONTAINS = 'this user already added to current Account (EU)';
    public static final String CAPACITY_EXCEEDED = 'Account (EU) field capacity exceeded';
    public static final String ADD = 'add';
    public static final String REMOVE = 'remove';
    public static final String EMAIL_SUBJECT = 'User can NOT be added to Account(EU) for sharing';
    @TestVisible
    private static final String NEW_STATUS = 'New';
    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';
    private static final String DEV_EMAIL = 'ruslan.nikitin@ctdev.io';
    private static final String ADMIN_EMAIL = 'irina.kurchenko@ctdev.io';
    private static Boolean runOnce = true;

    public void handleAccessLevelChange(Map<Id, EUR_CRM_AccountGroupUser__c> newAccountGroupUsers,
            Map<Id, EUR_CRM_AccountGroupUser__c> oldAccountGroupUsers) {
        System.debug('\n EUR_CRM_AccountGroupUserService.handleAccessLevelChange enter' + '\n');

        List<EUR_CRM_AccountGroupUser__c> accGrUsersToUpdate = getAccGrUsersWithChangedAccess(newAccountGroupUsers, oldAccountGroupUsers);
        System.debug('\n accGrUsersToUpdate.size => ' + accGrUsersToUpdate.size() + '\n');
        System.debug('\n accGrUsersToUpdate => ' + JSON.serializePretty(accGrUsersToUpdate) + '\n');

        if (accGrUsersToUpdate.isEmpty()) { return; }

        List<EUR_CRM_AccountGroupUser__c> clonedAccountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();

        for (EUR_CRM_AccountGroupUser__c accountGroupUser: accGrUsersToUpdate) {
            EUR_CRM_AccountGroupUser__c clonedAccountGroupUser = accountGroupUser.clone();
            clonedAccountGroupUser.EUR_CRM_Status__c = NEW_STATUS;
            clonedAccountGroupUsers.add(clonedAccountGroupUser);
            accountGroupUser.EUR_CRM_Status__c = TO_DELETE_STATUS;
            if (accountGroupUser.EUR_CRM_AccessLevel__c == 'Edit') {
                accountGroupUser.EUR_CRM_AccessLevel__c = 'Read';
            } else {
                accountGroupUser.EUR_CRM_AccessLevel__c = 'Edit';
            }
        }
        System.debug('\n clonedAccountGroupUsers size => ' + clonedAccountGroupUsers.size() + '\n');
        System.debug('\n clonedAccountGroupUsers => ' + JSON.serializePretty(clonedAccountGroupUsers) + '\n');
        if (runOnce) {
            insert clonedAccountGroupUsers;
            runOnce = false;
        }

    }

    private List<EUR_CRM_AccountGroupUser__c> getAccGrUsersWithChangedAccess(Map<Id, EUR_CRM_AccountGroupUser__c>
            newAccGrUsers, Map<Id, EUR_CRM_AccountGroupUser__c> oldAccGrUsers) {
        List<EUR_CRM_AccountGroupUser__c> result = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroupUser__c accGrUser : newAccGrUsers.values()) {
            if (accGrUser.EUR_CRM_AccessLevel__c != oldAccGrUsers.get(accGrUser.Id).EUR_CRM_AccessLevel__c &&
                    accGrUser.EUR_CRM_AccessLevel__c != null) {
                result.add(accGrUser);
            }
        }
        return result;
    }

    public void populateAccounts(List<EUR_CRM_AccountGroupUser__c> newList, String flag) {

        Set<Id> ids = new Set<Id>();

        for (EUR_CRM_AccountGroupUser__c accountGroupUser : newList) {
            if (accountGroupUser.EUR_CRM_AccessLevel__c == EDIT) {
                ids.add(accountGroupUser.Id);
            }
        }

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = getAccountGroupUsersWithAccountInfo(ids);
        Map<Id, EUR_CRM_Account__c> accountsMap = getAccountsMappedToAccGroupUsers(accountGroupUsers);

        EUR_CRM_Account__c account;
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : newList) {
            if (accountGroupUser.EUR_CRM_AccessLevel__c == EDIT) {

                account = accountsMap.get(accountGroupUser.Id);

                if (flag == ADD) {
                    addIdsToAccount(account, accountGroupUser);
                } else if (flag == REMOVE) {
                    removeIdsFromAccount(account, accountGroupUser);
                }
            }
        }

        Map<Id, EUR_CRM_Account__c> accountsMapResult = new Map<Id, EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accountsMap.values()) {
            accountsMapResult.put(acc.Id, acc);
        }

        Database.SaveResult[] srList = Database.update(accountsMapResult.values(), false);

        errorHandling(srList, accountsMapResult, newList);
    }


    private Map<Id, EUR_CRM_Account__c> getAccountsMappedToAccGroupUsers(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers) {

        Map<Id, EUR_CRM_Account__c> resultMap = new Map<Id, EUR_CRM_Account__c>();

        EUR_CRM_Account__c account;
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {

            for (EUR_CRM_Account__c acc : resultMap.values()) {
                if (acc.Id == accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c) {
                    account = acc;
                    break;
                }
            }

            if (account == null) {
                account = new EUR_CRM_Account__c(
                        Id = accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c,
                        EUR_CRM_Visible_to_ID1__c = accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID1__c,
                        EUR_CRM_Visible_to_ID2__c = accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID2__c
                );
            }

            resultMap.put(accountGroupUser.Id, account);

            account = null;
        }

        return resultMap;
    }

    private List<EUR_CRM_AccountGroupUser__c> getAccountGroupUsersWithAccountInfo(Set<Id> ids) {
        return [
                SELECT EUR_CRM_AccountGroup__r.EUR_CRM_Account__c,
                        EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID1__c,
                        EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID2__c
                FROM EUR_CRM_AccountGroupUser__c
                WHERE Id IN :ids
        ];
    }

    private void removeIdsFromAccount(EUR_CRM_Account__c account, EUR_CRM_AccountGroupUser__c accountGroupUser) {
        Set<String> ids = new Set<String>(toList(account.EUR_CRM_Visible_to_ID1__c, account.EUR_CRM_Visible_to_ID2__c));
        String oldId = String.valueOf(accountGroupUser.EUR_CRM_User__c);
        ids.remove(oldId);
        populateAccount(account, new List<String>(ids), accountGroupUser);
    }

    private void addIdsToAccount(EUR_CRM_Account__c account, EUR_CRM_AccountGroupUser__c accountGroupUser) {

        if (String.isBlank(account.EUR_CRM_Visible_to_ID1__c)) {
            String strId = String.valueOf(accountGroupUser.EUR_CRM_User__c);
            account.EUR_CRM_Visible_to_ID1__c = strId.subString(PREFIX_LENGTH) + SEPARATOR;
        } else {
            List<String> ids = toList(account.EUR_CRM_Visible_to_ID1__c, account.EUR_CRM_Visible_to_ID2__c);
            checkForUnique(ids, accountGroupUser);
            populateAccount(account, ids, accountGroupUser);
        }
    }

    private void checkForUnique(List<String> ids, EUR_CRM_AccountGroupUser__c accountGroupUser) {

        String newId = String.valueOf(accountGroupUser.EUR_CRM_User__c);

        if (!ids.contains(newId)) {
            ids.add(newId);
        } else if (!System.isBatch()) {
            // error handling
            //accountGroupUser.addError(ALREADY_CONTAINS);
        }
    }

    private void populateAccount(EUR_CRM_Account__c account, List<String> ids, EUR_CRM_AccountGroupUser__c accountGroupUser) {
        if (!isEnoughCapacityToPopulateAccount(account, ids)) {
            // error handling
            if (System.isBatch()) {
                sendMail(account, accountGroupUser, new List<String>{
                        DEV_EMAIL, ADMIN_EMAIL
                });
            } else {
                accountGroupUser.addError(CAPACITY_EXCEEDED);
            }
        }
    }

    private List<String> toList(String strIds1, String strIds2) {

        List<String> tmpList = new List<String>();
        if (!String.isBlank(strIds1)) {
            tmpList.addAll(strIds1.split(SEPARATOR));
        }

        if (!String.isBlank(strIds2)) {
            tmpList.addAll(strIds2.split(SEPARATOR));
        }

        List<String> result = new List<String>();

        for (String strId : tmpList) {
            result.add(USER_PREFIX + strId);
        }

        return result;
    }

    private boolean isEnoughCapacityToPopulateAccount(EUR_CRM_Account__c account, List<String> ids) {

        Boolean result = true;

        String fieldOne = EMPTY;
        String fieldTwo = EMPTY;
        String resultId = EMPTY;

        for (String idStr : ids) {

            resultId = idStr.subString(PREFIX_LENGTH);

            if ((fieldOne + resultId).length() < FIELD_CAPACITY) {
                fieldOne += (resultId + SEPARATOR);
            } else if ((fieldTwo + resultId).length() < FIELD_CAPACITY) {
                fieldTwo += (resultId + SEPARATOR);
            } else {
                result = false;
            }
        }

        if (result) {
            account.EUR_CRM_Visible_to_ID1__c = fieldOne;
            account.EUR_CRM_Visible_to_ID2__c = fieldTwo;
        }

        return result;
    }

    public static void sendMail(EUR_CRM_Account__c account, EUR_CRM_AccountGroupUser__c accountGroupUser, List<String> addresses) {
        Messaging.SingleEmailMessage [] emails = new Messaging.SingleEmailMessage[]{
        };
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(EMAIL_SUBJECT);
        email.setToAddresses(addresses);
        String body = 'Account (EU) Id:   ' + account.Id + '\n';
        body += 'User Id:                 ' + accountGroupUser.EUR_CRM_User__c + '\n';
        body += 'Host:                    ' + URL.getOrgDomainUrl().getHost();
        email.setPlainTextBody(body);
        emails.add(email);
        Messaging.sendEmail(emails);
    }

    public static void sendMail(String body, List<String> addresses) {
        Messaging.SingleEmailMessage [] emails = new Messaging.SingleEmailMessage[]{
        };
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(EMAIL_SUBJECT);
        email.setToAddresses(addresses);
        body += '\n\nHost:   ' + URL.getOrgDomainUrl().getHost();
        email.setPlainTextBody(body);
        emails.add(email);
        Messaging.sendEmail(emails);
    }

    private void errorHandling(Database.SaveResult[] srList, Map<Id, EUR_CRM_Account__c> accountsMapResult, List<EUR_CRM_AccountGroupUser__c> newList) {
        String body = '';
        for (Integer i = 0; i < srList.size(); i++) {
            if (!srList[i].isSuccess()) {
                for (Database.Error err : srList[i].getErrors()) {
                    if (System.isBatch()) {
                        body += 'The following error has occurred.\n';
                        body += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        body += 'sObject Id: ' + accountsMapResult.values()[i].Id + '\n';
                        body += 'Fields that affected this error: ' + err.getFields() + '\n\n';
                    } else {
                        newList[0].addError(err.getStatusCode() + ': ' + err.getMessage()
                                + '; sObject Id: ' + accountsMapResult.values()[i].Id
                                + '; Fields that affected this error: ' + err.getFields()
                        );
                    }
                }
            }
        }

        if (!String.isBlank(body)) {
            sendMail(body, new List<String>{
                    DEV_EMAIL, ADMIN_EMAIL
            });
        }
    }
}