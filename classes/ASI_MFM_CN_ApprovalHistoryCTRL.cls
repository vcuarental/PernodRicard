Public without sharing class ASI_MFM_CN_ApprovalHistoryCTRL {

    Public ASI_MFM_Payment__c selectedDate {Get; Set;}{selectedDate = new ASI_MFM_Payment__c();}
    Public String selectedObject {Get; Set;}
    Public String docNumber {Get; Set;}
    Public String selectedBU {Get; Set;}
    Public List<SelectOption> BUList {Get; Set;}
    Public Transient List<ProcessInstanceStep> approvalHistoryList {Get; Set;}
    Public Transient List<ProcessInstanceStep> approvalHistoryList2 {Get; Set;}
    Public Transient Map<Id, ProcessInstanceWorkitem> approvalHistoryMap {Get; Set;}
    Public Transient List<headerClass> csvList {Get; Set;}
    Public Transient List<headerClass> headerList {Get; Set;}
    Public Transient String JSONList {Get; Set;}
    Public Transient String JSONDate {Get; Set;}
    Public Transient Set<Id> distinctSet {Get; Set;}
    Public Transient List<ProcessInstanceWorkitem> currentItem {Get; Set;}
    Public Transient Map<id, ASI_MFM_Payment_Line_Item__c> paymentMap {Get; Set;}
    Public Transient Map<id, String> paymentPOMap {Get; Set;}
    Public Transient Map<id, ASI_MFM_PO__c> poMap {Get; Set;}
    Public Transient Map<id, ASI_MFM_Plan__c> planMap {Get; Set;}
    Private Set<id> hasRejected = new Set<Id>();//20180314 Introv
    
    Public ASI_MFM_CN_ApprovalHistoryCTRL(){
        
        BUList = new List<SelectOption>();
        BUList.add(new SelectOption('', '--None--'));
        
        for(ASI_MFM_BU__c obj : [SELECT id, Name
                                 FROM ASI_MFM_BU__c
                                 WHERE RecordType.developerName Like 'ASI_MFM_CN_BU'
                                ]){
                                    
                                    SelectOption tmp = new SelectOption(obj.id, obj.Name);
                                    BUList.add(tmp);
                                }
    }
    
    Public PageReference generateCSV(){
        
        queryApprovalHistory();
        
        if(approvalHistoryList2 == Null || approvalHistoryList2.size() == 0){
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'There is no record to export.'));
            Return Null;
        }
        
        csvList = new List<headerClass>();
        Set<Id> distinctSet2 = new Set<Id>();
        
        //20180314 Introv
        Set<Id> allBAUser = new Set<Id>();
        for(GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName LIKE 'ASI_MFM_CN_BA']){
            
            allBAUser.add(gm.UserOrGroupId);
        }
        
        for(ProcessInstanceStep obj : approvalHistoryList2){
            
            headerClass tmp;
            
            if(approvalHistoryMap.containsKey(obj.ProcessInstance.TargetObjectId) && !distinctSet.contains(obj.ProcessInstance.TargetObjectId)){
                
                ProcessInstanceWorkitem obj2 = approvalHistoryMap.get(obj.ProcessInstance.TargetObjectId);
                
                headerClass tmp2;
                
                if(selectedObject == 'ASI_MFM_Payment__c' && paymentMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp2 = new headerClass();
                    
                    tmp2.objectTypeStr = (obj2.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp2.headerNumber = obj2.ProcessInstance.TargetObject.Name;
                    tmp2.headerId = obj2.ProcessInstance.TargetObjectId;
                    tmp2.currentApprover = obj2.Actor.Name;
                    tmp2.currentApproverId = obj2.ActorId;
                    tmp2.currentStatus = obj2.processinstance.Status;
                    tmp2.submitter = obj2.processinstance.createdBy.Name;
                    tmp2.submitterId = obj2.processinstance.createdByid;
                    tmp2.submissionDate = obj2.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp2.startDate = (obj2.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    //20180205
                    
                    //20170830
                    tmp2.BU = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__r.Name : '';
                    tmp2.amount = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c) : '';
                    tmp2.owner = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.owner.Name;
                    tmp2.remark = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                    tmp2.supplierName = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name : '';
                    tmp2.supplierId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c) : '';
                    tmp2.oneOffPayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c : '';
                    tmp2.alternatePayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.name : '';
                    tmp2.alternatePayeeId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c) : '';
                    tmp2.bankDetails = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c : '';
                    tmp2.paymentAmountNetOfTax = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c) : '';
                    tmp2.discountPool = String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c);
                    tmp2.relatedPO = paymentPOMap.containsKey(obj.ProcessInstance.TargetObjectId) ? paymentPOMap.get(obj.ProcessInstance.TargetObjectId) : '';
                    
                }else if(selectedObject == 'ASI_MFM_PO__c' && poMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp2 = new headerClass();
                    
                    tmp2.objectTypeStr = (obj2.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp2.headerNumber = obj2.ProcessInstance.TargetObject.Name;
                    tmp2.headerId = obj2.ProcessInstance.TargetObjectId;
                    tmp2.currentApprover = obj2.Actor.Name;
                    tmp2.currentApproverId = obj2.ActorId;
                    tmp2.currentStatus = obj2.processinstance.Status;
                    tmp2.submitter = obj2.processinstance.createdBy.Name;
                    tmp2.submitterId = obj2.processinstance.createdByid;
                    tmp2.submissionDate = obj2.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp2.startDate = (obj2.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    //20180205
                    
                    tmp2.BU = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__r.Name : '';
                    tmp2.amount = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c != Null ? String.valueOf(poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c) : '';
                    tmp2.poStart = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c.format() : '';
                    tmp2.poEnd = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c.format() : '';
                    tmp2.owner = poMap.get(obj.ProcessInstance.TargetObjectId).owner.Name;
                    tmp2.remark = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c.replace('\r\n', ' ') : '';
                    
                }else if(selectedObject == 'ASI_MFM_Plan__c' && planMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp2 = new headerClass();
                    
                    tmp2.objectTypeStr = (obj2.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp2.headerNumber = obj2.ProcessInstance.TargetObject.Name;
                    tmp2.headerId = obj2.ProcessInstance.TargetObjectId;
                    tmp2.currentApprover = obj2.Actor.Name;
                    tmp2.currentApproverId = obj2.ActorId;
                    tmp2.currentStatus = obj2.processinstance.Status;
                    tmp2.submitter = obj2.processinstance.createdBy.Name;
                    tmp2.submitterId = obj2.processinstance.createdByid;
                    tmp2.submissionDate = obj2.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp2.startDate = (obj2.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    //20180205
                    
                    tmp2.amount = planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c != Null ? String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c) : '';
                    tmp2.owner = String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).owner.Name);
                }
                
                if(tmp2 != Null){
                    csvList.add(tmp2);
                    approvalHistoryMap.remove(obj.ProcessInstance.TargetObjectId);
                    distinctSet.add(obj.ProcessInstance.TargetObjectId);
                }
            }
            
            if(((distinctSet.contains(obj.ProcessInstance.TargetObjectId) && !distinctSet2.contains(obj.ProcessInstance.TargetObjectId)) || (!distinctSet.contains(obj.ProcessInstance.TargetObjectId))) && (obj.StepStatus == 'Rejected' || (!hasRejected.contains(obj.ProcessInstance.TargetObjectId) && allBAUser.contains(obj.ActorId)))){
                
                if(selectedObject == 'ASI_MFM_Payment__c' && paymentMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp = new headerClass();
                    
                    tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                    tmp.headerId = obj.ProcessInstance.TargetObjectId;
                    tmp.currentStatus = obj.StepStatus;
                    tmp.startDate = (obj.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    tmp.submitter = obj.processinstance.createdBy.Name;
                    tmp.comments = obj.Comments != Null && obj.Comments != '' ? obj.Comments.replace('\r\n', ' ').replace(',', '') : '';
                    tmp.actualApprover = obj.Actor.Name;
                    tmp.submissionDate = obj.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp.currentApprover = obj.OriginalActor.Name;
                    
                    //20170830
                    tmp.BU = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__r.Name : '';
                    tmp.amount = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c) : '';
                    tmp.owner = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.owner.Name;
                    tmp.remark = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                    tmp.supplierName = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name : '';
                    tmp.supplierId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c) : '';
                    tmp.oneOffPayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c : '';
                    tmp.alternatePayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.name : '';
                    tmp.alternatePayeeId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c) : '';
                    tmp.bankDetails = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c : '';
                    tmp.paymentAmountNetOfTax = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c) : '';
                    tmp.discountPool = String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c);
                    tmp.relatedPO = paymentPOMap.containsKey(obj.ProcessInstance.TargetObjectId) ? paymentPOMap.get(obj.ProcessInstance.TargetObjectId) : '';
                    
                }else if(selectedObject == 'ASI_MFM_PO__c' && poMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp = new headerClass();
                    
                    tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                    tmp.headerId = obj.ProcessInstance.TargetObjectId;
                    tmp.currentStatus = obj.StepStatus;
                    tmp.startDate = (obj.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    tmp.submitter = obj.processinstance.createdBy.Name;
                    tmp.comments = obj.Comments != Null && obj.Comments != '' ? obj.Comments.replace('\r\n', ' ').replace(',', '') : '';
                    tmp.actualApprover = obj.Actor.Name;
                    tmp.submissionDate = obj.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp.currentApprover = obj.OriginalActor.Name;
                    
                    tmp.BU = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__r.Name : '';
                    tmp.amount = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c != Null ? String.valueOf(poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c) : '';
                    tmp.poStart = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c.format() : '';
                    tmp.poEnd = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c.format() : '';
                    tmp.owner = poMap.get(obj.ProcessInstance.TargetObjectId).owner.Name;
                    tmp.remark = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                    
                }else if(selectedObject == 'ASI_MFM_Plan__c' && planMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                    
                    //20180205 Introv
                    tmp = new headerClass();
                    
                    tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                    tmp.headerId = obj.ProcessInstance.TargetObjectId;
                    tmp.currentStatus = obj.StepStatus;
                    tmp.startDate = (obj.CreatedDate).format('dd/MM/yyyy hh:mm a');
                    tmp.submitter = obj.processinstance.createdBy.Name;
                    tmp.comments = obj.Comments != Null && obj.Comments != '' ? obj.Comments.replace('\r\n', ' ').replace(',', '') : '';
                    tmp.actualApprover = obj.Actor.Name;
                    tmp.submissionDate = obj.processinstance.CreatedDate.format('dd/MM/yyyy hh:mm a');
                    tmp.currentApprover = obj.OriginalActor.Name;
                    
                    tmp.amount = planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c != Null ? String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c) : '';
                    tmp.owner = String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).owner.Name);
                }
                
                if(tmp != Null){
                    csvList.add(tmp);
                    distinctSet.add(obj.ProcessInstance.TargetObjectId);
                    distinctSet2.add(obj.ProcessInstance.TargetObjectId);
                }
            }
        }
        pagereference pdfPage = new pagereference('/apex/ASI_MFM_CN_ApprovalHistoryCSV_Page');
        return pdfPage;
    }
    
    Public PageReference queryApprovalHistory(){
        
        if(selectedObject != Null && selectedObject != ''){
            
            TimeZone tz = UserInfo.getTimeZone();
            Integer offset = tz.getOffset(system.now())/1000;
            
            hasRejected = new Set<Id>(); //20180314 Introv
            Set<String> objectSet = new Set<String>();
            objectSet.add(selectedObject); // ProcessInstance.TargetObject.Type only support IN
            Set<Id> headerIdSet = new Set<Id>();
            distinctSet = new Set<Id>();
            
            if( (docNumber == Null || docNumber == '' ) && selectedDate.ASI_MFM_PaymentDate__c == Null){
                
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Please input Document Number Or Target Month before searching.'));
                Return Null;
            }
            
            selectedDate.ASI_MFM_PaymentDate__c = selectedDate.ASI_MFM_PaymentDate__c > date.today() ? date.today() : selectedDate.ASI_MFM_PaymentDate__c;
            
            Date startDate;
            Date endDate;
            
            if(selectedDate.ASI_MFM_PaymentDate__c != Null){
                startDate = date.newInstance(selectedDate.ASI_MFM_PaymentDate__c.year(), selectedDate.ASI_MFM_PaymentDate__c.month(), 1);
                endDate = date.newInstance(selectedDate.ASI_MFM_PaymentDate__c.year(), selectedDate.ASI_MFM_PaymentDate__c.month(), date.daysInMonth(selectedDate.ASI_MFM_PaymentDate__c.year(), selectedDate.ASI_MFM_PaymentDate__c.month()));
            }
            
            if(selectedDate.ASI_MFM_Accrual_Date__c != Null){
                endDate = date.newInstance(selectedDate.ASI_MFM_Accrual_Date__c.year(), selectedDate.ASI_MFM_Accrual_Date__c.month(), date.daysInMonth(selectedDate.ASI_MFM_Accrual_Date__c.year(), selectedDate.ASI_MFM_Accrual_Date__c.month()));
            }
            
            approvalHistoryMap = new Map<Id, ProcessInstanceWorkitem>();
            headerList = new List<headerClass>();
            JSONDate = '[';
            
            String workItemStr = 'SELECT ActorId'
                + ', OriginalActorId'
                + ', ProcessInstanceId'
                + ', Id'
                + ', processInstance.targetobjectid'
                + ', processinstance.createdByid'
                + ', processinstance.createdBy.Name'
                + ', processinstance.Status'
                + ', Actor.Name'
                + ', CreatedDate'
                + ', processinstance.CreatedDate'
                + ', processinstance.TargetObject.Name'
                + ', OriginalActor.Name'
                + ', CreatedBy.name'
                + ', CreatedByid'
                + ' FROM ProcessInstanceWorkitem'
                + ' WHERE ProcessInstance.TargetObject.Type IN : objectSet'
                + ' AND ProcessInstance.TargetObject.recordType.DeveloperName LIKE \'ASI_MFM_CN_%\'';
            
            if(startDate != Null && endDate != Null){
                workItemStr += ' AND ProcessInstance.createdDate >= : startDate';
                workItemStr += ' AND ProcessInstance.createdDate <= : endDate';
            }
            
            if(docNumber != Null && docNumber != '')
                workItemStr += ' AND ProcessInstance.TargetObject.Name Like : docNumber';
            
            workItemStr += ' ORDER BY ProcessInstance.createdDate DESC, CreatedDate DESC Limit 10000';
            
            currentItem = database.query(workItemStr);
            
            String stepItemStr = 'SELECT id'
                + ', Actor.Name'
                + ', ActorId'
                + ', OriginalActorId'
                + ', OriginalActor.Name'
                + ', ProcessInstance.TargetObjectId'
                + ', ProcessInstance.TargetObject.Type'
                + ', StepStatus'
                + ', ProcessInstance.TargetObject.recordType.DeveloperName'
                + ', ProcessInstance.TargetObject.Name'
                + ', ProcessInstance.createdBy.Name'
                + ', ProcessInstance.createdById'
                + ', Comments'
                + ', CreatedDate'
                + ', processinstance.Status'
                + ', processinstance.CreatedDate'
                + ', ElapsedTimeInDays'
                + ', ElapsedTimeInMinutes'
                + ', ProcessInstanceId'
                + ' FROM ProcessInstanceStep'
                + ' WHERE ProcessInstance.TargetObject.Type IN : objectSet'
                + ' AND ProcessInstance.TargetObject.recordType.DeveloperName LIKE \'ASI_MFM_CN_%\'';
                //+ ' AND StepStatus Like \'Rejected\'';
            
            if(startDate != Null && endDate != Null){
                stepItemStr += ' AND ProcessInstance.createdDate >= : startDate';
                stepItemStr += ' AND ProcessInstance.createdDate <= : endDate';
            }
            
            if(docNumber != Null && docNumber != '')
                stepItemStr += ' AND ProcessInstance.TargetObject.Name Like : docNumber';
            
            stepItemStr += ' ORDER BY ProcessInstance.createdDate DESC, CreatedDate DESC Limit 10000';
            
            approvalHistoryList = new List<ProcessInstanceStep>();
            approvalHistoryList2 = database.query(stepItemStr);
            
            //20170822 Introv
            
            for(ProcessInstanceWorkitem obj : currentItem){
                
                headerIdSet.add(obj.ProcessInstance.TargetObjectId);
            }
            
            for(ProcessInstanceStep obj : approvalHistoryList2){
                
                headerIdSet.add(obj.ProcessInstance.TargetObjectId);
            }
            
            if(selectedObject == 'ASI_MFM_Payment__c'){
                paymentMap = new Map<Id, ASI_MFM_Payment_Line_Item__c >();
                paymentPOMap = new Map<Id, String >();
                
                List<ASI_MFM_Payment_Line_Item__c> paymentList = new List<ASI_MFM_Payment_Line_Item__c>();
                
                if(selectedBU != '' && selectedBU != Null){
                    
                    paymentList = new List<ASI_MFM_Payment_Line_Item__c>([SELECT id, ASI_MFM_Payment__r.ASI_MFM_BU__r.Name, ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c
                                                                          , ASI_MFM_Payment__r.Owner.Name, ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c
                                                                          , ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.Name, ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c, ASI_MFM_Payment__r.ASI_MFM_Remarks__c
                                                                          , ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c, ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c
                                                                          , ASI_MFM_Payment__c, ASI_MFM_Payment__r.ASI_MFM_BU__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name
                                                                          FROM ASI_MFM_Payment_Line_Item__c
                                                                          WHERE ASI_MFM_Payment__c IN : headerIdSet
                                                                          AND ASI_MFM_Payment__r.ASI_MFM_BU__c = : selectedBU//20180204 Introv
                                                                         ]);
                }else{
                    
                    paymentList = new List<ASI_MFM_Payment_Line_Item__c>([SELECT id, ASI_MFM_Payment__r.ASI_MFM_BU__r.Name, ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c
                                                                          , ASI_MFM_Payment__r.Owner.Name, ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c
                                                                          , ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.Name, ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c, ASI_MFM_Payment__r.ASI_MFM_Remarks__c
                                                                          , ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c, ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c
                                                                          , ASI_MFM_Payment__c, ASI_MFM_Payment__r.ASI_MFM_BU__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name
                                                                          FROM ASI_MFM_Payment_Line_Item__c
                                                                          WHERE ASI_MFM_Payment__c IN : headerIdSet
                                                                         ]);
                }
                
                for(ASI_MFM_Payment_Line_Item__c obj : paymentList){
                    
                    paymentMap.put(obj.ASI_MFM_Payment__c, obj);
                    
                    String po = '';
                    
                    if(paymentPOMap.containsKey(obj.ASI_MFM_Payment__c))
                        po = paymentPOMap.get(obj.ASI_MFM_Payment__c);
                    
                    po += obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name + '/';
                    
                    paymentPOMap.put(obj.ASI_MFM_Payment__c, po);
                }
                
            }else if(selectedObject == 'ASI_MFM_PO__c'){
                
                
                if(selectedBU != '' && selectedBU != Null)
                    poMap = new Map<Id, ASI_MFM_PO__c>([SELECT id, ASI_MFM_BU_Code__r.Name, ASI_MFM_CN_PO_Amount_RMB__c
                                                        , ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c
                                                        , Owner.Name, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c
                                                        FROM ASI_MFM_PO__c
                                                        WHERE id IN : headerIdSet
                                                        AND ASI_MFM_BU_Code__c = : selectedBU//20180204 Introv
                                                       ]);
                else
                    poMap = new Map<Id, ASI_MFM_PO__c>([SELECT id, ASI_MFM_BU_Code__r.Name, ASI_MFM_CN_PO_Amount_RMB__c
                                                        , ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c
                                                        , Owner.Name, ASI_MFM_Remarks__c, ASI_MFM_BU_Code__c
                                                        FROM ASI_MFM_PO__c
                                                        WHERE id IN : headerIdSet
                                                       ]);
                    
            }else if(selectedObject == 'ASI_MFM_Plan__c'){
                
                planMap = new Map<Id, ASI_MFM_Plan__c>([SELECT id, ASI_MFM_Plan_Amount__c
                                                        , Owner.Name
                                                        FROM ASI_MFM_Plan__c
                                                        WHERE id IN : headerIdSet
                                                       ]);
            }
            
            headerIdSet = new Set<Id>();
            
            //20170822 End
            
            for(ProcessInstanceWorkitem obj : currentItem){
                
                if(!headerIdSet.contains(obj.ProcessInstance.TargetObjectId)){
                    
                    headerClass tmp;// = new headerClass();
                    /*tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                    tmp.headerId = obj.ProcessInstance.TargetObjectId;
                    tmp.currentApprover = obj.Actor.Name;
                    tmp.currentApproverId = obj.ActorId;
                    tmp.currentStatus = obj.processinstance.Status;
                    tmp.submitter = obj.processinstance.createdBy.Name;
                    tmp.submitterId = obj.processinstance.createdByid;
                    tmp.submissionDate = obj.CreatedDate.format('dd/MM/yyyy hh:mm a');*/
                    
                    if(selectedObject == 'ASI_MFM_Payment__c' && paymentMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentApprover = obj.Actor.Name;
                        tmp.currentApproverId = obj.ActorId;
                        tmp.currentStatus = obj.processinstance.Status;
                        tmp.submitter = obj.processinstance.createdBy.Name;
                        tmp.submitterId = obj.processinstance.createdByid;
                        tmp.submissionDate = obj.CreatedDate.format('dd/MM/yyyy hh:mm a');
                        //20180204
                        
                        //20170830
                        tmp.BU = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__r.Name : '';
                        tmp.amount = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c) : '';
                        tmp.owner = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.owner.Name;
                        tmp.remark = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                        tmp.supplierName = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name : '';
                        tmp.supplierId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c) : '';
                        tmp.oneOffPayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c : '';
                        tmp.alternatePayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.name : '';
                        tmp.alternatePayeeId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c) : '';
                        tmp.bankDetails = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c : '';
                        tmp.paymentAmountNetOfTax = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c) : '';
                        tmp.discountPool = String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c);
                        tmp.relatedPO = paymentPOMap.containsKey(obj.ProcessInstance.TargetObjectId) ? paymentPOMap.get(obj.ProcessInstance.TargetObjectId) : '';
                        
                    }else if(selectedObject == 'ASI_MFM_PO__c' && poMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentApprover = obj.Actor.Name;
                        tmp.currentApproverId = obj.ActorId;
                        tmp.currentStatus = obj.processinstance.Status;
                        tmp.submitter = obj.processinstance.createdBy.Name;
                        tmp.submitterId = obj.processinstance.createdByid;
                        tmp.submissionDate = obj.CreatedDate.format('dd/MM/yyyy hh:mm a');
                        //20180204
                        
                        tmp.BU = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__r.Name : '';
                        tmp.amount = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c != Null ? String.valueOf(poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c) : '';
                        tmp.poStart = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c.format() : '';
                        tmp.poEnd = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c.format() : '';
                        tmp.owner = poMap.get(obj.ProcessInstance.TargetObjectId).owner.Name;
                        tmp.remark = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                        
                    }else if(selectedObject == 'ASI_MFM_Plan__c' && planMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentApprover = obj.Actor.Name;
                        tmp.currentApproverId = obj.ActorId;
                        tmp.currentStatus = obj.processinstance.Status;
                        tmp.submitter = obj.processinstance.createdBy.Name;
                        tmp.submitterId = obj.processinstance.createdByid;
                        tmp.submissionDate = obj.CreatedDate.format('dd/MM/yyyy hh:mm a');
                        //20180204
                        
                        tmp.amount = planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c != Null ? String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c) : '';
                        tmp.owner = String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).owner.Name);
                    }
                    
                    if(tmp != Null){
                        headerList.add(tmp);
                        
                        headerIdSet.add(obj.ProcessInstance.TargetObjectId);
                    }
                }
                
                approvalHistoryMap.put(obj.ProcessInstance.TargetObjectId, obj);
            }
            
            for(ProcessInstanceStep obj : approvalHistoryList2){
                
                if(!headerIdSet.contains(obj.ProcessInstance.TargetObjectId)){
                    
                    headerClass tmp;// = new headerClass();
                    /*tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                    tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                    tmp.headerId = obj.ProcessInstance.TargetObjectId;
                    tmp.currentStatus = obj.processinstance.Status;*/
                    
                    if(selectedObject == 'ASI_MFM_Payment__c' && paymentMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentStatus = obj.processinstance.Status;
                        //20180204
                        
                        //20170830
                        tmp.BU = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_BU__r.Name : '';
                        tmp.amount = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Payment_Amount_RMB__c) : '';
                        tmp.owner = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.owner.Name;
                        tmp.remark = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                        tmp.supplierName = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name : '';
                        tmp.supplierId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c : '';
                        tmp.oneOffPayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_One_Off_Payee__c : '';
                        tmp.alternatePayee = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__r.name : '';
                        tmp.alternatePayeeId = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_AlternatePayee__c) : '';
                        tmp.bankDetails = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c != Null ? paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_Bank_Details__c : '';
                        tmp.paymentAmountNetOfTax = paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c != Null ? String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Payment_Amount_Net_of_Tax__c) : '';
                        tmp.discountPool = String.valueOf(paymentMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Payment__r.ASI_MFM_CN_Discount_Pool__c);
                        tmp.relatedPO = paymentPOMap.containsKey(obj.ProcessInstance.TargetObjectId) ? paymentPOMap.get(obj.ProcessInstance.TargetObjectId) : '';
                        
                    }else if(selectedObject == 'ASI_MFM_PO__c' && poMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentStatus = obj.processinstance.Status;
                        //20180204
                        
                        tmp.BU = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_BU_Code__r.Name : '';
                        tmp.amount = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c != Null ? String.valueOf(poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_CN_PO_Amount_RMB__c) : '';
                        tmp.poStart = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_Start_Date__c.format() : '';
                        tmp.poEnd = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_PO_End_Date__c.format() : '';
                        tmp.owner = poMap.get(obj.ProcessInstance.TargetObjectId).owner.Name;
                        tmp.remark = poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c != Null ? poMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Remarks__c.replace('\r\n', ' ').replace(',', '') : '';
                        
                    }else if(selectedObject == 'ASI_MFM_Plan__c' && planMap.containsKey(obj.ProcessInstance.TargetObjectId)){
                        
                        //20180204 Introv
                        tmp = new headerClass();
                        tmp.objectTypeStr = (obj.ProcessInstance.TargetObjectID).getSObjectType().getDescribe().getLabel();
                        tmp.headerNumber = obj.ProcessInstance.TargetObject.Name;
                        tmp.headerId = obj.ProcessInstance.TargetObjectId;
                        tmp.currentStatus = obj.processinstance.Status;
                        //20180204
                        
                        tmp.amount = planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c != Null ? String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).ASI_MFM_Plan_Amount__c) : '';
                        tmp.owner = String.valueOf(planMap.get(obj.ProcessInstance.TargetObjectId).owner.Name);
                    }
                    
                    if(tmp != Null){
                        headerList.add(tmp);
                        
                        headerIdSet.add(obj.ProcessInstance.TargetObjectId);
                    }
                }
                
                if(!distinctSet.contains(obj.ProcessInstance.TargetObjectId) && obj.StepStatus == 'Rejected'){
                    JSONDate += '{"id":"' + obj.id + '","submissionDate":"' + (obj.CreatedDate).format('dd/MM/yyyy hh:mm a') + '","approvedDate":"' + ((obj.CreatedDate.addSeconds(integer.valueOf((obj.ElapsedTimeInMinutes != Null ? obj.ElapsedTimeInMinutes : 0) * 60 )))).format('dd/MM/yyyy hh:mm a') + '","initalSubmissionDate":"' + (obj.processinstance.CreatedDate).format('dd/MM/yyyy hh:mm a') + '"},';
                    approvalHistoryList.add(obj);
                    hasRejected.add(obj.ProcessInstance.TargetObjectId);//20180314 Introv
                	distinctSet.add(obj.ProcessInstance.TargetObjectId);
                }
            }
            
            JSONDate = JSONDate.substring(0, JSONDate.length() - 1) + ']';
            
            JSONList = JSON.serialize(approvalHistoryList);
        }
        
        Return Null;
    }
    
    Public Class headerClass{
        
        Public Transient String objectTypeStr {Get; Set;}
        Public Transient String headerNumber {Get; Set;}
        Public Transient String headerId {Get; Set;}
        Public Transient String currentApprover {Get; Set;}
        Public Transient String currentApproverId {Get; Set;}
        Public Transient String currentStatus {Get; Set;}
        Public Transient String submitter {Get; Set;}
        Public Transient String submitterId {Get; Set;}
        Public Transient String submissionDate {Get; Set;}
        Public Transient String actualApprover {Get; Set;}
        Public Transient String actualApproverId {Get; Set;}
        Public Transient String startDate {Get; Set;}
        Public Transient String comments {Get; Set;}
        Public Transient String BU {Get; Set;}
        Public Transient String amount {Get; Set;}
        Public Transient String poStart {Get; Set;}
        Public Transient String poEnd {Get; Set;}
        Public Transient String remark {Get; Set;}
        Public Transient String owner {Get; Set;}
        Public Transient String supplierName {Get; Set;}
        Public Transient String supplierId {Get; Set;}
        Public Transient String oneOffPayee {Get; Set;}
        Public Transient String alternatePayee {Get; Set;}
        Public Transient String alternatePayeeId {Get; Set;}
        Public Transient String bankDetails {Get; Set;}
        Public Transient String paymentAmountNetOfTax {Get; Set;}
        Public Transient String discountPool {Get; Set;}
        Public Transient String relatedPO {Get; Set;}
    }
}