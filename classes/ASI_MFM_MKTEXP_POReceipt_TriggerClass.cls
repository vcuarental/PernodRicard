public without sharing class ASI_MFM_MKTEXP_POReceipt_TriggerClass {
	public static void routineAfterUpsert(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {
		if (System.IsBatch() == false && System.isFuture() == false)
		{
			Set<ID> cIDs = new Set<ID>();
            Set<ID> qIDs = new Set<ID>();
            
            for (ASI_MFM_PO_Receipt__c p : trigger_new)
			{
				if (trigger_oldMap != null)
				{
					ASI_MFM_PO_Receipt__c o = trigger_oldMap.get(p.ID);

					if (o.ASI_MFM_Status__c != 'Final' && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Payment__c != null)
					{
						cIDs.add(p.ASI_MFM_Payment__c);
					}
				}
			}

			if (cIDs.size() > 0)
			{
				List<ASI_MFM_PO_Receipt__c> cList = [
					select ID, ASI_MFM_Payment__c, ASI_MFM_Status__c
					from ASI_MFM_PO_Receipt__c
					where ASI_MFM_Payment__c in :cIDs
				];

				Map<ID, Integer> totalMap = new Map<ID, Integer>();
				Map<ID, Integer> finishMap = new Map<ID, Integer>();

				for (ASI_MFM_PO_Receipt__c p : cList)
				{
					Integer total = totalMap.get(p.ASI_MFM_Payment__c);
					Integer finished = finishMap.get(p.ASI_MFM_Payment__c);

					if (total == null)
					{
						total = 0;
					}

					if (finished == null)
					{
						finished = 0;
					}

					totalMap.put(p.ASI_MFM_Payment__c, total + 1);

					if (p.ASI_MFM_Status__c == 'Final')
					{
						finishMap.put(p.ASI_MFM_Payment__c, finished + 1);
					}
				}

				for (ID id : cIDs)
				{
					Integer total = totalMap.get(id);
					Integer finished = finishMap.get(id);

					if (total == finished)
					{
                        qIDs.add(id);
					}
				}
			}

			if (qIDs.size() > 0)
			{
				ASI_MFM_MKTEXP_Payment_Queue.add(qIDs);
			}
		}

        Map<Id, ASI_MFM_PO_Receipt__c> receMap = new Map <Id, ASI_MFM_PO_Receipt__c>();
        List <ASI_MFM_PO_Receipt_Item__c> itemList = new List<ASI_MFM_PO_Receipt_Item__c>();
		Set<ID> poReceiptSet = new Set<ID>();
		Set<ID> paymentSet = new Set<ID>();

        for(ASI_MFM_PO_Receipt__c p : trigger_new)
        {
			if (trigger_oldMap == null || (trigger_oldMap != null && trigger_oldMap.get(p.ID).ASI_MFM_Status__c != p.ASI_MFM_Status__c))
			{
				receMap.put(p.Id , p);

				if (p.ASI_MFM_Status__c == 'Rejected')
				{
					if (p.ASI_MFM_Payment__c != null)
					{
						paymentSet.add(p.ASI_MFM_Payment__c);
					}

					poReceiptSet.add(p.ID);
				}
			}
        }
		for(ASI_MFM_PO_Receipt_Item__c item: [
                    select Id, ASI_MFM_PO_Receipt__c, ASI_MFM_Status__c
            		from ASI_MFM_PO_Receipt_Item__c
            		where ASI_MFM_PO_Receipt__c in : receMap.keySet()
                    ])
        {        	
            item.ASI_MFM_Status__c = receMap.get(item.ASI_MFM_PO_Receipt__c).ASI_MFM_Status__c;
            itemList.add(item);
        }

        if(!itemList.isEmpty())
        {
            update itemList;
        } 
        
		if (paymentSet.size() > 0)
		{
			List<ASI_MFM_Payment__c> paymentList = [
				select ID, ASI_MFM_Status__c
				from ASI_MFM_Payment__c
				where ID in :paymentSet
			];

			List<ASI_MFM_PO_Receipt__c> poReceiptList = [
				select ID, ASI_MFM_Status__c
				from ASI_MFM_PO_Receipt__c
				where ASI_MFM_Payment__c in :paymentSet
				and ID not in :poReceiptSet
			];

			for (ASI_MFM_Payment__c payment : paymentList)
			{
				payment.ASI_MFM_Status__c = 'Cancelled';
			}

			for (ASI_MFM_PO_Receipt__c receipt : poReceiptList)
			{
				receipt.ASI_MFM_Status__c = 'Cancelled';
			}

			if (paymentList.size() > 0)
			{
				update paymentList;
			}

			if (poReceiptList.size() > 0)
			{
				update poReceiptList;
			}
		}
    }
       
	public static void routineBeforeUpsert(list<ASI_MFM_PO_Receipt__c> trigger_new, map<id, ASI_MFM_PO_Receipt__c> trigger_oldMap) {

	}

	public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt__c> trigger_old) {

	}

	public static void routineAfterDelete(list<ASI_MFM_PO_Receipt__c> trigger_old) {

	}
}