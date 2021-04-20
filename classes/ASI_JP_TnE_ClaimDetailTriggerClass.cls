public class ASI_JP_TnE_ClaimDetailTriggerClass {

    public static void validateClaimDetailStatus(List<ASI_TnE_ClaimDetail__c> claims)
    {
        Set<Id> userinAccReview= new Set<Id>();
        
        List<groupmember> sql=[select userorgroupid from groupmember where group.developername in('ASI_JP_TnE_Accounting_Review_User')];        
        for(groupmember u: sql)
        {
          userinAccReview.add(u.userorgroupid );         
        }
        List <User> sql2=[select id from user where Profile.name in('ASI JP Admin User')];
        for(user u: sql2)
        {
            if(!userinAccReview.contains(u.id))
                userinAccReview.add(u.id);         
        }
        
        Set<Id> claimHeaderIds = new Set<Id>();
        for(ASI_TnE_ClaimDetail__c claimDetail : claims)
        {
          claimHeaderIds.add(claimDetail.ASI_TnE_ClaimHeader__c);         
        }
        
        Map<Id,ASI_TnE_ClaimHeader__c> claimHeaders = new 
        Map<Id,ASI_TnE_ClaimHeader__c>([Select Id, ASI_TnE_Status__c from ASI_TnE_ClaimHeader__c where id in:claimHeaderIds]);

        for(ASI_TnE_ClaimDetail__c claimDetail : claims)
        {
          ASI_TnE_ClaimHeader__c claimHeader = claimHeaders.get(claimDetail.ASI_TnE_ClaimHeader__c);
          if (!userinAccReview.contains(UserInfo.getUserId()) && claimHeader != null && (claimHeader.ASI_TnE_Status__c == 'Final' || claimHeader.ASI_TnE_Status__c == 'Complete'))
          {
             claimDetail.addError(Label.ASI_JP_TnE_Not_Allowed_to_change_Claim);
             System.debug('Error cannot delete debugging Detail');       
          }         
        }
        
    }

    public static void routineBeforeUpsert(List<ASI_TnE_ClaimDetail__c> triggerNew, Map<Id, ASI_TnE_ClaimDetail__c> triggerOldMap) {
            
      if (triggerNew != null) {                 
       
        validateClaimDetailStatus(triggerNew);
        
        RecordType claimHeaderfinanceViewRecordType = [SELECT Id from RecordType WHERE DeveloperName = 'ASI_JP_TnE_Claim_Header_Finance_View'];      
       
        Set<Integer> claimDetailYears = new Set<Integer>();
        List<ASI_TnE_ClaimDetail__c> validClaimDetails = new List<ASI_TnE_ClaimDetail__c>();
        List<String> counterCurrencies = new List<String>();
        Set<Id> expenseClassificationIds = new Set<Id>();
        Set<Id> claimHeadersToBeNotified = new Set<Id>();
        Set<Id> claimHeadersNotToBeNotified = new Set<Id>();
       
       // BETA CR: Ignore validAttendees when bypass attendee validation is true
       // Must map the expense classification according to claimdetail
       Set<ID> expenseClassicIds = new Set<ID>();
       Set<ID> claimHeadersSet = new Set<ID>();
       
       for (ASI_TnE_ClaimDetail__c claimDetail : triggerNew)
       {
            claimHeadersSet.add(claimDetail.ASI_TnE_ClaimHeader__c);
            if (claimDetail.ASI_TnE_Expense_Classification__c != null)
                expenseClassicIds.add(claimDetail.ASI_TnE_Expense_Classification__c);
       }
            
       Map<ID, ASI_JP_TnE_Expense_Classification__c> expenseClassicMap = new Map<ID, ASI_JP_TnE_Expense_Classification__c>([SELECT ID, Name_en_US__c, ASI_JP_TnE_Bypass_Attendee_Validation__c,ASI_Tne_JP_VAT_Rate__c
                                                                                                                            FROM ASI_JP_TnE_Expense_Classification__c
                                                                                                                            WHERE ID IN : expenseClassicIds]);
       
       Map<ID, ASI_TnE_ClaimHeader__c> allClaimHeaderMap = new Map<ID, ASI_TnE_ClaimHeader__c>([SELECT ID, ASI_TnE_Status__c, Name, (SELECT Id,Name FROM Attachments)
                                                                                                FROM ASI_TnE_ClaimHeader__c
                                                                                                WHERE ID IN : claimHeadersSet]);
       
       for (ASI_TnE_ClaimDetail__c claimDetail : triggerNew) { 
       
          boolean hasValidAttendees = true;
          ASI_JP_TnE_Expense_Classification__c expenseClassification = expenseClassicMap.get(claimDetail.ASI_TnE_Expense_Classification__c) != null 
                                                                        ? expenseClassicMap.get(claimDetail.ASI_TnE_Expense_Classification__c) 
                                                                        : new ASI_JP_TnE_Expense_Classification__c(ASI_JP_TnE_Bypass_Attendee_Validation__c = false);
          
          if ((!expenseClassification.ASI_JP_TnE_Bypass_Attendee_Validation__c 
                && claimDetail.ASI_TnE_Total_Number_Pax__c == null) )
          {
              claimDetail.ASI_TnE_Total_Number_Pax__c.addError(Label.ASI_JP_TnE_Required_Pax);   
          }
          
          /*if (claimDetail.ASI_TnE_FX_Rate__c == null && claimDetail.ASI_TnE_Currency__c != 'JPY')
          {
              claimDetail.ASI_TnE_FX_Rate__c.addError(Label.ASI_JP_TnE_Required_FXRate);
          }*/
          
          if (claimDetail.ASI_TnE_Total_Number_Pax__c >= 1 
                && !expenseClassification.ASI_JP_TnE_Bypass_Attendee_Validation__c)
                //&& claimDetail.ASI_TnE_Total_Number_Pax__c <= 10) //20160324 Ben @ Elufa
          {
               if(claimDetail.ASI_TnE_Attendee_Name__c != null && !''.equals(claimDetail.ASI_TnE_Attendee_Name__c.trim()))
               {
                   String[] attendees = claimDetail.ASI_TnE_Attendee_Name__c.split(';');        
                   if (attendees.size() != claimDetail.ASI_TnE_Total_Number_Pax__c)
                   {
                       hasValidAttendees = false;
                   }
               } else
               {
                   hasValidAttendees = false;               
               }
          }             
          
          if (hasValidAttendees)
          {
              
              ASI_TnE_ClaimDetail__c oldClaimDetail = triggerOldMap!=null?triggerOldMap.get(claimDetail.Id):null;                
           
              if ( (oldClaimDetail != null) &&
               (claimDetail.ASI_TnE_Expense_Category__c != oldClaimDetail.ASI_TnE_Expense_Category__c ||
            claimDetail.ASI_TnE_Expense_Classification__c != oldClaimDetail.ASI_TnE_Expense_Classification__c  || 
            claimDetail.ASI_TnE_Receipt_Amount__c != oldClaimDetail.ASI_TnE_Receipt_Amount__c ))
              {
                
                claimHeadersToBeNotified.add(claimDetail.ASI_TnE_ClaimHeader__c);              
              } 
              
              claimDetailYears.add(claimDetail.ASI_TnE_Receipt_Date__c.year());
                
              // Key records
              validClaimDetails.add(claimDetail);
              /*if (claimDetail.ASI_TnE_Receipt_Number__c == null)
              {
                
              }*/
              
              if (!'JPY'.equals(claimDetail.ASI_TnE_Currency__c))
              {    
               counterCurrencies.add(claimDetail.ASI_TnE_Currency__c);
              }            
              expenseClassificationIds.add(claimDetail.ASI_TnE_Expense_Classification__c);            
              
          } else
          {
              claimDetail.addError(String.format(Label.ASI_JP_TnE_Attendee_Equal_To_Pax
              , new List<String>{String.valueOf(claimDetail.ASI_TnE_Total_Number_Pax__c)}));          
              claimHeadersNotToBeNotified.add(claimDetail.ASI_TnE_ClaimHeader__c);              
          }         
       }
       
       List<ASI_JP_TnE_Tax_Date_Mapping__c> dateMappingList = [Select
       ASI_JP_TnE_Start_Date__c,
       ASI_JP_TnE_End_Date__c,
       ASI_JP_TnE_Tax_Rate__c,
       ASI_TnE_Tax_Area__c,
       ASI_JP_TnE_IsDefault_Tax_Rate__c
       from ASI_JP_TnE_Tax_Date_Mapping__c where CALENDAR_YEAR(ASI_JP_TnE_End_Date__c) in:claimDetailYears];
       
       Map<Integer,List<ASI_JP_TnE_Tax_Date_Mapping__c>> dateYearMappings = new Map<Integer,List<ASI_JP_TnE_Tax_Date_Mapping__c>>();
       
       for (ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping :dateMappingList )       
       {
           if (dateYearMappings.containsKey(taxDateMapping.ASI_JP_TnE_End_Date__c.year()))
           {           
               dateYearMappings.get(taxDateMapping.ASI_JP_TnE_End_Date__c.year()).add(taxDateMapping);
           }else
           {
               List<ASI_JP_TnE_Tax_Date_Mapping__c> taxDateList = new List<ASI_JP_TnE_Tax_Date_Mapping__c>();
               taxDateList.add(taxDateMapping);
               dateYearMappings.put(taxDateMapping.ASI_JP_TnE_End_Date__c.year(),taxDateList);
           }                 
       }
       
      List<ASI_MFM_Exchange_Rate__c> exchangeRateCurrencies = [SELECT ASI_MFM_Base_Currency__c, 
      ASI_MFM_Counter_Currency__c, ASI_MFM_Country__c, ASI_MFM_Effective_Date__c, 
      ASI_MFM_Exchange_Rate__c
      from ASI_MFM_Exchange_Rate__c
      where ASI_MFM_Country__c = 'JP'
      and ASI_MFM_Base_Currency__c = 'JPY'
      and ASI_MFM_Counter_Currency__c in :counterCurrencies
      order by ASI_MFM_Counter_Currency__c desc, ASI_MFM_Effective_Date__c desc];

      Map<String,List<ASI_MFM_Exchange_Rate__c>> exchangeRateMappings = new Map<String,List<ASI_MFM_Exchange_Rate__c>>();
       
       for (ASI_MFM_Exchange_Rate__c exchangeRate : exchangeRateCurrencies)       
       {
           String key = exchangeRate.ASI_MFM_Counter_Currency__c;
           if (exchangeRateMappings.containsKey(key))
           {           
               exchangeRateMappings.get(key).add(exchangeRate);
           } else 
           {
               List<ASI_MFM_Exchange_Rate__c> exchangeRates = new List<ASI_MFM_Exchange_Rate__c>();
               exchangeRates.add(exchangeRate);
               exchangeRateMappings.put(key,exchangeRates);           
           }            
        } 
        
       Map<Id,ASI_JP_TnE_Expense_Classification__c> expenseClassificationMap =
       new Map<Id,ASI_JP_TnE_Expense_Classification__c>([Select Id, ASI_TnE_BC_Code__c, ASI_JP_TnE_Tax_Flag__c, ASI_TnE_Auto_Receipt_No__c,ASI_Tne_JP_VAT_Rate__c
                                                        from ASI_JP_TnE_Expense_Classification__c
                                                        WHERE Id in :expenseClassificationIds]);
       
       Integer autoReceipt = 1;
       ID claimHeaderRecordID;
       if (validClaimDetails.size() > 0)
         claimHeaderRecordID = validClaimDetails.get(0).ASI_TnE_ClaimHeader__c;
         
       List<ASI_TnE_ClaimDetail__c> existingClaimDetails = new List<ASI_TnE_ClaimDetail__c>([SELECT ID, Name, ASI_TnE_Receipt_Number__c, 
                                                                                            ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c
                                                                                            FROM ASI_TnE_ClaimDetail__c 
                                                                                            WHERE ASI_TnE_ClaimHeader__c = : claimHeaderRecordID
                                                                                            order by name]);
       List<ASI_TnE_ClaimDetail__c> claimDetailForUpdate = new List<ASI_TnE_ClaimDetail__c>();
       
       if (triggerOldMap == null)
       {
         for(ASI_TnE_ClaimDetail__c claimDetail : existingClaimDetails)
         {
            if (claimDetail.ASI_TnE_Expense_Classification__r.ASI_TnE_Auto_Receipt_No__c)
            {
                claimDetail.ASI_TnE_Receipt_Number__c = autoReceipt;
                autoReceipt = autoReceipt + 1;
                claimDetailForUpdate.add(claimDetail);
            }
         }
       }
       
       for (ASI_TnE_ClaimDetail__c claimDetail : validClaimDetails) { 
                     
         if (claimDetail.ASI_TnE_Currency__c == 'JPY')
         {
             claimDetail.ASI_TnE_FX_Rate__c = 1;
         }else{
         
          List<ASI_MFM_Exchange_Rate__c> exchangeRates = exchangeRateMappings.get(claimDetail.ASI_TnE_Currency__c); 
          if (exchangeRates != null && (claimDetail.ASI_TnE_FX_Rate__c == null || claimDetail.ASI_TnE_FX_Rate__c<=0))
          {
           boolean isRateExist = false;           
           for (ASI_MFM_Exchange_Rate__c exchangeRate : exchangeRates)
           {
             if (exchangeRate.ASI_MFM_Effective_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c) 
             {
              isRateExist = true;
              claimDetail.ASI_TnE_FX_Rate__c = exchangeRate.ASI_MFM_Exchange_Rate__c; 
              break;
             } 
           }
            if (!isRateExist && claimDetail.ASI_TnE_FX_Rate__c == null)
            {
                claimDetail.addError(Label.ASI_JP_TnE_Currency_Non_Local_FX_Rate_Null);
            }           
          }
          }
         
         
         if (claimDetail.ASI_TnE_Expense_Classification__c!= null && claimDetail.ASI_TnE_BC__c==null)
         {
             claimDetail.ASI_TnE_BC__c = expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_TnE_BC_Code__c;
         } 
                
         
         ASI_JP_TnE_Expense_Classification__c currentExpense = expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c);
        
        if (claimDetail.ASI_TnE_Expense_Classification__c != null)
        {
            if (expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Tax_Flag__c && claimDetail.ASI_TnE_Currency__c == 'JPY')
            {
                claimDetail.ASI_TnE_Non_Taxable_Amount__c = 0;
                if(claimDetail.ASI_TnE_Tax_Area_override__c){
                    claimDetail.ASI_TnE_Tax_Area__c='';
                    claimDetail.ASI_TnE_Taxable_Amount__c =0;
                    claimDetail.ASI_TnE_Non_Taxable_Amount__c=claimDetail.ASI_TnE_Payment_Amount__c;
                }else{
                        List<ASI_JP_TnE_Tax_Date_Mapping__c> taxDateList = 
                         dateYearMappings.get(claimDetail.ASI_TnE_Receipt_Date__c.year());                                  
                        if (taxDateList != null) 
                        {       
                            ////
                            if(claimDetail.ASI_TnE_Tax_Area__c == '' || claimDetail.ASI_TnE_Tax_Area__c == Null){
                                if(expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_Tne_JP_VAT_Rate__c!=null){
                                    claimDetail.ASI_TnE_Tax_Area__c =expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_Tne_JP_VAT_Rate__c;
                                    for(ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping : taxDateList)   
                                    {
                                        if (taxDateMapping.ASI_JP_TnE_Start_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c
                                            && taxDateMapping.ASI_JP_TnE_End_Date__c >=claimDetail.ASI_TnE_Receipt_Date__c 
                                            && taxDateMapping.ASI_TnE_Tax_Area__c.equalsIgnoreCase(claimDetail.ASI_TnE_Tax_Area__c))
                                        {
                                            claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                                (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP); 
                                            break;
                                        }
                                    }
                                }else{
                                
                                    for(ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping : taxDateList)   
                                    {
                                        if (taxDateMapping.ASI_JP_TnE_Start_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c
                                        &&  taxDateMapping.ASI_JP_TnE_End_Date__c >=claimDetail.ASI_TnE_Receipt_Date__c 
                                        && taxDateMapping.ASI_JP_TnE_IsDefault_Tax_Rate__c)
                                        {
                                            claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                                (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP);
                                            claimDetail.ASI_TnE_Tax_Area__c =  taxDateMapping.ASI_TnE_Tax_Area__c;   
                                            break;
                                        }
                                    }
                                }
                            }else{
                                for(ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping : taxDateList)   
                                {
                                    if (taxDateMapping.ASI_JP_TnE_Start_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c
                                        && taxDateMapping.ASI_JP_TnE_End_Date__c >=claimDetail.ASI_TnE_Receipt_Date__c 
                                        && taxDateMapping.ASI_TnE_Tax_Area__c.equalsIgnoreCase(claimDetail.ASI_TnE_Tax_Area__c))
                                    {
                                        claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                            (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP); 
                                        break;
                                    }
                                }
                            }
                            
                            /* Mark  2019-9-25
                            for(ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping : taxDateList)   
                            {
                                if (taxDateMapping.ASI_JP_TnE_Start_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c
                                &&  taxDateMapping.ASI_JP_TnE_End_Date__c >=claimDetail.ASI_TnE_Receipt_Date__c 
                                && taxDateMapping.ASI_JP_TnE_IsDefault_Tax_Rate__c
                                && !claimDetail.ASI_TnE_Tax_Area_override__c )
                                {   
                                    //Ben @ Elufa 2015-08-10
                                    if(allClaimHeaderMap.get(claimDetail.ASI_TnE_ClaimHeader__c).ASI_TnE_Status__c.contains('Draft')){
                                        claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                            (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP);
                                        claimDetail.ASI_TnE_Tax_Area__c =  taxDateMapping.ASI_TnE_Tax_Area__c;   
                                        break;
                                        
                                    }else if(!allClaimHeaderMap.get(claimDetail.ASI_TnE_ClaimHeader__c).ASI_TnE_Status__c.contains('Draft')){
                                        if(claimDetail.ASI_TnE_Tax_Area__c == '' || claimDetail.ASI_TnE_Tax_Area__c == Null){
                                            claimDetail.ASI_TnE_Tax_Area__c='';
                                            claimDetail.ASI_TnE_Taxable_Amount__c =0;
                                            claimDetail.ASI_TnE_Non_Taxable_Amount__c=claimDetail.ASI_TnE_Payment_Amount__c;
                                        }else{
                                            claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                            (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP);
                                             claimDetail.ASI_TnE_Tax_Area__c =  taxDateMapping.ASI_TnE_Tax_Area__c;   
                                             break;
                                        }
                                    }
                                    //Ben @ Elufa 2015-08-10 End
                                } else if (claimDetail.ASI_TnE_Tax_Area_override__c && taxDateMapping.ASI_TnE_Tax_Area__c.equalsIgnoreCase(claimDetail.ASI_TnE_Tax_Area__c)){
                                    if(taxDateMapping.ASI_JP_TnE_Tax_Rate__c==0){
                                        claimDetail.ASI_TnE_Taxable_Amount__c =0;
                                        claimDetail.ASI_TnE_Non_Taxable_Amount__c=claimDetail.ASI_TnE_Payment_Amount__c;
                                    }else{
                                        claimDetail.ASI_TnE_Non_Taxable_Amount__c=0;
                                        claimDetail.ASI_TnE_Taxable_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c / 
                                        (1 + taxDateMapping.ASI_JP_TnE_Tax_Rate__c)).round(System.RoundingMode.HALF_UP);
                                    }
                                    break;
                                }    
                            }//for*/
                        }
                }
            }
            else
            {
                if(claimDetail.ASI_TnE_FX_Rate__c != null) //Leo @ Elufa 2015-12-14
                {
                    claimDetail.ASI_TnE_Non_Taxable_Amount__c = (claimDetail.ASI_TnE_Receipt_Amount__c * claimDetail.ASI_TnE_FX_Rate__c).round(System.RoundingMode.HALF_UP);
                    claimDetail.ASI_TnE_Taxable_Amount__c = 0;
                }//end if
                else //Leo @ Elufa 2015-12-14
                {
                    if(!Test.isRunningTest())
                    {
                        claimDetail.addError('Please enter FX rate');
                        claimDetail.addError('為替レートを入力してください');
                    }//end if
                }//end else //Leo @ Elufa 2015-12-14
            }
            
            //Auto receipt number logic
            if (expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_TnE_Auto_Receipt_No__c && triggerOldMap == null)
            {
                claimDetail.ASI_TnE_Receipt_Number__c = autoReceipt;
                autoReceipt = autoReceipt + 1;
            }
            
            //Auto receipt number logic: remove number when the expense classification is updated
            if (!expenseClassificationMap.get(claimDetail.ASI_TnE_Expense_Classification__c).ASI_TnE_Auto_Receipt_No__c && triggerOldMap != null && claimDetail.ASI_TnE_Receipt_Number__c != null)
            {
                claimDetail.ASI_TnE_Receipt_Number__c = null;
            }
            
        }
        else
        {
            claimDetail.ASI_TnE_Non_Taxable_Amount__c = (claimDetail.ASI_TnE_Receipt_Amount__c * claimDetail.ASI_TnE_FX_Rate__c).round(System.RoundingMode.HALF_UP);
            claimDetail.ASI_TnE_Taxable_Amount__c = 0;
        }
        
        
        
         /*if ( (claimDetail.ASI_TnE_Non_Taxable_Amount__c!= null && claimDetail.ASI_TnE_Non_Taxable_Amount__c==0)
         && (claimDetail.ASI_TnE_Tax_Amount__c== null || claimDetail.ASI_TnE_Tax_Amount__c <=0)
         )
         {        
             List<ASI_JP_TnE_Tax_Date_Mapping__c> taxDateList = 
                 dateYearMappings.get(claimDetail.ASI_TnE_Receipt_Date__c.year());                                  
                       
              for(ASI_JP_TnE_Tax_Date_Mapping__c taxDateMapping : taxDateList)   
              {
                  if (taxDateMapping.ASI_JP_TnE_Start_Date__c <= claimDetail.ASI_TnE_Receipt_Date__c
                  &&  taxDateMapping.ASI_JP_TnE_End_Date__c >=claimDetail.ASI_TnE_Receipt_Date__c)
                  {
                     claimDetail.ASI_TnE_Tax_Amount__c = (claimDetail.ASI_TnE_Payment_Amount__c * 
                     taxDateMapping.ASI_JP_TnE_Tax_Rate__c).round(System.RoundingMode.Up);
                       claimDetail.ASI_TnE_Tax_Area__c =  taxDateMapping.ASI_TnE_Tax_Area__c;            
                  }          
              }
          } else if (claimDetail.ASI_TnE_Tax_Amount__c == null){
           
          claimDetail.ASI_TnE_Tax_Amount__c = 0;
          
          }  */
          
          if (claimDetail.ASI_TnE_Currency__c != null && 'JPY'.equals(claimDetail.ASI_TnE_Currency__c.trim()))
          {
           if (claimDetail.ASI_TnE_Receipt_Amount__c != null && claimDetail.ASI_TnE_Receipt_Amount__c >0)
           {
            claimDetail.ASI_TnE_Receipt_Amount__c  = claimDetail.ASI_TnE_Receipt_Amount__c.round(System.RoundingMode.Up);
           }
          }       
       }       
       
       List<ASI_TnE_ClaimHeader__c> claimHeadersToBeUpdated = new List<ASI_TnE_ClaimHeader__c>();
       
       Map<Id,ASI_TnE_ClaimHeader__c> claimHeaders = new Map<Id,ASI_TnE_ClaimHeader__c>([Select Id, RecordTypeId
       from ASI_TnE_ClaimHeader__c WHERE Id =:claimHeadersToBeNotified]);
         
       
       for (Id claimHeaderId : claimHeadersToBeNotified)
       {
           if (!claimHeadersNotToBeNotified.contains(claimHeaderId) && claimHeaders.get(claimHeaderId).RecordTypeId == 
               claimHeaderfinanceViewRecordType.Id)
           {
               ASI_TnE_ClaimHeader__c claimHeader = new ASI_TnE_ClaimHeader__c(Id=claimHeaderId,ASI_TnE_Sys_Notified__c=true);
               claimHeadersToBeUpdated.add(claimHeader); 
           }       
       }
       
       if (claimHeadersToBeUpdated.size()>0)
       {
           update claimHeadersToBeUpdated;
       }
       
       if (claimDetailForUpdate.size() > 0)
        update claimDetailForUpdate;
             
      }        
    }   
}