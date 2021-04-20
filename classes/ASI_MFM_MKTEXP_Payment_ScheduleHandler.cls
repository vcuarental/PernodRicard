global class ASI_MFM_MKTEXP_Payment_ScheduleHandler implements schedulable
{
    global void execute(Schedulablecontext sc)
    {
		ASI_MFM_MKTEXP_Payment_Queue.run();
    }
}