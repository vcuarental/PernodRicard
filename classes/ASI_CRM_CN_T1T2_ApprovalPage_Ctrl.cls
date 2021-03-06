/* Filename:    ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Define approval for WS Brand T1, T2
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-05-04   leo.hui@introv.com      Created
 * 2014-06-10   michael.yip@introv.com  
 * 2014-10-15   twinkle.li@introv.com    Setting up PR Direct Approval process
 * 2014-10-20   twinkle.li@introv.com    Put the managers even that are not included in Dynamic Route into the approval process
 *
 */
public without sharing class ASI_CRM_CN_T1T2_ApprovalPage_Ctrl {

    public string PageId {get;set;}
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
    public string WSType {get;set;}             // T1 or T2
    public string WSType_Search {get;set;}      // WS T1 or WS T2
    //public Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute {get;set;}
    //public Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix {get;set;}
    public string Region {get;set;}
	public Static Boolean hasError = FALSE;//20160923 Ben @ Elufa

    public ASI_CRM_CN_T1T2_ApprovalPage_Ctrl(ApexPages.StandardController controller) {

        accountAdditionalField = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
        
        PageId = ApexPages.currentPage().getParameters().get('id');
        WSType = ApexPages.currentPage().getParameters().get('WSType');

        Region = accountAdditionalField.ASI_CRM_CN_Region__c;

        if(WSType == 'T1'){
            WSType_Search = 'WS T1';
            if(accountAdditionalField.ASI_CRM_CN_Status_T1__c != 'Final')
                accountAdditionalField.ASI_CRM_CN_Status_T1__c = 'Draft';
            if(accountAdditionalField.ASI_CRM_CN_Status_T2__c != 'Final')
                accountAdditionalField.ASI_CRM_CN_Status_T2__c = '';
            
        }
        else if(WSType == 'T2'){
            WSType_Search = 'WS T2';
            if(accountAdditionalField.ASI_CRM_CN_Status_T1__c != 'Final')
                accountAdditionalField.ASI_CRM_CN_Status_T1__c = '';
            if(accountAdditionalField.ASI_CRM_CN_Status_T2__c != 'Final')
                accountAdditionalField.ASI_CRM_CN_Status_T2__c = 'Draft';
            
        }
        else if(WSType == 'PR'){
            WSType_Search = 'PR Direct';     
            if(accountAdditionalField.ASI_CRM_CN_PR_Direct_Status__c!= 'Final')
                accountAdditionalField.ASI_CRM_CN_PR_Direct_Status__c= 'Draft'; 
        }
        else
            WSType_Search = '';
            
        //update accountAdditionalField;

        
    }

    public PageReference init() {
        /*MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();

        //----- init Approver fields -----
        setApproverToNull(accountAdditionalField);

        //----- get Dynamic Route setting -----
        List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [Select ASI_CRM_Approval_Limit__c, 
            ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c 
            from ASI_CRM_Dynamic_Approval_Route__c 
            where ASI_CRM_Type__c =: WSType_Search];

        for(ASI_CRM_Dynamic_Approval_Route__c a : LApp){
            MAppRoute.put(a.ASI_CRM_User__c, a);
            
            System.Debug('a.ASI_CRM_User__c: ' + a.ASI_CRM_User__c);
        }

        //----- get Fix Route setting -----
        List<ASI_CRM_Fix_Approval_Route__c> LFApp = [Select ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
            ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c, 
            ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c, 
            ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,
            ASI_CRM_CN_Entry_Limit__c, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c
            FROM ASI_CRM_Fix_Approval_Route__c
            WHERE ASI_CRM_CN_Type__c =: WSType_Search and ASI_CRM_CN_Region_Area_Channel__c =:Region];

        for(ASI_CRM_Fix_Approval_Route__c a : LFApp){
            MAppRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a);
        }
        
        System.Debug('accountAdditionalField: ' + accountAdditionalField);
        System.Debug('Region: ' + Region);

        System.Debug('MAppRoute: ' + MAppRoute);
        System.Debug('MAppRouteFix: ' + MAppRouteFix);

        setApprovers(accountAdditionalField, Region, MAppRoute, MAppRouteFix);*/
        defineApproval(WSType_Search, accountAdditionalField);
        
        /*
        PageReference redirect = new PageReference('/p/process/Submit');
        redirect.getParameters().put('id',PageId); 
        
        redirect.setRedirect(true); 
        
        return redirect;
        */
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(PageId);
        // submit the approval request for processing
        if(!hasError)//20160923 Ben @ Elufa Added if(!hasError)
            Approval.ProcessResult result = Approval.process(req);
        // display if the reqeust was successful
        
        PageReference redirect = new PageReference('/' + PageId);
        redirect.setRedirect(true);         
        return redirect;
    }
    
    public static void defineApproval(String WSType_Search, ASI_CRM_AccountsAdditionalField__c accountAdditionalField){
        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        Map<id, User> MUser = new Map<id, User>(); //Twinkle 20/10/2014

        //----- init Approver fields -----
        setApproverToNull(accountAdditionalField);

        //----- get Dynamic Route setting -----
        List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [Select ASI_CRM_Approval_Limit__c, 
            ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c 
            from ASI_CRM_Dynamic_Approval_Route__c 
            where ASI_CRM_Type__c =: WSType_Search];
        
        system.debug(LApp);
        
        for(ASI_CRM_Dynamic_Approval_Route__c a : LApp){
            MAppRoute.put(a.ASI_CRM_User__c, a);
            
            System.Debug('a.ASI_CRM_User__c: ' + a.ASI_CRM_User__c);
        }
        
        List<User> LUser = [Select id, ManagerID from User Where CompanyName = 'Pernod Ricard China'];
        for(User u : LUser){
            MUser.put(u.id, u);
        }      
        

        //----- get Fix Route setting -----
        List<ASI_CRM_Fix_Approval_Route__c> LFApp = [Select ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                                                     ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c, 
                                                     ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c, 
                                                     ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,
                                                     ASI_CRM_CN_Entry_Limit__c, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c
                                                     , ASI_CRM_Commercial_Team__c//20160912, added by Leo
                                                     , ASI_CRM_Channel__c
                                                     , ASI_CRM_CN_Approver_7__c, ASI_CRM_CN_Approver_8__c //20161027 Elufa
                                                     FROM ASI_CRM_Fix_Approval_Route__c
                                                     WHERE ASI_CRM_CN_Type__c =: WSType_Search and ASI_CRM_CN_Region_Area_Channel__c =:accountAdditionalField.ASI_CRM_CN_Region__c];

        /*for(ASI_CRM_Fix_Approval_Route__c a : LFApp){
            MAppRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a);
        }*/
        
        //20160912, edited by Leo
        for(ASI_CRM_Fix_Approval_Route__c a : LFApp)
        {
            String key = a.ASI_CRM_CN_Region_Area_Channel__c
                +(a.ASI_CRM_Commercial_Team__c!=''&&a.ASI_CRM_Commercial_Team__c!=null ? a.ASI_CRM_Commercial_Team__c:'');
            if (String.isNotBlank(a.ASI_CRM_Channel__c)) {
                key += a.ASI_CRM_Channel__c;
            }
            MAppRouteFix.put(key, a);
        }
        //20160912, edited by Leo
        
        System.Debug('accountAdditionalField: ' + accountAdditionalField);
        System.Debug('accountAdditionalField.ASI_CRM_CN_Region__c: ' + accountAdditionalField.ASI_CRM_CN_Region__c);
        System.Debug('Region: ' + accountAdditionalField.ASI_CRM_CN_Region__c);

        System.Debug('MAppRoute: ' + MAppRoute);
        System.Debug('MAppRouteFix: ' + MAppRouteFix);

        setApprovers(accountAdditionalField, accountAdditionalField.ASI_CRM_CN_Region__c, MAppRoute, MAppRouteFix, MUser);
    }


    public static void setApprovers(ASI_CRM_AccountsAdditionalField__c obj, 
                                    string Region, 
                                    Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute,
                                    Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,
                                    Map<id, User> MUser){
        integer approver_count = 0;
        boolean proceed = true;

        id currentUserid = obj.ASI_CRM_CN_Owner_Manager__c;
        ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
        User currentApproverU = null;
        
        System.Debug('currentUserid (1): ' + currentUserid);

        // (1) ----- Process Dynamic Route (start) -----
        while(proceed) {
            if(currentUserid!=null/*&& MAppRoute.containsKey(currentUserid)*/){
                if(MAppRoute.get(currentUserid) != null){
                    currentApprover = MAppRoute.get(currentUserid);
                    currentUserid = currentApprover.ASI_CRM_Manager_ID__c;
                }
                else{
                    currentApproverU = MUser.get(currentUserid);
                    currentUserid = currentApproverU.ManagerID;
                }                
                
                if(currentApprover != null && currentApproverU == null){
                    setApproverByCount(obj, approver_count, currentApprover.ASI_CRM_User__c);
                }
                else if(currentApprover == null && currentApproverU != null){
                    setApproverByCount(obj, approver_count, currentApproverU.id);
                }
                System.Debug('currentUserid (2): ' + currentUserid);
                approver_count++;
                
                if(currentApprover != null){
                    if(currentApprover.ASI_CRM_End_of_Dynamic_Route__c){
                        proceed = false;
                    }
                } 
                 currentApprover = null;
                 currentApproverU = null;                               
            }
            else
            {
                proceed = false;
            }
        }
        // (1) ----- Process Dynamic Route (end) -----

        //*********************************************************

        // (2) ----- Process Fix Route (start) -----
        //ASI_CRM_Fix_Approval_Route__c fixApprover = MAppRouteFix.get(obj.ASI_CRM_CN_Region__c);
        
        //20160912, edited by Leo
        ASI_CRM_Fix_Approval_Route__c fixApprover;
        String key = obj.ASI_CRM_CN_Region__c
                +(obj.ASI_CRM_CN_Commercial_Team__c!=''&&obj.ASI_CRM_CN_Commercial_Team__c!=null ? obj.ASI_CRM_CN_Commercial_Team__c:'');
        if (obj.ASI_CRM_CN_NewChannel__c != null) {
            String key2 = key + obj.ASI_CRM_CN_NewChannel__c;
            System.debug(LoggingLevel.INFO, '*** obj.ASI_CRM_CN_NewChannel__c: ' + obj.ASI_CRM_CN_NewChannel__c);
            System.debug(LoggingLevel.INFO, '*** key: ' + key);
            System.debug(LoggingLevel.INFO, '*** key2: ' + key2);
            System.debug(LoggingLevel.INFO, '*** MAppRouteFix: ' + MAppRouteFix);
            fixApprover = MAppRouteFix.get(key2);
            if (fixApprover == null) {
                fixApprover = MAppRouteFix.get(key);
            }
        } else {
            fixApprover = MAppRouteFix.get(key);
        }
        //20160912, edited by Leo
        
        System.Debug('fixApprover: ' + fixApprover);

        if(fixApprover != null) {
            if(fixApprover.ASI_CRM_CN_Approver_1__c != null){
            
                System.Debug('fixApprover (1) ');

                setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_1__c);
                approver_count++;

                if(fixApprover.ASI_CRM_CN_Approver_2__c != null) {
                    System.Debug('fixApprover (2) ');

                    setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_2__c);
                    approver_count++;

                    if(fixApprover.ASI_CRM_CN_Approver_3__c != null) {
                        setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_3__c);
                        approver_count++;

                        if(fixApprover.ASI_CRM_CN_Approver_4__c != null) {
                            setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_4__c);
                            approver_count++;

                            if(fixApprover.ASI_CRM_CN_Approver_5__c != null) {
                                setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_5__c);
                                approver_count++;

                                if(fixApprover.ASI_CRM_CN_Approver_6__c != null) {
                                    setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_6__c);
                                    approver_count++;
                                    
                                    //20161027 Elufa
                                    if(fixApprover.ASI_CRM_CN_Approver_7__c != null) {
                                        setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_7__c);
                                        approver_count++;
                                        
                                        if(fixApprover.ASI_CRM_CN_Approver_8__c != null) {
                                            setApproverByCount(obj, approver_count, fixApprover.ASI_CRM_CN_Approver_8__c);
                                            approver_count++;
                                        }
                                    }
                                    //20161027 End
                                } 
                            } 
                        } 
                    }  
                }   
            }      
        }

        // (2) ----- Process Fix Route (end) -----
        //20160923 Ben @ Elufa
                                        try{
                                            update obj;
                                        }catch(dmlException dmle){
                                            hasError = TRUE; //20160923 Ben @ Elufa
                                        }
        
    }

    public static void setApproverToNull(ASI_CRM_AccountsAdditionalField__c obj)
    {   
        obj.ASI_CRM_CN_Sys_Approver_1__c = null;
        obj.ASI_CRM_CN_Sys_Approver_2__c = null;
        obj.ASI_CRM_CN_Sys_Approver_3__c = null;
        obj.ASI_CRM_CN_Sys_Approver_4__c = null;
        obj.ASI_CRM_CN_Sys_Approver_5__c = null;
        obj.ASI_CRM_CN_Sys_Approver_6__c = null;
        obj.ASI_CRM_CN_Sys_Approver_7__c = null;
        obj.ASI_CRM_CN_Sys_Approver_8__c = null;
        obj.ASI_CRM_CN_Sys_Approver_9__c = null;
        obj.ASI_CRM_CN_Sys_Approver_10__c = null;
        //20161027 Elufa
        obj.ASI_CRM_CN_Sys_Approver_11__c = null;
        obj.ASI_CRM_CN_Sys_Approver_12__c = null; 
        //20161027 End
    }
    
    public static void setApproverByCount(ASI_CRM_AccountsAdditionalField__c obj, integer approver_count, Id userId)
    {
        if(approver_count == 0){
            obj.ASI_CRM_CN_Sys_Approver_1__c = userId;
        }
        else if(approver_count == 1){
            obj.ASI_CRM_CN_Sys_Approver_2__c = userId;
        }
        else if(approver_count == 2){
            obj.ASI_CRM_CN_Sys_Approver_3__c = userId;
        }
        else if(approver_count == 3){
            obj.ASI_CRM_CN_Sys_Approver_4__c = userId;
        }
        else if(approver_count == 4){
            obj.ASI_CRM_CN_Sys_Approver_5__c = userId;
        }
        else if(approver_count == 5){
            obj.ASI_CRM_CN_Sys_Approver_6__c = userId;
        }
        else if(approver_count == 6){
            obj.ASI_CRM_CN_Sys_Approver_7__c = userId;
        }
        else if(approver_count == 7){
            obj.ASI_CRM_CN_Sys_Approver_8__c = userId;
        }
        else if(approver_count == 8){
            obj.ASI_CRM_CN_Sys_Approver_9__c = userId;
        }
        else if(approver_count == 9){
            obj.ASI_CRM_CN_Sys_Approver_10__c = userId;
        }
        //20161027 Elufa
        else if(approver_count == 10){
            obj.ASI_CRM_CN_Sys_Approver_11__c = userId;
        }
        else if(approver_count == 11){
            obj.ASI_CRM_CN_Sys_Approver_12__c = userId;
        }
        //20161027 End
    }
}