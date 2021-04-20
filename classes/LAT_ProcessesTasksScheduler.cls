global class LAT_ProcessesTasksScheduler implements Schedulable {

    
    global void execute(SchedulableContext sc) {
        Set< Id > setRecTypeTasks = Global_RecordTypeCache.getRtIdSet('Task', new set<String>{'LAT_POP'});

        List<LAT_ProcessesEmails.emailMsg> duedTasks = new List<LAT_ProcessesEmails.emailMsg>();
        List<String> usersIds = new List<String>();

        integer dueDays = 7; 
        String[] days = LAT_GeneralConfigDao.getValueAsStringArray('POP_TASKS_REMAINDER_DAYS', ' ');
        if(days != null && days.size()>0)dueDays = integer.valueof(days[0]);
        
        for(Task ts :[Select id,OwnerId,Subject,ActivityDate from Task where ActivityDate != null and recordtypeId in: setRecTypeTasks AND status != 'Completed' AND status != 'Concluído']){
            if(ts.ActivityDate < Date.today() && (ts.ActivityDate == Date.today().addDays(-1) || Math.mod(ts.ActivityDate.daysBetween(Date.today()),  dueDays) == 0)){
                LAT_ProcessesEmails.emailMsg tmpMsg = new LAT_ProcessesEmails.emailMsg(new List<String>{ts.OwnerId},Label.LAT_Processes_012, Label.LAT_Processes_011.replace('{0}',URL.getSalesforceBaseUrl().getHost() + '/' + ts.id).replace('{1}',ts.subject));
                
                duedTasks.add(tmpMsg);
                usersIds.add(ts.OwnerId);
            } 
        }

        Map<Id,User> usersMap = new Map<Id,User>([Select id,managerId from User where id in :usersIds]);

        for(LAT_ProcessesEmails.emailMsg msg : duedTasks){
            User tmpUser = usersMap.get(msg.emailAddress.get(0));
            if(tmpUser != null && tmpUser.managerId != null)msg.emailAddress.add(tmpUser.managerId);
        }

            LAT_ProcessesEmails.sendEmail(duedTasks);
        
        

    }
}