public without sharing class ASI_CN_NPL_RequestTriggerAbstract {
    
  //20170814 Introv
  Private Final Static Map<String, Schema.SObjectField> npl_FIELD_MAP = Schema.SObjectType.ASI_CN_NPL_NPL_Request__c.fields.getMap();
  Private Final Static Map<String, Schema.SObjectField> FixApproval_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
  //20170814 End
  
  private List<Id> nplIDs = new List<Id>();   
  public ASI_CN_NPL_RequestTriggerAbstract(){                
  }
   
  public void executeAfterInsertTriggerAction(ASI_CN_NPL_NPL_Request__c[] npls){
      //Create NPL Forecast Childs for VisualForce page
      createNPLForecastChilds(npls);
      
      list<ASI_CN_NPL_NPL_Request__c> list_npl = new list<ASI_CN_NPL_NPL_Request__c>();
      Set<String> SET_CN_Chnl_Sty = new Set<String>{Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__cASI_CN_NPL_Class_A'), Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__cASI_CN_NPL_Class_D'), Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__cASI_CN_NPL_Class_E'), Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__cASI_CN_NPL_Class_F')};
  for(ASI_CN_NPL_NPL_Request__c npl : npls){
    if(SET_CN_Chnl_Sty.contains(npl.recordTypeId)) {
      list_npl.add(npl);
    }
  }
  if(list_npl.size()>0) createChannelStrategy(npls);
  }

  public static void executeBeforeInsertTriggerAction(List<ASI_CN_NPL_NPL_Request__c> trigger_new, map<id, ASI_CN_NPL_NPL_Request__c> trigger_oldMap){
//Set Classification for display
      for (ASI_CN_NPL_NPL_Request__c npl : trigger_new){
          npl.ASI_CN_NPL_Classification_Text__c = Global_RecordTypeCache.getRt(npl.RecordTypeID).Name;
          //assignBrandDirector(npl);       //20191013:AM@Introv - fix soql 101 and approver fields
      }
      
      //20191013:AM@Introv - fix soql 101 and approver fields
      assignDefaultValues(trigger_new, true);
      
      //20200113:AM@Introv - CR(Opt_Auto)
      assignSelectiveValues(trigger_new);
  }
  
  public static void executeAfterUpdateTriggerAction(List<ASI_CN_NPL_NPL_Request__c> trigger_new, map<id, ASI_CN_NPL_NPL_Request__c> trigger_oldMap){
      List<ASI_CN_NPL_NPL_Request__c> nplUpdateList = new List<ASI_CN_NPL_NPL_Request__c>();
      

      List<ASI_CN_NPL_NPL_Request__c> cnnplItemMasterList = new List<ASI_CN_NPL_NPL_Request__c>();//added by Laputa Kevin 2018-12-27
      List<ASI_CN_NPL_NPL_Request__c> cnnplFinalApprovedList = new List<ASI_CN_NPL_NPL_Request__c>();//added by Laputa Kevin 2018-12-27
      map<string, string> map_npl_brandDirector = new map<string, string>();//added by Laputa Vincent 2019-01-10
      Set<Id> cnnplIdSet = new Set<Id>();//added by Laputa Kevin 2018-12-27
      Map<Id,String> nplItemCodeMap = new Map<Id,String>();//added by Laputa Kevin 2018-12-27

  set<string> set_itemMasterId = new set<string>();
  map<string, string> map_itemMasterId_itemGroupCode = new map<string, string>();

      // 20190726 Wilson Chow start
      Map<Id, List<ASI_CN_NPL_NPL_Request__c>> itemMasterIdNplListMap =
              new Map<Id, List<ASI_CN_NPL_NPL_Request__c>>();
      // 20190726 Wilson Chow end

  for (ASI_CN_NPL_NPL_Request__c npl : trigger_new){
    if (npl.ASI_CN_NPL_Item_Master__c != NULL  || npl.ASI_CN_NPL_Item_Master__c != trigger_oldMap.get(npl.id).ASI_CN_NPL_Item_Master__c){
      set_itemMasterId.add(npl.ASI_CN_NPL_Item_Master__c);
    }
  }
  for(ASI_CN_NPL_Item_Master__c itemMaster : [select id, ASI_CN_NPL_Item_Goup_Code__c from ASI_CN_NPL_Item_Master__c where id in :set_itemMasterId]){
    map_itemMasterId_itemGroupCode.put(itemMaster.Id, itemMaster.ASI_CN_NPL_Item_Goup_Code__c);
  }

      for (ASI_CN_NPL_NPL_Request__c npl : trigger_new){
          System.debug('Class: ' + npl.ASI_CN_NPL_Classification__c + ' Status: ' + npl.ASI_CN_NPL_Status__c);

          //[Start] added by Laputa Kevin 2018-12-27
          //if (Global_RecordTypeCache.getRt(npl.recordTypeid).developerName.contains('ASI_CN_NPL')){

              if (npl.ASI_CN_NPL_Item_Master__c != NULL  || npl.ASI_CN_NPL_Item_Master__c != trigger_oldMap.get(npl.id).ASI_CN_NPL_Item_Master__c){
                  cnnplIdSet.add(npl.Id);
                  nplItemCodeMap.put(npl.Id, map_itemMasterId_itemGroupCode.get(npl.ASI_CN_NPL_Item_Master__c));
                  cnnplItemMasterList.add(npl);
              }

              if (npl.ASI_CN_NPL_Status__c == 'Final Approved' && trigger_oldMap.get(npl.id).ASI_CN_NPL_Status__c != 'Final Approved'){
                  cnnplIdSet.add(npl.Id);
                  cnnplFinalApprovedList.add(npl);

                  // 20190726 Wilson Chow start
                  if (npl.ASI_CN_NPL_Item_Master__c != NULL) {
                      if(!itemMasterIdNplListMap.containsKey(npl.ASI_CN_NPL_Item_Master__c)) {
                          itemMasterIdNplListMap.put(npl.ASI_CN_NPL_Item_Master__c, new List<ASI_CN_NPL_NPL_Request__c>());
                      }
                      List<ASI_CN_NPL_NPL_Request__c> tmpNplList =
                              itemMasterIdNplListMap.get(npl.ASI_CN_NPL_Item_Master__c);
                      if(!tmpNplList.contains(npl)) {
                          tmpNplList.add(npl);
                      }
                      itemMasterIdNplListMap.put(npl.ASI_CN_NPL_Item_Master__c, tmpNplList);
                  }
                  // 20190726 Wilson Chow end
              }

              if (npl.ASI_CN_NPL_Brand_Director__c != trigger_oldMap.get(npl.id).ASI_CN_NPL_Brand_Director__c){
                  cnnplIdSet.add(npl.Id);
                  map_npl_brandDirector.put(npl.Id, npl.ASI_CN_NPL_Brand_Director__c);
              }

          //}
          //[End] added by Laputa Kevin 2018-12-27
          
          //20200218:AM@Introv - CR(Opt_Auto) start
          //if (npl.ASI_CN_NPL_Status__c == 'Pre-Approved' && trigger_oldMap.get(npl.id).ASI_CN_NPL_Status__c != 'Pre-Approved'){
          boolean bGenItemMaster = false;
          if (!bGenItemMaster) bGenItemMaster = (npl.ASI_CN_NPL_Status__c == 'Pre-Approved' && trigger_oldMap.get(npl.id).ASI_CN_NPL_Status__c != 'Pre-Approved');
          if (!bGenItemMaster) bGenItemMaster = (npl.ASI_CN_NPL_Status__c == 'Waiting to Fill in Price Scenario' && trigger_oldMap.get(npl.id).ASI_CN_NPL_Status__c != 'Waiting to Fill in Price Scenario' &&
                                                (npl.ASI_CN_NPL_Classification__c == 'Class E' || npl.ASI_CN_NPL_Classification__c == 'Class F'));
          if (bGenItemMaster) {
          //20200218:AM@Introv - CR(Opt_Auto) end

              //Check if there are already Item Master record created
              List<ASI_CN_NPL_Item_Master__c> imList = [select id from ASI_CN_NPL_Item_Master__c where ASI_CN_NPL_NPL_Reference_No__c = :npl.id];
              
              
              if (imList.size() == 0){
                  string productName;
                  if (npl.ASI_CN_NPL_Product_Name_English__c != null){
                      if (npl.ASI_CN_NPL_Product_Name_English__c.length() > 30)
                          productName = npl.ASI_CN_NPL_Product_Name_English__c.substring(0, 30);
                      else 
                          productName = npl.ASI_CN_NPL_Product_Name_English__c;
                  }
                  ASI_CN_NPL_Item_Master__c im = new ASI_CN_NPL_Item_Master__c(ASI_CN_NPL_Item_Description_GE__c = productName, 
                      RecordTypeID = Global_RecordTypeCache.getRtId('ASI_CN_NPL_Item_Master__cASI_CN_NPL_Item_Master_TypeA'), ASI_CN_NPL_Item_Description_CH__c = npl.ASI_CN_NPL_Product_Name_Chinese__c, 
                          ASI_CN_NPL_NPL_Reference_No__c = npl.id, ASI_CN_NPL_Status__c = 'Waiting For Logistics Input Item Code', ASI_CN_NPL_VAP__c = npl.ASI_CN_NPL_VAP__c);
                  
                  List<Group> gList = [Select ID From Group where DeveloperName = 'ASI_CN_NPL_Item_Master_Logistics_User'];
                  
                  if (gList.size() == 1){
                      List<GroupMember> gmList = [select UserOrGroupId from GroupMember where GroupId = :gList.get(0).id];
                      
                      if (gmList.size() == 0)
                          im.ownerID = UserInfo.getUserId();
                      else 
                          im.ownerID = gmList.get(0).UserOrGroupId;
                  }
                  
                  System.debug('Item Master: ' + im);
                  insert im;
                  
                  ASI_CN_NPL_NPL_Request__c nplUpdate = [select ASI_CN_NPL_Item_Master__c from ASI_CN_NPL_NPL_Request__c where id = :npl.id];
                  nplUpdate.ASI_CN_NPL_Item_Master__c = im.id;
                  
                  nplUpdateList.add(nplUpdate);
              }
          }
      }
      // 20190726 Wilson Chow start
      List<ASI_MFM_Item_Group__c> ItemGroupList = null;
      // 20190726 Wilson Chow end
      if (cnnplIdSet.size()>0){
          // 20190726 Wilson Chow start
          ItemGroupList =
              [select id,ASI_MFM_Item_Group_Code__c from ASI_MFM_Item_Group__c
              where recordtype.developerName = 'ASI_CRM_CN_CRM_Item_Group'
              and ASI_MFM_Item_Group_Code__c =: nplItemCodeMap.values()
              and ASI_MFM_Item_Group_Code__c <> null];
          // 20190726 Wilson Chow end

          // 20190726 Wilson Chow start update
    updateChannelStrategy(cnnplIdSet, cnnplItemMasterList, cnnplFinalApprovedList, map_npl_brandDirector, nplItemCodeMap, ItemGroupList);
          // 20190726 Wilson Chow end update

          // 20200611 Added by Jack Yuan BLS start
          generatePOSMItemGroup(cnnplFinalApprovedList);
          // 20200611 Added by Jack Yuan BLS end
      }

      update nplUpdateList;

      // 20190726 Wilson Chow start
      if(!itemMasterIdNplListMap.isEmpty()
              && !map_itemMasterId_itemGroupCode.isEmpty()
              && ItemGroupList != null && ItemGroupList.size() > 0) {
          assignItemGroupSelective(itemMasterIdNplListMap, map_itemMasterId_itemGroupCode, ItemGroupList);
      }
      // 20190726 Wilson Chow end
  }
  
  public static void executeBeforeUpdateTriggerAction(List<ASI_CN_NPL_NPL_Request__c> trigger_new, map<id, ASI_CN_NPL_NPL_Request__c> trigger_oldMap){
//setDefaultApprover
  //20200113:AM@Introv - CR(Opt_Auto)
      assignSelectiveValues(trigger_new);
      
      //20191013:AM@Introv - fix soql 101 and approver fields start
      assignDefaultValues(trigger_new, false);
      Id idFinanceDirector = getPublicGroupUserIDByGroupName('ASI CN NPL Finance Director');
      //20191013:AM@Introv - fix soql 101 and approver fields end
      
      //20170814 Introv
      List<ASI_CN_NPL_NPL_Request__c> FinalApprovedNPL = new List<ASI_CN_NPL_NPL_Request__c>();
      
      for (ASI_CN_NPL_NPL_Request__c npl : trigger_new){
          System.debug('Start setDefaultApprover');
          
          //20191013:AM@Introv - fix soql 101 and approver fields - comment all start
          //Assign if all 5 director's lookup field is empty or before final approval // 20170921 remove trade marketing director, Introv
//            if ((npl.ASI_CN_NPL_National_Sales_Dev_VP__c == null && /*npl.ASI_CN_NPL_Trade_Marketing_Director__c == null &&*/ npl.ASI_CN_NPL_Finance_Director__c == null && npl.ASI_CN_NPL_Marketing_Director__c == null &&
//                npl.ASI_CN_NPL_Deputy_Managing_Director__c == null
//                 /* IM004689: Since brand director will be populated in beforeInsert, need to hide the checking here
//                 && npl.ASI_CN_NPL_Brand_Director__c == null
//                  */
//                ) 
//                    || (npl.ASI_CN_NPL_Status__c == 'Waiting for S&OP Alignment' && npl.ASI_CN_NPL_National_Sales_Dev_VP__c != null && /*npl.ASI_CN_NPL_Trade_Marketing_Director__c != null &&*/ npl.ASI_CN_NPL_Marketing_Director__c != null && npl.ASI_CN_NPL_Deputy_Managing_Director__c != null && npl.ASI_CN_NPL_Brand_Director__c != null)){         //***
//                
//                System.debug('Assign Approvers');
//                
//                //Assign Directors base on Role
//                //npl.ASI_CN_NPL_Trade_Marketing_Director__c = getPublicGroupUserIDByGroupName('ASI CN NPL Trade Marketing Director'); //20161013 Ben @ Elufa Commented
//                npl.ASI_CN_NPL_Marketing_Director__c = getPublicGroupUserIDByGroupName('ASI CN NPL Marketing Director');
//                npl.ASI_CN_NPL_Deputy_Managing_Director__c = getPublicGroupUserIDByGroupName('ASI CN NPL Deputy Managing Director');
//                npl.ASI_CN_NPL_National_Sales_Dev_VP__c = getPublicGroupUserIDByGroupName('ASI CN NPL National Sales Dev VP');
//                
//                assignBrandDirector(npl);
//                
//                //Only assign FD for Final Approval
//                if (npl.ASI_CN_NPL_Status__c == 'Waiting for S&OP Alignment'){                  //***
//                    npl.ASI_CN_NPL_Finance_Director__c = getPublicGroupUserIDByGroupName('ASI CN NPL Finance Director');
//                }
//                System.debug('End assign Brand Director');
//            }
          //20191013:AM@Introv - fix soql 101 and approver fields - comment all end
          //20191013:AM@Introv - fix soql 101 and approver fields - set Finance Director start
          if (npl.ASI_CN_NPL_Status__c == 'Waiting for S&OP Alignment'){                  //***
              npl.ASI_CN_NPL_Finance_Director__c = idFinanceDirector;
          }
          //20191013:AM@Introv - fix soql 101 and approver fields - set Finance Director end
          
          System.debug('End setDefaultApprover');
          
          //201708014 Introv
          if(npl.ASI_CN_NPL_Status__c == 'Final Approved'){
              FinalApprovedNPL.add(npl);
          }
          
          //Clear all approver fields before assign
          /*npl.ASI_CN_NPL_Approver1__c = null;
          npl.ASI_CN_NPL_Approver2__c = null;
          npl.ASI_CN_NPL_Approver3__c = null;
          npl.ASI_CN_NPL_Approver4__c = null;
          npl.ASI_CN_NPL_Approver5__c = null;
          npl.ASI_CN_NPL_Approver6__c = null;
          
          if (npl.ASI_CN_NPL_Brand_Director__c != null){
              System.debug('Assign BD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_Brand_Director__c, npl);
          }

          if (npl.ASI_CN_NPL_Marketing_Director__c != null){
              System.debug('Assign MKTD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_Marketing_Director__c, npl);
          }
          
          if (npl.ASI_CN_NPL_Trade_Marketing_Director__c != null){
              System.debug('Assign TMKTD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_Trade_Marketing_Director__c, npl);
          }
                      
          if (npl.ASI_CN_NPL_National_Sales_Dev_VP__c != null){
              System.debug('Assign DMD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_National_Sales_Dev_VP__c, npl);
          }
          
          if (npl.ASI_CN_NPL_Deputy_Managing_Director__c != null){
              System.debug('Assign DMD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_Deputy_Managing_Director__c, npl);
          }
          
          if (npl.ASI_CN_NPL_Finance_Director__c != null){
              System.debug('Assign FD to approver');
              fillFirstEmptyApproverLookup(npl.ASI_CN_NPL_Finance_Director__c, npl);
          }          
          System.debug('End assignHiddenApproverForProcess');          
          */


          Set<ID> subordinateID = new Set<ID>();
          
          List<User> requestByRoleName = [Select UserRole.DeveloperName from user where id =:npl.ASI_CN_NPL_Request_By__c];
          
          if(requestByRoleName.size() > 0){
              if (requestByRoleName.get(0).UserRole.DeveloperName.contains('Logistic')){
                  ID logisticDirector = [select id from userrole where developername='ASI_FOC_Logistic_Director' limit 1][0].ID;
                  subordinateID = getRoleSubordinateUsers(logisticDirector,false);
              }
              else if (npl.ASI_CN_NPL_Brand_Director__c != null){
                  subordinateID = getRoleSubordinateUsers(npl.ASI_CN_NPL_Brand_Director__c,true);
              }
          }
          else if (npl.ASI_CN_NPL_Brand_Director__c != null){
              subordinateID = getRoleSubordinateUsers(npl.ASI_CN_NPL_Brand_Director__c,true);
          }
              
          if(subordinateID != null && subordinateID.size()>0){
              System.debug('Subordinate ID Set: ' + subordinateID);
              List<User> subordinateUsers = [Select Id, Email From User Where Id = :subordinateID AND isActive = TRUE];//20160427 Ben @ Elufa Added isActive = TRUE
              
              if (subordinateUsers.size() > 0){
                  npl.ASI_CN_NPL_Email1__c = null;
                  npl.ASI_CN_NPL_Email2__c = null;
                  npl.ASI_CN_NPL_Email3__c = null;
                  npl.ASI_CN_NPL_Email4__c = null;
                  npl.ASI_CN_NPL_Email5__c = null;
                  npl.ASI_CN_NPL_Email6__c = null;
                  npl.ASI_CN_NPL_Email7__c = null;
                  npl.ASI_CN_NPL_Email8__c = null;
                  npl.ASI_CN_NPL_Email9__c = null;
                  npl.ASI_CN_NPL_Email10__c = null;
                  npl.ASI_CN_NPL_Email11__c = null;
                  npl.ASI_CN_NPL_Email12__c = null;
                  npl.ASI_CN_NPL_Email13__c = null;
                  npl.ASI_CN_NPL_Email14__c = null;
                  npl.ASI_CN_NPL_Email15__c = null;
                  npl.ASI_CN_NPL_Email16__c = null;
                  npl.ASI_CN_NPL_Email17__c = null;
                  npl.ASI_CN_NPL_Email18__c = null;
                  npl.ASI_CN_NPL_Email19__c = null;
                  npl.ASI_CN_NPL_Email20__c = null;
              }
              
              for (User u : subordinateUsers){
                  System.debug('Email: ' + u.Email);
                  
                  if (npl.ASI_CN_NPL_Email1__c == null)
                      npl.ASI_CN_NPL_Email1__c = u.Email;
                      
                  else if (npl.ASI_CN_NPL_Email2__c == null)
                      npl.ASI_CN_NPL_Email2__c = u.Email;
                      
                  else if (npl.ASI_CN_NPL_Email3__c == null)
                      npl.ASI_CN_NPL_Email3__c = u.Email;
                  
                  else if (npl.ASI_CN_NPL_Email4__c == null)
                      npl.ASI_CN_NPL_Email4__c = u.Email;
                      
                  else if (npl.ASI_CN_NPL_Email5__c == null)
                      npl.ASI_CN_NPL_Email5__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email6__c == null)
                      npl.ASI_CN_NPL_Email6__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email7__c == null)
                      npl.ASI_CN_NPL_Email7__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email8__c == null)
                      npl.ASI_CN_NPL_Email8__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email9__c == null)
                      npl.ASI_CN_NPL_Email9__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email10__c == null)
                      npl.ASI_CN_NPL_Email10__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email11__c == null)
                      npl.ASI_CN_NPL_Email11__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email12__c == null)
                      npl.ASI_CN_NPL_Email12__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email13__c == null)
                      npl.ASI_CN_NPL_Email13__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email14__c == null)
                      npl.ASI_CN_NPL_Email14__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email15__c == null)
                      npl.ASI_CN_NPL_Email15__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email16__c == null)
                      npl.ASI_CN_NPL_Email16__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email7__c == null)
                      npl.ASI_CN_NPL_Email17__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email18__c == null)
                      npl.ASI_CN_NPL_Email18__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email19__c == null)
                      npl.ASI_CN_NPL_Email19__c = u.Email;
                                              
                  else if (npl.ASI_CN_NPL_Email20__c == null)
                      npl.ASI_CN_NPL_Email20__c = u.Email;
              }
          }
//Validate Category with IsBrandNewProduct flag
          if (npl.ASI_CN_NPL_Category__c == 'N/A'){
              npl.ASI_CN_NPL_Is_Brand_New_Product__c = true;
          }
          else {
              npl.ASI_CN_NPL_Is_Brand_New_Product__c = false;
          }
      }
      
      //201708014 Introv
      if(FinalApprovedNPL.size() > 0){
          
          Map<String, ASI_CRM_Fix_Approval_Route__c> fixApprovalMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
          String whereClause = ' WHERE ASI_CRM_CN_Type__c Like \'New Product Launch%\' AND RecordType.developerName Like \'ASI_CRM_CN_%\'';
          
          for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FixApproval_FIELD_MAP, whereClause)){
              
              fixApprovalMap.put(obj.ASI_CRM_CN_Type__c, obj);
          }
          
          for(ASI_CN_NPL_NPL_Request__c npl : FinalApprovedNPL){
              
              if(fixApprovalMap.containsKey('New Product Launch - TP Approval')){
                  setApproverToNull(npl);
                  setApprover(npl, fixApprovalMap.get('New Product Launch - TP Approval'));
              }
          }
      }
      //201708014 End
  }

  //MT@Introv@20200429: fix querying inside the loop START
  //public static void assignBrandDirector(ASI_CN_NPL_NPL_Request__c npl) {
  public static void assignBrandDirector(List<ASI_CN_NPL_NPL_Request__c> trigger_new) {
      Set<Id> setUserId = new Set<Id>();
      for(ASI_CN_NPL_NPL_Request__c oRequest : trigger_new){
          if (oRequest.ASI_CN_NPL_Brand_Director__c == NULL) {
              if (oRequest.ASI_CN_NPL_Request_By__c != null) {
                  setUserId.add(oRequest.ASI_CN_NPL_Request_By__c);
              } else if (oRequest.OwnerID == null) {
                  System.debug('Owner ID is null, UserInfo.getUserId(): ' + UserInfo.getUserId());
                  setUserId.add(UserInfo.getUserId());
              } else {
                  System.debug('Owner ID is not null, oRequest.OwnerID: ' + oRequest.OwnerID);
                  setUserId.add(oRequest.OwnerID);
              }
          }
      }// end of for loop
      Map<Id, Id> result;
      if(!setUserId.isEmpty()){
          result = getBrandDirectorIdFromOwnerId(setUserId);
      }
      if(result != null){
          for(ASI_CN_NPL_NPL_Request__c oRequest : trigger_new){
            if (oRequest.ASI_CN_NPL_Brand_Director__c == NULL) {
              if (oRequest.ASI_CN_NPL_Request_By__c != null) {
                  oRequest.ASI_CN_NPL_Brand_Director__c = result.get(oRequest.ASI_CN_NPL_Request_By__c);
              } else if (oRequest.OwnerID == null) {
                  oRequest.ASI_CN_NPL_Brand_Director__c = result.get(UserInfo.getUserId());
              } else {
                  oRequest.ASI_CN_NPL_Brand_Director__c = result.get(oRequest.OwnerID);
              }
            }
          }
      }

      // if (npl.ASI_CN_NPL_Request_By__c != null) {
      //     npl.ASI_CN_NPL_Brand_Director__c = getBrandDirectorIdFromOwnerId(npl.ASI_CN_NPL_Request_By__c);
      // } else if (npl.OwnerID == null) {
      //     System.debug('Owner ID is null, UserInfo.getUserId(): ' + UserInfo.getUserId());
      //     npl.ASI_CN_NPL_Brand_Director__c = getBrandDirectorIdFromOwnerId(UserInfo.getUserId());
      // } else {
      //     System.debug('Owner ID is not null, npl.OwnerID: ' + npl.OwnerID);
      //     npl.ASI_CN_NPL_Brand_Director__c = getBrandDirectorIdFromOwnerId(npl.OwnerID);
      // }
  }
  //MT@Introv@20200429: fix querying inside the loop END

  private void createNPLForecastChilds(ASI_CN_NPL_NPL_Request__c[] npls) {
      //List<Id> nplIDs = new List<Id>();
      List<String> forecastTypes = new List<String>{'Sales Volume','Old Stock Inventory','Old Stock Depletion','Monitoring'}; 
      List<String> forecastRegions = new List<String>{'South','East','Central','North','North West', 'South West', 'Macau', 'Mongolia','STK3','HQ'};
      List<ASI_CN_NPL_NPL_Forecast__c> forecasts = new List<ASI_CN_NPL_NPL_Forecast__c>();
      
      System.debug('List Size of NPLs:' + npls.size());
      
      for (ASI_CN_NPL_NPL_Request__c npl : npls){
          for (String forecastType : forecastTypes){
              for (String forecastRegion : forecastRegions){
                  ASI_CN_NPL_NPL_Forecast__c forecast = new ASI_CN_NPL_NPL_Forecast__c(New_Product_Launch_Request__c = npl.Id, ASI_CN_NPL_Type__c = forecastType, ASI_CN_NPL_Region__c = forecastRegion);
                  forecasts.add(forecast);
                  nplIDs.add(npl.Id);
              }
          }
      }       
      insert forecasts;
  }
  
  //[Start] function added by Laputa Kevin 2018-12-19
  private void createChannelStrategy(ASI_CN_NPL_NPL_Request__c[] npls){
      system.debug('start createChannelStrategy');
      RecordType nplrt = [select id, name, developername from recordtype where developername = 'ASI_NPL_CN_Channel_Strategy'];
      List<ASI_CRM_CN_Channel_Strategy__c> channelStrategyInsertList = new List<ASI_CRM_CN_Channel_Strategy__c>();

      for (ASI_CN_NPL_NPL_Request__c npl : npls){
          ASI_CRM_CN_Channel_Strategy__c newChannelStrategy = new ASI_CRM_CN_Channel_Strategy__c();
          newChannelStrategy.recordtypeid = nplrt.Id;
          newChannelStrategy.ASI_CRM_CN_Status__c = 'Draft';
          newChannelStrategy.ASI_NPL_Vision__c = 1;
          newChannelStrategy.ASI_NPL_New_Product_Launch_Request__c =  npl.Id;
          newChannelStrategy.ASI_CRM_CN_Sys_Approver_1__c = npl.ASI_CN_NPL_Brand_Director__c;

          channelStrategyInsertList.add(newChannelStrategy);
      }

      if (channelStrategyInsertList.size() >0)
          insert channelStrategyInsertList;

  }

  // 20190726 Wilson Chow start update signature
  private static void updateChannelStrategy(Set<Id> nplIdSet, List<ASI_CN_NPL_NPL_Request__c> itemMasterList, List<ASI_CN_NPL_NPL_Request__c> FinalApprovedList, map<string, string> map_npl_brandDirector, Map<Id,String> nplItemCodeMap, List<ASI_MFM_Item_Group__c> ItemGroupList){
  // 20190726 Wilson Chow end update signature

      Map<Id, ASI_CRM_CN_Channel_Strategy__c> channelStrategyIdMap = new Map<Id, ASI_CRM_CN_Channel_Strategy__c>();
      Map<String, ASI_MFM_Item_Group__c> ItemGroupCodeMap = new Map<String, ASI_MFM_Item_Group__c>();
      List<ASI_CRM_CN_Channel_Strategy__c> channelStrategyUpdateList = new List<ASI_CRM_CN_Channel_Strategy__c>();

      List<ASI_CRM_CN_Channel_Strategy__c > channelStrategyList = [select id,ASI_NPL_New_Product_Launch_Request__c, ASI_NPL_Item_Group__c, ASI_CRM_CN_Status__c
                                                                   from ASI_CRM_CN_Channel_Strategy__c
                                                                   where ASI_NPL_New_Product_Launch_Request__c =: nplIdSet];

      // 20190726 Wilson Chow comment
      /*
      List<ASI_MFM_Item_Group__c> ItemGroupList = [select id,ASI_MFM_Item_Group_Code__c from ASI_MFM_Item_Group__c
                                                   where recordtype.developerName = 'ASI_CRM_CN_CRM_Item_Group'
                                                   and ASI_MFM_Item_Group_Code__c =: nplItemCodeMap.values()
                                                   and ASI_MFM_Item_Group_Code__c <> null];
      */

      for (ASI_CRM_CN_Channel_Strategy__c channelStrategy: channelStrategyList){
          if(map_npl_brandDirector.containsKey(channelStrategy.ASI_NPL_New_Product_Launch_Request__c)){
      channelStrategy.ASI_CRM_CN_Sys_Approver_1__c = map_npl_brandDirector.get(channelStrategy.ASI_NPL_New_Product_Launch_Request__c);
    }
    channelStrategyIdMap.put(channelStrategy.ASI_NPL_New_Product_Launch_Request__c,channelStrategy);
      }

      // 20190726 Wilson Chow start
      if(itemGroupList != null && itemGroupList.size() > 0) {
      // 20190726 Wilson Chow end
          for (ASI_MFM_Item_Group__c itemGroup : ItemGroupList) {
              ItemGroupCodeMap.put(itemGroup.ASI_MFM_Item_Group_Code__c, itemGroup);
          }
      }

      for (ASI_CN_NPL_NPL_Request__c itemPasterNpl: itemMasterList){
          if(channelStrategyIdMap.containsKey(itemPasterNpl.Id)){
      ASI_CRM_CN_Channel_Strategy__c relatedChannel = channelStrategyIdMap.get(itemPasterNpl.Id);
      String ItemCode = nplItemCodeMap.get(itemPasterNpl.Id);

      if(ItemGroupCodeMap.containsKey(ItemCode)){
        ASI_MFM_Item_Group__c relatedItemGroup = ItemGroupCodeMap.get(ItemCode);

        relatedChannel.ASI_NPL_Item_Group__c = relatedItemGroup.Id;
        //channelStrategyUpdateList.add(relatedChannel);
      }
    }
      }

      for (ASI_CN_NPL_NPL_Request__c approvedNpl: FinalApprovedList){
          if(channelStrategyIdMap.containsKey(approvedNpl.Id)){
      ASI_CRM_CN_Channel_Strategy__c relatedChannel = channelStrategyIdMap.get(approvedNpl.Id);
      relatedChannel.ASI_CRM_CN_Status__c = 'Final';
      relatedChannel.ASI_CRM_Effective_Date__c = approvedNpl.ASI_CN_NPL_Domestic_Launch_Date__c;
      //channelStrategyUpdateList.add(relatedChannel);
    }
      }

  /*
      if (channelStrategyUpdateList.size() >0){
          update channelStrategyUpdateList;
      }
  */
  if(channelStrategyIdMap != null && channelStrategyIdMap.values().size()>0){
    update channelStrategyIdMap.values();
  }

  }

    // 20200611 Added by Jack Yuan BLS
    public static void generatePOSMItemGroup (List<ASI_CN_NPL_NPL_Request__c> cnnplFinalApprovedList) {
        if (cnnplFinalApprovedList.size() == 0) {
            return;
        }
        Set<Id> itemMasterIds = new Set<Id>();
        for (ASI_CN_NPL_NPL_Request__c npl : cnnplFinalApprovedList) {
            if (String.isNotBlank(npl.ASI_CN_NPL_Item_Master__c)) itemMasterIds.add(npl.ASI_CN_NPL_Item_Master__c);
        }
        List<ASI_CN_NPL_Item_Master__c> itemMasterList = [SELECT ASI_CN_NPL_NPL_Reference_No__c, ASI_CN_NPL_Status__c,
                                                                 ASI_CN_NPL_Item_Goup_Code__c, ASI_CN_NPL_Item_Description_CH__c,
                                                                 ASI_CN_NPL_Item_Description_GE__c,ASI_CN_NPL_NPL_Reference_No__r.ASI_CN_NPL_Sub_brand__c,
                                                                 ASI_CN_NPL_NPL_Reference_No__r.OwnerId, ASI_CN_NPL_Sub_Brand_RP6__c
                                                          FROM ASI_CN_NPL_Item_Master__c
                                                          WHERE Id IN :itemMasterIds
                                                          AND (ASI_CN_NPL_Item_Goup_Code__c LIKE '9D%' 
                                                              OR ASI_CN_NPL_Item_Goup_Code__c LIKE '9Y%')
                                                          AND ASI_CN_NPL_Status__c = 'Completed'];
        if (itemMasterList.isEmpty()) { return; }
        Set<String> subbrandCode = new Set<String>();
        Set<String> itemGroupCode = new Set<String>();
        for (ASI_CN_NPL_Item_Master__c itemMaster : itemMasterList) {
            subbrandCode.add(itemMaster.ASI_CN_NPL_Sub_Brand_RP6__c);
            itemGroupCode.add(itemMaster.ASI_CN_NPL_Item_Goup_Code__c);
        }
        Map<String, Id> subbrandMap = new Map<String, Id>();
        for (ASI_MFM_Sub_brand__c subbrand : [SELECT Id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Sub_brand_Code__c IN:subbrandCode AND RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand']){
            subbrandMap.put(subbrand.ASI_MFM_Sub_brand_Code__c, subbrand.Id);
        }
        // if the item group already exists, will not generate
        Set<String> existItemGroupCode = new Set<String>();
        for (ASI_MFM_Item_Group__c itemGroup : [SELECT Id, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN:itemGroupCode AND RecordType.DeveloperName = 'ASI_MFM_CN_POSM_Item_Group']){
            existItemGroupCode.add(itemGroup.ASI_MFM_Item_Group_Code__c);
        }

        List<ASI_MFM_Item_Group__c> POSMItemGroupList = new List<ASI_MFM_Item_Group__c>();
        for (ASI_CN_NPL_Item_Master__c itemMaster : itemMasterList) {
            if (existItemGroupCode.contains(itemMaster.ASI_CN_NPL_Item_Goup_Code__c) || 
                subbrandMap.isEmpty() || subbrandMap.get(itemMaster.ASI_CN_NPL_Sub_Brand_RP6__c) == NULL) {
                continue;
            }
            ASI_MFM_Item_Group__c POSMItemGroup = new ASI_MFM_Item_Group__c();
            POSMItemGroup.ASI_MFM_Sub_brand__c = subbrandMap.get(itemMaster.ASI_CN_NPL_Sub_Brand_RP6__c);
            POSMItemGroup.ASI_CRM_CN_Chinese_Name__c = itemMaster.ASI_CN_NPL_Item_Description_CH__c;
            POSMItemGroup.ASI_CRM_CN_Eng_Name__c = itemMaster.ASI_CN_NPL_Item_Description_GE__c;
            POSMItemGroup.ASI_MFM_Item_Group_Code__c = itemMaster.ASI_CN_NPL_Item_Goup_Code__c;
            POSMItemGroup.OwnerId = itemMaster.ASI_CN_NPL_NPL_Reference_No__r.OwnerId;
            POSMItemGroup.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
            POSMItemGroupList.add(POSMItemGroup);
        }
        if (!POSMItemGroupList.isEmpty()) {
            insert POSMItemGroupList;
        }
    }


  //[End] function added by Laputa Kevin 2018-12-19


  private static Set<ID> getRoleSubordinateUsers(Id userId,boolean userFlag) {
      // get requested user's role
      Id roleId =NULL;
      if(userFlag)
          roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
      else
          roleId = userId;
           
      // get all of the roles underneath the user
      Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
      // get all of the ids for the users in those roles
      Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where 
        UserRoleId IN :allSubRoleIds]);
      
      //Modified by Wilken on 20130911, add Brand Director for notification
      if(userFlag){
          User approver = [select Id, Name from User where Id = :userId];
          users.put(approver.Id, approver);
      }
      //End modification on 20130911
      
      // return the ids as a set so you can do what you want with them
      return users.keySet();
   
  }

  private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
      Set<ID> currentRoleIds = new Set<ID>();
   
      // get all of the roles underneath the passed roles
      for(UserRole userRole :[select Id from UserRole where ParentRoleId 
        IN :roleIds AND ParentRoleID != null])
      currentRoleIds.add(userRole.Id);
   
      // go fetch some more rolls!
      if(currentRoleIds.size() > 0)
        currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
   
      return currentRoleIds;
   
  }
  
  
  /*private static void fillFirstEmptyApproverLookup(Id approver, ASI_CN_NPL_NPL_Request__c npl){
      if (npl.ASI_CN_NPL_Approver1__c == null)
          npl.ASI_CN_NPL_Approver1__c = approver;
          
      else if (npl.ASI_CN_NPL_Approver2__c == null)
          npl.ASI_CN_NPL_Approver2__c = approver;
          
      else if (npl.ASI_CN_NPL_Approver3__c == null)
          npl.ASI_CN_NPL_Approver3__c = approver;
          
      else if (npl.ASI_CN_NPL_Approver4__c == null)
          npl.ASI_CN_NPL_Approver4__c = approver;
          
      else if (npl.ASI_CN_NPL_Approver5__c == null)
          npl.ASI_CN_NPL_Approver5__c = approver;
          
      else if (npl.ASI_CN_NPL_Approver6__c == null)
          npl.ASI_CN_NPL_Approver6__c = approver;
  }*/
  
  private static Id getPublicGroupUserIDByGroupName(String name){
      String userType = Schema.SObjectType.User.getKeyPrefix();
      List<Group> publicGroup = [Select Id From Group Where Name = :name Limit 1];
      if(publicGroup.size() > 0){
          List<GroupMember> member = [Select UserOrGroupId From GroupMember Where GroupId = :publicGroup[0].Id Limit 1];
          
          if(member.size() > 0){
              if (((String)member[0].UserOrGroupId).startsWith(userType)){
                  return member[0].UserOrGroupId;
              }
              else {
                  return null;
              }
          }else{
              return null;
          }
      }else{
          return null;
      }
  }
  
  private static Id getSupervisorID(Id ownerId){
      if(ownerId==null)
          return null;
          
      System.debug('start getSupervisorID, ownerID: ' + ownerId);
      User u = [Select UserRoleId From User Where Id = :ownerId Limit 1];
      List<UserRole> ur = [Select ParentRoleId From UserRole Where Id = :u.UserRoleId];
      ID result;
      
      if (ur.size() == 1){
          List<User> su = [Select Id From User Where UserRoleId = :ur.get(0).ParentRoleId];
          
          if (su.size() >= 1){
              result = su.get(0).Id;
          }
          else if(su.size() == 0){//20151224 Ben @ Elufa System
              
              List<UserRole> ur2 = [Select ParentRoleId From UserRole Where Id = :ur.get(0).ParentRoleId];
              if(ur2.size() > 0){
                  List<User> su2 = [Select Id From User Where UserRoleId = :ur2.get(0).ParentRoleId];
                  if(su2.size() > 0)
                      result = su2.get(0).id;
              }
          }//20151224 End
      }
      
      System.debug('end getSupervisorID, return supervisor ID: ' + result);
      return result;
  }
 
  //MT@Introv@20200429: fix querying inside the loop START
  //private static Id getBrandDirectorIdFromOwnerId(Id ownerId){
    private static Map<Id, Id> getBrandDirectorIdFromOwnerId(Set<Id> setOwnerId){
      Set<Id> setOwnerUserRole = new Set<Id>();
      Map<Id, UserRole> mapAllUserRole = new Map<Id, UserRole>();
      Map<Id, List<UserRole>> mapOwnerParentUserRole = new Map<Id, List<UserRole>>();
      Map<Id, Id> mapResultMap = new Map<Id, Id>();
    
      if(setOwnerId.isEmpty()){
        return null;
      }
      Map<Id, User> mapOwnerUser = new map<Id, User>([Select Id, UserRoleId From User Where Id = :setOwnerId]);
      for(User u : mapOwnerUser.values()){
          setOwnerUserRole.add(u.UserRoleId);
      }
      if(setOwnerUserRole.isEmpty()){
          return null;
      }
    
      mapAllUserRole = new Map<Id, UserRole>([SELECT Id, ParentRoleId From UserRole]);
      if(mapAllUserRole.isEmpty()){
          return null;
      }
      //Get all parent userRole of an userRole
      for(Id urId : setOwnerUserRole){
          if(mapAllUserRole.containsKey(urId)){
              UserRole ur = mapAllUserRole.get(urId);
              List<UserRole> l_listParentUserRole = new List<UserRole>();
              while(ur.ParentRoleId != null){
                  if(mapAllUserRole.containsKey(ur.ParentRoleId)){
                      UserRole parentUserRole = mapAllUserRole.get(ur.ParentRoleId);
                      l_listParentUserRole.add(parentUserRole);
                      ur = parentUserRole;
                  }
                  else
                      break;
              }
              mapOwnerParentUserRole.put(urId, l_listParentUserRole);
          }
      }
      system.debug('mapOwnerParentUserRole :' + mapOwnerParentUserRole);
    
      Set<Id> setRelatedParentUserRoleId = new Set<Id>();
      for(Id urId : mapOwnerParentUserRole.keySet()){
          for(UserRole ur : mapOwnerParentUserRole.get(urId)){
              setRelatedParentUserRoleId.add(ur.Id);
          }
      }
      List<User> listSupervisor = new List<User>();
      Map<Id, List<User>> mapSupervisor = new Map<Id, List<User>>();
      if(!setRelatedParentUserRoleId.isEmpty()){
          listSupervisor = [SELECT Id, UserRoleId FROM User where UserRoleId IN :setRelatedParentUserRoleId];
      }
      for(User u : listSupervisor){
          List<User> tempList;
          if(mapSupervisor.containsKey(u.UserRoleId)){
              tempList = mapSupervisor.get(u.UserRoleId);               
          }
          else{
              tempList = new List<User>();
          }
          tempList.add(u); 
          mapSupervisor.put(u.UserRoleId, tempList);
      }
      if(mapSupervisor.isEmpty())
          return null;
    
      String userType = Schema.SObjectType.User.getKeyPrefix();
      Group approverGroup = [Select Id From Group Where DeveloperName = 'ASI_CN_NPL_Brand_Director_Approvers'];
      List<GroupMember> approverGroupMember = [Select Id, UserOrGroupId From GroupMember Where GroupId = :approverGroup.Id];
      Boolean result = false;
      
      for(Id userId : setOwnerId){
          Id urId = mapOwnerUser.containsKey(userId)? mapOwnerUser.get(userId).UserRoleId : null;
          result = false;
          for(UserRole parentUr : mapOwnerParentUserRole.get(urId)){
                if(result == true)
                    break;
                if(mapSupervisor.containsKey(parentUr.Id)){
                    for(User u : mapSupervisor.get(parentUr.Id)){
                      for (GroupMember m : approverGroupMember){
                          if (((String)m.UserOrGroupId).startsWith(userType)){
                              if (m.UserOrGroupId == u.Id){
                                  System.debug('getBrandDirectorIdFromOwnerId m.UserOrGroupId: ' + m.UserOrGroupId + ' supervisorID: ' + u.Id);
                                  result = true;
                                  mapResultMap.put(userId, u.Id);
                                  break;
                              }
                          }
                      }
                      if(result == true)
                        break;
                    }
                }
          }
      }
           
      return mapResultMap;
      // String userType = Schema.SObjectType.User.getKeyPrefix();
      // List<User> nplOwner = [Select Id, ManagerId From User Where Id = :ownerId];
      // Group approverGroup = [Select Id From Group Where DeveloperName = 'ASI_CN_NPL_Brand_Director_Approvers'];
      // Boolean result = false;
      // Id brandDirectorId;
      // Id supervisorID = getSupervisorID(ownerId);

      // if (nplOwner.size() == 1){
      //     for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :approverGroup.Id]){
      //         if (((String)m.UserOrGroupId).startsWith(userType)){
      //             if (m.UserOrGroupId == supervisorID){
      //                 System.debug('getBrandDirectorIdFromOwnerId m.UserOrGroupId: ' + m.UserOrGroupId + ' supervisorID: ' + supervisorID);
      //                 result = true;
      //                 brandDirectorId = supervisorID;
      //             }
      //         }
      //     }
          
      //     if (result == false){
      //         System.debug('getBrandDirectorIdFromOwnerId Result = false');
      //         brandDirectorId = getBrandDirectorIdFromOwnerId(supervisorID);
      //     }
      // }
      
      // return brandDirectorId;
  }
  //MT@Introv@20200429: fix querying inside the loop END
  
  //20170814 Introv
  
  Private Static void setApprover(ASI_CN_NPL_NPL_Request__c npl, ASI_CRM_Fix_Approval_Route__c fixApproval){
      
      Integer i = 1;
      Integer j = 1;
      String sysApprover = 'ASI_CN_NPL_Approver' + i + '__c';
      String fixApprover = 'asi_crm_cn_approver_' + j + '__c';
      
      While(npl_FIELD_MAP.containsKey(sysApprover) && FixApproval_FIELD_MAP.containsKey(fixApprover)){
          
          if(npl.get(sysApprover) != Null){
              
              i++;
              sysApprover = 'ASI_CN_NPL_Approver' + i + '__c';
              continue;
          }
          
          if(fixApproval.get(fixApprover) == Null){
              
              j++;
              fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
              continue;
          }
          
          npl.put(sysApprover, fixApproval.get(fixApprover));
          
          i++;
          sysApprover = 'ASI_CN_NPL_Approver' + i + '__c';
          
          j++;
          fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
      }
  }
  
  Private Static void setApproverToNull(ASI_CN_NPL_NPL_Request__c npl){
      
      Integer i = 1;
      String sysApprover = 'ASI_CN_NPL_Approver' + i + '__c';
      
      While(npl_FIELD_MAP.containsKey(sysApprover)){
          
          npl.put(sysApprover, null);
          
          i++;
          sysApprover = 'ASI_CN_NPL_Approver' + i + '__c';
      }
  }
  
  Private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
      
      String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
      
      List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
      return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
  }
  
  Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
  }
  //20170814 End

  // 20190726 Wilson Chow start
  private static void assignItemGroupSelective(
          Map<Id, List<ASI_CN_NPL_NPL_Request__c>> itemMasterIdNplListMap,
          Map<string, string> map_itemMasterId_itemGroupCode,
          List<ASI_MFM_Item_Group__c> ItemGroupList) {

      Map<String, List<ASI_CN_NPL_NPL_Request__c>> itemCodeNplMap =
              new Map<String, List<ASI_CN_NPL_NPL_Request__c>>();

      if(itemMasterIdNplListMap != null
              && !itemMasterIdNplListMap.isEmpty()) {

          /*
          for (ASI_CN_NPL_Item_Master__c itemMaster :
          [select Id, ASI_CN_NPL_Item_Goup_Code__c
          from ASI_CN_NPL_Item_Master__c
          where Id in :itemMasterIdNplListMap.keySet()]) {

              List<ASI_CN_NPL_NPL_Request__c> tmpNplList = itemMasterIdNplListMap.get(itemMaster.Id);

              if(tmpNplList.size() > 0) {

                  system.debug('Set item code:' + itemMaster.ASI_CN_NPL_Item_Goup_Code__c + ' for id list:' + tmpNplList);
                  itemCodeNplMap.put(itemMaster.ASI_CN_NPL_Item_Goup_Code__c, tmpNplList);
              }
          }
          */

          if(map_itemMasterId_itemGroupCode != null
                  && !map_itemMasterId_itemGroupCode.isEmpty()) {
              for(String itemMasterId: map_itemMasterId_itemGroupCode.keySet()) {
                  List<ASI_CN_NPL_NPL_Request__c> tmpNplList = itemMasterIdNplListMap.get(Id.valueOf(itemMasterId));

                  if(tmpNplList.size() > 0) {

                      system.debug('Set item code:' + map_itemMasterId_itemGroupCode.get(itemMasterId) + ' for id list:' + tmpNplList);
                      itemCodeNplMap.put(map_itemMasterId_itemGroupCode.get(itemMasterId), tmpNplList);
                  }
              }
          }

          if(!itemCodeNplMap.isEmpty()) {
              system.debug('Get item group by nplItemCodeMap:' + itemCodeNplMap);
              /*
              List<ASI_MFM_Item_Group__c> itemGroupList =
              [select id,ASI_MFM_Item_Group_Code__c from ASI_MFM_Item_Group__c
              where recordtype.developerName = 'ASI_CRM_CN_CRM_Item_Group'
              and ASI_MFM_Item_Group_Code__c =: itemCodeNplMap.keySet()
              and ASI_MFM_Item_Group_Code__c <> null];
              */

              if(itemGroupList.size() > 0) {
                  List<ASI_MFM_Item_Group__c> updateItemGroupList = new List<ASI_MFM_Item_Group__c>();

                  for(ASI_MFM_Item_Group__c itemGroup: itemGroupList) {

                      List<ASI_CN_NPL_NPL_Request__c> tmpNplList = itemCodeNplMap.get(itemGroup.ASI_MFM_Item_Group_Code__c);

                      if(tmpNplList.size() > 0) {
                          // assume npl:itemGroup is 1 to 1
                          //20200707:AM@Introv - fix selective field start
                          //***When NPL=”Final Approved” and ASI_CRM_Selective_Picklist__c=”Yes”, then set item group “Seletive” as “Yes”***
                          /*itemGroup.ASI_CRM_Selective__c =
                                  ((String.isNotBlank(tmpNplList.get(0).ASI_CN_NPL_Status__c)
                                          && tmpNplList.get(0).ASI_CN_NPL_Status__c.equals('Final Approved')
                                          && String.isNotBlank(tmpNplList.get(0).ASI_CN_NPL_Category__c)
                                          && tmpNplList.get(0).ASI_CN_NPL_Category__c.equalsIgnoreCase('WINE'))
                                          ? true: false);*/
                          itemGroup.ASI_CRM_Selective__c =
                                  ((String.isNotBlank(tmpNplList.get(0).ASI_CN_NPL_Status__c)
                                          && tmpNplList.get(0).ASI_CN_NPL_Status__c.equals('Final Approved')
                                          && tmpNplList.get(0).ASI_CRM_Selective__c)
                                          ? true: false);
                          //20200707:AM@Introv - fix selective field end

                          //20200113:AM@Introv - CR(Opt_Auto) start
                          itemGroup.ASI_CRM_Selective_Picklist__c = (itemGroup.ASI_CRM_Selective__c ? 'SLT' : 'NSLT');
                          //20200113:AM@Introv - CR(Opt_Auto) end
                          
                          system.debug('Item group selective:' + itemGroup.ASI_CRM_Selective__c
                                  + ' by NPL status:' + tmpNplList.get(0).ASI_CN_NPL_Status__c
                                  + ' and NPL category:' + tmpNplList.get(0).ASI_CN_NPL_Category__c);
                      }

                      updateItemGroupList.add(itemGroup);
                  }

                  if(updateItemGroupList.size() > 0) {
                      system.debug('Update item group list');
                      update updateItemGroupList;
                  }
              }
          }
      }
  }
  // 20190726 Wilson Chow end
  
  //20191013:AM@Introv - fix soql 101 and approver fields start
  private static void assignDefaultValues(List<ASI_CN_NPL_NPL_Request__c> trigger_new, Boolean bIgnoreCheck) {
      List<ASI_CN_NPL_NPL_Request__c> ltUpdate = new List<ASI_CN_NPL_NPL_Request__c>();
      for (ASI_CN_NPL_NPL_Request__c oRequest : trigger_new) {
          if ((oRequest.ASI_CN_NPL_Status__c == NULL) || (oRequest.ASI_CN_NPL_Status__c == 'Open') || (bIgnoreCheck)) {
              ltUpdate.add(oRequest);
          }
      }
      if (ltUpdate.size()>0) assignDefaultApprovers(ltUpdate, bIgnoreCheck);
  }
  
  private static void assignDefaultApprovers(List<ASI_CN_NPL_NPL_Request__c> trigger_new, Boolean bIgnoreCheck) {
      Id idMarketing = getPublicGroupUserIDByGroupName('ASI CN NPL Marketing Director');
      Id idManaging = getPublicGroupUserIDByGroupName('ASI CN NPL Deputy Managing Director');
      Id idNationalSales = getPublicGroupUserIDByGroupName('ASI CN NPL National Sales Dev VP');
      //20200113:AM@Introv - CR(Opt_Auto) start
      Id idBusinessHead = getPublicGroupUserIDByGroupName('ASI CN NPL Business Head');
      Id idFinanceDirector = getPublicGroupUserIDByGroupName('ASI CN NPL Finance Director');
      Id idAssFinanceDirector = getPublicGroupUserIDByGroupName('ASI CN NPL Ass. Finance Director');
      //20200113:AM@Introv - CR(Opt_Auto) end

      Map<String, ASI_CRM_Fix_Approval_Route__c> fixApprovalMap2 = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
      String whereClause2 = ' WHERE ASI_CRM_CN_Type__c Like \'NPL - Class%\' AND RecordType.developerName Like \'ASI_CRM_CN_%\'';
      
      for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FixApproval_FIELD_MAP, whereClause2)){
            fixApprovalMap2.put(obj.ASI_CRM_CN_Type__c, obj);
      }

      for (ASI_CN_NPL_NPL_Request__c oRequest : trigger_new) {
          if ((oRequest.ASI_CN_NPL_Status__c == NULL) 
              || (oRequest.ASI_CN_NPL_Status__c == 'Open') 
              || (bIgnoreCheck)) {
              oRequest.ASI_CN_NPL_English_Name_Final__c = oRequest.ASI_CN_NPL_Product_Name_English__c;
              oRequest.ASI_CN_NPL_English_Name_Proposal__c = oRequest.ASI_CN_NPL_Product_Name_English__c;
              
              oRequest.ASI_CN_NPL_Chinese_Name_Final__c = oRequest.ASI_CN_NPL_Product_Name_Chinese__c;
              oRequest.ASI_CN_NPL_Chinese_Name_Proposal__c = oRequest.ASI_CN_NPL_Product_Name_Chinese__c;
          }
          
    //MT@Introv@20200429: fix querying inside the loop START
          //if (oRequest.ASI_CN_NPL_Brand_Director__c == NULL) assignBrandDirector(oRequest); 
          //MT@Introv@20200429: fix querying inside the loop END
          //20200514:AM@Introv - override approvers start
          /*
          if (oRequest.ASI_CN_NPL_Marketing_Director__c == NULL) oRequest.ASI_CN_NPL_Marketing_Director__c = idMarketing;
          if (oRequest.ASI_CN_NPL_Deputy_Managing_Director__c == NULL) oRequest.ASI_CN_NPL_Deputy_Managing_Director__c = idManaging;
          if (oRequest.ASI_CN_NPL_National_Sales_Dev_VP__c == NULL) oRequest.ASI_CN_NPL_National_Sales_Dev_VP__c = idNationalSales;
          //20200113:AM@Introv - CR(Opt_Auto) start
          if (oRequest.ASI_CN_NPL_Business_Head__c == NULL) oRequest.ASI_CN_NPL_Business_Head__c = idBusinessHead;
          if ((oRequest.ASI_CN_NPL_Classification_Text__c=='Class D')&&(oRequest.ASI_CN_NPL_Finance_Director__c == NULL)) oRequest.ASI_CN_NPL_Finance_Director__c = idFinanceDirector;
          if ((oRequest.ASI_CN_NPL_Classification_Text__c=='Class E'||oRequest.ASI_CN_NPL_Classification_Text__c=='Class F')
             &&(oRequest.ASI_CN_NPL_Finance_Director__c == NULL)) oRequest.ASI_CN_NPL_Finance_Director__c = idAssFinanceDirector;
          if (oRequest.ASI_CN_NPL_PnL_BA_Approver__c == NULL) oRequest.ASI_CN_NPL_PnL_BA_Approver__c = idAssFinanceDirector;
          //20200113:AM@Introv - CR(Opt_Auto) end
          */
          oRequest.ASI_CN_NPL_Marketing_Director__c = idMarketing;
          oRequest.ASI_CN_NPL_Deputy_Managing_Director__c = idManaging;
          oRequest.ASI_CN_NPL_National_Sales_Dev_VP__c = idNationalSales;
          String nplClassText = 'NPL - ' + oRequest.ASI_CN_NPL_Classification_Text__c;
          if (fixApprovalMap2.containsKey(nplClassText) && fixApprovalMap2.get(nplClassText) != null) {
             oRequest.ASI_CN_NPL_Final_Approval1__c = fixApprovalMap2.get(nplClassText).ASI_CRM_CN_Approver_1__c;
          }
          //20200113:AM@Introv - CR(Opt_Auto) start
          oRequest.ASI_CN_NPL_Business_Head__c = idBusinessHead;
          if (oRequest.ASI_CN_NPL_Classification_Text__c=='Class D') oRequest.ASI_CN_NPL_Finance_Director__c = idFinanceDirector;
          if ((oRequest.ASI_CN_NPL_Classification_Text__c=='Class E'||oRequest.ASI_CN_NPL_Classification_Text__c=='Class F')) oRequest.ASI_CN_NPL_Finance_Director__c = idAssFinanceDirector;
          oRequest.ASI_CN_NPL_PnL_BA_Approver__c = idAssFinanceDirector;
          //20200113:AM@Introv - CR(Opt_Auto) end
          //20200514:AM@Introv - override approvers end
      }
      //MT@Introv@20200429: fix querying inside the loop START
      assignBrandDirector(trigger_new);
      //MT@Introv@20200429: fix querying inside the loop END
  }
  //20191013:AM@Introv - fix soql 101 and approver fields end
  
  //20200113:AM@Introv - CR(Opt_Auto) start
  private static void assignSelectiveValues(List<ASI_CN_NPL_NPL_Request__c> trigger_new) {
      for (ASI_CN_NPL_NPL_Request__c oRequest : trigger_new) {
          if (oRequest.ASI_CRM_Selective_Picklist__c != NULL) {
              boolean bSelective = (oRequest.ASI_CRM_Selective_Picklist__c=='Yes');
              oRequest.ASI_CRM_Selective__c = bSelective;
          }
      }
  }
  //20200113:AM@Introv - CR(Opt_Auto) end
  
}