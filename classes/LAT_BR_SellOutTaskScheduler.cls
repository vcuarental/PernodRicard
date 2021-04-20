global class LAT_BR_SellOutTaskScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		Boolean colletaCreateTasks = false;
		String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('COLLETA_CREATE_TASKS', ',');
        if (!stringBoolean.isEmpty()) {
            colletaCreateTasks = Boolean.valueOf(stringBoolean[0]);
        } 

        if (colletaCreateTasks) {
        	Date lastDay = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        	LAT_BR_SellOutTaskCreator.createTask(lastDay);
        }
	}
}