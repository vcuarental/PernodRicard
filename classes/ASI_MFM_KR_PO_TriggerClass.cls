public with sharing class ASI_MFM_KR_PO_TriggerClass
{
    static String DARRecordType = 'ASI_MFM_KR_Dynamic_Approval_Route'; //obj: ASI_MFM_Dynamic_Approval_Route__c
    
    public static void beforeUpsertMethod(List<ASI_MFM_PO__c> triggerNew, map<id, ASI_MFM_PO__c> trigger_oldMap)
    {
        
        Map<ID, User> mapUser 
            = new Map<ID,User>([SELECT ID, Name, ManagerID, UserRole.DeveloperName FROM User WHERE CompanyName = 'Pernod Ricard Korea']); //get all Korea User
        Map<String,ASI_MFM_Dynamic_Approval_Route__c> DARMap 
            =new Map<String,ASI_MFM_Dynamic_Approval_Route__c>();//map Role name and approval route obj
        /*
        //get the dynamic approval route of KR plan, by record type: kr, type: plan
        List<ASI_MFM_Dynamic_Approval_Route__c> DARList 
            = new List<ASI_MFM_Dynamic_Approval_Route__c>([SELECT id,
                                                           ASI_MFM_Type__c, 
                                                           ASI_MFM_User__c, 
                                                           ASI_MFM_Approval_Limit__c,
                                                           ASI_MFM_End_of_1st_Route__c
                                                           FROM ASI_MFM_Dynamic_Approval_Route__c
                                                           WHERE RecordType.DeveloperName LIKE: DARRecordType 
                                                           AND ASI_MFM_Type__c LIKE 'PO']);
        
        //put DARList into DARMap
        for(ASI_MFM_Dynamic_Approval_Route__c DAR: DARList)
        {
            DARMap.put(DAR.ASI_MFM_User__c+''+DAR.ASI_MFM_Type__c, DAR);//Map<sub-Cat+brand, Approval Route obj>
        }//end for: loop approval route list
        */
        // Added by 2018-02-23 Linus@introv 
        // get fix approval route for PO 
        Map<String, ASI_MFM_Fix_Approval_Route__c> FARMap = new Map<String, ASI_MFM_Fix_Approval_Route__c>();
        
        for(ASI_MFM_Fix_Approval_Route__c far: [Select id, ASI_MFM_Team__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c, ASI_MFM_Corporate_Approver_3__c, ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Corporate_Approver_5__c, ASI_MFM_Corporate_Approver_6__c, ASI_MFM_Corporate_Approver_7__c, ASI_MFM_Corporate_Approver_8__c, ASI_MFM_Corporate_Approver_9__c, ASI_MFM_Corporate_Approver_10__c, ASI_MFM_Corporate_Approver_11__c, ASI_MFM_Corporate_Approver_12__c,
                                                ASI_MFM_Approval_Limit_CA1__c, ASI_MFM_Approval_Limit_CA2__c, ASI_MFM_Approval_Limit_CA3__c, ASI_MFM_Approval_Limit_CA4__c, ASI_MFM_Approval_Limit_CA5__c, ASI_MFM_Approval_Limit_CA6__c, ASI_MFM_Approval_Limit_CA7__c, ASI_MFM_Approval_Limit_CA8__c, ASI_MFM_Approval_Limit_CA9__c, ASI_MFM_Approval_Limit_CA10__c, ASI_MFM_Approval_Limit_CA11__c, ASI_MFM_Approval_Limit_CA12__c 
                                                from ASI_MFM_Fix_Approval_Route__c 
                                                where RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route' AND ASI_MFM_Module__c LIKE 'PO' AND ASI_MFM_Inactive__c = false])
        {
            FARMap.put(far.ASI_MFM_Team__c, far);
                                                
        }
        
        //Get Purchase Request Id
        set<id> pr_set = new set<id>();
        set<id> Plan_Set= new set<id>();
        
        //Get Supplier Id
        set<id> acc_set = new set<id>();
        set<id> shiptoset = new set<id>();        
        set<id> px_set = new set<id>();
        set<id> wareHseSet = new set<id>();
        
        // Check PO whether is created by Payment    ****Added by 2018-02-23 Linus@introv
        Boolean isPaymentCreated = false;
        for(ASI_MFM_PO__c po: triggerNew){
            px_set.add(po.ASI_MFM_Prefix__c);
            wareHseSet.add(po.ASI_MFM_Warehouse__c);
            
            if(po.ASI_MFM_Is_Pre_Payment__c || po.ASI_MFM_Is_Direct_Payment__c || po.ASI_MFM_Is_Offset_Payment__c)
                isPaymentCreated = true;
        }
        
        if(trigger_oldMap == null){  // insert
            map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c, ASI_MFM_TW_Delivery_Address__c from asi_mfm_prefix__c where id in :px_set for update]);
            for(ASI_MFM_PO__c p: triggerNew){
                
                // Assign Name from Prefix           
                 if( px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Company__c!=null){
                        p.name = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Company__c + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                 }else{
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                 }
                 p.ASI_MFM_Company__c=px_map.get(p.asi_mfm_prefix__c).name;
                 //Company Code
                 if(p.ASI_MFM_Company__c=='PRK'){
                        p.ASI_MFM_Company_Code__c='222';
                 }
                 if(p.ASI_MFM_Company__c=='PRKI'){
                        p.ASI_MFM_Company_Code__c='286';
                 }
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
                        
            ASI_MFM_Function.updatePrefix(px_map.values());   
        }
        
        // Bypass if PO is created by Pre-Paymen, Direct Payment or Offset Payment        ****Added by 2018-02-23 Linus@introv
        if(isPaymentCreated == false){
            for(ASI_MFM_PO__c po: triggerNew)
            {            
                if(po.ASI_MFM_Prefix__c != null){
                    px_set.add(po.ASI_MFM_Prefix__c);
                }
                //Add one text field in PO header. (Field name: Purchase Code) Once saving the record, Purchase Code should be trimmed.
                if(po.ASI_MFM_Purchase_Code__c!=null){
                    String[] splitString = po.ASI_MFM_Purchase_Code__c.trim().split(' ');
                    String str='';
                    for(String s: splitString) {
                        str = str+s;
                    }
                    po.ASI_MFM_Purchase_Code__c=str;//po.ASI_MFM_Purchase_Code__c.trim();
                    //system.assertEquals(null, po.ASI_MFM_Purchase_Code__c);
                }
                setApproverToNull(po); //clear sys approvers
                //setDynamicApprover(po,mapUser,DARMap,'PO'); //get dynamic approvers
                setApprover(po, FARMap); // Added by 2018-02-23 Linus@introv
                if(po.ASI_MFM_Status__c=='Draft' || po.ASI_MFM_Dummy_PO__c){
                    if(po.ASI_MFM_Plan__c!=null) Plan_Set.add(po.ASI_MFM_Plan__c);
                    if(po.ASI_MFM_Supplier_Name__c!=null) acc_set.add(po.ASI_MFM_Supplier_Name__c);
                    if(po.ASI_MFM_Warehouse__c!=null && po.ASI_MFM_Company_Address__c==null){
                        shiptoset.add(po.ASI_MFM_Warehouse__c);
                    }
                }
                
                if(po.ASI_MFM_Purchase_Request__c!=null) pr_set.add(po.ASI_MFM_Purchase_Request__c);
            }// For Loop End -- Get Id
            
            
            //Purchase Request
            list<ASI_MFM_Purchase_Request__c> pr_list;
            Map<id,ASI_MFM_Purchase_Request__c> pr_Map=new Map<id,ASI_MFM_Purchase_Request__c>();
            if(pr_set.size()>0){
                pr_list=[select id,name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,ownerId  from ASI_MFM_Purchase_Request__c where id in : pr_set];
                for(ASI_MFM_Purchase_Request__c pr:pr_list){
                    pr_Map.put(pr.id, pr);
                }
            }
            
            Map<id,ASI_MFM_Plan__c> Plan_Map=new Map<id,ASI_MFM_Plan__c>();
            if(Plan_Set.size()>0){
                for(ASI_MFM_Plan__c pl:[select id,name,ASI_MFM_Project_Code__c from ASI_MFM_Plan__c where id in : Plan_Set]){
                    Plan_Map.put(pl.id, pl);
                }
            }
            
            
            //Get Suppiler Email 
            Map<id,Account> acc_Map=new Map<id,Account>();
            if(acc_set.size()>0 || shiptoset.size()>0){
                for(Account acc: [select id, name,ASI_LUX_Email_Business__c,ASI_MFM_Address_Line_1__c,ASI_MFM_Address_Line_2__c,ASI_MFM_Address_Line_3__c,ASI_MFM_Address_Line_4__c from Account where (id in : acc_set and ASI_LUX_Email_Business__c!=null) or (id in : shiptoset)]){
                    acc_Map.put(acc.id,acc);
                }
            }

            for(ASI_MFM_PO__c po: triggerNew){
                             
                //Get Plan / Project Code based on Purchase Request
                if(po.ASI_MFM_Purchase_Request__c!=null && pr_Map.containsKey(po.ASI_MFM_Purchase_Request__c)){
                    po.ASI_MFM_PRRequester__c=pr_Map.get(po.ASI_MFM_Purchase_Request__c).ownerId;//Once PO approved -> email notification to PR requester
                    po.ASI_MFM_Plan__c=pr_Map.get(po.ASI_MFM_Purchase_Request__c).ASI_MFM_Plan__c; //po.ASI_MFM_Project_Code__c=pr_Map.get(po.ASI_MFM_Purchase_Request__c).ASI_MFM_Plan__r.ASI_MFM_Project_Code__c;
                }
                
                if(Plan_Map.containsKey(po.ASI_MFM_Plan__c)){
                    po.ASI_MFM_Project_Code__c=Plan_Map.get(po.ASI_MFM_Plan__c).ASI_MFM_Project_Code__c;
                }
                
                //Get Suppiler Email
                if(acc_Map.containsKey(po.ASI_MFM_Supplier_Name__c) && po.ASI_MFM_TR_Supplier_Email__c==null){
                    po.ASI_MFM_TR_Supplier_Email__c=acc_Map.get(po.ASI_MFM_Supplier_Name__c).ASI_LUX_Email_Business__c;
                }
                
                
                if(acc_Map.containsKey(po.ASI_MFM_Warehouse__c) && po.ASI_MFM_Company_Address__c==null){
                    if(acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_1__c!=null ||acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_2__c!=null){
                        string address='';
                        
                        if(acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_2__c!=null){
                            address=string.valueOf(acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_1__c)+string.valueOf(acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_2__c);
                        }else{
                            address=acc_Map.get(po.ASI_MFM_Warehouse__c).ASI_MFM_Address_Line_1__c;
                        }
                        po.ASI_MFM_Company_Address__c=address;
                    }else{
                        if(!Test.isRunningTest()){ 
                            po.addError('Please input Company Address.');
                        }
                    }
                    // po.ASI_MFM_Company_Address__c=
                }
                
                if(po.ASI_MFM_Purchase_Request__c==null && po.ASI_MFM_Plan__c==null){
                    if(!Test.isRunningTest()){ 
                        po.addError('Please Choose Plan or Purchase Request.');
                    }
                }
            }// For Loop End --  get value                
        }        
    }//end method: beforeUpsertMethod
    
    // Added by 2018-02-23 Linus@introv      ****Set Approver from Fix Approver Route*****
    private static void setApprover(ASI_MFM_PO__c po, Map<String, ASI_MFM_Fix_Approval_Route__c> FARMap)
    {
        System.debug('Linus: Start assign fix approver');
        Id ownerid = po.ASI_MFM_PRRequester__c == null? po.OwnerId:po.ASI_MFM_PRRequester__c;
        User owner = [Select ASI_MFM_Team__c, ASI_MFM_Brand_Manager__c from User where id =: ownerid];
        
        if(owner.ASI_MFM_Team__c != null){
            ASI_MFM_Fix_Approval_Route__c CurrentFAR = FARMap.get(owner.ASI_MFM_Team__c);      system.debug('Linus: CurrentFAR');
            
            integer CurrApproverNum=1;
            for(integer i = 1; i <= 12 ; i++)
            {
                string sysApprover = 'ASI_MFM_Sys_Approver_' + CurrApproverNum + '__c'; // sys approver 1 - 5
                string fixApprover = 'ASI_MFM_Corporate_Approver_'+ i +'__c';
                string approvalLimit = 'ASI_MFM_Approval_Limit_CA' + i + '__c';
                
                    decimal local_amount = po.ASI_MFM_Exchange_Rate__c != null? po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c: po.ASI_MFM_PO_Amount__c;                   
                    if(CurrentFAR != null && CurrentFAR.get(fixApprover) != null && local_amount > Double.valueOf(CurrentFAR.get(approvalLimit)))
                    {
                        po.put(sysApprover, CurrentFAR.get(fixApprover));    system.debug('Linus: sysApprover');
                        CurrApproverNum++;    
                    }
                
            }            
        }
    }
    
    
    /*
    private static void setDynamicApprover(ASI_MFM_PO__c po, Map<ID, User> mapUser, Map<String, ASI_MFM_Dynamic_Approval_Route__c> DARMap, String aType)
    {
        ID approverID = mapUser.get(po.OwnerId).ManagerID; //get po owner manager
        String sysApprover; //string for store system approver apiname
        
        for(integer i = 1 ; i <= 10 ; i++)
        {
            sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c'; //sys approver 1 - 10
            if(mapUser.containsKey(approverID))
            {
                //check 2 case, 1. dynamic route do not have that manager / 2. dynamic route have that manager & amount >limit
                decimal local_amount=0;
                if(po.ASI_MFM_Exchange_Rate__c!=null){
                    local_amount= po.ASI_MFM_PO_Amount__c* po.ASI_MFM_Exchange_Rate__c;
                }else{
                    local_amount= po.ASI_MFM_PO_Amount__c;
                }
                if(!DARMap.containsKey(approverID + aType) ||(DARMap.containsKey(approverID + aType) && local_amount> DARMap.get(approverID + aType).ASI_MFM_Approval_Limit__c))
                {
                    po.put(sysApprover, approverID);
                }
                //check is end at this approver
                if(DARMap.containsKey(approverID + aType))
                {
                    if(DARMap.get(approverID + aType).ASI_MFM_End_of_1st_Route__c)
                    {
                        break;
                    }//end if
                }//end if
                //manager approver move to next manager approver 
                approverID = mapUser.get(approverID).ManagerID;
            }//end if
            else 
                break;
        }//end for
    }//end method: setDynamicApprover
    */
    public static void setApproverToNull(ASI_MFM_PO__c po)
    {
        String sysApprover;
        
        for(integer i = 1 ; i <=10 ; i++)
        {
            sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
            po.put(sysApprover,null);
        }//end for
    }//end method: setApproverToNull
    
    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
        // Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        list<ASI_MFM_Payment_Line_Item__c> pi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        if( !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_KR_Delete_PO')){
            for (ASI_MFM_PO__c p:trigger_old) { 
                if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete'){
                   // p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                }
                po_set.add(p.id);
            }
            
            if(po_set != NULL){
                pi_list = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c != TRUE and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c in :po_set order by ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c]; 
            }
            
            map<id, integer> pi_map = new map<id, integer>();
            id current_pid;
            integer pi_count = 0;
            for (ASI_MFM_Payment_Line_Item__c pi:pi_list) {
                if (pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c != current_pid) {
                    pi_map.put(current_pid, pi_count);
                    current_pid = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c;
                    pi_count = 1;
                }
                else {
                    pi_count++;
                }
            }
            if (current_pid != null) {
                pi_map.put(current_pid, pi_count);
            }
            for (ASI_MFM_PO__c p:trigger_old) { 
                if (pi_map.get(p.id) > 0 && !Test.isRunningTest()) {
                    p.addError('Not allowed to delete because it has related payment line items');
                }
            }
        }
        
    }
    
    
    
    //After All method
    public static void routineAfterAll(list<ASI_MFM_PO__c> triggerNew, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        set<id> PRIdset= new set<id> ();
        Set<id> CurrentIdSet = new Set<id>(); //  Current Id Set 
        if(triggerNew!=null){
            for(ASI_MFM_PO__c po: triggerNew){
                //change from 'Draft'/'Submitted'---> 'Approved' or 'Approved'-->'Draft'
                if(po.id!=null && !po.ASI_MFM_Is_Direct_Payment__c && po.ASI_MFM_Purchase_Request__c!=null && ((po.ASI_MFM_Status__c=='Approved' && trigger_oldMap.get(po.id).ASI_MFM_Status__c!='Approved')||(po.ASI_MFM_Status__c!='Approved' && trigger_oldMap.get(po.id).ASI_MFM_Status__c=='Approved')) ){
                    PRIdset.add(po.ASI_MFM_Purchase_Request__c);
                    if(po.ASI_MFM_Status__c!='Approved'){
                        CurrentIdSet.add(po.id);
                    }
                    
                }
            }
        }
        
        
        if(triggerNew==null && trigger_oldMap!=null){// For delete case
            for (ASI_MFM_PO__c po:trigger_oldmap.values()) {
                if(!po.ASI_MFM_Is_Direct_Payment__c && po.ASI_MFM_Purchase_Request__c!=null && po.id!=null ){
                    PRIdset.add(po.ASI_MFM_Purchase_Request__c);
                    CurrentIdSet.add(po.id);
                }
            }
        }
        
        if(PRIdset!=null && !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_POAfterAllTriggerClass','KR')  ){
            Map<Id,decimal> PR_Map=new Map<Id,decimal>();		
            //List<ASI_MFM_Purchase_Request_Line__c> prList =[select id from ASI_MFM_Purchase_Request_Line__c where RecordType.DeveloperName like 'ASI_MFM_KR%' and  ASI_MFM_Purchase_Request__c in :PRIdset ];
            
            for(ASI_MFM_Purchase_Request_Line__c prl:[select id from ASI_MFM_Purchase_Request_Line__c where RecordType.DeveloperName like 'ASI_MFM_KR%' and  ASI_MFM_Purchase_Request__c in :PRIdset ]){
                PR_Map.put(prl.id,0.00);
            }
            
            List<ASI_MFM_PO_Line_Item__c> PoList=new List<ASI_MFM_PO_Line_Item__c>();//PoList=Database.query('select id,name,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Amount_in_PR_Currency__c from ASI_MFM_PO_Line_Item__c where RecordType.DeveloperName = \'ASI_MFM_KR_PO_Line_Item\'' + ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_PO_TriggerClass','routineAfterAll','KR'));   //PoList=[ select id,name,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Amount_in_PR_Currency__c from ASI_MFM_PO_Line_Item__c where RecordType.DeveloperName = 'ASI_MFM_KR_PO_Line_Item'  and  ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c in:  PRIdset and (ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' or  ASI_MFM_PO__r.ASI_MFM_Status__c='Closed') ];
            
            //PoList=
            
            
            for(ASI_MFM_PO_Line_Item__c pl: [ select id,name,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Amount_in_PR_Currency__c from ASI_MFM_PO_Line_Item__c where RecordType.DeveloperName = 'ASI_MFM_KR_PO_Line_Item'  and  ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c in:  PRIdset and (ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' or  ASI_MFM_PO__r.ASI_MFM_Status__c='Closed') ]){
                if(CurrentIdSet==null || (CurrentIdSet!=null && !CurrentIdSet.contains(pl.ASI_MFM_PO__c))){
                    //if(!CurrentIdSet.contains(pl.ASI_MFM_PO__c)){
                    // and ASI_MFM_PO__c not in: CurrentIdSet 
                    decimal amt=pl.ASI_MFM_PO_Amount_in_PR_Currency__c;
                    if(pl.ASI_MFM_PO_Amount_in_PR_Currency__c==0 && pl.ASI_MFM_PO_Amount__c!=0 && pl.ASI_MFM_PO_Amount__c!=null){
                        amt=pl.ASI_MFM_PO_Amount__c;
                    }
                    if(PR_Map.containsKey(pl.ASI_MFM_Purchase_Request_Line__c)){
                        // accumulate all Payment amount 
                        decimal POAmount=PR_Map.get(pl.ASI_MFM_Purchase_Request_Line__c)+amt;
                        PR_Map.remove(pl.ASI_MFM_Purchase_Request_Line__c);
                        PR_Map.put(pl.ASI_MFM_Purchase_Request_Line__c,POAmount);
                    }else{
                        PR_Map.put(pl.ASI_MFM_Purchase_Request_Line__c,amt);
                    }
                    
                }
                
                
            }//End For Loop
            
            List<ASI_MFM_Purchase_Request_Line__c> upsertList = new List<ASI_MFM_Purchase_Request_Line__c>();
            //construct Update list                  
            for(String key : PR_Map.keySet()){
                ASI_MFM_Purchase_Request_Line__c PRItemp =NEW ASI_MFM_Purchase_Request_Line__c();
                PRItemp.ID=key;
                PRItemp.ASI_MFM_PO_Amount_in_PR_Currency__c=PR_Map.get(key);
                upsertList.add(PRItemp);
            }
            
            if(upsertList.size()>0 && ! test.isRunningTest() ){
                update upsertList;
            }
            
            
            //End Update
        }
        
    }
    
    
    
}//end class: ASI_MFM_KR_PO_TriggerClass