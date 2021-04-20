/*********************************************************************************
* Name: ASI_MFM_CN_SCPayment_PDFController
* Description: Controller class for Structure Cost Payment PDF 
* Related PDF : ASI_MFM_CN_SCPayment_PDFPage 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 28/03/2017       Tony Ren                 Created          
* 18/12/2020       BLS                      Changed          
*/

public class ASI_MFM_CN_SCPayment_PDFController {
    
    private final static Map<String, Schema.SObjectField> Payment_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PaymentDetail_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment_Detail__c.fields.getMap();
    
    public id paymentID {set;get;}
    public boolean showBudgetInfo {set;get;}
    public boolean isAdmin {Get; Set;}{isAdmin = False;}
    public boolean isApprover {Get; Set;}{isApprover = False;}
    public boolean isSCBalanceSheetOperation {Get; Set;}{isSCBalanceSheetOperation = False;} // add by BLS

    public ASI_MFM_Payment__c paymentCurrent{get;set;}{paymentCurrent= NEW ASI_MFM_Payment__c();}
   
    Public Map<String, List<ASI_MFM_Payment_Detail__c>> PayLineMap {get;set;}{PayLineMap= new Map<String, List<ASI_MFM_Payment_Detail__c>>();}
    Public List<apprivalHistoryClass> apprivalHistoryList {Get; Set;}{apprivalHistoryList = new List<apprivalHistoryClass>();}
    
    public ASI_MFM_CN_SCPayment_PDFController(){}
    
    Public Boolean hasLine {Get; Set;}{hasLine = False;}
    Public Boolean isAccrual {Get; Set;}{isAccrual = False;}
    
    public ASI_MFM_CN_SCPayment_PDFController(ApexPages.StandardController controller) {
        this.paymentCurrent = (ASI_MFM_Payment__c)controller.getRecord();
        
    }  
    
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init(){
        
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT id FROM PermissionSetAssignment WHERE AssigneeId = : userInfo.getUserId() AND PermissionSet.Name Like '%ASI_MFM_CN_StructureCost_AdminUser%']);
        if(psa.size() > 0)
            isAdmin = True;
        
        List<GroupMember> gm = new List<GroupMember>([SELECT GroupId, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName LIKE 'ASI_MFM_CN_SC_Approver_Group' AND UserOrGroupId = : userInfo.getUserId()]);
        if(gm.size() > 0)
            isApprover = True;
        
        paymentCurrent=RetrievePaymentInfo(paymentID);
        
        if(paymentCurrent != Null && paymentCurrent.ASI_MFM_Prefix__r.ASI_MFM_Module__c.contains('Structure Cost Accrual')){
            isAccrual = True;
        }

        if(paymentCurrent != Null && paymentCurrent.ASI_MFM_Expense_Type__r?.ASI_MFM_PP_Category__r?.ASI_MFM_External_ID__c == 'Structure Cost - BalanceSheet Operation'){
            isSCBalanceSheetOperation = True;
        }
        
        //20170721 Introv
        if(paymentCurrent != Null){
            
            apprivalHistoryList = getApprovalHisotry(paymentCurrent.id);
            
            if(paymentCurrent.ASI_MFM_Remarks__c != '' && paymentCurrent.ASI_MFM_Remarks__c != null && paymentCurrent.ASI_MFM_Remarks__c.length() > 14)
                paymentCurrent.ASI_MFM_Remarks__c = ASI_MFM_CN_StructureCostHelperClass.splitString(paymentCurrent.ASI_MFM_Remarks__c, 14);
            
            if(paymentCurrent.ASI_MFM_Contract__r.ASI_MFM_Contract__c != '' && paymentCurrent.ASI_MFM_Contract__r.ASI_MFM_Contract__c != Null && paymentCurrent.ASI_MFM_Contract__r.ASI_MFM_Contract__c.length() > 14)
                paymentCurrent.ASI_MFM_Contract__r.ASI_MFM_Contract__c = ASI_MFM_CN_StructureCostHelperClass.splitString(paymentCurrent.ASI_MFM_Contract__r.ASI_MFM_Contract__c, 14);
        }
        
        List<ASI_MFM_Payment_Detail__c> PaymentLineList=RetrievePaymentDetailsInfo(paymentID);
        
        if(PaymentLineList != Null){
            hasLine = True;
        
            for(ASI_MFM_Payment_Detail__c payLine:PaymentLineList){
                if(PayLineMap.containsKey(payLine.RecordType.Name)){
                    PayLineMap.get(payLine.RecordType.Name).add(payLine);
                }else{
                    List<ASI_MFM_Payment_Detail__c> TempLineList= new List<ASI_MFM_Payment_Detail__c>();
                    TempLineList.add(payLine);
                    PayLineMap.put(payLine.RecordType.Name, TempLineList);
                }
            }
        }
        //system.assertEquals(null,PayLineMap);
        
        return true;
    }
    
    private ASI_MFM_Payment__c RetrievePaymentInfo(String HeaderId) {
        String query = 'SELECT ' + genQueryField(Payment_FIELD_MAP) + 
            ',ASI_MFM_Expense_Type__r.Name,ASI_MFM_Budget_Owner__r.Name,ASI_MFM_Supplier_Name__r.Name, RecordType.DeveloperName,ASI_MFM_Contract__r.Name,ASI_MFM_PO__r.Name ' +
            ',ASI_MFM_Contract__r.ASI_MFM_Contract__c,ASI_MFM_Tax_Code__r.Name, ASI_MFM_Expense_Type__r.ASI_MFM_AllocationMethod__c, ASI_MFM_Prefix__r.ASI_MFM_Module__c ' +
            ', ASI_MFM_Contract__r.ASI_MFM_Rental_Request__r.Name, ASI_MFM_Prefix__r.Name, ASI_MFM_Expense_Type__r.ASI_MFM_PP_Category__r.ASI_MFM_External_ID__c ' +
            'FROM ASI_MFM_Payment__c ' + 'Where Id = \''+HeaderId+'\' ';
        
        List<ASI_MFM_Payment__c> PaymentList = (List<ASI_MFM_Payment__c>) Database.query(query);
        return PaymentList.size() > 0 ? PaymentList.get(0) : null;
    }
    
    private List<ASI_MFM_Payment_Detail__c>  RetrievePaymentDetailsInfo(String HeaderId) {
        String query = 'SELECT ' + genQueryField(PaymentDetail_FIELD_MAP) + 
            ', RecordType.DeveloperName,RecordType.Name ' + 
            'FROM ASI_MFM_Payment_Detail__c ' + 
            'Where ASI_MFM_Payment__c = \''+HeaderId+'\'';
        List<ASI_MFM_Payment_Detail__c> PaymentList = (List<ASI_MFM_Payment_Detail__c>) Database.query(query);
        return PaymentList.size() > 0 ? PaymentList : null;
    }
    
    
    /***************  * *  Tools Function    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
    
    Private List<apprivalHistoryClass> getApprovalHisotry(String paymentId){
        
        List<apprivalHistoryClass> ac = new List<apprivalHistoryClass>();
        
        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>([Select Actor.Name, ProcessInstanceId, ProcessInstance.CreatedDate, ProcessInstance.createdBy.Name From ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId = : paymentId Order By CreatedDate DESC Limit 1]);
        
        if(piwi.size() > 0){
            
            for(ProcessInstanceStep obj : [Select Actor.Name, StepStatus, ElapsedTimeInMinutes, createdDate From ProcessInstanceStep Where ProcessInstanceId = : piwi[0].ProcessInstanceId ]){
                
                if(obj.StepStatus == 'Started')
                    continue;
                
                apprivalHistoryClass tmp = new apprivalHistoryClass();

                tmp.approver = obj.Actor.Name;
                tmp.approvalStatus = obj.StepStatus == 'Started' ? 'Submitted' : obj.StepStatus == 'Removed' ? 'Recalled' : obj.StepStatus;
                tmp.approvedDate = obj.createdDate.format('yyyy-MM-dd');
                
                ac.add(tmp);
            }
            
            apprivalHistoryClass tmp2 = new apprivalHistoryClass();
            tmp2.approver = piwi[0].ProcessInstance.createdBy.Name;
            tmp2.approvalStatus = 'Submitted';
            tmp2.approvedDate = piwi[0].ProcessInstance.CreatedDate.format('yyyy-MM-dd');
            
            ac.add(tmp2);
            
            Return ac;
            
        }else{
            
            List<ProcessInstanceStep> pis = new List<ProcessInstanceStep>([Select Actor.Name, StepStatus, ElapsedTimeInMinutes, createdDate, ProcessInstanceId From ProcessInstanceStep Where ProcessInstance.TargetObjectId = : paymentId Order By CreatedDate DESC]);
            
            String piId = '';
            
            if(pis.size() > 0){
                
                for(ProcessInstanceStep obj : pis){
                    
                    if(piId != '' && piId != obj.ProcessInstanceId)
                        Break;
                    
                    apprivalHistoryClass tmp = new apprivalHistoryClass();
                    
                    tmp.approver = obj.Actor.Name;
                    tmp.approvalStatus = obj.StepStatus == 'Started' ? 'Submitted' : obj.StepStatus == 'Removed' ? 'Recalled' : obj.StepStatus;
                    tmp.approvedDate = obj.createdDate.format('yyyy-MM-dd');
                    
                    piId = obj.ProcessInstanceId;
                    ac.add(tmp);
                }
                
                Return ac;
            }else{
                
                Return new List<apprivalHistoryClass>();
            }
        }
    }
    
    Public Class apprivalHistoryClass{
        
        Public String approver{Get; Set;}
        Public String approvedDate{Get; Set;}
        Public String approvalStatus{Get; Set;}
    }
}