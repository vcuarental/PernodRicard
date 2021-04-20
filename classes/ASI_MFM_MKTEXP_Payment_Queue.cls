public class ASI_MFM_MKTEXP_Payment_Queue
{
	public static void add(Set<ID> ids)
	{
		List<ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c> insertPSJList = new List<ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c>();

		for (ID id : ids)
		{
			insertPSJList.add(new ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c(
				ASI_MFM_Payment__c = id
			));
		}

		if (insertPSJList.size() > 0)
		{
			insert insertPSJList;
			run();
		}
	}

	public static void run()
	{
		List<ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c> pfsList = [
			select ID, ASI_MFM_Payment__c
			from ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c
			order by ID
			limit 2000
		];
        Set<ID> ids = new Set<ID>();

		for (ASI_MFM_MKTEXP_Payment_For_Schedule_Job__c pfs : pfsList)
		{
			ids.add(pfs.ASI_MFM_Payment__c);
		}

		if (ids.size() > 0)
		{
			ID classID = [Select ID from ApexClass where Name = 'ASI_MFM_MKTEXP_Payment_Batch'][0].ID;
			List<AsyncApexJob> jobList = [
				select ApexClassID, Status
				from AsyncApexJob
				where JobType = 'BatchApex'
				and ApexClassID = :classID
				and Status != 'Aborted' and Status != 'Completed' and Status != 'Failed'
			];

			if (jobList.size() == 0)
			{
				ASI_MFM_MKTEXP_Payment_Batch obj = new ASI_MFM_MKTEXP_Payment_Batch(ids);
            	DataBase.executeBatch(obj, 1);

				delete pfsList;
			}
		}
	}
}