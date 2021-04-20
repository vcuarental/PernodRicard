global class ASI_CRM_CN_UpdateChannelStrategy_Schd implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new ASI_CRM_CN_UpdateChannelStrategy_Batch());
   }
}