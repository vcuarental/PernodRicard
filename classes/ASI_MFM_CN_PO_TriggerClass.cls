/* Filename:    ASI_MFM_CN_PO_TriggerClass.cls
* Author:      Michael Yip (Introv Limited)
* Purpose:     PO CN Trigger
*

*
* History
* -----------------------------------------------------------------------------
* 2012-12-20    michael.yip@introv.com      Created
* 2012-12-21    michael.yip@introv.com      Added Approval Flow for CN PO without sub-brand restriction
* 2012-12-23    michael.yip@introv.com      Added Send Approval Email with Attachment
* 2014-02-13    stella.sing@introv.com      Added Exchange Rate Calculation to PO
* 2014-03-03    stella.sing@introv.com      Change Base Currency of Exchange Rate Calculation
* 2014-04-08    stella.sing@introv.com      Change ASI_MFM_Function.getRecordTypeId to Global_RecordTypeCache.getRtList
* 2014-04-24    stella.sing@introv.com      Change Exchange Rate calculation only happens when new create & change of Currency             
* 2014-05-09    kf.leung@introv.com         Added checking to abort change of currency if related payment or receipt exists
* 2014-07-14    michael.yip@introv.com      Change ASI_MFM_Application__c to 'MFM' for BU exchange rate calculation
* 2014-08-13    michael.yip@introv.com      Exclude approver assignment for PO Type "eMarket"
* 2014-08-19    twinkle.li@introv.com       Copy MFM PO to consumer A&P PO object, Update PO Amount in Consumer A&P PO, Update Consumer A&P PO Amount to 0 if PO is deleted
* 2014-09-12    michael.yip@introv.com      Copy Final Date to G\L Date
* 2014-10-03    michael.yip@introv.com      Fix Copy MFM PO to consumer A&P PO function, set recordtype, create consumer A&P PO when update to final
* 2014-10-16    Axel.Leung@introv.com       Copy PO Final Date to Consumer A&P Date
* 2014-10-16    Axel.Leung@introv.com       Fix to renew exchange rate on changing currency code
* 2014-10-27    Axel.leung@introv.com       #102, Fixx bug on re-approving the MFM PO, not to insert again the Free Good PO / Consumer A&P PO if it existed 
* 2014-10-30    Axel.leung@introv.com       #95, to fix the Plan's "Total PO Amount", to replicate logic from ASI_MFM_PO_Trigger's routineAfterAll
* 2014-12-15    daniel.wong@introv.com      #85
* 2015-01-09    twinkle.li@introv.com       #Update Dynamic Approval Route
*/
public without sharing class ASI_MFM_CN_PO_TriggerClass {
    
    Private Static List<ASI_MFM_Team_Member__c> teamMemberList = new List<ASI_MFM_Team_Member__c>([SELECT id, ASI_MFM_Team__c, ASI_MFM_Team_Member__c FROM ASI_MFM_Team_Member__c WHERE ASI_MFM_Team__r.RecordType.DeveloperName = 'ASI_MFM_CN_Project_Team']);//20170112 Elufa
    Private Static Map<Id, User> LUser = new Map<Id, User>([Select id, ManagerID, UserRoleId, ASI_CRM_Sales_Team__c, ASI_MFM_Team__c, BypassTriggers__c from User Where (CompanyName = 'Pernod Ricard China' OR ID = : userInfo.getUserId()) AND isActive = TRUE]);//20161116 Elufa
    Private Static Integer Counting = 0;
    Private Static List<ASI_MFM_BU__c> BU_List = [Select id, Name, ASI_MFM_CN_Country__c, ASI_MFM_Auto_Receipt__c, ASI_MFM_Base_Currency__c from ASI_MFM_BU__c];//20170112 Elufa moved from SetBULookupValue()
    Private Static List<Account> LAcc = [SELECT id FROM Account WHERE recordtypeid = :Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier') and RecordType.name = 'CN Supplier' and ASI_MFM_Customer_Supplier_Number__c = '61202305' limit 1];//20170112 Elufa 
    Private Static List<ASI_MFM_Exchange_Rate__c> ExRateList = [SELECT id, ASI_MFM_Exchange_Rate__c, ASI_MFM_Effective_Date__c, ASI_MFM_Country__c, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c FROM ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' AND ASI_MFM_Country__c = 'CN' ORDER By ASI_MFM_Effective_Date__c DESC];//20170112 Elufa
    //20170627 PO category validation
    Private Static Map<Id, ASI_MFM_PP_Category__c> mapPPCatgeory = new Map<Id, ASI_MFM_PP_Category__c>([SELECT id, ASI_MFM_Marketing_Category__c, ASI_MFM_CN_Late_PO__c FROM ASI_MFM_PP_Category__c WHERE recordType.developerName LIKE 'ASI_MFM_CN_PP_Category']); // 2019-04-24 @ Introv add late po search
    Private Static List<ASI_MFM_Dynamic_Approval_Route__c> approvalRouteList = [Select ASI_MFM_Approval_Limit__c, ASI_MFM_End_of_1st_Route__c, ASI_MFM_Manager_ID__c, ASI_MFM_Type__c, ASI_MFM_User__c from ASI_MFM_Dynamic_Approval_Route__c where ASI_MFM_Type__c = 'PO']; //20180718 Introv
    
    //20191025:AM@Introv - bypass budget owner validation
    Private Static List<GroupMember> G_MEMBER_IN_HR_ADMIN_GRP = [SELECT Group.Name, GroupId, UserorGroupId FROM GroupMember WHERE Group.name = 'ASI CRM CN HR Admin' LIMIT 2000];
    //20200505 Howard@Introv - POConNum Mapping
    Private Static Map<Id, List<String>> POtoConNumList = new Map<Id, List<String>>();
    public static Boolean ISVALIDATION = false;
    public static Boolean ISVALIDATION2 = false;
    public static Boolean ISVALIDATION3 = false;

    public static void routineBeforeInsert(list<ASI_MFM_PO__c> trigger_new) {
        
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_CN_PO_TriggerClass')){//20161223 Elufa added Bypass
            // 20200226:Enoch@Introv Contract Validate
            validateContractNumber(trigger_new);
            
            Integer i;
            /** added by leo - 2014/06/16 **/
            // Set the BU Code lookup from "BU" picklist
            SetBULookupValue(trigger_new);
            
            // Set the PO number for new PO                     
            set<id> px_set = new set<id>();
            Set<id> PlanSetId = new Set<id>();//20161116 Elufa
            Map<Id, List<ASI_MFM_PO__c>> planPOMap = new Map<Id, List<ASI_MFM_PO__c>>();//20161116 Elufa
            
            for (ASI_MFM_PO__c p:trigger_new) {
                
                //20161116 Elufa
                if(p.ASI_MFM_Plan__c != NULL){
                    PlanSetId.add(p.ASI_MFM_Plan__c);
                    
                    List<ASI_MFM_PO__c> tmpList = new List<ASI_MFM_PO__c>();
                    
                    if(planPOMap.containsKey(p.ASI_MFM_Plan__c))
                        tmpList = planPOMap.get(p.ASI_MFM_Plan__c);
                    
                    tmpList.add(p);
                    
                    planPOMap.put(p.ASI_MFM_Plan__c, tmpList);
                    
                }
                //20161116 End
                
                if (p.asi_mfm_prefix__c != null) {
                    px_set.add(p.asi_mfm_prefix__c);
                }
            }
            
            BudgetOwnerValidationCheck(PlanSetId, planPOMap, null);//20161116 Elufa
            
            map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c from asi_mfm_prefix__c 
                                                                                where asi_mfm_module__c = 'PO' and id in :px_set for update]);
            
            for (ASI_MFM_PO__c p:trigger_new) {
                if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                }
                p.ASI_MFM_PO_Original_Amount__c = null;
                
                // Added by Michael Yip (Introv) 12Sep2014 for copy final date to G\L Date
                if(p.ASI_MFM_PO_Final_Date__c != null && p.ASI_MFM_GL_Date__c != p.ASI_MFM_PO_Final_Date__c)
                    p.ASI_MFM_GL_Date__c = p.ASI_MFM_PO_Final_Date__c;
            }
            ASI_MFM_Function.updatePrefix(px_map.values());
            
            /* Added by Michael Yip (Introv) 20Dec2013
Fill in plan for in-channel PO when event id is filled
*/
            Set<id> SEventPP = new Set<id>();
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_Event_ID__c != null) {
                    SEventPP.add(p.ASI_MFM_Event_ID__c);
                }
            }
            System.debug(SEventPP);
            if (!SEventPP.isEmpty()) {
                Map<id, ASI_MFM_Event_PP__c> MEvent = new Map<id, ASI_MFM_Event_PP__c>([Select id, ASI_MFM_Plan__c, ASI_MFM_Event__c from ASI_MFM_Event_PP__c where id IN :SEventPP]);
                for (ASI_MFM_PO__c p:trigger_new) {
                    if (p.ASI_MFM_Event_ID__c != null  && MEvent.containsKey(p.ASI_MFM_Event_ID__c)) {
                        //if(p.ASI_MFM_Plan__c == null){
                        p.ASI_MFM_Plan__c = MEvent.get(p.ASI_MFM_Event_ID__c).ASI_MFM_Plan__c;
                        //}
                        if(p.ASI_MFM_Event_sys__c == null){
                            p.ASI_MFM_Event_sys__c = MEvent.get(p.ASI_MFM_Event_ID__c).ASI_MFM_Event__c;
                        }
                    }
                }
            }
            
            UpdateExRate(trigger_new, null);
            
            /* added by Twinkle - 2014/08/19
Copy PO to consumer A&P PO object if PO with BU Code: PRCN, Status = Final, Currency = RMB and Supplier = 61202305*/
            
            List<ASI_FOC_PO__c> LFOC = new List<ASI_FOC_PO__c>();
            Set<id> SPID = new set<id>();
            
            //List<Account> LAcc = [SELECT id FROM Account WHERE recordtypeid = :Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier') and RecordType.name = 'CN Supplier' and ASI_MFM_Customer_Supplier_Number__c = '61202305' limit 1];//20170112 Elufa Changed to Static Variable
            Set<id> SAcc = new set<id>();
            for(Account a : LAcc){
                SAcc.add(a.id);
            }
            
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_CN_Consumer_A_P_PO__c == null && p.ASI_MFM_CN_BU_Picklist__c == 'PRCN' && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Currency__c == 'RMB' && SAcc.Contains(p.ASI_MFM_Supplier_Name__c)) {
                    // Updated by Michael Yip (Introv) 3Sep2014 to add record type and copy name
                    ASI_FOC_PO__c tempFOC = new ASI_FOC_PO__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_PO__cASI_FOC_CN_PO'));
                    tempFOC.ASI_FOC_PO_Final_Amount__c = p.ASI_MFM_PO_Amount__c;
                    tempFOC.ASI_FOC_Date__c = p.ASI_MFM_PO_Start_Date__c; // By Axel@introv, 2014-10-16, Copy PO Final Date to Consumer A&P Date
                    tempFOC.name = p.name;
                    tempFOC.Ownerid = p.Ownerid;//20151118 Ben @ Elufa System
                    LFOC.add(tempFOC);
                    SPID.add(p.id);
                }
            }
            if(LFOC != null && LFOC.size()>0) 
                insert(LFOC);
            
            i=0;
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_CN_BU_Picklist__c == 'PRCN' && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Currency__c == 'RMB' && SAcc.Contains(p.ASI_MFM_Supplier_Name__c) && SPID.Contains(p.id)) {
                    p.ASI_MFM_CN_Consumer_A_P_PO__c = LFOC[i].id;
                    i++;
                }
                // 2019-04-10 @Introv update submit date 
                if(p.ASI_MFM_Status__c == 'Submitted') {
                    p.ASI_MFM_Submit_Date__c = DateTime.now();
                }
                // 2019-04-24 @Introv add late po checking
                ASI_MFM_PP_Category__c ppCate = null;
                p.ASI_MFM_CN_Late_PO__c = false;
                if(p.ASI_MFM_PO_PP_Category__c != null) ppCate=mapPPCatgeory.get(p.ASI_MFM_PO_PP_Category__c);
                if(ppCate!=null) {
                    p.ASI_MFM_CN_Late_PO__c = ppCate.ASI_MFM_CN_Late_PO__c;
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap){
       
        List<ASI_MFM_PO_Line_Item__c> LPOItem;//20170112 Elufa moved from line 287
        
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_CN_PO_TriggerClass')){//20161223 Elufa Added bypass
            // 20200226:Enoch@Introv Contract Validate
            validateContractNumber(trigger_new);
            
            //added by Daniel WONG 2014-12-15
            set<id> setofPO = new set<id>();
            Set<Id> approvedPOSet = new Set<Id>();//20180524 Introv
            
            Map<Id, ASI_MFM_PO_Line_Item__c> mapPOLine = new Map<Id, ASI_MFM_PO_Line_Item__c>();//20160718 Ben @ Elufa
            
            Set<id> PlanSetId = new Set<id>();//20161116 Elufa
            Map<Id, List<ASI_MFM_PO__c>> planPOMap = new Map<Id, List<ASI_MFM_PO__c>>();//20161116 Elufa
            
            for(ASI_MFM_PO__c pi : trigger_new) {
                if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO') || pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only'))
                    setofPO.add(pi.id);
                
                //20180619 Introv
                if(pi.ASI_MFM_Status__c == 'Final' && (pi.ASI_MFM_PO_Start_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_PO_Start_Date__c || pi.ASI_MFM_PO_End_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_PO_End_Date__c)){
                    pi.recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO');
                    pi.ASI_MFM_Status__c = 'Draft';
                }
                
                //20161116 Elufa
                if(pi.ASI_MFM_Plan__c != NULL){
                    PlanSetId.add(pi.ASI_MFM_Plan__c);
                    
                    List<ASI_MFM_PO__c> tmpList = new List<ASI_MFM_PO__c>();
                    
                    if(planPOMap.containsKey(pi.ASI_MFM_Plan__c))
                        tmpList = planPOMap.get(pi.ASI_MFM_Plan__c);
                    
                    tmpList.add(pi);
                    
                    planPOMap.put(pi.ASI_MFM_Plan__c, tmpList);
                    
                }
                //20161116 End
                
                //20180524 Introv
                if(trigger_oldMap.get(pi.id).ASI_MFM_Status__c != pi.ASI_MFM_Status__c && (pi.ASI_MFM_Status__c == 'Final' || pi.ASI_MFM_Status__c == 'Complete')){
                    
                    approvedPOSet.add(pi.id);
                }
            }
            
            BudgetOwnerValidationCheck(PlanSetId, planPOMap, trigger_oldMap);//20161116 Elufa
            
            //20180524 Introv
            if(approvedPOSet.size() > 0){
                List<ASI_MFM_PO_Receipt_Phasing__c> receiptPhasingList = new List<ASI_MFM_PO_Receipt_Phasing__c>([SELECT id, ASI_MFM_PO_Approved__c FROM ASI_MFM_PO_Receipt_Phasing__c WHERE ASI_MFM_PO__c IN : approvedPOSet AND ASI_MFM_PO_Approved__c = False]);
                for(ASI_MFM_PO_Receipt_Phasing__c obj : receiptPhasingList){
                    obj.ASI_MFM_PO_Approved__c = True;
                }
                
                try{
                    Update receiptPhasingList;
                }catch(dmlException dmle){
                    
                }
            }
            //20180524 End
            
            map<id, set<id>> mapOfPOWithSubBrand = new map<id, set<id>>();
            if (!setofPO.isEmpty()) {
                if (ISVALIDATION2) return;
                ISVALIDATION2 = true;
                
                for(ASI_MFM_PO_Line_Item__c i : [SELECT ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c
                                             FROM ASI_MFM_PO_Line_Item__c
                                             WHERE ASI_MFM_Sub_brand_Code__c != NULL
                                             AND ASI_MFM_PO__c IN :setofPO
                                            ]){
                                                id idKey = i.ASI_MFM_PO__c;
                                                set <ID> setOfID = new set <ID>();
                                                if(mapOfPOWithSubBrand.get(idKey) != NULL)
                                                    setOfID = mapOfPOWithSubBrand.get(idKey);
                                                
                                                setOfID.add(i.ASI_MFM_Sub_brand_Code__c);    
                                                mapOfPOWithSubBrand.put(idKey, setOfID);
                                            }
            }
           
            map<id, set<id>> mapOfPlanWithSubBrand = new map<id, set<id>>();
            if (!PlanSetId.isEmpty()) {
                if (ISVALIDATION3) return;
                ISVALIDATION3 = true;
                for(ASI_MFM_Plan_Line_Item__c i : [SELECT ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c
                                               FROM ASI_MFM_Plan_Line_Item__c
                                               WHERE ASI_MFM_Sub_brand_Code__c != NULL
                                               AND recordtypeid = :Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item')
                                               AND ASI_MFM_Plan__c IN : PlanSetId
                                              ]){
                                                  id idKey = i.ASI_MFM_Plan__c;
                                                  set <ID> setOfID = new set <ID>();
                                                  if(mapOfPlanWithSubBrand.get(idKey) != NULL)
                                                      setOfID = mapOfPlanWithSubBrand.get(i.ASI_MFM_Plan__c);
                                                  
                                                  setOfID.add(i.ASI_MFM_Sub_brand_Code__c);
                                                  mapOfPlanWithSubBrand.put(idKey, setOfID);
                                              } 
            }
            
            for(ASI_MFM_PO__c i : trigger_new){
                if(i.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO') || i.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only')){
                    if(i.ASI_MFM_Plan__c != trigger_oldMap.get(i.id).ASI_MFM_Plan__c){
                        if(i.ASI_MFM_Plan__c != NULL){
                            if(mapOfPOWithSubBrand.get(i.id) != NULL){
                                set<id> tempSetofPOSubBrand = new set<id>(mapOfPOWithSubBrand.get(i.id));
                                set<id> tempSetOfPlanSubBrand = new set<id>();
                                if(mapOfPlanWithSubBrand.get(i.ASI_MFM_Plan__c) != NULL){
                                    tempSetOfPlanSubBrand = mapOfPlanWithSubBrand.get(i.ASI_MFM_Plan__c);
                                    
                                    for(id temp : tempSetofPOSubBrand){
                                        if(!tempSetOfPlanSubBrand.contains(temp))
                                            i.addError('The sub-brand in the new Plan doesnt match with the existing sub-brand.');
                                    }
                                }else{
                                    i.addError('The sub-brand in the new Plan doesnt match with the existing sub-brand.');
                                }
                            }
                        }else{
                            i.addError('Plan cannot be NULL.');
                        }
                    }
                }// END of recordType for CN - Daniel WONG
            }       
            
            Integer i =0;
            /** added by leo - 2014/06/16 **/
            // Set the BU Code lookup from "BU" picklist
            SetBULookupValue(trigger_new);
            
            /*  Added by Michael Yip (Introv) 20Dec2013
retreive recordtype by sojbect and filter out record by record type and filter out CN PO
*/
            System.debug('CN PO Trigger Class');
            //Stella 2014-0407
            
            //Map<string, id> MRecTypeID = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');
            //Set<id> SCNRecTypeID = checkRecordType('ASI_MFM_PO__c', 'CN_PO');
            
            Map<string, id> MRecTypeID = new Map<string, id>();
            for(RecordType r : Global_RecordTypeCache.getRtList('ASI_MFM_PO__c')){
                MRecTypeID.put(r.developername,r.id); 
            }
            Set<id> SCNRecTypeID = new Set<id>();
            for(String key : MRecTypeID.keySet()){
                if(key.contains('CN_PO')){
                    SCNRecTypeID.add(MRecTypeID.get(key));
                }
            }       
            Set<id> SPOID = new Set<id>();
            Map<id, ASI_MFM_PO__c> MPO = new Map<id,ASI_MFM_PO__c>();
            for(ASI_MFM_PO__c PO : trigger_new){            
                if(SCNRecTypeID.contains(PO.recordtypeid)){
                    SPOID.add(PO.id);
                    MPO.put(PO.id,PO);
                    if(PO.ASI_MFM_PO_Original_Amount__c != null && (PO.ASI_MFM_CN_PO_Max_Approved_Amount__c == null || PO.ASI_MFM_PO_Original_Amount__c > PO.ASI_MFM_CN_PO_Max_Approved_Amount__c)){
                        PO.ASI_MFM_CN_PO_Max_Approved_Amount__c = PO.ASI_MFM_PO_Original_Amount__c;
                    }
                }
                
                // Added by Michael Yip (Introv) 12Sep2014 for copy final date to G\L Date
                if(po.ASI_MFM_PO_Final_Date__c != null && po.ASI_MFM_GL_Date__c != po.ASI_MFM_PO_Final_Date__c)
                    po.ASI_MFM_GL_Date__c = po.ASI_MFM_PO_Final_Date__c;
            }
            /* Added by Michael Yip (Introv) 20Dec2013
Update PO Remark for child line item for CN PO line item & PO receipt line item when PO Remark changes
*/
            if(SPOID != null && SPOID.size()>0){
                LPOItem = [Select id, ASI_MFM_PO__c, ASI_MFM_PO_Remark__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Director__c//20160718 Ben @ Elufa added ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Director__c
                           , (SELECT Id FROM Payment_Line_Items__r), (SELECT Id, ASI_MFM_PO_Remark__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c FROM PO_Receipt_Items__r) from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c IN :SPOID
                           Order BY LastModifiedDate ASC];//20170112 Elufa moved to method header and added , (SELECT Id FROM Payment_Line_Items__r), (SELECT Id FROM PO_Receipt_Items__r)
                
                List<ASI_MFM_PO_Line_Item__c> LPOItemUpdate = new List<ASI_MFM_PO_Line_Item__c>();
                List<ASI_MFM_PO_Receipt_Item__c> LPOReceiptItem = new List<ASI_MFM_PO_Receipt_Item__c>();
                
                for(ASI_MFM_PO_Line_Item__c POItem : LPOItem){
                    if(MPO.containsKey(POItem.ASI_MFM_PO__c)){
                        if(POItem.ASI_MFM_PO_Remark__c != MPO.get(POItem.ASI_MFM_PO__c).ASI_MFM_Remarks__c){
                            POItem.ASI_MFM_PO_Remark__c = MPO.get(POItem.ASI_MFM_PO__c).ASI_MFM_Remarks__c;
                            LPOItemUpdate.add(POItem);
                        }
                        
                        //20160718 Ben @ Elufa
                        mapPOLine.put(POItem.ASI_MFM_PO__c, POItem);
                        
                        //20180524 removed below soql to relases resources
                        LPOReceiptItem.addAll(POItem.PO_Receipt_Items__r);
                    }
                }
                if(LPOItemUpdate != null && LPOItemUpdate.size()>0){
                    update LPOItemUpdate;
                }
                /*List<ASI_MFM_PO_Receipt_Item__c> LPOReceiptItem = [Select id, ASI_MFM_PO_Remark__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c
                                                                   from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c IN :SPOID];*/ // 20180524 Introv Commented
                
                List<ASI_MFM_PO_Receipt_Item__c> LPOReceiptItemUpdate = new List<ASI_MFM_PO_Receipt_Item__c>();
                for(ASI_MFM_PO_Receipt_Item__c PORecItem : LPOReceiptItem){
                    if(MPO.containsKey(PORecItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c)){
                        if(PORecItem.ASI_MFM_PO_Remark__c != MPO.get(PORecItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).ASI_MFM_Remarks__c){
                            PORecItem.ASI_MFM_PO_Remark__c = MPO.get(PORecItem.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).ASI_MFM_Remarks__c;
                            LPOReceiptItemUpdate.add(PORecItem);
                        }
                    }
                }
                if(LPOReceiptItemUpdate != null && LPOReceiptItemUpdate.size()>0){
                    update LPOReceiptItemUpdate;
                }
                
            }
            
            set<id> rejected_set = new set<id>();
            map<id, ASI_MFM_PO__c> reject_map = new map<id, ASI_MFM_PO__c>();
            for (ASI_MFM_PO__c p:trigger_new) {
                //Only mark the flag if it is not returned by finance
                System.debug(p.ASI_MFM_CN_Return_Flag__c);
                System.debug(trigger_oldMap.get(p.id).ASI_MFM_CN_Return_Flag__c); 
                if (SPOID.contains(p.id) && p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted' && !(p.ASI_MFM_CN_Return_Flag__c == true && trigger_oldMap.get(p.id).ASI_MFM_CN_Return_Flag__c == false) ) {
                    reject_map.put(p.id, p);
                }
            }
            if (reject_map.size() > 0) {
                list<ASI_MFM_PO__c> reject_list = [select ASI_MFM_CN_Return_Flag__c, id, (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_PO__c where id in :reject_map.keySet()];
                for (ASI_MFM_PO__c r:reject_list) {
                    if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                        reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                        reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                        
                    }
                }
            }
            // End 20Dec2013 Edit
            /*  Added by Michael Yip (Introv) 21Dec2013
Assign Approver
*/
            Boolean SkipApproverAssignment = true; //Only skip for PO Type "eMarket"
            set<id> pid_set = new set<id>();
            set<string> STeam = new set<string>();
            for (ASI_MFM_PO__c p:trigger_new) {
                if (SPOID.contains(p.id) && p.ASI_MFM_CN_PO_Amount_RMB__c != null) {
                    pid_set.add(p.id);
                    
                    setApproverToNull(p);
                    
                    STeam.add(p.asi_mfm_budget_owner_team__c);                                                            
                }
                if(p.ASI_MFM_PO_Type__c != 'eMarket'){
                    SkipApproverAssignment = false;
                }
            }
            
            //Updated by Twinkle 20150109 - Dynamic Route -> Managers
            if(!SkipApproverAssignment){
                Map<id, ASI_MFM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_MFM_Dynamic_Approval_Route__c>();
                Map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_MFM_Fix_Approval_Route__c>();
                Map<id, User> MUser = new Map<id, User>();
                
                List<ASI_MFM_Dynamic_Approval_Route__c> LApp = approvalRouteList; //20180718 Introv
                
                //List<User> LUser = [Select id, ManagerID from User Where CompanyName = 'Pernod Ricard China']; 20161116 Elufa Commented.
                for(User u : LUser.values()){
                    MUser.put(u.id, u);
                }   
                for(ASI_MFM_Dynamic_Approval_Route__c a : LApp){
                    MAppRoute.put(a.ASI_MFM_User__c, a);
                }
                System.debug(MAppRoute);
                
                List<ASI_MFM_Fix_Approval_Route__c> LFApp = [Select ASI_MFM_BA__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c,
                                                             ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Finance__c, ASI_MFM_Module__c, ASI_MFM_Team__c, 
                                                             ASI_MFM_Approval_Limit_BA__c, ASI_MFM_Approval_Limit_CA1__c, ASI_MFM_Approval_Limit_CA2__c, ASI_MFM_Approval_Limit_CA3__c,
                                                             ASI_MFM_Approval_Limit_CA4__c,ASI_MFM_Approval_Limit_Finance__c, ASI_MFM_Approval_Limit_BD__c //20160718 Ben @ Elufa added ASI_MFM_Approval_Limit_BD__c
															 ,ASI_MFM_CN_PO_Type__c //20170418, Elufa
                                                             from ASI_MFM_Fix_Approval_Route__c
                                                             where ASI_MFM_Module__c = 'PO' and ASI_MFM_Team__c IN :STeam
                                                             AND RecordType.DeveloperName = 'ASI_MFM_CN_Fix_Approval_Route'//20160810 Ben @ Elufa
                                                            ];      
                for(ASI_MFM_Fix_Approval_Route__c a : LFApp){
                    //MAppRouteFix.put(a.ASI_MFM_Team__c, a); //20170418, Elufa
					MAppRouteFix.put(a.ASI_MFM_CN_PO_Type__c+a.ASI_MFM_Team__c+a.ASI_MFM_Module__c, a); //20170418, Elufa
                }
                System.debug(MAppRouteFix);
                
                if (pid_set.size() > 0) { 
                    for (ASI_MFM_PO__c p:trigger_new) {
                        if (pid_set.contains(p.id)){                       
                            setApprovers(p, STeam, MAppRoute, MAppRouteFix, MUser, mapPOLine);
                        }
                    }
                }
            }
            
            Set<id> SEventPP = new Set<id>();
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_Event_ID__c != null ) {
                    SEventPP.add(p.ASI_MFM_Event_ID__c);
                }
            }
            if (!SEventPP.isEmpty()) {
                Map<id, ASI_MFM_Event_PP__c> MEvent = new Map<id, ASI_MFM_Event_PP__c>([Select id, ASI_MFM_Plan__c from ASI_MFM_Event_PP__c where id IN :SEventPP]);
                for (ASI_MFM_PO__c p:trigger_new) {
                    if (p.ASI_MFM_Event_ID__c != null) {
                        p.ASI_MFM_Plan__c = MEvent.get(p.ASI_MFM_Event_ID__c).ASI_MFM_Plan__c;
                    }
                }
            }
            
            
            UpdateExRate(trigger_new, trigger_oldMap);
            
            //// START: Added by KF Leung (Introv) 2014-05-09, Added checking to abort change of currency if related payment or receipt exists
            
            set<Id> abortedIds = new set<Id>(); 
            for(ASI_MFM_PO_Line_Item__c lineItem: LPOItem) {//20170112 Elufa replaced soql by LPOItem
                
                Id poId = lineItem.ASI_MFM_PO__c;
                ASI_MFM_PO__c po = MPO.get(poId);
                ASI_MFM_PO__c poOld = trigger_oldMap.get(poId);
                
                if(abortedIds.contains(poId))
                    continue;
                
                if(po.ASI_MFM_Currency__c == poOld.ASI_MFM_Currency__c)
                    continue;
                
                if(lineItem.Payment_Line_Items__r.size()>0) {
                    po.addError('Payment exists.  Change of Currency is not allowed.');
                    abortedIds.add(poId);                        
                }
                if(lineItem.PO_Receipt_Items__r.size()>0) {
                    po.addError('Receipt exists.  Change of Currency is not allowed.');
                    abortedIds.add(poId);
                }
            }
            
            //// END: Added by KF Leung (Introv) 2014-05-09, Added checking to abort change of currency if related payment or receipt exists
            
            /* added by Twinkle - 2014/08/19
Copy PO to consumer A&P PO object if Status changed to 'Final'
*/ 
            
            List<ASI_FOC_PO__c> LFOC = new List<ASI_FOC_PO__c>();
            Set<id> SPID = new set<id>(); // Set of PO's ID
            
            //List<Account> LAcc = [SELECT id FROM Account WHERE recordtypeid = :Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier') and RecordType.name = 'CN Supplier' and ASI_MFM_Customer_Supplier_Number__c = '61202305' limit 1];//20170112 Elufa Changed to static varaible
            Set<id> SAcc = new set<id>();
            for(Account a : LAcc){
                SAcc.add(a.id);
            }
            
            for (ASI_MFM_PO__c p:trigger_new) {
                if ((trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft'||trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Currency__c == 'RMB' && SAcc.Contains(p.ASI_MFM_Supplier_Name__c)) {
                    ASI_FOC_PO__c tempFOC = new ASI_FOC_PO__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_PO__cASI_FOC_CN_PO'));
                    tempFOC.ASI_FOC_PO_Final_Amount__c = p.ASI_MFM_PO_Amount__c;
                    tempFOC.ASI_FOC_Date__c = p.ASI_MFM_PO_Start_Date__c; // By Axel@introv, 2014-10-16, Copy PO Final Date to Consumer A&P Date
                    tempFOC.name = p.name;
                    tempFOC.Ownerid = p.Ownerid;//20151118 Ben @ Elufa System
                    LFOC.add(tempFOC);
                    SPID.add(p.id); // Set of PO's ID
                }
            }
            if(LFOC != null && LFOC.size()>0) {
                //insert(LFOC);
                upsert LFOC Name; // 2014-10-27     Axel @ Introv       #102 Fix bug on re-approve the MFM PO, not to create the Free Good PO / Consumer A&P PO if it existed
            }
            
            i=0;
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_CN_Consumer_A_P_PO__c == null && p.ASI_MFM_CN_BU_Picklist__c == 'PRCN' && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Currency__c == 'RMB' && SAcc.Contains(p.ASI_MFM_Supplier_Name__c) && SPID.Contains(p.id)) {
                    p.ASI_MFM_CN_Consumer_A_P_PO__c = LFOC[i].id;
                    i++;
                }
                // 2019-04-10 Introv update submit date 
                if(p.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft') {
                    //AM@Introv 20190617 - fix change amount issue
                    if (p.ASI_MFM_Submit_Date__c == NULL)
                    	p.ASI_MFM_Submit_Date__c = DateTime.now();
                }
                //AM@Introv 20190617 - fix change amount issue start
                if(p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final') {
                    if (p.ASI_MFM_Submit_Date__c == NULL)
                    	p.ASI_MFM_Submit_Date__c = Date.newInstance(p.ASI_MFM_PO_Start_Date__c.year()-2, 1, 1);
                }
                //reject case
                if(p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                    if (p.ASI_MFM_Submit_Date__c != NULL)
                    	p.ASI_MFM_Submit_Date__c = NULL;
                }
                //AM@Introv 20190617 - fix change amount issue end
                
                // 2019-04-24 @Introv add late po checking
                ASI_MFM_PP_Category__c ppCate = null;
                p.ASI_MFM_CN_Late_PO__c = false;
                if(p.ASI_MFM_PO_PP_Category__c != null) ppCate=mapPPCatgeory.get(p.ASI_MFM_PO_PP_Category__c);
                if(ppCate!=null) {
                    p.ASI_MFM_CN_Late_PO__c = ppCate.ASI_MFM_CN_Late_PO__c;
                }
            }
        }
    }
    
    //20200226:Enoch@Introv 
    public static void validateContractNumber(list<ASI_MFM_PO__c> trigger_new) {
        List<Id> CN_RTID_LIST = new List<Id>{
            Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO'),
            Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only')
        };
        Id CNC_RTID = Global_recordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'); 
        Id CNCD_RTID = Global_recordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract_Dummy'); 
        Id CNLG_RTID = Global_recordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract'); 
        Id CNLGA_RTID = Global_recordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract_Approved'); 
        Id CNLGFin_RTID = Global_recordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract_Final'); 
        List<String> tempConNumList = new List<String>();
        //MAp(POid, Listofcontractno.)
        //Howard @introv 20200505
		List<String> contractNumberList = new List<String>();
        for(ASI_MFM_PO__c newpo :trigger_new) {
            if(newpo.ASI_MFM_PO_Type__c == 'Gift material'
              && CN_RTID_LIST.contains(newpo.RecordTypeId) )
            {
                if(newpo.ASI_MFM_Contract_Number__c != '' && newpo.ASI_MFM_Contract_Number__c != null) {
                    tempConNumList = newpo.ASI_MFM_Contract_Number__c.split(';');
                    contractNumberList.addall(tempConNumList);
                    POtoConNumList.put(newpo.id, tempConNumList);
                }
                else {newpo.ASI_MFM_Contract_Number__c.addError('Contract Number missing.');}
            }
        }
        if(contractNumberList.size() == 0) return;
        Set<String> existingContract = new Set<String>();
        for(ASI_TH_CRM_Contract__c contract :[
            SELECT id, ASI_CRM_CN_PO_No__c FROM ASI_TH_CRM_Contract__c
            WHERE ASI_CRM_CN_PO_No__c IN :contractNumberList
            AND (RecordTypeId = :CNC_RTID OR RecordTypeId = :CNCD_RTID OR RecordTypeId = :CNLG_RTID OR RecordTypeId = :CNLGA_RTID OR RecordTypeId = :CNLGFin_RTID)])
        {
            existingContract.add(contract.ASI_CRM_CN_PO_No__c);
        }
        for(ASI_MFM_PO__c newpo :trigger_new) {
            if(newpo.ASI_MFM_PO_Type__c != 'Gift material'){ 
            	system.debug('newpo.ASI_MFM_PO_Type__c'+newpo.ASI_MFM_PO_Type__c);    
                continue; 
            }  
            if(!CN_RTID_LIST.contains(newpo.RecordTypeId)){ continue; }
            if(newpo.ASI_MFM_Contract_Number__c != '' && !existingContract.containsall(POtoConNumList.get(newpo.id))) {
                newpo.ASI_MFM_Contract_Number__c.addError('Contract Number not exist.');
            }else
                system.debug('no error');
        }
    }
    //20191025:AM@Introv - bypass budget owner validation
    private static boolean CheckByPassBudgetOwnerValidation(Id idCheckUser) {
        boolean bByPass = false;
        
        if (G_MEMBER_IN_HR_ADMIN_GRP.size() > 0) {
            for(GroupMember oMember : G_MEMBER_IN_HR_ADMIN_GRP) {
                if (oMember.UserorGroupId == idCheckUser) {
                    bByPass = true;
                    break;
                }
            }
        }
        
        return bByPass;
    }
    
    //20161116 Elufa
    
    Public Static Void BudgetOwnerValidationCheck(Set<Id> planSetID, Map<Id, List<ASI_MFM_PO__c>> planPOMap, Map<id, ASI_MFM_PO__c> triggerOldMap){
        System.debug(LoggingLevel.INFO, '*** BudgetOwnerValidationCheck: ');
        
        Map<Id, Set<Id>> mapTeamMember = new Map<Id, Set<Id>>();//20161114 Elufa
        List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>();
        if (!planSetID.isEmpty()) {
            // if (ISVALIDATION) return;
            // ISVALIDATION = true;
            planList = new List<ASI_MFM_Plan__c>([SELECT id, ASI_MFM_Project_Team__c, ASI_MFM_Marketing_Category__c FROM ASI_MFM_Plan__c WHERE ID IN : planSetID]);
        }
        
        for(ASI_MFM_Team_Member__c obj : teamMemberList){//20170112 Elufa changed to teamMemberList
            
            Set<Id> tmpSet = new Set<Id>();
            
            if(mapTeamMember.containsKey(obj.ASI_MFM_Team__c)){
                tmpSet = mapTeamMember.get(obj.ASI_MFM_Team__c);
            }
            
            tmpSet.add(obj.ASI_MFM_Team_Member__c);
            
            mapTeamMember.put(obj.ASI_MFM_Team__c, tmpSet);
        }
        
        for(ASI_MFM_Plan__c p : planList){
            if(planPOMap.containsKey(p.id)){
                for(ASI_MFM_PO__c po : planPOMap.get(p.id)){
                    
                    //20170627 
                    if((triggerOldMap == Null || (triggerOldMap.containsKey(po.id) && triggerOldMap.get(po.id).ASI_MFM_PO_PP_Category__c != po.ASI_MFM_PO_PP_Category__c) ) && po.ASI_MFM_PO_PP_Category__c != Null && mapPPCatgeory.containsKey(po.ASI_MFM_PO_PP_Category__c)){
                        if(p.ASI_MFM_Marketing_Category__c != mapPPCatgeory.get(po.ASI_MFM_PO_PP_Category__c).ASI_MFM_Marketing_Category__c){
                            po.ASI_MFM_PO_PP_Category__c.addError('PO Category does NOT match with Plan Marketing Category, please select correct PO Category.');
                            Break;
                        }
                    }
                    
                    //20191025:AM@Introv - bypass budget owner validation
                    if (CheckByPassBudgetOwnerValidation(po.OwnerId))
                        continue;
                    
                    user POOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(po.OwnerId);
                    user POBudgetOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(po.ASI_MFM_Budget_Owner__c);
                    
                    if(POOwner != NULL && POBudgetOwner != NULL && POOwner.ASI_MFM_Team__c != POBudgetOwner.ASI_MFM_Team__c && POOwner.ASI_MFM_Team__c != '' && POBudgetOwner.ASI_MFM_Team__c != ''){
                        
                        if(mapTeamMember.containsKey(p.ASI_MFM_Project_Team__c)){
                            if(!mapTeamMember.get(p.ASI_MFM_Project_Team__c).contains(po.OwnerId) || !mapTeamMember.get(p.ASI_MFM_Project_Team__c).contains(po.ASI_MFM_Budget_Owner__c)){
                                po.ASI_MFM_Budget_Owner__c.addError('You are NOT allowed to created PO for budget owner not in your team');
                                Break;
                            }
                        }else{
                            po.ASI_MFM_Budget_Owner__c.addError('You are NOT allowed to created PO for budget owner not in your team');
                            Break;
                        }
                    }
                }
            }
        }
    }
    
    //20161116 End
    
    public static void UpdateExRate(list <ASI_MFM_PO__c > trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
    /* 2014-02-13 
        Added by Stella Sing 
        Goal: Update (ASI_MFM_Exchange_Rate_BUCode__c) from Exchange Rate Table, according to BU Code specified country rate.
       2014-03-03
        Added by Stella Sing
        Use BU Code defined Base Currency for Exchange Rate. 
        2014-04-24
        Added by Stella Sing
        Update Exchange Rate only happens when Currency Changed.
        */
        Decimal strExRate;
        string strCountry;
        string strBUBCurrency;
        string strCCurrency;
        string strBCurrency;
        string strExCCurrency;
        Date strEffDate;
        ID BUCodeId;
        
        //List <ASI_MFM_Exchange_Rate__c> ExRateList = [SELECT ASI_MFM_Exchange_Rate__c, ASI_MFM_Effective_Date__c FROM ASI_MFM_Exchange_Rate__c WHERE ASI_MFM_Country__c =:strCountry AND ASI_MFM_Base_Currency__c =:strBUBCurrency AND ASI_MFM_Counter_Currency__c = :strCCurrency AND ASI_MFM_Effective_Date__c <= :strEffDate];
        //List <ASI_MFM_Exchange_Rate__c> ExRateList = [SELECT id, ASI_MFM_Exchange_Rate__c, ASI_MFM_Effective_Date__c, ASI_MFM_Country__c, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c FROM ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' AND ASI_MFM_Country__c = 'CN'];//20170112 Elufa changed as static variable
        //List <ASI_MFM_BU__c> BUCodeList = [SELECT id, ASI_MFM_CN_Country__c, ASI_MFM_Base_Currency__c FROM ASI_MFM_BU__c];//20170112 Elufa Commented reuse BU_List
		List <ASI_MFM_BU__c> BUCodeList = BU_List;//20170112 Elufa
        
        for (ASI_MFM_PO__c a : trigger_new){
            BUCodeId = a.ASI_MFM_BU_Code__c;
            strCCurrency = a.ASI_MFM_Currency__c;
            strBCurrency = a.ASI_MFM_Sys_Local_Currency__c;
            strEffDate = a.ASI_MFM_PO_Raised_Date__c;
            System.debug('BUCodeId: ' + String.valueOf(BUCodeId) + ', strCCurrency: ' + strCCurrency + ', strBCurrency: ' + strBCurrency);
            
            //If Currency is changed
            if (trigger_oldMap == null || strCCurrency != trigger_oldMap.get(a.id).ASI_MFM_Currency__c){
                system.debug('Do Exchange!');
                
                for (ASI_MFM_BU__c b : BUCodeList){
                        if (b.id == BUCodeId ){
                            strCountry = b.ASI_MFM_CN_Country__c;
                            strBUBCurrency = b.ASI_MFM_Base_Currency__c ;
                        }
                    }
                
                if (strCCurrency != strBUBCurrency && strCCurrency != null ){
                    system.debug('Different currency');
                    //BUCodeList = [SELECT ASI_MFM_CN_Country__c, ASI_MFM_Base_Currency__c FROM ASI_MFM_BU__c WHERE id = :BUCodeId];
                    
                    //ExRateList = [SELECT ASI_MFM_Exchange_Rate__c, ASI_MFM_Effective_Date__c FROM ASI_MFM_Exchange_Rate__c WHERE ASI_MFM_Country__c =:strCountry AND ASI_MFM_Base_Currency__c =:strBUBCurrency AND ASI_MFM_Counter_Currency__c = :strCCurrency AND ASI_MFM_Effective_Date__c <= :strEffDate];
                    for (ASI_MFM_Exchange_Rate__c c : ExRateList){
                        if (c.ASI_MFM_Country__c ==strCountry && c.ASI_MFM_Base_Currency__c == strBUBCurrency && c.ASI_MFM_Counter_Currency__c == strCCurrency && c.ASI_MFM_Effective_Date__c <= strEffDate){
                            strExRate = c.ASI_MFM_Exchange_Rate__c;
                            break;//20180416 Introv, break if fx rate is found
                        }
                    }
                    
                    if (strExRate != Null){ //20180530 Introv
                        a.ASI_MFM_Exchange_Rate_BUCode__c = strExRate;
                    }else{
                        a.ASI_MFM_Exchange_Rate_BUCode__c = null;
                        system.debug('Exchange Rate reference not found.');
                    }
                }else{ 
                    a.ASI_MFM_Exchange_Rate_BUCode__c = 1;
                    a.ASI_MFM_Exchange_Rate__c = 1;
                }
                if (strExRate != null){
                    a.ASI_MFM_CN_Amount_Ex__c = a.ASI_MFM_PO_Amount__c * strExRate;
                }else{
                    a.ASI_MFM_CN_Amount_Ex__c = a.ASI_MFM_PO_Amount__c;
                }

                // 2014-10-16, Axel@introv, Fix to renew exchange rate on changing currency code
                /*for (ASI_MFM_Exchange_Rate__c c : ExRateList){
                    if (c.ASI_MFM_Country__c ==strCountry && c.ASI_MFM_Base_Currency__c == strBUBCurrency && c.ASI_MFM_Counter_Currency__c == strCCurrency)
                        strExRate = c.ASI_MFM_Exchange_Rate__c;
                }*/ // 20180416 Introv Commented
                
                if(strExRate != Null)//20180530 Introv
                    a.ASI_MFM_Exchange_Rate__c = strExRate;
                // 2014-10-16 ***End***
                
            }//End DoExchange
        }
    }
    
    public static void setApprovers(ASI_MFM_PO__c p, set<string> STeam, Map<id, ASI_MFM_Dynamic_Approval_Route__c> MAppRoute, Map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFix, Map<id, User> MUser, Map<Id, ASI_MFM_PO_Line_Item__c> mapPOLine){
        integer approver_count = 0;
        boolean proceed = true;
        id currentUserid = p.ASI_MFM_Budget_Owner_Manager__c;
        
        ASI_MFM_Dynamic_Approval_Route__c currentApprover = null;
        User userCurrentApprover = null;
        
        //Dynamic Route 
        //Updated by Twinkle - Dynamic Route -> Managers        
        while(proceed){
            if(currentUserid != null && (MAppRoute.containsKey(currentUserid) || MUser.containsKey(currentUserid))){
                if(MAppRoute.get(currentUserid) != null){
                    currentApprover = MAppRoute.get(currentUserid);
                    currentUserid = currentApprover.ASI_MFM_Manager_ID__c;
                }
                else{
                    if(MUser.get(currentUserid) != null){
                        userCurrentApprover = MUser.get(currentUserid);
                        currentUserid = userCurrentApprover.ManagerID;
                    }
                }
                
                if(currentApprover != null && userCurrentApprover == null){                            
                    setApproverByCount(p, approver_count, currentApprover.ASI_MFM_User__c);
                }
                else if(currentApprover == null && userCurrentApprover != null){
                    setApproverByCount(p, approver_count, userCurrentApprover.id);
                }
                
                approver_count++;
                if(currentApprover != null && ((currentApprover.ASI_MFM_Approval_Limit__c != 0 && currentApprover.ASI_MFM_Approval_Limit__c >= p.ASI_MFM_CN_PO_Amount_RMB__c) || currentApprover.ASI_MFM_End_of_1st_Route__c)){
                    proceed = false;                                
                }
                currentApprover = null;
                userCurrentApprover = null;
            }
            else{
                proceed = false;
            }
        }
        
        //Fix Route
        //ASI_MFM_Fix_Approval_Route__c fixApprover = MAppRouteFix.get(p.ASI_MFM_Budget_Owner_Team__c); //20170418, Elufa
		ASI_MFM_Fix_Approval_Route__c fixApprover = MAppRouteFix.get(p.ASI_MFM_PO_Type__c+p.ASI_MFM_Budget_Owner_Team__c+'PO'); //20170418, Elufa
        if(fixApprover != null){
            if(fixApprover.ASI_MFM_Finance__c != null){
                p.ASI_MFM_CN_Finance__c = fixApprover.ASI_MFM_Finance__c;                           
                setApproverByCount(p, approver_count, fixApprover.ASI_MFM_Finance__c);
                approver_count++;
                system.debug(p.ASI_MFM_CN_Finance__c);
            }
            if(fixApprover.ASI_MFM_Approval_Limit_Finance__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/ || p.ASI_MFM_Is_Retainer_Agency__c){
                p.ASI_MFM_CN_Return_Approver1__c = fixApprover.ASI_MFM_BA__c;
                
                setApproverByCount(p, approver_count, fixApprover.ASI_MFM_BA__c);
                approver_count++;
                if(fixApprover.ASI_MFM_Approval_Limit_BA__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/){
                    //20160718 Ben @ Elufa skip Brand Director if Brand Director limit is NULL
                    if(mapPOLine.containsKey(p.id) && mapPOLine.get(p.id).ASI_MFM_Sub_brand_Code__c != NULL && mapPOLine.get(p.id).ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Director__c != NULL && fixApprover.ASI_MFM_Approval_Limit_BD__c != NULL){
                        p.ASI_MFM_CN_Return_Approver2__c = mapPOLine.get(p.id).ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Director__c;
                        
                        setApproverByCount(p, approver_count, mapPOLine.get(p.id).ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Director__c);
                        approver_count++;
                    }
                    //20160718 End
                    
                    if(fixApprover.ASI_MFM_Approval_Limit_BD__c == NULL || fixApprover.ASI_MFM_Approval_Limit_BD__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/){//20160729 Ben @ Elufa
                        if(p.ASI_MFM_CN_Return_Approver2__c == NULL){
                        	p.ASI_MFM_CN_Return_Approver2__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                        }else{
                            p.ASI_MFM_CN_Return_Approver3__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                        }
                        
                        setApproverByCount(p, approver_count, fixApprover.ASI_MFM_Corporate_Approver_1__c);
                        approver_count++;
                        if(fixApprover.ASI_MFM_Approval_Limit_CA1__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/){
                            if(p.ASI_MFM_CN_Return_Approver3__c == NULL){
                            	p.ASI_MFM_CN_Return_Approver3__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                            }else{
                                p.ASI_MFM_CN_Return_Approver4__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                            }
                            
                            setApproverByCount(p, approver_count, fixApprover.ASI_MFM_Corporate_Approver_2__c);
                            approver_count++;
                            
                            /**** added by Twinkle - 2014/08/20  Expand Fix approvers from 4 to 6 ****/
                            if(fixApprover.ASI_MFM_Approval_Limit_CA2__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/){
                                system.debug(fixApprover.ASI_MFM_Approval_Limit_CA2__c+'<='+p.ASI_MFM_CN_PO_Amount_RMB__c);
                                if(p.ASI_MFM_CN_Return_Approver4__c == NULL){
                                	p.ASI_MFM_CN_Return_Approver4__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;  
                                }else{
                                    p.ASI_MFM_CN_Return_Approver5__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;  
                                }
                                setApproverByCount(p, approver_count, fixApprover.ASI_MFM_Corporate_Approver_3__c);
                                approver_count++;
                                
                                if(fixApprover.ASI_MFM_Approval_Limit_CA3__c <= p.ASI_MFM_CN_PO_Amount_RMB__c/*ASI_MFM_PO_Amount__c*/){
                                    system.debug(fixApprover.ASI_MFM_Approval_Limit_CA3__c+'<='+p.ASI_MFM_CN_PO_Amount_RMB__c);
                                    if(p.ASI_MFM_CN_Return_Approver5__c == NULL){
                                    	p.ASI_MFM_CN_Return_Approver5__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                    }else{
                                        p.ASI_MFM_CN_Return_Approver6__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                    }
                                    setApproverByCount(p, approver_count, fixApprover.ASI_MFM_Corporate_Approver_4__c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void setApproverToNull(ASI_MFM_PO__c p)
    {   
        p.ASI_MFM_Sys_Approver_1__c = null;
        p.ASI_MFM_Sys_Approver_2__c = null;
        p.ASI_MFM_Sys_Approver_3__c = null;
        p.ASI_MFM_Sys_Approver_4__c = null;
        p.ASI_MFM_Sys_Approver_5__c = null;
        p.ASI_MFM_Sys_Approver_6__c = null; 
        p.ASI_MFM_Sys_Approver_7__c = null;
        p.ASI_MFM_Sys_Approver_8__c = null;
        p.ASI_MFM_Sys_Approver_9__c = null;
        p.ASI_MFM_Sys_Approver_10__c = null;
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver1__c = null;
        p.ASI_MFM_CN_Return_Approver2__c = null;
        p.ASI_MFM_CN_Return_Approver3__c = null; 
        p.ASI_MFM_CN_Return_Approver4__c = null; 
        p.ASI_MFM_CN_Return_Approver5__c = null;
        p.ASI_MFM_CN_Return_Approver6__c = null;//20160729 Ben @ Elufa
    }
    
    public static void setApproverByCount(ASI_MFM_PO__c p, integer approver_count, Id userId)
    {
        if(approver_count == 0){
            p.ASI_MFM_Sys_Approver_1__c = userId;
        }
        else if(approver_count == 1){
            p.ASI_MFM_Sys_Approver_2__c = userId;
        }
        else if(approver_count == 2){
            p.ASI_MFM_Sys_Approver_3__c = userId;
        }
        else if(approver_count == 3){
            p.ASI_MFM_Sys_Approver_4__c = userId;
        }
        else if(approver_count == 4){
            p.ASI_MFM_Sys_Approver_5__c = userId;
        }
        else if(approver_count == 5){
            p.ASI_MFM_Sys_Approver_6__c = userId;
        }
        else if(approver_count == 6){
            p.ASI_MFM_Sys_Approver_7__c = userId;
        }
        else if(approver_count == 7){
            p.ASI_MFM_Sys_Approver_8__c = userId;
        }
        else if(approver_count == 8){
            p.ASI_MFM_Sys_Approver_9__c = userId;
        }
        else if(approver_count == 9){
            p.ASI_MFM_Sys_Approver_10__c = userId;
        }
    }
    
    public static void SetBULookupValue(list <ASI_MFM_PO__c > trigger_new) {
        /***** added by leo - 2014/06/16 *****/
        //List<ASI_MFM_BU__c> BU_List = [Select id, Name from ASI_MFM_BU__c];//20170112 Elufa changed to static variable

        for (ASI_MFM_PO__c po : trigger_new) {
            if(po.ASI_MFM_CN_BU_Picklist__c != null)
            {
                string tmpStrBU = po.ASI_MFM_CN_BU_Picklist__c;
                if(BU_List != null && BU_List.size()>0){
                    for (ASI_MFM_BU__c bu : BU_List)
                    {
                        if(bu.Name == tmpStrBU){
                            po.ASI_MFM_BU_Code__c = bu.id;
                            po.ASI_MFM_Auto_Receipt__c = bu.ASI_MFM_Auto_Receipt__c;//20180712 Introv
                        }
                    }
                }
            }
            else
            {
                po.ASI_MFM_BU_Code__c = null;
            }
            
            //20191128:AM@introv - filter PO type for Auto Receipt field
            if (po.ASI_MFM_PO_Type__c != NULL) {
                String sPOType = po.ASI_MFM_PO_Type__c.toUpperCase();
                if (sPOType=='EMARKET' || sPOType=='IT OPEX' || sPOType=='IT CAPEX HARDWARE REGION' || sPOType=='IT CAPEX HARDWARE HQ' || sPOType=='IT CAPEX SOFTWARE' || sPOType=='IT CAPEX RENOVATION')
                    po.ASI_MFM_Auto_Receipt__c = FALSE;
            }
        }
    }
    
    /**** added by Twinkle - 2014/08/19   
    Update PO Amount in Consumer A&P PO(ASI_FOC_PO__c) ****/
    public static void routineAfterUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // if (ISVALIDATION3) return;
        // ISVALIDATION3 = true;
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_CN_PO_TriggerClass')){//20161223 Elufa Added bypass
            // 2014-10-30       Axel@introv     #95, to fix the Plan's "Total PO Amount", to replicate logic from ASI_MFM_PO_Trigger's routineAfterUpdate
            map<id, decimal> xrate_map = new map<id, decimal>();
            for (ASI_MFM_PO__c p : trigger_new) { 
                if (p.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(p.id).ASI_MFM_Exchange_Rate__c) {
                    System.debug('ASI_MFM_CN_PO_TriggerClass:routineAfterUpdate: Exchange Rate Changed');
                    xrate_map.put(p.id, p.ASI_MFM_Exchange_Rate__c);
                }
            } 
            if (xrate_map.size() > 0) {
                list<ASI_MFM_PO_Line_Item__c> pol_list = [select ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :xrate_map.keySet() for update]; 
                for (ASI_MFM_PO_Line_Item__c pol : pol_list) {
                    pol.ASI_MFM_Exchange_Rate__c = xrate_map.get(pol.ASI_MFM_PO__c);
                }
                System.debug('ASI_MFM_CN_PO_TriggerClass:routineAfterUpdate: Update PO Line Exchange Rate');
                update pol_list;
            }
            // End
            
            Set<id> STempID1 = new Set<id>();
            Set<id> STempID2 = new Set<id>();
            Map<String,Decimal> MPOAmt = new Map<String,Decimal>();
            
            /*List<ASI_MFM_PO__c> LPO = [Select ASI_MFM_CN_Consumer_A_P_PO__c from ASI_MFM_PO__c WHERE ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c = '61202305'];
Set<id> SPOID = new set<id>();
for(ASI_MFM_PO__c a : LPO){
SPOID.add(a.ASI_MFM_CN_Consumer_A_P_PO__c);
}        
List<ASI_MFM_PO__c> LFreeGoodsPO = [Select id from ASI_MFM_PO__c WHERE id IN: LPO];
*/
            
            for (ASI_MFM_PO__c p:trigger_new) {
                if (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final' && (p.ASI_MFM_Status__c == 'Draft' || p.ASI_MFM_Status__c == 'Submitted') && p.ASI_MFM_CN_Consumer_A_P_PO__c != null) {
                    STempID1.add(p.ASI_MFM_CN_Consumer_A_P_PO__c);
                    system.debug('1');
                }
                if (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_CN_Consumer_A_P_PO__c != null) {
                    STempID2.add(p.ASI_MFM_CN_Consumer_A_P_PO__c);
                    MPOAmt.put(p.ASI_MFM_CN_Consumer_A_P_PO__c,p.ASI_MFM_PO_Amount__c);
                    system.debug('2');
                }
            }
            if (!STempID1.isEmpty() || !STempID2.isEmpty()) {
                List<ASI_FOC_PO__c> LFOC = [SELECT id, ASI_FOC_PO_Final_Amount__c FROM ASI_FOC_PO__c WHERE (id IN: STempID1) OR (id IN: STempID2)];
                for(ASI_FOC_PO__c f : LFOC){
                    if(STempID1.Contains(f.id)){
                        f.ASI_FOC_PO_Final_Amount__c = 0;
                    }
                    if(STempID2.Contains(f.id)){
                        f.ASI_FOC_PO_Final_Amount__c = MPOAmt.get(f.id);
                    }
                }
                update LFOC;
            }
            
            
        }
        
        //AM 20190822: assign Budget Owner from PO to POSM lines
        //AM 20181219: assign supplier email from PO to POSM lines
        assignPOSMLineDetails(trigger_new, trigger_oldMap);
    }
    
    //AM 20181219: assign supplier email from PO to POSM lines - start
    private static void assignPOSMLineDetails(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        Set<Id> setPO = new Set<Id>();
        Map<Id, String> mapPO = new Map<Id, String>();
        Map<Id, Id> mapBudgetOwner = new Map<Id, Id>();
        for (ASI_MFM_PO__c p : trigger_new) {
            if (p.ASI_MFM_PO_Type__c == 'eMarket') continue;
            setPO.add(p.Id);
            mapPO.put(p.Id, p.ASI_MFM_Supplier_Email__c);
            mapBudgetOwner.put(p.Id, p.ASI_MFM_Budget_Owner__c);
        }
        
        if (setPO.isEmpty()) return;
		List<ASI_MFM_PO_POSM_Line__c> pol_list = [select ASI_MFM_PO__c,ASI_MFM_Supplier_Email__c,ASI_MFM_Budget_Owner__c from ASI_MFM_PO_POSM_Line__c where ASI_MFM_PO__c in :setPO for update];
        for (ASI_MFM_PO_POSM_Line__c pol : pol_list) {
            pol.ASI_MFM_Supplier_Email__c = mapPO.get(pol.ASI_MFM_PO__c);
            pol.ASI_MFM_Budget_Owner__c = mapBudgetOwner.get(pol.ASI_MFM_PO__c);
        }
        update pol_list;
    }
    //AM 20181219: assign supplier email from PO to POSM lines - end
    
    /**** added by Twinkle - 2014/08/19   
    Update Consumer A&P PO Amount to 0 if PO is deleted****/
    public static void routineAfterDelete(list<ASI_MFM_PO__c> trigger_oldMap) {
         
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_CN_PO_TriggerClass')){//20161223 Elufa Added bypass
            Set<id> STempID = new Set<id>();
            for(ASI_MFM_PO__c p : trigger_oldMap){              
                STempID.add(p.id);
            }
            List<ASI_FOC_PO__c> LFOC = [SELECT id, ASI_FOC_PO_Final_Amount__c FROM ASI_FOC_PO__c WHERE id IN: STempID];
            
            for(ASI_FOC_PO__c f : LFOC){
                f.ASI_FOC_PO_Final_Amount__c = 0;
            }
        }
    }
    
    // 2014-10-30       Axel@introv     #95, to fix the Plan's "Total PO Amount", to replicate logic from ASI_MFM_PO_Trigger's routineAfterAll
    public static void routineAfterAll (list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        
        if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_CN_PO_TriggerClass')){//20161223 Elufa Added bypass
            
            // Update Total PO Amount in Plan object        
            set<id> pid_set = new set<id>();
            
            //20161107 Elufa
            Map<Id, Set<Id>> mapPlan = new Map<Id, Set<Id>>();
            
            if (trigger_new != null) {
                for (ASI_MFM_PO__c po:trigger_new) {
                    pid_set.add(po.ASI_MFM_Plan__c);
                    
                    //20161107 Elufa
                    Set<Id> tmpPOId = new Set<Id>();
                    
                    if(mapPlan.containsKey(po.ASI_MFM_Plan__c))
                        tmpPOId = mapPlan.get(po.ASI_MFM_Plan__c);
                    
                    tmpPOId.add(po.id);
                    mapPlan.put(po.ASI_MFM_Plan__c, tmpPOId);
                    //20161107 End
                }
            }
            /*else*/ if (trigger_oldMap != null) {//20151231 Ben @ Elufa Systems remove else
                for (ASI_MFM_PO__c po:trigger_oldMap.values()) {
                    pid_set.add(po.ASI_MFM_Plan__c);
                }           
            }
            if (pid_set.size() > 0) {
                list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Currency__c, (select ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c from POs__r) from ASI_MFM_Plan__c where id in :pid_set for update];
                for (ASI_MFM_Plan__c p:p_list) {
                    p.ASI_MFM_Total_PO_Amount__c = 0;
                    for (ASI_MFM_PO__c po:p.POs__r) {
                        if (po.ASI_MFM_Exchange_Rate__c > 0) {
                            p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);
                        }
                    }
                }
                update p_list;
                
                //20161107 Elufa
                if(Counting == 0){
                    List<ASI_MFM_PO__Share> poExistingSharingList = new List<ASI_MFM_PO__Share>([SELECT Id, RowCause, UserOrGroupId, ParentID FROM ASI_MFM_PO__Share WHERE RowCause = : Schema.ASI_MFM_PO__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c AND ParentID IN : trigger_new]);
                    if(poExistingSharingList.size() > 0)
                        Delete poExistingSharingList;
                    
                    List<ASI_MFM_PO__Share> POSharingList= new List<ASI_MFM_PO__Share>();
                    List<ASI_MFM_Plan__Share> PlanSharingList= new List<ASI_MFM_Plan__Share>([SELECT Id, AccessLevel, RowCause, UserOrGroupId, ParentID FROM ASI_MFM_Plan__Share WHERE RowCause = : Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c AND ParentID IN : pid_set]);
                    
                    for(ASI_MFM_Plan__Share obj : PlanSharingList){
                        if(mapPlan.containsKey(obj.ParentID)){
                            for(Id POId : mapPlan.get(obj.ParentID)){
                                POSharingList.add(new ASI_MFM_PO__Share(RowCause = Schema.ASI_MFM_PO__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c
                                                                        , AccessLevel = obj.AccessLevel
                                                                        , ParentID = POId
                                                                        , UserOrGroupId = obj.UserOrGroupId
                                                                       ));
                            }
                        }
                    }
                    if(POSharingList.size() > 0)
                    	Insert POSharingList;
                    Counting++;
                    //20161107 End
                }
            }
        }
    }
}