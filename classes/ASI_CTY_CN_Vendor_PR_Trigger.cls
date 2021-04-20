/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PR_Trigger       
* Test Class:  ASI_CTY_CN_Vendor_PR_TriggerTest
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-10-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PR_Trigger {
    public static void beforeInsertMethod(List<ASI_MFM_Purchase_Request__c> triggerNew)
    {
       List<ASI_MFM_Prefix__c> prefixlist = new List<ASI_MFM_Prefix__c>([SELECT id, Name, ASI_MFM_Next_Number__c, ASI_MFM_Fiscal_year__c 
                                                                          FROM ASI_MFM_Prefix__c 
                                                                          WHERE ASI_MFM_Module__c = 'CN Vendor PR' AND ASI_MFM_Inactive__c = False 
                                                                          Order By CreatedDate
                                                                          Limit 1]);
        Boolean updatePrefix = False;

        Set<String>  acCodeSets = new Set<String>();
        Set<String>  cateSets = new Set<String>();
        for(ASI_MFM_Purchase_Request__c re : triggerNew)
        {
          acCodeSets.add(re.ASI_CTY_CN_Vendor_AC_Code__c);
          cateSets.add(re.ASI_CTY_CN_Vendor_PP_Category__c);
        }
        List<ASI_MFM_PP_Category_A_C__c> caAcList = [SELECT ASI_MFM_PP_Category__c,ASI_MFM_A_C_Code__c FROM ASI_MFM_PP_Category_A_C__c WHERE ASI_MFM_A_C_Code__c IN: acCodeSets
                                                    AND ASI_MFM_PP_Category__c IN:cateSets];
        Set<String>  caAcSets = new Set<String>();
        for(ASI_MFM_PP_Category_A_C__c ac:caAcList)
        {
           caAcSets.add(ac.ASI_MFM_A_C_Code__c + '_' + ac.ASI_MFM_PP_Category__c);
        }
        
        for(ASI_MFM_Purchase_Request__c obj : triggerNew){
          
          String key = obj.ASI_CTY_CN_Vendor_AC_Code__c + '_' + obj.ASI_CTY_CN_Vendor_PP_Category__c;
          if(!caAcSets.contains(key))
          {
              obj.addError('The value of A/C code is not in the range of category, please select again!');
          }

          if(prefixlist.size() > 0){
                    
                    obj.ASI_MFM_Prefix__c = prefixlist[0].id;
                    
                    obj.Name = prefixlist[0].Name + prefixlist[0].ASI_MFM_Fiscal_year__c.subString(2, 4);
                    
                    obj.Name += ('' + (1000000 + prefixlist[0].ASI_MFM_Next_Number__c)).subString(1);
                    
                    prefixlist[0].ASI_MFM_Next_Number__c = prefixlist[0].ASI_MFM_Next_Number__c + 1;
                    
                    updatePrefix = True;
                    //obj.ASI_CTY_CN_Vendor_Responsible_by__c = UserInfo.getUserId();
                   // obj.CurrencyIsoCode= 'CNY';
                }else{
                    
                    obj.addError('No effective Prefix can be found, Please contact Admin.');
                }
        }

        if(prefixlist.size() > 0 && updatePrefix)
        {
          Update prefixlist;
        } 
    }



    public static void beforeUpdateMethod(List<ASI_MFM_Purchase_Request__c> triggerNew,Map<Id,ASI_MFM_Purchase_Request__c> oldMap)
    {
       Set<Id> reIds = new  Set<Id>();

        Set<String>  acCodeSets = new Set<String>();
        Set<String>  cateSets = new Set<String>();
       for(ASI_MFM_Purchase_Request__c re: triggerNew)
       {
         ASI_MFM_Purchase_Request__c oldRe = oldMap.get(re.Id);
         acCodeSets.add(re.ASI_CTY_CN_Vendor_AC_Code__c);
         cateSets.add(re.ASI_CTY_CN_Vendor_PP_Category__c);
         if(re.ASI_CTY_CN_Vendor_Plan__c != oldRe.ASI_CTY_CN_Vendor_Plan__c || re.ASI_CTY_CN_Vendor_Bu__c != oldRe.ASI_CTY_CN_Vendor_Bu__c ||
            re.ASI_CTY_CN_Vendor_PP_Category__c != oldRe.ASI_CTY_CN_Vendor_PP_Category__c || re.ASI_CTY_CN_Vendor_Subchannel__c != oldRe.ASI_CTY_CN_Vendor_Subchannel__c)
         {
            reIds.add(re.Id);
         }
         
       }

        List<ASI_MFM_PP_Category_A_C__c> caAcList = [SELECT ASI_MFM_PP_Category__c,ASI_MFM_A_C_Code__c FROM ASI_MFM_PP_Category_A_C__c WHERE ASI_MFM_A_C_Code__c IN: acCodeSets
                                                    AND ASI_MFM_PP_Category__c IN:cateSets];
        Set<String>  caAcSets = new Set<String>();
        for(ASI_MFM_PP_Category_A_C__c ac:caAcList)
        {
           caAcSets.add(ac.ASI_MFM_A_C_Code__c + '_' + ac.ASI_MFM_PP_Category__c);
        }

       List<ASI_MFM_Purchase_Request_Line__c>  reLines = [SELECT ASI_MFM_Purchase_Request__c,Name FROM ASI_MFM_Purchase_Request_Line__c WHERE ASI_MFM_Purchase_Request__c IN: reIds AND (ASI_CTY_CN_Vendor_Status__c = 'In Distribution' 
        OR ASI_CTY_CN_Vendor_Status__c = 'Allocated' OR ASI_CTY_CN_Vendor_Status__c = 'Approved' OR ASI_CTY_CN_Vendor_Status__c = 'Generate PO')];
       Map<Id,String> reMaps = new  Map<Id,String>();
       System.debug(LoggingLevel.INFO, '*** reLines: ' + reLines);
       for(ASI_MFM_Purchase_Request_Line__c line :reLines)
       {
         reMaps.put(line.ASI_MFM_Purchase_Request__c, line.Name);
       }

       for(ASI_MFM_Purchase_Request__c re: triggerNew)
       {
          String key = re.ASI_CTY_CN_Vendor_AC_Code__c + '_' + re.ASI_CTY_CN_Vendor_PP_Category__c;
          if(!caAcSets.contains(key))
          {
              re.addError('The value of A/C code is not in the range of category, please select again!');
          }
          if(reMaps.containsKey(re.Id))
          {
            re.addError('There is a purchase request line under this purchase request, which is being approved or approved. Modification is not allowed!');
          }
       }
    }

    
    public static void afterUpdateMethod(List<ASI_MFM_Purchase_Request__c> triggerNew,Map<Id,ASI_MFM_Purchase_Request__c> oldMap)
    {
      Set<Id> creatId = new Set<Id>();
      Set<Id> purList = new Set<Id>();
      List<ASI_MFM_Purchase_Request__Share> shareList = new  List<ASI_MFM_Purchase_Request__Share>();
       for(ASI_MFM_Purchase_Request__c re: triggerNew)
       {
         ASI_MFM_Purchase_Request__c oldRe = oldMap.get(re.Id);
         if(re.ASI_CTY_CN_Vendor_Responsible_by__c != oldRe.ASI_CTY_CN_Vendor_Responsible_by__c)
         {
            creatId.add(re.ASI_CTY_CN_Vendor_Responsible_by__c);
            purList.add(re.Id);
         }
       }

      Map<Id, User> lUser = new Map<Id, User>([Select id, ManagerID, UserRoleId, ASI_CRM_Sales_Team__c, ASI_MFM_Team__c, BypassTriggers__c from User Where (CompanyName = 'Pernod Ricard China' OR ID IN :creatId) AND isActive = TRUE]);
      List<ASI_MFM_Dynamic_Approval_Route__c> approvalRouteList = [Select ASI_MFM_Approval_Limit__c, ASI_MFM_End_of_1st_Route__c, ASI_MFM_Manager_ID__c, ASI_MFM_Type__c, ASI_MFM_User__c from ASI_MFM_Dynamic_Approval_Route__c where ASI_MFM_Type__c = 'PR'];
      Map<id, ASI_MFM_Dynamic_Approval_Route__c> mAppRoute = new Map<id, ASI_MFM_Dynamic_Approval_Route__c>();
      Map<id, User> mUser = new Map<id, User>();
      for(User u : lUser.values()){
          mUser.put(u.id, u);
      }   
      for(ASI_MFM_Dynamic_Approval_Route__c a : approvalRouteList){
          mAppRoute.put(a.ASI_MFM_User__c, a);
      }

      for(ASI_MFM_Purchase_Request__c pr:triggerNew)
      {  
         setApprovers(pr, mAppRoute, mUser,shareList);
      }

      if(shareList.size()>0)
      {
        insert shareList;
      }

      if(purList.size()>0)
      {
        List<ASI_MFM_Purchase_Request_Line__c> reLineList = [SELECT Id,ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c FROM ASI_MFM_Purchase_Request_Line__c WHERE ASI_MFM_Purchase_Request__c IN:purList];
        for(ASI_MFM_Purchase_Request_Line__c line :reLineList)
        {
           line.ASI_CTY_CN_Vendor_Approval_MKT__c = line.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c;
        }

        if(reLineList.size()>0)
        {
          update reLineList;
        }
      }

      
    }

    public static void afterInsertMethod(List<ASI_MFM_Purchase_Request__c> triggerNew)
    {
      
      Set<Id> creatId = new Set<Id>();
      List<ASI_MFM_Purchase_Request__Share> shareList = new  List<ASI_MFM_Purchase_Request__Share>();
      for(ASI_MFM_Purchase_Request__c pre:triggerNew)
      { 
          creatId.add(pre.ASI_CTY_CN_Vendor_Responsible_by__c);
      }
      Map<Id, User> lUser = new Map<Id, User>([Select id, ManagerID, UserRoleId, ASI_CRM_Sales_Team__c, ASI_MFM_Team__c, BypassTriggers__c from User Where (CompanyName = 'Pernod Ricard China' OR ID IN :creatId) AND isActive = TRUE]);
      List<ASI_MFM_Dynamic_Approval_Route__c> approvalRouteList = [Select ASI_MFM_Approval_Limit__c, ASI_MFM_End_of_1st_Route__c, ASI_MFM_Manager_ID__c, ASI_MFM_Type__c, ASI_MFM_User__c from ASI_MFM_Dynamic_Approval_Route__c where ASI_MFM_Type__c = 'PR'];
      Map<id, ASI_MFM_Dynamic_Approval_Route__c> mAppRoute = new Map<id, ASI_MFM_Dynamic_Approval_Route__c>();
      Map<id, User> mUser = new Map<id, User>();
      for(User u : lUser.values()){
          mUser.put(u.id, u);
      }   
      for(ASI_MFM_Dynamic_Approval_Route__c a : approvalRouteList){
          mAppRoute.put(a.ASI_MFM_User__c, a);
      }

      for(ASI_MFM_Purchase_Request__c pr:triggerNew)
      {  
         setApprovers(pr, mAppRoute, mUser,shareList);
      }

      if(shareList.size()>0)
      {
        insert shareList;
      }
    }

   

   

  public static void setApprovers(ASI_MFM_Purchase_Request__c p, Map<id, ASI_MFM_Dynamic_Approval_Route__c> mAppRoute,  Map<id, User> mUser,List<ASI_MFM_Purchase_Request__Share> shareList){
        integer approver_count = 0;
        boolean proceed = true;
        id currentUserid = p.ASI_CTY_CN_Vendor_Responsible_by__c;
        
        ASI_MFM_Dynamic_Approval_Route__c currentApprover = null;
        User userCurrentApprover = null;
        System.debug(LoggingLevel.INFO, '*** mAppRoute: ' + mAppRoute);
        System.debug(LoggingLevel.INFO, '*** mUser: ' + mUser);
        System.debug(LoggingLevel.INFO, '*** currentUserid: ' + currentUserid);
        List<Id> mktManager = new List<Id>();
        while(proceed){
            if(currentUserid != null && (mAppRoute.containsKey(currentUserid) || mUser.containsKey(currentUserid))){
                if(mAppRoute.get(currentUserid) != null){
                    currentApprover = mAppRoute.get(currentUserid);
                    currentUserid = currentApprover.ASI_MFM_Manager_ID__c;
                }
                else{
                    if(mUser.get(currentUserid) != null){
                        userCurrentApprover = mUser.get(currentUserid);
                        currentUserid = userCurrentApprover.ManagerID;
                    }
                }
                System.debug(LoggingLevel.INFO, '*** currentUserid: ' + currentUserid);
                System.debug(LoggingLevel.INFO, '*** userCurrentApprover: ' + userCurrentApprover);
                if(currentApprover != null && userCurrentApprover == null){                            
                    mktManager.add(currentApprover.ASI_MFM_User__c);
                }
                else if(currentApprover == null && userCurrentApprover != null){
                    mktManager.add(userCurrentApprover.id);
                }
                
                approver_count++;
                if(approver_count>5){
                    proceed = false;                                
                }
                currentApprover = null;
                userCurrentApprover = null;
            }
            else{
                proceed = false;
            }
        }
        setShareMktManger(p,mktManager,shareList);
        System.debug(LoggingLevel.INFO, '*** mktManager: ' + mktManager);
    }

    public static void setShareMktManger(ASI_MFM_Purchase_Request__c p,List<Id> mktManager,List<ASI_MFM_Purchase_Request__Share> shareList)
    {
       for(Id mktId :mktManager)
       {
          if(!mktId.equals(p.ASI_CTY_CN_Vendor_Responsible_by__c) || p.CreatedById != p.ASI_CTY_CN_Vendor_Responsible_by__c)
          {
             ASI_MFM_Purchase_Request__Share requestShare = new ASI_MFM_Purchase_Request__Share();
             requestShare.AccessLevel = 'Edit';
             requestShare.ParentId = p.Id;
             requestShare.RowCause = 'Manual';
             requestShare.UserOrGroupId = mktId;
             shareList.add(requestShare);
          }
       }
    }

   
    
}