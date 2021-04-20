/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PurLine_TriggerClass       
* Test Class:  ASI_CTY_CN_Vendor_PurLine_TriggerCtlTest
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-10-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PurLine_TriggerClass {


	public void beforeUpdateBudil(List<ASI_MFM_Purchase_Request_Line__c> requestLines,Map<Id,ASI_MFM_Purchase_Request_Line__c>oldMap)
	{
        List<ASI_MFM_Purchase_Request_Line__c> noAllowApprove = new List<ASI_MFM_Purchase_Request_Line__c>();
        List<ASI_MFM_Purchase_Request_Line__c> assignmentList = new List<ASI_MFM_Purchase_Request_Line__c>();
        List<ASI_MFM_Purchase_Request_Line__c> buyeList = new List<ASI_MFM_Purchase_Request_Line__c>();
        Set<Id> creatId = new Set<Id>();
        Set<Id> rejectList = new Set<Id>();
        for(ASI_MFM_Purchase_Request_Line__c re:requestLines)
        {
           ASI_MFM_Purchase_Request_Line__c oldLine = (ASI_MFM_Purchase_Request_Line__c)oldMap.get(re.Id);
           if(oldLine.ASI_CTY_CN_Vendor_IsBuyerApprove__c !=re.ASI_CTY_CN_Vendor_IsBuyerApprove__c && re.ASI_CTY_CN_Vendor_IsBuyerApprove__c && !re.ASI_CTY_CN_Vendor_IsSelectQuotation__c)
           {
               noAllowApprove.add(re);
           }
           if(oldLine.ASI_CTY_CN_Vendor_Item_Group_Code__c != re.ASI_CTY_CN_Vendor_Item_Group_Code__c)
           {
               buyeList.add(re);
           }

           if(oldLine.ASI_CTY_CN_Vendor_IsBuyerApprove__c !=re.ASI_CTY_CN_Vendor_IsBuyerApprove__c && re.ASI_CTY_CN_Vendor_IsBuyerApprove__c && re.ASI_CTY_CN_Vendor_IsSelectQuotation__c)
           {
                assignmentList.add(re);
                creatId.add(re.ASI_CTY_CN_Vendor_Approval_MKT__c);
           }
            if(re.ASI_CTY_CN_Vendoe_IsNeedComparePrice__c)
           {
              if(null != re.ASI_CTY_CN_Vendor_Select_Quotation__c)
              {
                  
                  System.debug(LoggingLevel.INFO, '*** re.ASI_CTY_CN_Vendor_Last_Offer__c: ' + re.ASI_CTY_CN_Vendor_Last_Offer__c);
                  
                  System.debug(LoggingLevel.INFO, '***  re.ASI_CTY_CN_Vendor_All_Price__c: ' +  re.ASI_CTY_CN_Vendor_All_Price__c);
                  if( re.ASI_CTY_CN_Vendor_Last_Offer__c >= re.ASI_CTY_CN_Vendor_All_Price__c)
                  {
                    re.ASI_CTY_CN_Vendor_Is_Need_MKT_Approval__c = false;
                    System.debug(LoggingLevel.INFO, '*** 111111: ' );
                  }
                  else
                  {
                    re.ASI_CTY_CN_Vendor_Is_Need_MKT_Approval__c = true;
                  }

                 
              }
           }
           if(oldLine.ASI_CTY_CN_Vendor_Status__c != re.ASI_CTY_CN_Vendor_Status__c && re.ASI_CTY_CN_Vendor_Status__c == 'Reject')
           {
              re.ASI_CTY_CN_Vendor_Merge_Quotation__c = null;
              re.ASI_CTY_CN_Vendor_Select_Quotation__c = null;
              re.ASI_CTY_CN_Vendor_Supplier__c = null;
              re.ASI_CTY_CN_Vendor_Last_Offer__c = re.ASI_CTY_CN_Vendor_All_Price__c;
              re.ASI_CTY_CN_Vendor_All_Price__c = null;
              if(re.ASI_CTY_CN_Vendor_IsMerged__c)
              {
                 rejectList.add(re.Id);
              }
              
           }

        }
        
        Set<Id> quoIds1 = new Set<Id>();
        Set<Id> quoIds = new Set<Id>();
        Map<Id,Id> qlineMaps = new  Map<Id,Id>();
        if(rejectList.size()>0)
        {
          
          List<ASI_CRM_Quotation__c> quos = [SELECT ASI_CTY_CN_Vendor_Quotation__c,ASI_CTY_CN_Purchase_Request_Line__c from ASI_CRM_Quotation__c where ASI_CTY_CN_Purchase_Request_Line__c IN:rejectList];
          for(ASI_CRM_Quotation__c qu: quos)
          {
            quoIds.add(qu.ASI_CTY_CN_Vendor_Quotation__c);
            qlineMaps.put(qu.ASI_CTY_CN_Purchase_Request_Line__c, qu.ASI_CTY_CN_Vendor_Quotation__c);
          }
          List<ASI_CRM_Quotation__c> quos1 = [SELECT ASI_CTY_CN_Vendor_Quotation__c,ASI_CTY_CN_Purchase_Request_Line__c,ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Status__c from ASI_CRM_Quotation__c where ASI_CTY_CN_Vendor_Quotation__c IN:quoIds
          AND ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Status__c ='Approved'];
          for(ASI_CRM_Quotation__c qu1: quos1)
          {
            quoIds1.add(qu1.ASI_CTY_CN_Vendor_Quotation__c);
          }
        }

        for(ASI_MFM_Purchase_Request_Line__c re1:requestLines)
        {
            Id mquoId = qlineMaps.get(re1.Id);
            if(quoIds1.contains(mquoId))
            {
              re1.addError('The record of merging quotation with this PR line has been approved, so this PR line cannot be rejected!');
            }
        }

        if(buyeList.size()>0)
        {
            setApprovalBuyer(requestLines);
        }
        if(noAllowApprove.size()>0)
        {
           ASI_MFM_Purchase_Request_Line__c line = noAllowApprove.get(0);
           line.addError('Please select a supplier quotation for PR line first!');
        }

        if(assignmentList.size()>0)
        {
           List<ASI_MFM_Fix_Approval_Route__c> routs = [select ASI_MFM_Corporate_Approver_1__c,ASI_MFM_Corporate_Approver_2__c,ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Approval_Limit_CA1__c from ASI_MFM_Fix_Approval_Route__c where RecordType.Name = 'CN Fix Approval Route' and ASI_MFM_Module__c ='PR' AND ASI_MFM_Team__c = null limit 1];
           List<User> userList = [SELECT Id,ManagerId FROM User WHERE Id IN: creatId];
           Map<Id,Id> userMap = new  Map<Id,Id>();
           for(User u:userList)
           {
             userMap.put(u.Id, u.ManagerId);
           }
           for(ASI_MFM_Purchase_Request_Line__c l:assignmentList)
           {
             if(routs.size() == 0 )
             {
               l.addError('Please contact the system administrator to configure buyer manage.');
             }
             else
             {
                  ASI_MFM_Fix_Approval_Route__c rout = routs.get(0);
                 if(l.ASI_CTY_CN_Vendor_All_Price__c > rout.ASI_MFM_Approval_Limit_CA1__c)
                 {
                    l.ASI_CTY_CN_Vendor_Approval_Buyer_Manger__c = rout.ASI_MFM_Corporate_Approver_2__c;
                 }
                 else
                 {
                  l.ASI_CTY_CN_Vendor_Approval_Buyer_Manger__c = rout.ASI_MFM_Corporate_Approver_1__c;
                 }
             }
            
           }

           setApprovalMktManager(assignmentList,creatId);
           setApprovalBA(assignmentList,creatId);
        }
	}

	public void beforeInsertBudil(List<ASI_MFM_Purchase_Request_Line__c> requestLines)
	{
       setApprovalBuyer(requestLines);
	}

  public void setApprovalBuyer(List<ASI_MFM_Purchase_Request_Line__c> requestLines)
  {
      Set<Id> buyidSet = new Set<Id>();
        for(ASI_MFM_Purchase_Request_Line__c re1:requestLines)
        {
           buyidSet.add(re1.ASI_CTY_CN_Vendor_Buyer__c);
        }
        List<ASI_MFM_Buyer_Master__c> buyers = [SELECT Id,ASI_MFM_Buyer__c FROM ASI_MFM_Buyer_Master__c WHERE Id IN : buyidSet];
        Map<Id,Id> buyIdMaps = new Map<Id,Id>();
        for(ASI_MFM_Buyer_Master__c buy :buyers)
        {
          buyIdMaps.put(buy.Id, buy.ASI_MFM_Buyer__c);
        }

        for(ASI_MFM_Purchase_Request_Line__c re2:requestLines)
        {
          re2.ASI_CTY_CN_Vendor_Approval_Buyer__c = buyIdMaps.get(re2.ASI_CTY_CN_Vendor_Buyer__c);
        }
  }

  public void setApprovalMktManager(List<ASI_MFM_Purchase_Request_Line__c> requestLines,Set<Id> creatId )
  {
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

      for(ASI_MFM_Purchase_Request_Line__c pr:requestLines)
      {  
         
         //pr.ASI_CTY_CN_Vendor_Approval_MKT__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_MKT_Manage__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_MKT_Manage1__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_MKT_Manage2__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_MKT_Manage3__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_MKT_Manage4__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_BA__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_BA1__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_BA2__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_BA3__c = null;
         pr.ASI_CTY_CN_Vendor_Approval_BA4__c = null;
         setApprovers(pr, mAppRoute, mUser);
      }

       
  }

  public static void setApprovers(ASI_MFM_Purchase_Request_Line__c p, Map<id, ASI_MFM_Dynamic_Approval_Route__c> mAppRoute,  Map<id, User> mUser){
        integer approver_count = 0;
        boolean proceed = true;
        id currentUserid = p.ASI_CTY_CN_Vendor_Approval_MKT__c;
        
        ASI_MFM_Dynamic_Approval_Route__c currentApprover = null;
        User userCurrentApprover = null;
        System.debug(LoggingLevel.INFO, '*** mAppRoute: ' + mAppRoute);
        System.debug(LoggingLevel.INFO, '*** mUser: ' + mUser);
        System.debug(LoggingLevel.INFO, '*** currentUserid: ' + currentUserid);
        
        //Dynamic Route 
        //Updated by Twinkle - Dynamic Route -> Managers        
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
                System.debug(LoggingLevel.INFO, '*** userCurrentApprover: ' + userCurrentApprover);
                System.debug(LoggingLevel.INFO, '*** currentUserid: ' + currentUserid);
                if(currentApprover != null && userCurrentApprover == null){                            
                    setApproverByCount(p, approver_count, currentApprover.ASI_MFM_User__c);
                }
                else if(currentApprover == null && userCurrentApprover != null){
                    setApproverByCount(p, approver_count, userCurrentApprover.id);
                }
                
                if(approver_count !=0 && currentApprover != null && ((currentApprover.ASI_MFM_Approval_Limit__c != 0 && currentApprover.ASI_MFM_Approval_Limit__c >= p.ASI_CTY_CN_Vendor_All_Price__c) || currentApprover.ASI_MFM_End_of_1st_Route__c)){
                    proceed = false;                                
                }
                approver_count++;
                currentApprover = null;
                userCurrentApprover = null;
            }
            else{
                proceed = false;
            }
        }
    }

    public static void setApproverByCount(ASI_MFM_Purchase_Request_Line__c p, integer approver_count, Id userId)
    {
        System.debug(LoggingLevel.INFO, '*** userId: ' + userId);
        System.debug(LoggingLevel.INFO, '*** approver_count: ' + approver_count);
        if(approver_count == 1){
            p.ASI_CTY_CN_Vendor_Approval_MKT_Manage__c = userId;
        }
        else if(approver_count == 2){
            p.ASI_CTY_CN_Vendor_Approval_MKT_Manage1__c = userId;
        }
        else if(approver_count == 3){
            p.ASI_CTY_CN_Vendor_Approval_MKT_Manage2__c = userId;
        }
        else if(approver_count == 4){
            p.ASI_CTY_CN_Vendor_Approval_MKT_Manage3__c = userId;
        }
        else if(approver_count == 5){
            p.ASI_CTY_CN_Vendor_Approval_MKT_Manage4__c = userId;
        }
       
    }

    public void setApprovalBA(List<ASI_MFM_Purchase_Request_Line__c> requestLines,Set<Id> creatId )
    {
        List<User> userList = [SELECT Id,ASI_MFM_Team__c   FROM User WHERE Id IN:creatId];
        Map<Id,String> teams = new Map<Id,String>();
        for(User u:userList)
        {
          teams.put(u.Id,u.ASI_MFM_Team__c);
        }
        System.debug(LoggingLevel.INFO, '*** teams: ' + teams);
        
        Map<String,ASI_MFM_Fix_Approval_Route__c> routeMap = new Map<String,ASI_MFM_Fix_Approval_Route__c>();
        List<ASI_MFM_Fix_Approval_Route__c> approvalRouteList = [SELECT Id,ASI_MFM_Team__c,ASI_MFM_BA__c,ASI_MFM_Approval_Limit_BA__c,
        ASI_MFM_Approval_Limit_CA1__c,ASI_MFM_Approval_Limit_CA2__c,ASI_MFM_Approval_Limit_CA3__c,ASI_MFM_Approval_Limit_CA4__c,
        ASI_MFM_Corporate_Approver_1__c,ASI_MFM_Corporate_Approver_2__c,ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c 
        FROM ASI_MFM_Fix_Approval_Route__c  WHERE ASI_MFM_Module__c ='PR' AND ASI_MFM_Team__c IN :teams.values() AND RecordType.Name = 'CN Fix Approval Route'];
        for(ASI_MFM_Fix_Approval_Route__c route :approvalRouteList)
        {
           routeMap.put(route.ASI_MFM_Team__c, route);
        }

        for(ASI_MFM_Purchase_Request_Line__c line:requestLines)
        {
           String team = teams.get(line.ASI_CTY_CN_Vendor_Approval_MKT__c);
           System.debug(LoggingLevel.INFO, '*** line.ASI_CTY_CN_Vendor_Approval_MKT__c: ' + line.ASI_CTY_CN_Vendor_Approval_MKT__c);
           if(routeMap.containsKey(team))
           {
             ASI_MFM_Fix_Approval_Route__c appRoute =  routeMap.get(team);
             line.ASI_CTY_CN_Vendor_Approval_BA__c = appRoute.ASI_MFM_BA__c;
             if(appRoute.ASI_MFM_Approval_Limit_BA__c == null)
             {
               continue;
             }
             if(line.ASI_CTY_CN_Vendor_All_Price__c>appRoute.ASI_MFM_Approval_Limit_BA__c)
             {
               line.ASI_CTY_CN_Vendor_Approval_BA1__c = appRoute.ASI_MFM_Corporate_Approver_1__c;
             }

             if(line.ASI_CTY_CN_Vendor_All_Price__c>appRoute.ASI_MFM_Approval_Limit_CA1__c)
             {
               line.ASI_CTY_CN_Vendor_Approval_BA2__c = appRoute.ASI_MFM_Corporate_Approver_2__c;
             }

             if(line.ASI_CTY_CN_Vendor_All_Price__c>appRoute.ASI_MFM_Approval_Limit_CA2__c)
             {
               line.ASI_CTY_CN_Vendor_Approval_BA3__c = appRoute.ASI_MFM_Corporate_Approver_3__c;
             }

             if(line.ASI_CTY_CN_Vendor_All_Price__c>appRoute.ASI_MFM_Approval_Limit_CA3__c)
             {
               line.ASI_CTY_CN_Vendor_Approval_BA4__c = appRoute.ASI_MFM_Corporate_Approver_4__c;
             }
           }
           else
           {
             line.addError('Please contact the system administrator for team:'+team+',Configure Ba approval personnel');
           }
        }
    }

    public void afterUpdateBudil(List<ASI_MFM_Purchase_Request_Line__c> requestLines, Map<Id,ASI_MFM_Purchase_Request_Line__c> oldMap)
    {
        Map<Id, Integer> prlQuantityMap = new Map<Id, Integer>();
        ASI_MFM_Purchase_Request_Line__c tempPrl = null;
        Set<Id> rejectList = new Set<Id>();
        for (ASI_MFM_Purchase_Request_Line__c prl : requestLines) {
            tempPrl = oldMap.get(prl.Id);
            if (prl.ASI_CTY_CN_Vendor_Total_Quantity__c != tempPrl.ASI_CTY_CN_Vendor_Total_Quantity__c) {
                prlQuantityMap.put(prl.Id, Integer.valueOf(prl.ASI_CTY_CN_Vendor_Total_Quantity__c - tempPrl.ASI_CTY_CN_Vendor_Total_Quantity__c));
            }

             // Clear quotation status on reject
           if(tempPrl.ASI_CTY_CN_Vendor_Status__c != prl.ASI_CTY_CN_Vendor_Status__c && prl.ASI_CTY_CN_Vendor_Status__c == 'Reject')
           {
              rejectList.add(prl.Id);
           }
        }
        System.debug(LoggingLevel.INFO, '*** prlQuantityMap: ' + prlQuantityMap);
        Set<Id> prlIds = prlQuantityMap.keySet();
        List<ASI_CRM_quotation__c> quoteList = null;
        if (prlIds != null && prlIds.size() > 0) {
            quoteList = new List<ASI_CRM_quotation__c>();
            Integer quantity = 0;
            for (ASI_CRM_quotation__c q : [SELECT Id, ASI_CTY_CN_Purchase_Request_Line__c, ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Total_Quantity__c 
            FROM ASI_CRM_quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c IN :prlIds]) {
                System.debug(LoggingLevel.INFO, '*** q: ' + q);
               System.debug(LoggingLevel.INFO, '*** : q.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Total_Quantity__c' +q.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Total_Quantity__c );
                quantity = Integer.valueOf(q.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Total_Quantity__c) + Integer.valueOf(prlQuantityMap.get(q.ASI_CTY_CN_Purchase_Request_Line__c));
                 System.debug(LoggingLevel.INFO, '*** quantity: ' + quantity);
                quoteList.add(new ASI_CRM_quotation__c(Id = q.ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_Total_Quantity__c = quantity));
            }
            System.debug(LoggingLevel.INFO, '*** quoteList: ' + quoteList);
            update quoteList;
        }

        List<ASI_CRM_quotation__c> qList = new List<ASI_CRM_quotation__c>();
        if(rejectList.size()>0)
        {
          for (ASI_CRM_quotation__c q1 : [SELECT Id, ASI_CTY_CN_Purchase_Request_Line__c,ASI_CTY_CN_Vendor_Result_Status__c,ASI_CTY_CN_Vendor_IsConfirmed__c, ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Total_Quantity__c 
            FROM ASI_CRM_quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c IN :rejectList AND ASI_CTY_CN_Vendor_IsConfirmed__c = true])
          {
            
            q1.ASI_CTY_CN_Vendor_Result_Status__c = 'Pending Confirm';
            q1.ASI_CTY_CN_Vendor_IsConfirmed__c = false;
            qList.add(new ASI_CRM_quotation__c(Id = q1.ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_IsConfirmed__c = false,ASI_CTY_CN_Vendor_Result_Status__c = 'Pending Confirm'));
            qList.add(q1);
          }

          update qList;
        }
    }
}