Global class ASI_MFM_CN_CheckItemGroupCode_Schd implements Schedulable{
    Global void execute(SchedulableContext sc) {
        database.executebatch(new ASI_MFM_CN_CheckItemGroupCode_Batch());
    }
}