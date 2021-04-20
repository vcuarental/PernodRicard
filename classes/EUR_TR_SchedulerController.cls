global class EUR_TR_SchedulerController implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Id cancelTaskJobId = Database.executeBatch(new EUR_TR_TaskTransferBatch(EUR_TR_TaskTransferBatch.RunModes.Cancel));
        Id otherTaskJobId = Database.executeBatch(new EUR_TR_TaskTransferBatch(EUR_TR_TaskTransferBatch.RunModes.Other));
        System.debug('EUR_TR_TaskTransferBatch called: ' + cancelTaskJobId);
        System.debug('EUR_TR_TaskTransferBatch called: ' + otherTaskJobId);

        EUR_TR_RemPeopleControllerUtil.doCallout();
        System.debug('EUR_TR_RemPeopleControllerUtil called');

        EUR_TR_CensusControllerUtil.doCallout();
        System.debug('EUR_TR_CensusControllerUtil called');

        Id closeWorkedDayBatch = Database.executeBatch(new EUR_TR_CloseWorkedDayBatch(), 1);
        System.debug('EUR_TR_CloseWorkedDayBatch called: ' + closeWorkedDayBatch);
    }
}