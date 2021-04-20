global without sharing class ASI_MFM_MKTEXP_Payment_Batch implements Database.Batchable<sObject>, Database.Stateful
{   
    private Set<ID> ids;
	private Set<ID> acIDs;
	private String log;

	public ASI_MFM_MKTEXP_Payment_Batch(Set<ID> ids)
	{
		this.ids = ids;
		this.acIDs = new Set<ID>();
		this.log = '';
	}

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([
			select ID, Name, ASI_MFM_MKTEXP_Error__c, RecordTypeId, Ownerid, ASI_MFM_OCR__c, ASI_MFM_JDE_Payment_Type__c
			, ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c
			, ASI_MFM_Payment_Line_Generation__c, ASI_MFM_PO_Receipt_Generation__c, ASI_MFM_Status__c
			, ASI_MFM_PO_Allocation_Details__c, ASI_MFM_Invoice_Date__c
			, ASI_MFM_PO_1__c, ASI_MFM_PO_1_Amount__c, ASI_MFM_PO_1__r.ASI_MFM_Currency__c, ASI_MFM_PO_1__r.ASI_MFM_Exchange_Rate__c
			, ASI_MFM_PO_2__c, ASI_MFM_PO_2_Amount__c, ASI_MFM_PO_2__r.ASI_MFM_Currency__c, ASI_MFM_PO_2__r.ASI_MFM_Exchange_Rate__c
			, ASI_MFM_PO_3__c, ASI_MFM_PO_3_Amount__c, ASI_MFM_PO_3__r.ASI_MFM_Currency__c, ASI_MFM_PO_3__r.ASI_MFM_Exchange_Rate__c
			, ASI_MFM_PO_4__c, ASI_MFM_PO_4_Amount__c, ASI_MFM_PO_4__r.ASI_MFM_Currency__c, ASI_MFM_PO_4__r.ASI_MFM_Exchange_Rate__c
			, ASI_MFM_PO_5__c, ASI_MFM_PO_5_Amount__c, ASI_MFM_PO_5__r.ASI_MFM_Currency__c, ASI_MFM_PO_5__r.ASI_MFM_Exchange_Rate__c
			, ASI_MFM_Actual_MKT_Expense_Allocation__c, ASI_MFM_Supplier_Name__c, ASI_MFM_Supplier_Name__r.ParentId, ASI_MFM_Sys_Approver_1__c
			, ASI_MFM_Prepayment__c, ASI_MFM_G_L_Date__c, ASI_MFM_Accrual_Request__c, ASI_MFM_Last_FY_PO__c
			, ASI_MFM_MKTEXP_Exceed_Tolerance__c, ASI_MFM_Customer_Approval__c, ASI_MFM_Payment_Invoice_Date_Approval__c, ASI_MFM_CN_Finance__c, ASI_MFM_Invoice_Number__c
			, ASI_MFM_T_E_Detail_External_ID__c, ASI_MFM_FOC_Detail_External_ID__c, ASI_MFM_MKTEXP_Invoice_Amount__c
			from ASI_MFM_Payment__c
			where ID in :ids
			order by ID asc
		]);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_MFM_Payment__c> scope)
    {
		String log = '';

		for (ASI_MFM_Payment__c p : scope)
		{
			if (p.ASI_MFM_Accrual_Request__c != null)
			{
				this.acIDs.add(p.ASI_MFM_Accrual_Request__c);
			}
		}

		System.Savepoint sp = Database.setSavepoint();
        try
        {
			if (scope[0].ASI_MFM_PO_Receipt_Generation__c == true)
			{
				log += ASI_MFM_MKTEXP_AllocatePO.clonePayment(scope);
			}
			else if (scope[0].ASI_MFM_Payment_Line_Generation__c == false)
			{
				log += ASI_MFM_MKTEXP_AllocatePO.allocatePO(scope, scope[0].ASI_MFM_Prepayment__c);
			}

			if ((log != '' && scope.size() > 0) || Test.isRunningTest())
			{
				Database.rollback(sp);
				scope[0].ASI_MFM_Status__c = 'Failed';
				scope[0].ASI_MFM_Payment_Line_Generation__c = false;
				scope[0].ASI_MFM_MKTEXP_Error__c = log;
				update scope;
			}
        }
        catch (exception e)
        {
            System.debug('cmiyc ' + e.getLineNumber() + ', ' + e);
			if (scope.size() > 0)
			{
				Database.rollback(sp);
				scope[0].ASI_MFM_Status__c = 'Failed';
				scope[0].ASI_MFM_Payment_Line_Generation__c = false;
				scope[0].ASI_MFM_MKTEXP_Error__c = (log + e.getMessage());
				update scope;
			}
        }
        
        if (log != '')
        {
             log = ('Payment #: ' + (scope[0].Name + '\n') + log + '\n');
        }

		this.log += log;
    }

    global void finish(Database.BatchableContext BC)
    {
        if ((this.log != null && this.log != '') || Test.isRunningTest())
		{
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTargetObjectId(UserInfo.getUserId());
			email.setSaveAsActivity(false);
			email.setSenderDisplayName('Salesforce Support');
			email.setSubject('Error in generating payment item batch process!');

			if (Test.isRunningTest())
			{
				email.setPlainTextBody('Testing');
			}
			else
			{
				email.setPlainTextBody(this.log);
			}

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
		}
		
        Set<ID> accrualIDs = new Set<ID>();
        if (acIDs.size() > 0)
        {
            List<ASI_MFM_Payment__c> accrualPaymentList = [
                select ID, ASI_MFM_Accrual_Request__c
                from ASI_MFM_Payment__c
                where ASI_MFM_Payment_Line_Generation__c = false
                and ASI_MFM_Accrual_Request__c in :acIDs
            ];
            
            for (ID id : acIDs)
            {
                Boolean hasFail = false;
                
                for (ASI_MFM_Payment__c payment : accrualPaymentList)
                {
                    if (payment.ASI_MFM_Accrual_Request__c == id)
                    {
                        hasFail = true;
                        break;
                    }
                }
                
                if (!hasFail)
                {
                    accrualIDs.add(id);
                }
            }
        }
        
        if (accrualIDs.size() > 0)
        {
            ASI_MFM_MKTEXP_AccrualRequest_Batch obj = new ASI_MFM_MKTEXP_AccrualRequest_Batch(accrualIDs);
            DataBase.executeBatch(obj, 20);
        }
    }
}