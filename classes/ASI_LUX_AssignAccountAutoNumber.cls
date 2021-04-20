public with sharing class ASI_LUX_AssignAccountAutoNumber extends ASI_HK_CRM_TriggerAbstract {
  
  public ASI_LUX_AssignAccountAutoNumber() {
    super('ASI_LUX_AssignAccountAutoNumber');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
      && !isBypassByCurrentUser()) {
      List<Account> AccList = (List<Account>)sObjList; 
      /*Start Steve 19March2014 modify on Global_RecordTypeCache           
        List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType 
                                    WHERE SobjectType = 'Account' 
                                    AND (RecordType.DeveloperName LIKE 'ASI_Luxury_Account_HK%' 
                                    OR RecordType.DeveloperName LIKE 'ASI_Luxury_Account_Regional%')];
        */
        List<RecordType> RTTempList =Global_RecordTypeCache.getRtList('Account'); 
        List<RecordType> RTList = new List<RecordType>();
        for(RecordType RT : RTTempList)
        {
            if (RT.DeveloperName.contains('ASI_Luxury_Account_Regional') 
                    || RT.DeveloperName.contains('ASI_Luxury_Account_HK') 
                        || RT.DeveloperName.contains('ASI_Luxury_Account_MY') 
                            || RT.DeveloperName.contains('ASI_Luxury_Account_MY')
                                || RT.DeveloperName.contains('ASI_Luxury_Account_TW')
                                    || RT.DeveloperName.contains('ASI_Luxury_Account_JP')
                                        || RT.DeveloperName.contains('ASI_LUX_SG')
                                            || RT.DeveloperName.contains('ASI_BRD_SG_GHM_Account')
                                                || RT.DeveloperName.contains('ASI_BRD_SG_TGL_Account'))
            {
                RTList.add(RT);
            }
       }
                  
      if (RTList != null && RTList.size() > 0) {
          ASI_HK_CRM_AutoNumberAssignment autoNumAssign = null;
          ASI_HK_CRM_AutoNumberAssignment autoNumAssignCustomer = null;
        for (Account Acc : AccList) {
              boolean is_HK_Lux_Acct = false;
              boolean is_HK_Lux_Potential = false;
              boolean is_Regional_Lux = false;
              boolean is_MY_Lux = false;
              boolean is_TW_Lux = false;
              boolean is_JP_Lux = false;
              boolean is_SG_Lux = false;
              boolean is_SGBRD_GHM_Lux = false;
              boolean is_SGBRD_TGL_Lux = false;
              for(RecordType RT : RTList)
              {
                    if(acc.RecordTypeId== RT.id)
                        is_HK_Lux_Acct = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName == 'ASI_Luxury_Account_HK_Potential')
                        is_HK_Lux_Potential = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_Regional'))
                        is_Regional_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_MY'))
                        is_MY_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_TW'))
                        is_TW_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_Luxury_Account_JP'))
                        is_JP_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_LUX_SG'))
                        is_SG_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_BRD_SG_GHM_Account'))
                        is_SGBRD_GHM_Lux = true;
                        
                    if(acc.RecordTypeId == RT.id && RT.DeveloperName.contains('ASI_BRD_SG_TGL_Account'))
                        is_SGBRD_TGL_Lux = true;
        
              }
              if((is_HK_Lux_Acct || is_Regional_Lux || is_MY_Lux || is_TW_Lux) && !is_HK_Lux_Potential && tAction == TriggerAction.BEFORE_INSERT)
              {
                if (autoNumAssign == null) {
                  if(is_Regional_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_Regional');
                    /*if (autoNumAssignCustomer == null)
                    {
                        autoNumAssignCustomer = new ASI_HK_CRM_AutoNumberAssignment('ASI_LUX_Regional_Customer_Num');
                        Acc.ASI_CRM_Customer_No__c = autoNumAssignCustomer.nextAutoNumStr();
                    }*/
                  }
                  else if (is_MY_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_MY');
                  }
                  else if (is_TW_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_TW');
                  }
                  else if (is_JP_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_JP');
                  }
                  else if (is_SG_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                  }
                  else if (is_SGBRD_GHM_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                  }
                  else if (is_SGBRD_TGL_Lux)
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                  }
                  else
                  {
                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_HK');
                  }
                }
                  Acc.ASI_LUX_Internal_Member_No__c = autoNumAssign.nextAutoNumStr();
                  //Acc.ASI_LUX_Internal_Member_No__c=acc.RecordType.DeveloperName;
              }
          
              // To accomodate Lux Potential Account being edited to either First Contact record type or Second Contact record type
              if (tAction == TriggerAction.BEFORE_UPDATE)
              {
                Map<ID, Account> oldMapAcc = (Map<ID, Account>)oldMap;
                if((acc.ASI_LUX_Profile__c == 'First Contact' || acc.ASI_LUX_Profile__c == 'Second Contact')
                    && oldMapAcc.get(acc.id).ASI_LUX_Profile__c == 'Potential')
                    {
                        if (acc.ASI_LUX_Internal_Member_No__c == null)
                        {
                            if (autoNumAssign == null) {
                                if(is_Regional_Lux)
                                {
                                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_Regional');
                                    /*if (autoNumAssignCustomer == null)
                                    {
                                        autoNumAssignCustomer = new ASI_HK_CRM_AutoNumberAssignment('ASI_LUX_Regional_Customer_Num');
                                        Acc.ASI_CRM_Customer_No__c = autoNumAssignCustomer.nextAutoNumStr();
                                    }*/ 
                                }
                                else if (is_MY_Lux)
                                {
                                  autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_MY');
                                }
                                else if (is_TW_Lux)
                                {
                                  autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_TW');
                                }
                                else if (is_TW_Lux)
                                {
                                  autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_JP');
                                }
                                else if (is_SG_Lux)
                                {
                                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                                }
                                else if (is_SGBRD_GHM_Lux)
                                {
                                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                                }
                                else if (is_SGBRD_TGL_Lux)
                                {
                                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Brand_Account_SG');
                                }
                                else
                                    autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_Luxury_Account_HK');
                            }
                            Acc.ASI_LUX_Internal_Member_No__c = autoNumAssign.nextAutoNumStr();
                        } 
                    }
              }           
        }
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
            
        if (autoNumAssignCustomer != null)
            autoNumAssignCustomer.writeToDB();
      }
    }
  }

}