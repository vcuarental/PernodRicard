trigger ASI_LUX_AccountBeforeUpdateApproved on Account (before update) {
    
    // Checking to avoid firing HK_CRM account trigger irrelevant to its recordtype
    //if (ASI_HK_CRM_Util.isLuxAcct(trigger.new))
    //Modified by Wilken Lee on 20140318, reduce usage of SOQL limit on Account triggers
    //Modified by Conrad Pantua on 20140804, clean up trigger and organize recordtypes/countries for LUXURY multi-country development
    // Laputa Vincent Lam 20161103: check record type is null
    if (trigger.new[0].recordTypeid != null){
        List<Account> validLuxuryAccounts = new List<Account>();
        for (Account acc : trigger.new)
        {
            if(('Approved').equals(acc.ASI_LUX_LeCercle_Member_Appl_Status__c) 
                    && acc.ASI_LUX_LeCercle_Member_Appl_Status__c!= Trigger.oldMap.get(acc.Id).ASI_LUX_LeCercle_Member_Appl_Status__c 
                        && acc.ASI_LUX_LeCercle_Member_Since_Date__c == null
                            && acc.ASI_LUX_Le_Cercle_Member_Number__c == null && !acc.ASI_LUX_Le_Cercle_Member__c)
            {
                validLuxuryAccounts.add(acc);
            }
        }
        if (validLuxuryAccounts.size() > 0)
        {
            if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_Luxury_Account_TW'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num_TW');
            }
            else if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_Luxury_Account_HK'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num');
            }
            else if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_Luxury_Account_MY'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num_MY');
            }
            else if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_Luxury_Account_Regional'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num_Regional');
            }
            else if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_Luxury_Account_JP'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num_JP');
            }
            else if (Global_RecordTypeCache.getRt(validLuxuryAccounts.get(0).recordTypeid).developerName.contains('ASI_LUX_SG_Account'))
            {
                ASI_LUX_AutoNumber_Account_Assignment.assignLuxLeCercleNumber(validLuxuryAccounts, 'ASI_LUX_Le_Cercle_Membership_Num_SG');
            }
        }
    }
    
    /*
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_First_Contact') 
        ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Second_Contact')
            ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Potential')
                ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked')
                    ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_Regional_Second_Contact')
                        ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_Regional_Second_Contact_Le_Cercle_Locked')
                            ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_First_Contact')
                                ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Potential')
                                    ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Second_Contact_Le_Cercle_Locked')
                                        ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Second_Contact')
                                            || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_TW')
    ){
        List<ASI_HK_CRM_Running_Number__c> runningNumbers = [select ASI_HK_CRM_Running_Number__c, ASI_HK_CRM_Object_Name__c from ASI_HK_CRM_Running_Number__c 
                                                            where ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num' 
                                                            OR ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_Regional' 
                                                            OR ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_MY'
                                                            OR ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_TW'
                                                            for update];
        ASI_HK_CRM_Running_Number__c runningNumber;
        ASI_HK_CRM_Running_Number__c runningNumberRegional;
        ASI_HK_CRM_Running_Number__c runningNumberMY;
        ASI_HK_CRM_Running_Number__c runningNumberTW;
        
        if(runningNumbers.size() > 0)
        {
            for (ASI_HK_CRM_Running_Number__c runNum : runningNumbers)
            {
                if (runNum.ASI_HK_CRM_Object_Name__c == 'ASI_LUX_Le_Cercle_Membership_Num'  )
                    runningNumber = runNum;
                // CR Feb 25 2014
                if (runNum.ASI_HK_CRM_Object_Name__c == 'ASI_LUX_Le_Cercle_Membership_Num_Regional'  )
                    runningNumberRegional = runNum;
                // Add Malaysia Country
                if (runNum.ASI_HK_CRM_Object_Name__c == 'ASI_LUX_Le_Cercle_Membership_Num_MY'  )
                    runningNumberMY = runNum;
                // Add Taiwan Country
                if (runNum.ASI_HK_CRM_Object_Name__c == 'ASI_LUX_Le_Cercle_Membership_Num_TW'  )
                    runningNumberTW = runNum;
            }
        }
        
        
        Integer rNumber = 0;
        // CR Feb 25 2014
        Integer rNumberRegional = 0;
        // Add Malsyia Country
        Integer rNumberMY = 0;
        // Add Taiwan Country
        Integer rNumberTW = 0;
        
        if (runningNumberRegional != null)
        {
            rNumberRegional = (Integer) runningNumberRegional.ASI_HK_CRM_Running_Number__c;
        }
        if(runningNumber != null )
        {
            rNumber = (Integer) runningNumber.ASI_HK_CRM_Running_Number__c;
        }
        if(runningNumberMY != null )
        {
            rNumberMY = (Integer) runningNumberMY.ASI_HK_CRM_Running_Number__c;
        }
        
        if(runningNumberTW != null )
        {
            rNumberTW = (Integer) runningNumberTW.ASI_HK_CRM_Running_Number__c;
        }
        
        List<Account> updateAccount = new List<Account>();

        List<RecordType> RTList =Global_RecordTypeCache.getRtList('Account'); 
        
        String countryCode = '01'; //hongkong  
        String countryCodeASI = '00'; //Asia
        String countryCodeMY = '02'; // Malaysia
        String countryCodeTW = '03'; // Taiwan
        
        Boolean flag = false;
        Boolean flagRegional = false;
        boolean flagMY = false;
        boolean flagTW = false;
        
        for ( Account account : Trigger.new ){
            
            boolean is_Regional_Lux = false;
            boolean is_MY = false;
            boolean is_HK = false;
            boolean is_TW = false;
            
            for(RecordType RT : RTList)
            {
                if(account.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_Regional'))
                    is_Regional_Lux = true;
                if(account.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_MY'))
                    is_MY = true;
                if(account.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_HK'))
                    is_HK = true;
                if(account.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_TW'))
                    is_TW = true;
            }
            
            if (runningNumbers.isEmpty())
                account.adderror(' The record ASI_LUX_Le_Cercle_Membership_Num for the Object ASI_HK_CRM_Running_Number__c is missing. Please contact the System Administrator to verify that this Running Number record is deployed');
            
            if(('Approved').equals(account.ASI_LUX_LeCercle_Member_Appl_Status__c) && 
                account.ASI_LUX_LeCercle_Member_Appl_Status__c!= Trigger.oldMap.get(account.Id).ASI_LUX_LeCercle_Member_Appl_Status__c && account.ASI_LUX_LeCercle_Member_Since_Date__c == null
                && account.ASI_LUX_Le_Cercle_Member_Number__c == null && !account.ASI_LUX_Le_Cercle_Member__c)
            {       
                    Integer year = DateTime.now().year() - 2000;
                    String n = null;
                    
                    if (is_Regional_Lux)
                    {
                        rNumberRegional = rNumberRegional + 1;
                        n = '' + year + countryCodeASI  + leadingZero(rNumberRegional, 4);
                    }
                    else if (is_MY)
                    {
                        rNumberMY = rNumberMY + 1;
                        n = '' + year + countryCodeMY + leadingZero(rNumberMY, 4); 
                    }
                    else if (is_HK)
                    {
                        rNumber = rNumber + 1;
                        n = '' + year + countryCode + leadingZero(rNumber, 4);
                    }
                    else if (is_TW)
                    {
                        rNumberTW = rNumberTW + 1;
                        n = '' + year + countryCodeTW + leadingZero(rNumberTW, 4);
                    }
                    
                    account.ASI_LUX_LeCercle_Member_Since_Date__c = DateTime.now().date();
                    account.ASI_LUX_Le_Cercle_Member_Number__c = n;

                    // Not In USE
                    updateAccount.add(account);
                    
                    if (is_Regional_Lux)
                        flagRegional = true;
                    else if (is_MY)
                        flagMY = true;
                    else if (is_HK)
                        flag = true;
                    else if (is_TW)
                        flagTW = true;
            }
        }

        if(flag){
            runningNumber.ASI_HK_CRM_Running_Number__c = (Decimal) rNumber;
            update(runningNumber);
        }
        if (flagRegional)
        {
            runningNumberRegional.ASI_HK_CRM_Running_Number__c = (Decimal) rNumberRegional;
            update(runningNumberRegional);
        }
        if (flagMY)
        {
            runningNumberMY.ASI_HK_CRM_Running_Number__c = (Decimal) rNumberMY;
            update(runningNumberMY);
        }
        if (flagTW)
        {
            runningNumberTW.ASI_HK_CRM_Running_Number__c = (Decimal) rNumberTW;
            update(runningNumberTW);
        }
        
    }

    public String leadingZero(Integer myNumber,Integer resultLength)
    {  
    
        String fn = string.valueof(myNumber);  
        while (fn.length() < resultLength)   
        {  
            fn = '0' + fn;  
        }  
      
        return fn;  
    }*/

}