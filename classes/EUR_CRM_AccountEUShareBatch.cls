global class EUR_CRM_AccountEUShareBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

//    Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_AccountEUShareBatch scheduledJob = new EUR_CRM_AccountEUShareBatch();
//    System.schedule('EUR_CRM_AccountEUShareBatch: creating of Account Group User records', cronExpression, scheduledJob);

    public static final List<String> ROLLOUT_COUNTRY_CODES = new List<String>();
    static {
        for(EUR_CRM_Rollout_Country__mdt setting :[SELECT DeveloperName FROM EUR_CRM_Rollout_Country__mdt]) {
            ROLLOUT_COUNTRY_CODES.add(setting.DeveloperName);
        }
    }

    private Id accountId;
    @TestVisible
    private Boolean isScheduledJob = false;

    private Map<Id, Map<Id, String>> accessLevelByUserOrGroupIdByAccountEUId;

    global EUR_CRM_AccountEUShareBatch() {
        this.accountId = null;
    }

    global EUR_CRM_AccountEUShareBatch(Boolean isRunByScheduler) {
        this.accountId = null;
        this.isScheduledJob = isRunByScheduler;
    }

    global EUR_CRM_AccountEUShareBatch(Id accId) {
        this.accountId = accId;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(true), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (this.accountId != null) {
            return Database.getQueryLocator([
                SELECT Id
                ,   ParentId
                ,   Parent.EUR_CRM_External_ID__c
                ,   UserOrGroupId
                ,   AccessLevel
                FROM EUR_CRM_Account__Share
                WHERE ParentId = :this.accountId
                    AND UserOrGroup.Name != NULL
                    AND Parent.EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
            ]);
        }

        if (this.isScheduledJob == true) {
            Date dt = getStartDate(BC, Date.today());
            System.debug('\n\n dt => ' + JSON.serializePretty(dt) + '\n');

            return Database.getQueryLocator([
                SELECT Id
                ,   ParentId
                ,   Parent.EUR_CRM_External_ID__c
                ,   UserOrGroupId
                ,   AccessLevel
                FROM EUR_CRM_Account__Share
                WHERE LastModifiedDate >= :dt
                    AND UserOrGroup.Name != NULL
                    AND Parent.EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
            ]);
        }

        return Database.getQueryLocator([
            SELECT Id
            ,   ParentId
            ,   Parent.EUR_CRM_External_ID__c
            ,   UserOrGroupId
            ,   AccessLevel
            FROM EUR_CRM_Account__Share
            WHERE UserOrGroup.Name != NULL
                AND Parent.EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Account__Share> accountShares) {
        System.debug('\n\n accountShares.size() => ' + JSON.serializePretty(accountShares.size()) + '\n');
        System.debug('\n\n accountShares => ' + JSON.serializePretty(accountShares) + '\n');

        this.configureAccessLevelByUserOrGroupIdByAccountId(accountShares);
        System.debug('\n\n this.accessLevelByUserOrGroupIdByAccountEUId.size() => ' + JSON.serializePretty(this.accessLevelByUserOrGroupIdByAccountEUId.size()) + '\n');
        System.debug('\n\n this.accessLevelByUserOrGroupIdByAccountEUId => ' + JSON.serializePretty(this.accessLevelByUserOrGroupIdByAccountEUId) + '\n');

        Map<Id, Set<Id>> userIdsByAccountId = this.getUserIdsByAccountId(accountShares);
        System.debug('\n\n userIdsByAccountId.size() => ' + JSON.serializePretty(userIdsByAccountId.size()) + '\n');
        System.debug('\n\n userIdsByAccountId => ' + JSON.serializePretty(userIdsByAccountId) + '\n');

        Map<Id, String> accIdByAccExtId = this.getAccountExtIdByAccountId(accountShares);
        System.debug('\n accIdByAccExtId.size() => ' + accIdByAccExtId.size() + '\n');
        System.debug('\n accIdByAccExtId => ' + JSON.serializePretty(accIdByAccExtId) + '\n');

        Map<Id, Set<Id>> roleIdsByAccountId = this.getRoleIdsByAccountId(accountShares);
        System.debug('\n\n roleIdsByAccountId.size() => ' + JSON.serializePretty(roleIdsByAccountId.size()) + '\n');
        System.debug('\n\n roleIdsByAccountId => ' + JSON.serializePretty(roleIdsByAccountId) + '\n');

        Set<Id> allAccountIds = new Set<Id>();
        allAccountIds.addAll(userIdsByAccountId.keySet());
        allAccountIds.addAll(roleIdsByAccountId.keySet());
        System.debug('\n\n allAccountIds.size() => ' + JSON.serializePretty(allAccountIds.size()) + '\n');
        System.debug('\n\n allAccountIds => ' + JSON.serializePretty(allAccountIds) + '\n');

        Set<Id> roleIds = this.collectAllRoleIds(roleIdsByAccountId);
        System.debug('\n\n roleIds.size() => ' + JSON.serializePretty(roleIds.size()) + '\n');
        System.debug('\n\n roleIds => ' + JSON.serializePretty(roleIds) + '\n');
        Map<Id, Set<Id>> userIdsByRoleId = this.getUserIdsByRoleId(roleIds);
        System.debug('\n\n userIdsByRoleId.size() => ' + JSON.serializePretty(userIdsByRoleId.size()) + '\n');
        System.debug('\n\n userIdsByRoleId => ' + JSON.serializePretty(userIdsByRoleId) + '\n');

        Set<Id> allUserIds = this.collectAllUserIds(userIdsByAccountId);
        for (Id roleId : userIdsByRoleId.keySet()) {
            allUserIds.addAll(userIdsByRoleId.get(roleId));
        }
        System.debug('\n\n allUserIds.size() => ' + JSON.serializePretty(allUserIds.size()) + '\n');
        System.debug('\n\n allUserIds => ' + JSON.serializePretty(allUserIds) + '\n');

        Map<Id, List<EUR_CRM_AccountGroupUser__c>> existAccountGroupUsersByAccountId = this.getAccountGroupUsersByAccountId(allAccountIds, allUserIds);
        Set<String> existsPair = new Set<String>();
        for (Id accId : existAccountGroupUsersByAccountId.keySet()) {
            for (EUR_CRM_AccountGroupUser__c accountGroupUser : existAccountGroupUsersByAccountId.get(accId)) {
                existsPair.add(accId + ':' + accountGroupUser.EUR_CRM_User__c);
            }
        }
        System.debug('\n\n existAccountGroupUsersByAccountId.size() => ' + JSON.serializePretty(existAccountGroupUsersByAccountId.size()) + '\n');
        System.debug('\n\n existAccountGroupUsersByAccountId => ' + JSON.serializePretty(existAccountGroupUsersByAccountId) + '\n');

        Set<Id> accountIdsWithoutAccountGroupUsers = new Set<Id>(allAccountIds);
        accountIdsWithoutAccountGroupUsers.removeAll(existAccountGroupUsersByAccountId.keySet());
        System.debug('\n\n accountIdsWithoutAccountGroupUsers.size() => ' + JSON.serializePretty(accountIdsWithoutAccountGroupUsers.size()) + '\n');
        System.debug('\n\n accountIdsWithoutAccountGroupUsers => ' + JSON.serializePretty(accountIdsWithoutAccountGroupUsers) + '\n');

        Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c> allAccountGroupByAccount = this.getAccountGroupByAccount(allAccountIds);
        System.debug('\n allAccountGroupByAccount.size() => ' + allAccountGroupByAccount.size() + '\n');
        System.debug('\n allAccountGroupByAccount => ' + JSON.serializePretty(allAccountGroupByAccount) + '\n');


        Map<Id, Id> existAccountGroupIdByAccountId = this.getAccountGroupIdByAccountId(allAccountGroupByAccount, accountIdsWithoutAccountGroupUsers);
//        Map<Id, Id> existAccountGroupIdByAccountId = this.getAccountGroupIdByAccountId(accountIdsWithoutAccountGroupUsers);
        System.debug('\n\n existAccountGroupIdByAccountId.size() => ' + JSON.serializePretty(existAccountGroupIdByAccountId.size()) + '\n');
        System.debug('\n\n existAccountGroupIdByAccountId => ' + JSON.serializePretty(existAccountGroupIdByAccountId) + '\n');

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToInsert = new List<EUR_CRM_AccountGroupUser__c>();

        Map<Id, EUR_CRM_AccountGroup__c> accountGroupToInsertByAccountId = new Map<Id, EUR_CRM_AccountGroup__c>();
        Map<Id, List<EUR_CRM_AccountGroupUser__c>> accountGroupUsersToInsertByAccountId = new Map<Id, List<EUR_CRM_AccountGroupUser__c>>();
        for (Id accId : userIdsByAccountId.keySet()) {
            for (Id userId : userIdsByAccountId.get(accId)) {
                if ( ! existsPair.contains(accId + ':' + userId)) {
                    String accessLevel = 'Read';
                    if (this.accessLevelByUserOrGroupIdByAccountEUId.containsKey(accId)) {
                        if (this.accessLevelByUserOrGroupIdByAccountEUId.get(accId).containsKey(userId)) {
                            accessLevel = this.accessLevelByUserOrGroupIdByAccountEUId.get(accId).get(userId);
                        }
                    } else {
                        Id roleId = this.findRoleIdByUserId(userIdsByRoleId, userId);
                        if (roleId != null) {
                            if (this.accessLevelByUserOrGroupIdByAccountEUId.get(accId).containsKey(roleId)) {
                                accessLevel = this.accessLevelByUserOrGroupIdByAccountEUId.get(accId).get(roleId);
                            }
                        }
                    }

                    if (existAccountGroupUsersByAccountId.containsKey(accId)) {
                        Id agId = existAccountGroupUsersByAccountId.get(accId)[0].EUR_CRM_AccountGroup__c;
                        accountGroupUsersToInsert.add(this.makeAccountGroupUser(agId, userId, accessLevel));
                    } else if (existAccountGroupIdByAccountId.containsKey(accId)) {
                        Id agId = existAccountGroupIdByAccountId.get(accId);
                        accountGroupUsersToInsert.add(this.makeAccountGroupUser(agId, userId, accessLevel));
                    } else if (accountGroupToInsertByAccountId.containsKey(accId)) {
                        if (accountGroupUsersToInsertByAccountId.containsKey(accId)) {
                            accountGroupUsersToInsertByAccountId.get(accId).add(this.makeAccountGroupUser(null, userId, accessLevel));
                        } else {
                            accountGroupUsersToInsertByAccountId.put(accId, new List<EUR_CRM_AccountGroupUser__c> { this.makeAccountGroupUser(null, userId, accessLevel) });
                        }
                    } else {
                        accountGroupToInsertByAccountId.put(accId, this.makeAccountGroup(accId, accIdByAccExtId.get(accId)));

                        if (accountGroupUsersToInsertByAccountId.containsKey(accId)) {
                            accountGroupUsersToInsertByAccountId.get(accId).add(this.makeAccountGroupUser(null, userId, accessLevel));
                        } else {
                            accountGroupUsersToInsertByAccountId.put(accId, new List<EUR_CRM_AccountGroupUser__c> { this.makeAccountGroupUser(null, userId, accessLevel) });
                        }
                    }
                }
            }
        }

        System.debug('\n\n accountGroupUsersToInsert.size() => ' + JSON.serializePretty(accountGroupUsersToInsert.size()) + '\n');
        System.debug('\n\n accountGroupUsersToInsert => ' + JSON.serializePretty(accountGroupUsersToInsert) + '\n');
        this.insertRecords(accountGroupUsersToInsert);

        System.debug('\n\n accountGroupToInsertByAccountId.size() => ' + JSON.serializePretty(accountGroupToInsertByAccountId.size()) + '\n');
        System.debug('\n\n accountGroupToInsertByAccountId => ' + JSON.serializePretty(accountGroupToInsertByAccountId) + '\n');
        this.insertRecords(accountGroupToInsertByAccountId.values());

        accountGroupUsersToInsert = new List<EUR_CRM_AccountGroupUser__c>();
        for (Id accId : accountGroupToInsertByAccountId.keySet()) {
            EUR_CRM_AccountGroup__c accountGroup = accountGroupToInsertByAccountId.get(accId);
            if (accountGroupUsersToInsertByAccountId.containsKey(accId)) {
                List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = accountGroupUsersToInsertByAccountId.get(accId);
                for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
                    accountGroupUser.EUR_CRM_AccountGroup__c = accountGroup.Id;
                    accountGroupUsersToInsert.add(accountGroupUser);
                }
            }
        }

        System.debug('\n\n accountGroupUsersToInsert.size() => ' + JSON.serializePretty(accountGroupUsersToInsert.size()) + '\n');
        System.debug('\n\n accountGroupUsersToInsert => ' + JSON.serializePretty(accountGroupUsersToInsert) + '\n');
        this.insertRecords(accountGroupUsersToInsert);

        List<EUR_CRM_AccountGroup__c> accountGroupToUpdateExtId = this.updateAccountGroupExternalId(allAccountGroupByAccount);

        System.debug('\n accountGroupToUpdateExtId.size() => ' + accountGroupToUpdateExtId.size() + '\n');
        System.debug('\n accountGroupToUpdateExtId => ' + JSON.serializePretty(accountGroupToUpdateExtId) + '\n');
        if (accountGroupToUpdateExtId.isEmpty()) { return; }
        this.upsertRecords(accountGroupToUpdateExtId);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void configureAccessLevelByUserOrGroupIdByAccountId(List<EUR_CRM_Account__Share> accountShares) {
        Map<String, String> apexSharingAccessLevelByManualSharingLevel = new Map<String, String> {
            'Read' => 'Read'
        ,   'Edit' => 'Edit'
        ,   'All' => 'Edit'
        };

        this.accessLevelByUserOrGroupIdByAccountEUId = new Map<Id, Map<Id, String>>();
        for (EUR_CRM_Account__Share share : accountShares) {
            Id accountId = share.ParentId;
            Id userOrGroupId = share.UserOrGroupId;
            String accessLevel = apexSharingAccessLevelByManualSharingLevel.get(share.AccessLevel);

            if (this.accessLevelByUserOrGroupIdByAccountEUId.containsKey(accountId)) {
                this.accessLevelByUserOrGroupIdByAccountEUId.get(accountId).put(userOrGroupId, accessLevel);
            } else {
                this.accessLevelByUserOrGroupIdByAccountEUId.put(accountId, new Map<Id, String> { userOrGroupId => accessLevel });
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, Set<Id>> getUserIdsByAccountId(List<EUR_CRM_Account__Share> accountShares) {
        Map<Id, Set<Id>> userIdsByAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_Account__Share share : accountShares) {
            if (this.isUserId(share.UserOrGroupId)) {
                if (userIdsByAccountId.containsKey(share.ParentId)) {
                    userIdsByAccountId.get(share.ParentId).add(share.UserOrGroupId);
                } else {
                    userIdsByAccountId.put(share.ParentId, new Set<Id> { share.UserOrGroupId });
                }
            }
        }
        return userIdsByAccountId;
    }

    private Map<Id, String> getAccountExtIdByAccountId(List<EUR_CRM_Account__Share> accountShares) {
        Map<Id, String> userIdsByAccountExtId = new Map<Id, String>();
        for (EUR_CRM_Account__Share share : accountShares) {
            userIdsByAccountExtId.put(share.ParentId, share.Parent.EUR_CRM_External_ID__c);
        }
        return userIdsByAccountExtId;
    }

    private Map<Id, Set<Id>> getRoleIdsByAccountId(List<EUR_CRM_Account__Share> accountShares) {
        Map<Id, Set<Id>> roleIdsByAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_Account__Share share : accountShares) {
            if (this.isRoleId(share.UserOrGroupId)) {
                if (roleIdsByAccountId.containsKey(share.ParentId)) {
                    roleIdsByAccountId.get(share.ParentId).add(share.UserOrGroupId);
                } else {
                    roleIdsByAccountId.put(share.ParentId, new Set<Id> { share.UserOrGroupId });
                }
            }
        }
        return roleIdsByAccountId;
    }

    private Map<Id, Set<Id>> getUserIdsByRoleId(Set<Id> roleIds) {
        List<User> users = this.selectUsersWhereRoleId(roleIds);
        Map<Id, Set<Id>> userIdsByRoleId = new Map<Id, Set<Id>>();
        for (User us : users) {
            if (userIdsByRoleId.containsKey(us.UserRoleId)) {
                userIdsByRoleId.get(us.UserRoleId).add(us.Id);
            } else {
                userIdsByRoleId.put(us.UserRoleId, new Set<Id> { us.Id });
            }
        }
        return userIdsByRoleId;
    }

    private Map<Id, List<EUR_CRM_AccountGroupUser__c>> getAccountGroupUsersByAccountId(Set<Id> allAccountIds, Set<Id> allUserIds) {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = this.selectAccountGroupUsers(allAccountIds, allUserIds);
        System.debug('\n\n accountGroupUsers.size() => ' + JSON.serializePretty(accountGroupUsers.size()) + '\n');
        System.debug('\n\n accountGroupUsers => ' + JSON.serializePretty(accountGroupUsers) + '\n');

        Map<Id, List<EUR_CRM_AccountGroupUser__c>> existAccountGroupUsersByAccountId = new Map<Id, List<EUR_CRM_AccountGroupUser__c>>();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            if (existAccountGroupUsersByAccountId.containsKey(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c)) {
                existAccountGroupUsersByAccountId.get(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c).add(accountGroupUser);
            } else {
                existAccountGroupUsersByAccountId.put(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c, new List<EUR_CRM_AccountGroupUser__c> { accountGroupUser });
            }
        }
        return existAccountGroupUsersByAccountId;
    }

//    private Map<Id, Id> getAccountGroupIdByAccountId(Set<Id> accIds) {
//        List<EUR_CRM_Account__c> accounts = this.selectAccountsWithAccountGroup(accIds);
//        System.debug('\n\n accounts => ' + JSON.serializePretty(accounts) + '\n');
//        Map<Id, Id> existAccountGroupIdByAccountId = new Map<Id, Id>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if ( ! account.EUR_CRM_AccountGroups__r.isEmpty()) {
//                existAccountGroupIdByAccountId.put(account.Id, account.EUR_CRM_AccountGroups__r[0].Id);
//            }
//        }
//        return existAccountGroupIdByAccountId;
//    }

    private Map<Id, Id> getAccountGroupIdByAccountId(Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c> accGroupByAcc, Set<Id> accIds) {
        Map<Id, Id> accountGroupIdByAccountId = new Map<Id, Id>();
        for (EUR_CRM_Account__c account : accGroupByAcc.keySet()) {
            if (accIds.contains(account.Id)) {
                accountGroupIdByAccountId.put(account.Id, accGroupByAcc.get(account).Id);
            }
        }
        return accountGroupIdByAccountId;
    }

    private Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c> getAccountGroupByAccount(Set<Id> accIds) {
        List<EUR_CRM_Account__c> accounts = this.selectAccountsWithAccountGroup(accIds);
        System.debug('\n\n accounts => ' + JSON.serializePretty(accounts) + '\n');
        Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c> accountGroupByAccount = new Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_Account__c account : accounts) {
            if ( ! account.EUR_CRM_AccountGroups__r.isEmpty()) {
                accountGroupByAccount.put(account, account.EUR_CRM_AccountGroups__r[0]);
            }
        }
        return accountGroupByAccount;
    }

    private List<EUR_CRM_AccountGroup__c> updateAccountGroupExternalId(Map<EUR_CRM_Account__c, EUR_CRM_AccountGroup__c> existAccountGroupByAccountWithAccountGroupUser) {
        List<EUR_CRM_AccountGroup__c> accountGroupToUpdateExtId = new List<EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_Account__c account : existAccountGroupByAccountWithAccountGroupUser.keySet()) {
            EUR_CRM_AccountGroup__c accountGroup = existAccountGroupByAccountWithAccountGroupUser.get(account);
            if (accountGroup.EUR_CRM_External_ID__c != account.EUR_CRM_External_ID__c) {
                accountGroup.EUR_CRM_External_ID__c = account.EUR_CRM_External_ID__c;
                accountGroupToUpdateExtId.add(accountGroup);
            }
        }
        return accountGroupToUpdateExtId;
    }

    private Id findRoleIdByUserId(Map<Id, Set<Id>> userIdsByRoleId, Id userId) {
        for (Id roleId : userIdsByRoleId.keySet()) {
            for (Id uId : userIdsByRoleId.get(roleId)) {
                if (uId == userId) {
                    return roleId;
                }
            }
        }

        return null;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> collectAllUserIds(Map<Id, Set<Id>> userIdsByAccountId) {
        Set<Id> userIds = new Set<Id>();
        for (Id accId : userIdsByAccountId.keySet()) {
            userIds.addAll(userIdsByAccountId.get(accId));
        }
        return userIds;
    }

    private Set<Id> collectAllRoleIds(Map<Id, Set<Id>> roleIdsByAccountId) {
        Set<Id> roleIds = new Set<Id>();
        for (Id accId : roleIdsByAccountId.keySet()) {
            roleIds.addAll(roleIdsByAccountId.get(accId));
        }
        return roleIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isUserId(Id userOrGroupId) {
        return ((String)userOrGroupId).startsWith('005');
    }

    private Boolean isRoleId(Id userOrGroupId) {
        return ((String)userOrGroupId).startsWith('00E');
    }

    private EUR_CRM_AccountGroup__c makeAccountGroup(Id accId, String accExtId) {
        return new EUR_CRM_AccountGroup__c(
            EUR_CRM_Account__c = accId
        ,   EUR_CRM_External_ID__c = accExtId
        );
    }

    private EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId, String accessLevel) {
        return new EUR_CRM_AccountGroupUser__c(
            EUR_CRM_AccountGroup__c = agId
        ,   EUR_CRM_User__c = usId
        ,   EUR_CRM_AccessLevel__c = accessLevel
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<User> selectUsersWhereRoleId(Set<Id> roleIds) {
        return [
            SELECT Id
            ,   UserRole.Id
            FROM User
            WHERE UserRole.Id IN:roleIds
        ];
    }

    private List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers(Set<Id> accIds, Set<Id> userIds) {
        return [
            SELECT Id
            ,   EUR_CRM_AccountGroup__c
            ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
            ,   EUR_CRM_User__c
            FROM EUR_CRM_AccountGroupUser__c
            WHERE EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :accIds
                AND EUR_CRM_User__c IN :userIds
        ];
    }

    private List<EUR_CRM_Account__c> selectAccountsWithAccountGroup(Set<Id> accIds) {
        return [
            SELECT Id
            ,   EUR_CRM_External_ID__c
            ,   (
                SELECT Id
                ,   EUR_CRM_External_ID__c
                FROM EUR_CRM_AccountGroups__r
                LIMIT 1
            )
            FROM EUR_CRM_Account__c
            WHERE Id IN :accIds
        ];
    }

}