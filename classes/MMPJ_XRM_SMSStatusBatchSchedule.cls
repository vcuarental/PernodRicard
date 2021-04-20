global class MMPJ_XRM_SMSStatusBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
      MMPJ_XRM_SMSStatusBatch batch = new MMPJ_XRM_SMSStatusBatch();
      database.executebatch(batch,100);

   }
}