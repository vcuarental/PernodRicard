public without sharing class EUR_CRM_CacheBatchService {

    public static final String DYN_GROUP_MEMB_BATCH_ID = 'DGM';             //AccountGroup__c, ProductGroup__c
    public static final String DYN_GROUP_MEMB_CHANGING_BATCH_ID = 'DGC';    //Account, CTCPG__Product__c

    public static final String TERR_USER_DEL_SHARING_BATCH_ID = 'TUD';      //User
    public static final String TERR_ACC_SHARING_BATCH_ID = 'TAS';           //Account
    public static final String TERR_ACC_DEL_SHARING_BATCH_ID = 'TAD';       //Account
    public static final String TERR_SHARING_BATCH_ID = 'TTS';               //Territory__c
    public static final String TERR_DEL_SHARING_BATCH_ID = 'TTD';           //Group
    public static final String TERR_MODEL_SHARING_BATCH_ID = 'TMS';         //TerritoryModel__c

    public static final String TERR_ACC_ASS_RULE_BATCH_ID = 'TAR';          //TerritoryAssignmentRule__c
    public static final String TERR_ACC_DEL_ASS_RULE_BATCH_ID = 'TDR';      //TerritoryAssignmentRule__c
    public static final String TERR_ACC_DEL_BATCH_ID = 'TDO';               //Territory__c
    public static final String TERR_ACC_MODEL_ASS_RULE_BATCH_ID = 'TMR';    //TerritoryModel__c

    public static final String PRODCATALOG_SHARING_BATCH_ID = 'PCS';        //ContractModel__c
    public static final String PRODCATALOG_SHARING_DEL_BATCH_ID = 'PCD';        //ContractModel__c

    public static final String TERR_ACC_UPDATING_AFTER_SHARING_BATCH = 'TAU'; //Group

}