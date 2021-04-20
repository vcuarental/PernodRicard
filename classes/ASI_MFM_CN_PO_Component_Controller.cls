public without sharing class ASI_MFM_CN_PO_Component_Controller {
    //ApexPages.StandardController controller;
    public ASI_MFM_PO__c po {set;get;}
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public List<ASI_MFM_PO_Receipt_Phasing__c> linePhasing{get;set;}
    public id POID {set;get;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_ApprHist_LineItem > appHistList {get;set;}
    public ASI_ApprHist_LineItem appHistSubmitter {get;set;}
    public boolean hasHistroy {get;set;}
    public boolean hasReceiptPhasing {get;set;} //20180615 Introv
    private final String object_ApiName = 'ASI_MFM_PO__c';


    public ASI_MFM_CN_PO_Component_Controller(){
        
    }
    
    private String strSplit(String inputText, Integer count){
        if(inputText==null) return '';
        String[] sList = inputText.split(' ');
        if(sList.size()==0) return '';
        String result = '';
        for (String s:sList) {
            if(s.length()>count) {
                do {
                    String subString = s.subString(0,count);
                    s = s.subString(count, s.length());
                    result = result+subString+' ';
                } while (s.length()>count);
                result = result+s+' ';
            } else {
                result = result+s+' ';
            }
        }
        return result;
    }
    
    public boolean init(){
        system.debug(poid);
        
        List<ASI_MFM_PO__c> LPO = [Select ASI_MFM_Status__c, ASI_MFM_Supplier_Name__r.Name, Name,  ASI_MFM_PO_Start_Date__c,
                                   ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Type__c, Owner.Name, ASI_MFM_BU_Code__r.Name,// ASI_MFM_KPI__c,
                                   ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Remarks__c, 
                                   ASI_MFM_Event_ID__r.ASI_MFM_Event__r.Name, ASI_MFM_Currency__c,
                                   LastModifiedBy.Name, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
                                   ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_Plan__r.ASI_MFM_PP_Category__r.name,
                                   ASI_MFM_PO_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, createddate,
                                   ASI_MFM_Sys_Approver_1__c, ASI_MFM_Sys_Approver_2__c, ASI_MFM_Sys_Approver_3__c, ASI_MFM_Sys_Approver_4__c, ASI_MFM_Sys_Approver_5__c,
                                   ASI_MFM_Sys_Approver_6__c, ASI_MFM_Sys_Approver_7__c, ASI_MFM_Sys_Approver_8__c, ASI_MFM_Sys_Approver_9__c, ASI_MFM_CN_Finance__c,
                                   ASI_MFM_PO_PP_Category__r.Name,//20170904 Introv
                                   ASI_MFM_Paid_Amount_in_PO_Currency__c, ASI_MFM_Total_Receipt_Amount__c, ASI_MFM_Remaining_Balance__c
                                   from ASI_MFM_PO__c where id =:POID limit 1];
        if(LPO != null && LPO.size()>0){
            this.Po = LPO[0];
            
            linePhasing = new List<ASI_MFM_PO_Receipt_Phasing__c>();
            List<ASI_MFM_PO_Receipt_Phasing__c> phasingList = [SELECT ASI_MFM_Version__c, ASI_MFM_Modify_BY__c, ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_Amount_Total__c, ASI_MFM_Comments__c 
                                                               , ASI_MFM_Allocated_Amount_7__c, ASI_MFM_Allocated_Amount_8__c, ASI_MFM_Allocated_Amount_9__c, ASI_MFM_Allocated_Amount_10__c
                                                               , ASI_MFM_Allocated_Amount_11__c, ASI_MFM_Allocated_Amount_12__c, ASI_MFM_Allocated_Amount_1__c, ASI_MFM_Allocated_Amount_2__c
                                                               , ASI_MFM_Allocated_Amount_3__c, ASI_MFM_Allocated_Amount_4__c, ASI_MFM_Allocated_Amount_5__c, ASI_MFM_Allocated_Amount_6__c
                                                               FROM ASI_MFM_PO_Receipt_Phasing__c
                                                               WHERE ASI_MFM_PO__c = :Po.Id
                                                               ORDER BY ASI_MFM_PO__c DESC, CreatedDate DESC, Id DESC, ASI_MFM_Version__c DESC LIMIT 1];
            
            if(phasingList.size() > 0)
                hasReceiptPhasing = True;
            else
                hasReceiptPhasing = False;
            
            for(ASI_MFM_PO_Receipt_Phasing__c phasing:phasingList) {
                String comment = strSplit(phasing.ASI_MFM_Comments__c, 15);
                phasing.ASI_MFM_Comments__c = comment;
                linePhasing.add(phasing);
            }
            
            lineItem = new List<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: Po.Id];
            System.debug('POId ' + Po.Id);
            List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_A_C_Code__r.Name, ASI_MFM_BU_Code__r.ASI_MFM_BU_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c, ASI_MFM_AP_Code__r.Name,
                ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c, 
                ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, ASI_MFM_Customer_Name__r.Name 
                from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id];
                
            //****** generate approval history - by leo (start) ******
            ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName , Po.Id);
            System.Debug('appHistHelper: ' + appHistHelper);            
            
            /*if (appHistHelper.appHistorySObjList != null) {
                this.processInstList = appHistHelper.appHistorySObjList;
                hasHistroy=true;
                
                System.Debug('appHistHelper.appHistorySObjList: ' + appHistHelper.appHistorySObjList);
                
                appHistList  = new List<ASI_ApprHist_LineItem >();
                Boolean isExit = false;
                
                for (ProcessInstanceHistory li : this.processInstList ) {
                    //---- check is included in the approval history list ----
                    
                    System.Debug('ProcessInstanceHistory li: ' + li);
                    
                    if(li.StepStatus != 'Approved')
                    {                      
                        if(li.StepStatus == 'Rejected')
                        {
                            if(li.OriginalActor.Id == this.Po.ASI_MFM_CN_Finance__c)
                                isExit = false;
                            else
                                isExit = true;
                        }
                        else
                        {
                            isExit = true;
                        }
                    }
                    else
                    {
                        
                        addToApprHistList(li);
                        
                        if(this.Po.ASI_MFM_Sys_Approver_1__c != null)
                        {
                            if(li.OriginalActor.Id == this.Po.ASI_MFM_Sys_Approver_1__c)
                                isExit = true;
                        }
                    }
                    
                    if(isExit) break;
                    
                }
                
                if (appHistList.size() <=0)
                    hasHistroy=false;
            }*/
            // Edited by Michael Yip (Introv) 15Sep2014 to include submitter and submit date
            appHistSubmitter = new ASI_ApprHist_LineItem();
            appHistSubmitter.oriActorName=this.po.Owner.Name;
            appHistSubmitter.CreatedDateString=this.po.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
            if (appHistHelper.appHistorySObjList != null) {
                this.processInstList = appHistHelper.appHistorySObjList;
                hasHistroy=true;
                
                System.Debug('appHistHelper.appHistorySObjList: ' + appHistHelper.appHistorySObjList);
                
                appHistList  = new List<ASI_ApprHist_LineItem >();
                Boolean isExit = false;
                
				set<string> set_approverId = new set<string>();
                
                for (ProcessInstanceHistory li : this.processInstList ) {
                    //---- check is included in the approval history list ----
                    addToApprHistList(li);
					if(li.OriginalActor.Id != Null){
						set_approverId.add(li.OriginalActor.Id);
					}
					if(li.Actor.Id != Null){
						set_approverId.add(li.Actor.Id);
					}
                    System.Debug('ProcessInstanceHistory li: ' + li);
                    /*
                    if(li.StepStatus != 'Approved')
                    {                      
                        if(li.StepStatus == 'Rejected')
                        {
                            if(li.OriginalActor.Id == this.Po.ASI_MFM_CN_Finance__c)
                                isExit = false;
                            else
                                isExit = true;
                            addToApprHistList(li); //added by Daniel WONG 20141216
                        }
                        else
                        {
                            isExit = true;
                        }
                    }
                    else
                    {
                        
                        addToApprHistList(li);
                        
                        if(this.Po.ASI_MFM_Sys_Approver_1__c != null)
                        {
                            if(li.OriginalActor.Id == this.Po.ASI_MFM_Sys_Approver_1__c)
                                isExit = true;
                        }
                    }
                    
                    if(isExit) break; */
                    
                }
                
                
                for (ProcessInstanceHistory li : this.processInstList ) {
                    if(li.StepStatus == 'Started'){
                            addToSubmitter(li);
                            break;
                    }
                }
				
				
				/* INC0060206 20181205 Laputa, solve too many soql 101, populate approver details at this moment */
				map<string, user> map_user = getApprDetailInfo(set_approverId);
				for(ASI_ApprHist_LineItem tempLi : appHistList){
					if(map_user.containsKey(tempLi.oriActorId)){
						user u = map_user.get(tempLi.oriActorId);
						tempLi.oriActorName =  u.Name;
						tempLi.oriActorTitle =  u.Title;
					}
					if(map_user.containsKey(tempLi.actActorId)){
						user u = map_user.get(tempLi.actActorId);
						tempLi.actActorName =  u.Name;
						tempLi.actActorTitle =  u.Title;
						tempLi.actActorDepartment = u.Department;
					}
				}
                
                if (appHistList.size() <=0)
                    hasHistroy=false;
            }
            else
            {
                hasHistroy=false;
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'my error msg');
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No Approval History in this record'));
            }
            //****** generate approval history - by leo (end) ******
                
            return init(poCurrent,lineItemList);
        }
        return true;
    }
    /*public boolean init(){
        
        system.debug(poid);
        List<ASI_MFM_PO__c> LPO = [Select ASI_MFM_Status__c, ASI_MFM_Supplier_Name__r.Name, Name,  ASI_MFM_PO_Start_Date__c,
            ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Type__c, Owner.Name, ASI_MFM_BU_Code__r.Name, 
            ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Remarks__c, 
            ASI_MFM_Event_ID__r.ASI_MFM_Event__r.Name, ASI_MFM_Currency__c,
            LastModifiedBy.Name, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
            ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_Plan__r.ASI_MFM_PP_Category__r.name,
            ASI_MFM_PO_Amount__c
            from ASI_MFM_PO__c where id =:POID limit 1];
        if(LPO != null && LPO.size()>0){
        this.Po = LPO[0];
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        
        ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: Po.Id];
        System.debug('POId ' + Po.Id);
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_A_C_Code__r.Name, ASI_MFM_BU_Code__r.ASI_MFM_BU_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c, ASI_MFM_AP_Code__r.Name,
        ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c, 
        ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, ASI_MFM_Customer_Name__r.Name 
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id];
        
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
        }
        //catch(exception e){e.getMessage();}
        }
        return true;
    }*/
    
    public boolean init(ASI_MFM_PO__c poCurrent, List<ASI_MFM_PO_Line_Item__c> lineItemList){
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
        }
        //catch(exception e){e.getMessage();}
        
        return true;
    }

    String LongDate = ' ';

      // Init cLongDate with the current Datetime in long date format    
    public String getLongDate() {
        Datetime cDT = System.now();
        LongDate = cDT.format('yyyy-MM-dd hh:mm');
        return LongDate;
        }
        
    //################################################################
        
    //****** generate approval history: functions - by leo (start) ******
    public static User getApprDetailInfo(String userId) {
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
    }

    //****** generate approval history: functions - by leo (start) ******
    public map<string, User> getApprDetailInfo(set<String> set_userId) {
        list<user> list_user = [select id, name, title, department from user where id in :set_userId];
		return new map<string, User>(list_user);
    }

    public class ASI_ApprHist_LineItem {
        public String id { get; set; }
        public String StepStatus{ get; set; }
        public String Comments{ get; set; }
        public DateTime CreatedDate{ get; set; }
        public String CreatedDateString{ get; set; }
        public String oriActorId { get; set; }
        public String oriActorName { get; set; }
        public String oriActorTitle { get; set; }
        public String oriActorDepartment { get; set; }
        public String actActorId { get; set; }
        public String actActorName { get; set; }
        public String actActorTitle { get; set; }
        public String actActorDepartment { get; set; }
      
    }
    
    @TestVisible
    private void addToApprHistList(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate != Null ? li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong') : '';//20170911 Introv
      
        tempLi.oriActorId =  li.OriginalActor.Id;
		/* INC0060206 20181205 Laputa, solve too many soql 101
        User oriApprover = li.OriginalActor.Id != Null ? getApprDetailInfo(li.OriginalActor.Id) : Null;//20170911 Introv
        tempLi.oriActorName =  oriApprover != Null ? oriApprover .Name : Null;
        tempLi.oriActorTitle =  oriApprover != Null ? oriApprover .Title : Null;
		*/
      
        tempLi.actActorId =  li.Actor.Id;
		/* INC0060206 20181205 Laputa, solve too many soql 101
        User actApprover = li.Actor.Id != Null ? getApprDetailInfo(li.Actor.Id) : Null;//20170911 Introv
        tempLi.actActorName =  actApprover != Null ? actApprover.Name : Null;
        tempLi.actActorTitle =  actApprover != Null ? actApprover.Title : Null;
        tempLi.actActorDepartment = actApprover != Null ? actApprover.Department : Null;
		*/
        if (appHistList.size() <=0)
            appHistList.add(tempLi);
        else
            appHistList.add(0, tempLi);
    }
    
    // Added by Michael Yip (Introv) 15Sep2014 to include submitter and submit date
    @TestVisible
    private void addToSubmitter(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate != Null ? li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong') : '';//20170911 Introv
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = li.OriginalActor.Id != Null ? getApprDetailInfo(li.OriginalActor.Id) : Null;//20170911 Introv
        tempLi.oriActorName =  oriApprover != Null ? oriApprover .Name : Null;
        tempLi.oriActorTitle =  oriApprover != Null ? oriApprover.Title : Null;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = li.Actor.Id != Null ? getApprDetailInfo(li.Actor.Id) : Null;//20170911 Introv
        tempLi.actActorName =  actApprover != Null ? actApprover.Name : Null;
        tempLi.actActorTitle =  actApprover != Null ? actApprover.Title : Null;
        tempLi.actActorDepartment = actApprover != Null ? actApprover.Department : Null;
        appHistSubmitter = tempLi; 
    }
                
    //****** generate approval history: functions - by leo (end) ******
}