public without sharing class ASI_MFM_AccrualRequest_TriggerClass {

    public static void routineBeforeUpsert(list<ASI_MFM_Accrual_Request__c> trigger_new, map<id, ASI_MFM_Accrual_Request__c> trigger_oldMap) {
        System.debug('Start Acrrual Request routineBeforeUpsert');

        Set<Id> setAccrualRequestId = new Set<Id>();
        List<ASI_MFM_Accrual_Request__c> listDupAccrualRequest;
        Set<String> setYear = new Set<String> ();
        Set<String> setMonth = new Set<String> ();
        
        for (ASI_MFM_Accrual_Request__c ar : trigger_new){
            if(ar.ASI_MFM_Status__c == 'Submitted' && ar.ASI_MFM_A_D__c == false) {
                setAccrualRequestId.add(ar.id);
                if(!setYear.contains(ar.ASI_MFM_Year__c))
                    setYear.add(ar.ASI_MFM_Year__c);
                if(!setMonth.contains(ar.ASI_MFM_Month__c))
                    setMonth.add(ar.ASI_MFM_Month__c);
            }
        }
        
        if(setAccrualRequestId != null && setAccrualRequestId.size()>0)
            listDupAccrualRequest = [SELECT id, Name, ASI_MFM_Company_Code__c, ASI_MFM_Year__c, ASI_MFM_Month__c, ASI_MFM_Interface_Method__c, ASI_MFM_Status__c FROM ASI_MFM_Accrual_Request__c WHERE recordType.developerName = 'ASI_MFM_MKTEXP_Accrual_Request' AND ASI_MFM_Year__c IN :setYear AND ASI_MFM_Month__c IN :setMonth AND ASI_MFM_Status__c <> 'New'];

        if(listDupAccrualRequest != null && listDupAccrualRequest.size()>0)
            for (ASI_MFM_Accrual_Request__c ar : trigger_new)
                for (ASI_MFM_Accrual_Request__c arToCompare : listDupAccrualRequest) {
                    if(ar.id != arToCompare.id && arToCompare.ASI_MFM_Year__c == ar.ASI_MFM_Year__c && arToCompare.ASI_MFM_Month__c == ar.ASI_MFM_Month__c &&
                        (arToCompare.ASI_MFM_Company_Code__c == ar.ASI_MFM_Company_Code__c || arToCompare.ASI_MFM_Company_Code__c == 'ALL' || ar.ASI_MFM_Company_Code__c == 'ALL')) {
                        if(arToCompare.ASI_MFM_Interface_Method__c == 'Accrual Interface' && ar.ASI_MFM_Interface_Method__c == 'JDE Interface')
                            ar.addError('JDE Inteface is not allowed after Accrual Interface: ' + arToCompare.Name);
                        if(arToCompare.ASI_MFM_Status__c != 'JDE Accrual Completed')
                            ar.addError('Accrual Request ' + arToCompare.Name + ' is in progress. Please submit after completion.');
                    }
                }
    }

    public static void routineAfterUpsert(list<ASI_MFM_Accrual_Request__c> trigger_new, map<id, ASI_MFM_Accrual_Request__c> trigger_oldMap) {
        System.debug('Start Acrrual Request routineAfterUpsert');

        if (System.IsBatch() == false && System.isFuture() == false)
        {
            Set<ID> qIDs = new Set<ID>();
            Set<ID> pgIDs = new Set<ID>();
            Set<ID> ssIDs = new Set<ID>();
            for (ASI_MFM_Accrual_Request__c ar: trigger_new)
            {
                if (trigger_oldMap != null)
                {
                    ASI_MFM_Accrual_Request__c oar = trigger_oldMap.get(ar.ID);
                    if (oar.ASI_MFM_Status__c != 'ETL Create Payment Completed' && ar.ASI_MFM_Status__c == 'ETL Create Payment Completed')
                    {
                        pgIDs.add(ar.ID);
                    }
                    else if (oar.ASI_MFM_Status__c != 'Snapshot Work In Progress' && ar.ASI_MFM_Status__c == 'Snapshot Work In Progress')
                    {
                        ssIDs.add(ar.ID);
                    }
                }
            }

            if (pgIDs.size() > 0)
            {
                List<ASI_MFM_Payment__c> paymentList = [
                    select ID, ASI_MFM_Prepayment__c
                    from ASI_MFM_Payment__c
                    where ASI_MFM_Accrual_Request__c in :pgIDs
                    order by ASI_MFM_Accrual_Request__c, ID
                ];

                // add non pre payment first
                for (ASI_MFM_Payment__c p : paymentList)
                {
                    if (p.ASI_MFM_Prepayment__c == false)
                    {
                        qIDs.add(p.ID);
                    }
                }

                for (ASI_MFM_Payment__c p : paymentList)
                {
                    if (p.ASI_MFM_Prepayment__c == true)
                    {
                        qIDs.add(p.ID);
                    }
                }
            }

            if (qIDs.size() > 0)
			{
				ASI_MFM_MKTEXP_Payment_Queue.add(qIDs);
			}

            if (ssIDs.size() > 0)
            {
                ASI_MFM_MKTEXP_AccrualRequest_Batch obj = new ASI_MFM_MKTEXP_AccrualRequest_Batch(ssIDs);
				DataBase.executeBatch(obj, 20);
            }
        }
    }
}