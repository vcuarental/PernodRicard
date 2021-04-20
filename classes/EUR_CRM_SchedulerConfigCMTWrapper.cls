public with sharing class EUR_CRM_SchedulerConfigCMTWrapper {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public Map<String, Integer> getBatchSizeByBatchClassName(String apexSchedulerJobClass, Datetime dt) {
        List<EUR_CRM_SchedulerConfig__mdt> schedulerConfigs = selectSchedulerConfigs(apexSchedulerJobClass);
        System.debug('\n\n schedulerConfigs.size() => ' + JSON.serializePretty(schedulerConfigs.size()) + '\n');
        System.debug('\n\n schedulerConfigs => ' + JSON.serializePretty(schedulerConfigs) + '\n');
        if (schedulerConfigs.isEmpty()) { return new Map<String, Integer>(); }

        Integer day = dt.day();
        Integer hour = dt.hour();
        Integer quarterMinutes = this.getQuarterMinutes(dt);

        Map<String, Integer> batchSizeByBatchClassName = new Map<String, Integer>();
        for (EUR_CRM_SchedulerConfig__mdt schedulerConfig : schedulerConfigs) {
            if (this.isValidTime(schedulerConfig, day, hour, quarterMinutes)) {
                batchSizeByBatchClassName.put(schedulerConfig.EUR_CRM_ApexBatchJobClass__c, (Integer)schedulerConfig.EUR_CRM_BatchSize__c);
            }
        }
        return batchSizeByBatchClassName;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Boolean isValidTime(EUR_CRM_SchedulerConfig__mdt schedulerConfig, Integer day, Integer hour, Integer quarterMinutes) {
        return this.isValidDay(schedulerConfig, day)
            && this.isValidHour(schedulerConfig, hour)
            && this.isValidQuarterMinutes(schedulerConfig, quarterMinutes)
        ;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Integer getQuarterMinutes(Datetime dt) {
        return (Integer)(dt.minute() / 15);
    }

    private Boolean isValidDay(EUR_CRM_SchedulerConfig__mdt schedulerConfig, Integer day) {
        return schedulerConfig.EUR_CRM_Days__c.equalsIgnoreCase('00')
            || schedulerConfig.EUR_CRM_Days__c.containsIgnoreCase(String.valueOf(day));
    }

    private Boolean isValidHour(EUR_CRM_SchedulerConfig__mdt schedulerConfig, Integer hour) {
        return schedulerConfig.EUR_CRM_Hours__c.equalsIgnoreCase('00')
            || schedulerConfig.EUR_CRM_Hours__c.containsIgnoreCase(String.valueOf(hour));
    }

    private Boolean isValidQuarterMinutes(EUR_CRM_SchedulerConfig__mdt schedulerConfig, Integer quarterMinutes) {
        return schedulerConfig.EUR_CRM_MinuteQuarters__c.equalsIgnoreCase('00')
            || schedulerConfig.EUR_CRM_MinuteQuarters__c.containsIgnoreCase(String.valueOf(quarterMinutes));
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_SchedulerConfig__mdt> selectSchedulerConfigs(String apexSchedulerJobClass) {
        return [
            SELECT Id
            ,   EUR_CRM_ApexBatchJobClass__c
            ,   EUR_CRM_BatchSize__c
            ,   EUR_CRM_Days__c
            ,   EUR_CRM_Hours__c
            ,   EUR_CRM_MinuteQuarters__c
            FROM EUR_CRM_SchedulerConfig__mdt
            WHERE EUR_CRM_ApexScheduledJobClass__c = :apexSchedulerJobClass
                AND EUR_CRM_IsActive__c = TRUE
        ];
    }

}