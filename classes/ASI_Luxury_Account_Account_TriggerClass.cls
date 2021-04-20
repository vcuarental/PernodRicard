public without sharing class ASI_Luxury_Account_Account_TriggerClass { 

    // When this field is updated, please update the HK_CRM_UTIL class, the method checking ISLUXACCT 
    public static final Set<String> LUX_ACCT_REC_TYPES = new Set<String> {
        'ASI_Luxury_Account_HK_First_Contact'
        , 'ASI_Luxury_Account_HK_Second_Contact'
        , 'ASI_Luxury_Account_Regional_Second_Contact'
        , 'ASI_Luxury_Account_HK_Potential'
    };
    
    public static List<Account> returnTrigger (List<Account> triggerObj)
    {
        Set<ID> newAcctSet = new Set<ID>();
        for (Account newAcct : triggerObj)
            newAcctSet.add(newAcct.id);
            
        List<Account> triggerNew = [SELECT ID, NAME, Ownerid, RecordType.developername FROM Account WHERE ID IN : newAcctSet];
        
        for (Account i : triggerNew)
            System.debug('clkk1 ' + i.recordType.developername);
            
        return triggerNew;
    }
    
    public static void routineBeforeDelete(list<account> trigger_old) 
    {
        Set<ID> deleteLuxAcctDir = new Set<ID>();
        for (Account acc : trigger_old) 
        {
            System.debug('delk1 ' + acc.recordType.id);
            //if (LUX_ACCT_REC_TYPES.contains(acc.recordType.developerName))
            deleteLuxAcctDir.add(acc.id);
        }
        
        if (deleteLuxAcctDir.size() > 0)
        {
            List<ASI_LUX_Account_Directory__c> acctDirList = [SELECT ID FROM ASI_LUX_Account_Directory__c WHERE ASI_LUX_Account__c IN : deleteLuxAcctDir for UPDATE];
            if (acctDirList != null)
                delete acctDirList;
        }
    }
    
    public static void routineAfterInsert(List<Account> trigger_new)
    {
        List<ASI_LUX_Account_Directory__c> acctDirList = new List<ASI_LUX_Account_Directory__c>();
        
        List<Account> triggerNew = returnTrigger(trigger_new) == null ? new List<Account> () : returnTrigger(trigger_new);
        
        for (Account acc : triggerNew)
        {
            System.debug('devk1 ' + acc.recordType);
            System.debug('devk2 ' + acc.recordType.developerName);
            System.debug('devk3 ' + acc);
            if (LUX_ACCT_REC_TYPES.contains(acc.recordType.developerName))
            {
                ASI_LUX_Account_Directory__c newAccDir = new ASI_LUX_Account_Directory__c();
                newAccDir.name = acc.name.left(80);
                newAccDir.ASI_LUX_Account__c = acc.id;
                newAccDir.ASI_LUX_Account_Owner__c = acc.OwnerID;
                acctDirList.add(newAccDir);
            }
        }
        if (acctDirList.size() > 0)
            insert acctDirList;
    }
    
    public static void routineAfterUpdate(list<account> trigger_new, map<id, account> trigger_oldMap) 
    {
        
       Map<ID, account> updatedLuxAcctMap = new Map<ID, account>();
       
       List<Account> triggerNew = returnTrigger(trigger_new) == null ? new List<Account>() : returnTrigger(trigger_new);
       
       for (Account acc : triggerNew)
       {
            if (LUX_ACCT_REC_TYPES.contains(acc.recordType.developerName))
            {
                if(trigger_oldMap.get(acc.id).name != acc.name || trigger_oldMap.get(acc.id).OwnerID != acc.OwnerID)
                {
                    updatedLuxAcctMap.put(acc.id, acc);
                }
            }
       }
       
       if (updatedLuxAcctMap.size() > 0)
       {
           List<ASI_LUX_Account_Directory__c> accDirList = [SELECT ID, name, OwnerID, ASI_LUX_Account__c FROM ASI_LUX_Account_Directory__c WHERE ASI_LUX_Account__c IN : updatedLuxAcctMap.keySet()];
           for (ASI_LUX_Account_Directory__c accLuxDir : accDirList)
           {
               Account acc = updatedLuxAcctMap.get(accLuxDir.ASI_LUX_Account__c);
               if (acc != null)
               {
                    accLuxDir.name = acc.name.left(80);
                    accLuxDir.ASI_LUX_Account_Owner__c = acc.OwnerID;
               }
           }
           if (accDirList.size() > 0)
               update accDirList;
       }
        
    }
}