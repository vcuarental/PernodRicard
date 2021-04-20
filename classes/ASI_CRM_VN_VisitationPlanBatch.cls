/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_VisitationPlanBatch
 * Description: Test class for ASI_CRM_VN_VisitationPlanBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-10       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

global class ASI_CRM_VN_VisitationPlanBatch implements Database.Batchable<sObject>, Database.Stateful {
	Id orgEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'itservicedesk@pernod-ricard.com' LIMIT 1].Id;
    
    List<ASI_HK_CRM_Visitation_Plan__c> secondHalfPlans;
    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailsNew = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailsOld = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
    List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailsAll = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
    List<User> northRegionManager;
    List<User> centralRegionManager;
    List<User> southRegionManager;
    Map<String, List<User>> regionManagerByUser = new Map<String, List<User>>();
    Map<Id, User> UserById = new Map<Id, User>();

    /*****
    FOR UAT
    *****/
    Date defaultDate;
    
    public DateTime getNextWorkingDate(DateTime d) {
        String weekday = d.format('EEEE');
        if (weekday == 'Friday') {
            return d.addDays(3); // next Monday
        }
        return d.addDays(1);
    }

    //    if d < 16, return 1, else 16
    public Date getPeriodStart(Date d) {
        Integer day = d.day();
        return day < 16? d.toStartOfMonth() : Date.newInstance(d.year(), d.month(), 15);
    }

    //    if d < 16, return 16, else 28/29/30/31
    public Date getPeriodEnd(Date d) {
        Integer day = d.day();
        return day < 16? Date.newInstance(d.year(), d.month(), 15) : d.addMonths(1).toStartOfMonth().addDays(-1);
    }

    public String generateEmailBodyToManager(List<ASI_HK_CRM_Visitation_Plan_Detail__c> details) {
        String str = 'Please note the following Visitation Plan Details were unvisited or cancelled: ';
        str += '<table style="text-align: left; border: 1px solid; border-collapse: collapse; width: 100%;">';
        str += '<tr style="border: 1px solid black;"> <th>Outlet</th> <th>VisitDate</th> <th>Purpose</th> <th>Owner</th> <th>Status</th> <th>Link</th> </tr>';
        for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : details) {
            str += String.format('<tr style="border: 1px solid black;"> <td>{0}</td> <td>{1}</td> <td>{2}</td> <td>{3}</td> <td>{4}</td> <td>{5}</td> </tr>',
                    new String[]{
                            detail.ASI_CRM_MY_Customer__r.Name,
                            Datetime.newInstance(detail.ASI_HK_CRM_Visit_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-YYYY'),
                            detail.ASI_CRM_Purpose_of_Visit__c,
                            detail.ASI_HK_CRM_Visitation_Plan__r.Owner.Name,
                            detail.ASI_HK_CRM_Status__c == null ? 'Unvisited' : detail.ASI_HK_CRM_Status__c,
                            '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + detail.Id + '" target="_blank">link</a>'
                    }
            );
        }
        str += '</table>';
        return str;
    }

    public String generateCSVBodyToManager(List<ASI_HK_CRM_Visitation_Plan_Detail__c> details) {
        String str = '';
        for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : details) {
            List<String> stringList = new String[]{
                    detail.ASI_CRM_MY_Customer__r.Name,
                    Datetime.newInstance(detail.ASI_HK_CRM_Visit_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-YYYY'),
                    detail.ASI_CRM_Purpose_of_Visit__c,
                    detail.ASI_HK_CRM_Visitation_Plan__r.Owner.Name,
                    detail.ASI_HK_CRM_Status__c == null ? 'Unvisited' : detail.ASI_HK_CRM_Status__c
            };
            str += String.join(stringList, ',') + '\n';
        }
        return str;
    }
	
    public ASI_CRM_VN_VisitationPlanBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        Date now = Date.today();

        secondHalfPlans = [
                SELECT Id, OwnerId, Owner.Name
                FROM ASI_HK_CRM_Visitation_Plan__c
                WHERE
                RecordType.DeveloperName IN ('ASI_CRM_VN_Visitation_Plan', 'ASI_CRM_VN_Visitation_Plan_Submitted') AND
                ASI_HK_CRM_Year__c = :String.valueOf(now.year()) AND
                ASI_CRM_Month_Number__c = :String.valueOf(now.month()) AND
                ASI_CRM_VN_Period__c = 'Second Half'
        ];
        northRegionManager = [SELECT Id FROM User WHERE userRole.DeveloperName = 'ASI_VN_North_Sales_Manager'];
        centralRegionManager = [SELECT Id FROM User WHERE userRole.DeveloperName = 'ASI_VN_Central_Region_Manager'];
        southRegionManager = [SELECT Id FROM User WHERE userRole.DeveloperName = 'ASI_VN_South_Sales_Director'];
        regionManagerByUser.put('north', northRegionManager);
        regionManagerByUser.put('central', centralRegionManager);
        regionManagerByUser.put('south', southRegionManager);

        List<Id> userIds = new List<Id>();
        for (ASI_HK_CRM_Visitation_Plan__c plan : [
                SELECT OwnerId
                FROM ASI_HK_CRM_Visitation_Plan__c
                WHERE
                RecordType.DeveloperName IN ('ASI_CRM_VN_Visitation_Plan', 'ASI_CRM_VN_Visitation_Plan_Submitted') AND
                ASI_HK_CRM_Year__c = :String.valueOf(now.year()) AND ASI_CRM_Month_Number__c = :String.valueOf(now.month())
        ]) {
            userIds.add(plan.OwnerId);
        }
        for (User u : [SELECT Id, Name, ManagerId, ASI_KOR_User_Region_Name__c FROM User WHERE Id IN :userIds]) {
            UserById.put(u.Id, u);
        }

        return Database.getQueryLocator([
                SELECT Id, Name, ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name, ASI_HK_CRM_Visit_Date__c, ASI_CRM_Purpose_of_Visit__c,
                        ASI_HK_CRM_Visitation_Plan__c,
                        ASI_HK_CRM_Visitation_Plan__r.OwnerId,
                        ASI_HK_CRM_Visitation_Plan__r.Owner.Name,
                        ASI_HK_CRM_Status__c,
                        ASI_HK_CRM_Visitation_Plan__r.ASI_CRM_VN_Period__c

                FROM ASI_HK_CRM_Visitation_Plan_Detail__c
                WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Visitation_Plan_Detail' AND
                ASI_HK_CRM_Visit_Date__c >= :getPeriodStart(now) AND
                ASI_HK_CRM_Visit_Date__c <= :getPeriodEnd(now) AND
                ASI_HK_CRM_Status__c != 'Achieved'
        ]);
    }
    global void execute(Database.BatchableContext contextInstance, List<Sobject> objects) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetails = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) objects;
        visitationPlanDetailsAll = visitationPlanDetails;

        for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : visitationPlanDetails) {
            DateTime visitDate = detail.ASI_HK_CRM_Visit_Date__c;
            DateTime nextWorkingDate = getNextWorkingDate(visitDate);

            //            do nothing if visitDate is not ytd OR next working day is next month
            if (visitDate != Date.today().addDays(-1) || nextWorkingDate.month() != visitDate.month()) {
                    continue;
            }

            ASI_HK_CRM_Visitation_Plan_Detail__c newDetail = detail.clone();
            newDetail.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_VN_Visitation_Plan_Detail');
            newDetail.ASI_HK_CRM_Visit_Date__c = nextWorkingDate.date();
            if (nextWorkingDate.day() > 15) {
                newDetail.ASI_HK_CRM_Visitation_Plan__c = null;
                //                if second half plan exists, assign new detail's plan to it.
                for (ASI_HK_CRM_Visitation_Plan__c plan : secondHalfPlans) {
                    if (detail.ASI_HK_CRM_Visitation_Plan__r.OwnerId == plan.OwnerId) {
                        newDetail.ASI_HK_CRM_Visitation_Plan__c = plan.Id;
                    }
                }

                //                if second half plan doesn't exist, create second half plan and assign new detail's plan to it.
                if (newDetail.ASI_HK_CRM_Visitation_Plan__c == null) {
                    ASI_HK_CRM_Visitation_Plan__c secondHalfPlan = new ASI_HK_CRM_Visitation_Plan__c(
                        	Name               = String.valueOf(visitDate.year()) + '-' + String.valueOf(visitDate.month()) + '-Second Half-' + detail.ASI_HK_CRM_Visitation_Plan__r.Owner.Name,
                            ASI_HK_CRM_Year__c = String.valueOf(visitDate.year()),
                            ASI_HK_CRM_Month__c = visitDate.format('MMMMM'),
                            ASI_CRM_VN_Period__c = 'Second Half',
                            OwnerId = detail.ASI_HK_CRM_Visitation_Plan__r.OwnerId,
                            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan')
                    );
                    insert secondHalfPlan;
                    //                    update secondHalfPlans so another Visitation Plan Detail can find it
                    secondHalfPlans.add(secondHalfPlan);
                    newDetail.ASI_HK_CRM_Visitation_Plan__c = secondHalfPlan.Id;
                }

                visitationPlanDetailsNew.add(newDetail);
                visitationPlanDetailsOld.add(detail);


            } else {
                visitationPlanDetailsNew.add(newDetail);
                visitationPlanDetailsOld.add(detail);
            }

        }

        upsert visitationPlanDetailsNew;
        delete visitationPlanDetailsOld;

    }
    global void finish(Database.BatchableContext contextInstance) {
        Date now = Date.today();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //        create email for Visitation Plan Owner
        Map<Id, List<ASI_HK_CRM_Visitation_Plan_Detail__c>> visitationPlanDetailsByOwner = new Map<Id, List<ASI_HK_CRM_Visitation_Plan_Detail__c>>();
        for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : visitationPlanDetailsNew) {
            Id ownerId = detail.ASI_HK_CRM_Visitation_Plan__r.OwnerId;
            if (visitationPlanDetailsByOwner.get(ownerId) == null) {
                visitationPlanDetailsByOwner.put(ownerId, new List<ASI_HK_CRM_Visitation_Plan_Detail__c>{
                        detail
                });
            } else {
                List<ASI_HK_CRM_Visitation_Plan_Detail__c> details = visitationPlanDetailsByOwner.get(ownerId);
                details.add(detail);
                visitationPlanDetailsByOwner.put(ownerId, details);
            }
        }

        for (Id ownerId : visitationPlanDetailsByOwner.keySet()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(orgEmailAddressId);
            //email.setToAddresses(new String[] {'hugo.cheung@laputatech.com'});
            email.setToAddresses(new String[]{
                                        ownerId
            });
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('visitation_plan_detail.csv');
            String csvBody = '';
            String str;
            for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : visitationPlanDetailsByOwner.get(ownerId)) {
                String dateString = Datetime.newInstance(detail.ASI_HK_CRM_Visit_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MM-YYYY');
                if(String.isBlank(str)) {
                	str = 'The following visitation plans are moved to ' + dateString + '.';
           			str += 'Lịch thăm viếng bên dưới đã được chuyển sang ngày ' + dateString + '.';
                    str += '<table style="text-align: left; border: 1px solid; border-collapse: collapse; width: 100%;">';
                    str += '<tr style="border: 1px solid black;"> <th>Outlet</th> <th>VisitDate</th> <th>Purpose</th> <th>Link</th> </tr>';
                }
                email.setSubject('Visitation Plan Details are moved to ' + dateString);

                str += String.format('<tr style="border: 1px solid black;"> <td>{0}</td> <td>{1}</td> <td>{2}</td> <td>{3}</td>  </tr>',
                        new String[]{
                                detail.ASI_CRM_MY_Customer__r.Name,
                                dateString,
                                detail.ASI_CRM_Purpose_of_Visit__c,
                                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + detail.Id + '" target="_blank">link</a>'
                        }
                );
                List<String> csvBodyList = new String[]{
                        detail.ASI_CRM_MY_Customer__r.Name,
                        dateString,
                        detail.ASI_CRM_Purpose_of_Visit__c
                };
                csvBody += String.join(csvBodyList, ',') + '\n';
            }
            str += '</table>';
            email.setHtmlBody(str);
            attachment.setBody(Blob.valueOf(csvBody));
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                    attachment
            });

            emails.add(email);
        }


        if (Date.today().day() == 15 || Date.today() == Date.today().addMonths(1).toStartOfMonth().addDays(-1) || Test.isRunningTest()) {
            //        create email for Line Manager
            Map<Id, List<ASI_HK_CRM_Visitation_Plan_Detail__c>> visitationPlanDetailsByManager = new Map<Id, List<ASI_HK_CRM_Visitation_Plan_Detail__c>>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : visitationPlanDetailsAll) {
                Id managerId = UserById.get(detail.ASI_HK_CRM_Visitation_Plan__r.OwnerId).ManagerId;
                if (visitationPlanDetailsByManager.get(managerId) == null) {
                    visitationPlanDetailsByManager.put(managerId, new List<ASI_HK_CRM_Visitation_Plan_Detail__c>{
                            detail
                    });
                } else {
                    List<ASI_HK_CRM_Visitation_Plan_Detail__c> details = visitationPlanDetailsByManager.get(managerId);
                    details.add(detail);
                    visitationPlanDetailsByManager.put(managerId, details);
                }
            }
            for (Id managerId : visitationPlanDetailsByManager.keySet()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('visitation_plan_detail.csv');
                attachment.setBody(Blob.valueOf(generateCSVBodyToManager(visitationPlanDetailsByManager.get(managerId))));
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                        attachment
                });
                List<String> addresses = new List<String>();
                if (managerId != null) {
                    addresses.add(managerId);
           	 		email.setOrgWideEmailAddressId(orgEmailAddressId);
                    email.setToAddresses(addresses);
                    email.setSubject(
                            String.format('Unvisited/Cancelled Visitation Plan of {0}-{1} {2} Month',
                                    new String[]{
                                            String.valueOf(now.year()), String.valueOf(now.month()), visitationPlanDetailsByManager.get(managerId)[0].ASI_HK_CRM_Visitation_Plan__r.ASI_CRM_VN_Period__c
                                    })
                    );
                    email.setHtmlBody(generateEmailBodyToManager(visitationPlanDetailsByManager.get(managerId)));

                    emails.add(email);

                }
            }

            //        create email for regional manager
            Map<String, List<ASI_HK_CRM_Visitation_Plan_Detail__c>> visitationPlanDetailsByRegion = new Map<String, List<ASI_HK_CRM_Visitation_Plan_Detail__c>>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : visitationPlanDetailsAll) {
                String region = UserById.get(detail.ASI_HK_CRM_Visitation_Plan__r.OwnerId).ASI_KOR_User_Region_Name__c;
                region = String.isEmpty(region) ? '' : region;
                if (visitationPlanDetailsByRegion.get(region) == null) {
                    visitationPlanDetailsByRegion.put(region, new List<ASI_HK_CRM_Visitation_Plan_Detail__c>{
                            detail
                    });
                } else {
                    List<ASI_HK_CRM_Visitation_Plan_Detail__c> details = visitationPlanDetailsByRegion.get(region);
                    details.add(detail);
                    visitationPlanDetailsByRegion.put(region, details);
                }
            }

            for (String region : visitationPlanDetailsByRegion.keySet()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('visitation_plan_detail.csv');
                attachment.setBody(Blob.valueOf(generateCSVBodyToManager(visitationPlanDetailsByRegion.get(region))));
                email.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                        attachment
                });

                List<Id> regionManagerIds = new List<Id>();
                if (regionManagerByUser.get(region.toLowerCase()) != null) {
                    for (User u : regionManagerByUser.get(region.toLowerCase())) {
                        regionManagerIds.add(u.Id);
                    }
                }
            	email.setOrgWideEmailAddressId(orgEmailAddressId);
                email.setToAddresses(regionManagerIds);
                email.setSubject(
                        String.format('Unvisited/Cancelled Visitation Plan of {0}-{1} {2} Month',
                                new String[]{
                                        String.valueOf(now.year()), String.valueOf(now.month()), visitationPlanDetailsByRegion.get(region)[0].ASI_HK_CRM_Visitation_Plan__r.ASI_CRM_VN_Period__c
                                })
                );
                email.setHtmlBody(generateEmailBodyToManager(visitationPlanDetailsByRegion.get(region)));
				if(regionManagerIds.size() > 0)
                	emails.add(email);
            }
        }


        // Sends the email
        if (!emails.isEmpty()) {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
        }
    }
}