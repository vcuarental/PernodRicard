<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__Notify_Incident_Owner_when_final_Task_Linked_to_Incident_is_Closed</fullName>
        <description>Notify incident owner when final task linked to incident is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__All_Tasks_closed_for_Incident</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_client_when_service_request_status_changes</fullName>
        <description>Notify_client_when_service_request_status_changes</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Status_Change</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_owner_when_linked_task_is_closed</fullName>
        <description>Notify incident owner when linked task is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Linked_Task_for_an_incident_is_closed</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__call_status_from_email</fullName>
        <description>call_status_from_email</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_5_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_assign_to_on_ticket_followup</fullName>
        <description>notify_assign_to_on_ticket_followup</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_2_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_assign_to_on_ticket_reopen</fullName>
        <description>notify_assign_to_on_ticket_reopen</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_8_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_on_service_request_reopen</fullName>
        <description>notify_client_on_service_request_reopen</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Reopened</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_on_ticket_reopen</fullName>
        <description>notify_client_on_ticket_reopen</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_8_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_incident_is_closed</fullName>
        <description>notify_client_when_incident_is_closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_6_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_incident_is_created</fullName>
        <description>notify_client_when_incident_is_created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_service_request_is_closed</fullName>
        <description>notify_client_when_service_request_is_closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Closed</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_service_request_is_created</fullName>
        <description>notify_client_when_service_request_is_created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__SRM_Created</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_of_incident_due_in_1_hour</fullName>
        <description>notify_staff_of_incident_due_in_1_hour</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_9_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_of_incident_nearing_due_date</fullName>
        <description>notify_staff_of_incident_nearing_due_date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_4_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_incident_is_assigned_to_them</fullName>
        <description>notify_staff_when_incident_is_assigned_to_them</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_incident_is_created</fullName>
        <description>notify_staff_when_incident_is_created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_no_action_has_occurred_for_24_hours</fullName>
        <description>notify_staff_when_no_action_has_occurred_for_24_hours</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Incident_Email_Template_3_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Approval_Approved_Notification</fullName>
        <description>BMC_RF_Incident Approval Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Appr_Approved_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Approval_Rejected_Notification</fullName>
        <description>BMC_RF_Incident Approval Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Approval_Rejected_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Assignment_Notification_CGI</fullName>
        <description>BMC_RF_Incident Assignment Notification (CGI)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Category_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Assignment_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Assignment_Notification_Dimension_Data</fullName>
        <ccEmails>pra.helpdesk.hk@dimensiondata.com</ccEmails>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Assignment Notification (Dimension Data)</description>
        <protected>false</protected>
        <senderAddress>may.kong@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Assignment_Dimension</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Assignment_Notification_Queue</fullName>
        <description>BMC_RF_Incident Assignment Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Integration_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Assignment_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Assignment_Notification_Queue_Category</fullName>
        <description>BMC_RF_Incident Assignment Notification (Queue - Category)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_Distribution__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Assignment_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Assignment_Notification_Staff</fullName>
        <description>BMC_RF_Incident Assignment Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Assignment_Notif_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Closed_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Closed Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Closed_Notification_Auto</fullName>
        <ccEmails>bmcrof_emailcoversation@2ftz4he77ywenshepnsbxo6d2fvef7rhfx05seqpv4j50gndre.d-qc0emae.d.apex.salesforce.com</ccEmails>
        <description>BMC_RF_Incident Closed Notification (Auto)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Closed_Notification_Auto</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Closed_Notification_Bridge</fullName>
        <description>BMC_RF_Incident Closed Notification (Bridge)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Closed_Notification_Bridge</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Closed_Notification_CGI</fullName>
        <description>BMC_RF_Incident Closed Notification (CGI)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Category_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Closed_Notif_CGI</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Closed_Notification_Non_IT</fullName>
        <description>BMC_RF_Incident Closed Notification (Non-IT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>support@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_INC_Close_NonIT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Created_Notification_Non_IT</fullName>
        <description>BMC_RF_Incident Created Notification (Non-IT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>support@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_INC_Created_NonIT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Client</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (Client)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_Cl</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Client_CGI</fullName>
        <description>BMC_RF_Incident Creation Notification (Client - CGI)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Creation_Notif_Client_CGI</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_P1_P2</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (P1/P2)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Category_Notification_DL__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Emergency_Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_P1</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_P1_P2_BHO</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (P1/P2 - BHO)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_BHO_Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_P1</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_P1_P2_NBH</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (P1/P2 - NBH)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_NBH_Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_P1</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Queue</fullName>
        <description>BMC_RF_Incident Creation Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Integration_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Queue_Category</fullName>
        <description>BMC_RF_Incident Creation Notification (Queue - Category)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_Distribution__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Queue_No_Category_or_Priority</fullName>
        <description>BMC_RF_Incident Creation Notification (Queue - No Category or Priority)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Integration_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Crea_Notif_Q_No_Cat_or_Pri</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Queue_No_Category_or_Priority_Category</fullName>
        <description>BMC_RF_Incident Creation Notification (Queue - No Category or Priority - Category)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_Distribution__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Crea_Notif_Q_No_Cat_or_Pri</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_SMS</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (SMS)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Emergency_Notification_SMS__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_SM</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_SMS_BHO</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (SMS - BHO)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_BHO_Notification_SMS__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_SM</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_SMS_NBH</fullName>
        <ccEmails>noreply@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Creation Notification (SMS - NBH)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_NBH_Notification_SMS__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Notification_SM</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Creation_Notification_Staff</fullName>
        <description>BMC_RF_Incident Creation Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Creation_Not_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Escalation_to_Problem_Major_Incident_Approval_Approved</fullName>
        <description>BMC_RF_Incident Escalation to Problem / Major Incident Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Major_Incident_Escalation_Sub_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Problem_Escalation_Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Escalation_Approved</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Escalation_to_Problem_Major_Incident_Approval_Notification_ITSM</fullName>
        <description>BMC_RF_Incident Escalation to Problem / Major Incident Approval Notification (ITSM)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approver_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Escalation_to_Problem_Major_Incident_Approval_Notification_PM</fullName>
        <description>BMC_RF_Incident Escalation to Problem / Major Incident Approval Notification (PM)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approver_II__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Escalation_to_Problem_Major_Incident_Approval_Rejected</fullName>
        <description>BMC_RF_Incident Escalation to Problem / Major Incident Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Major_Incident_Escalation_Sub_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Problem_Escalation_Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Escalation_Rejected</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Equipment_Manager_Approval_Notification_IDL_General</fullName>
        <description>BMC_RF_Incident New Equipment Manager Approval Notification (IDL: General)</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>jean-baptiste.briot@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Equi_Mngr_Appr_Notif_IDL</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Equipment_Manager_Approval_Request</fullName>
        <description>BMC_RF_Incident New Equipment Manager Approval Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>erica.dean@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Equip_Mngr_Appr_Req</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Equipment_Manager_Approval_Request_Reminders</fullName>
        <description>BMC_RF_Incident New Equipment Manager Approval Request Reminders</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Manager_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Equip_Mngr_Appr_Remind</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Equipment_Manager_Approval_Response_Rejected</fullName>
        <description>BMC_RF_Incident New Equipment Manager Approval Response Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Equip_Mngr_Appr_Rejec</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_ELS_Day_01</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire ELS - Day 01</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_ELS_Day_01</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_ELS_Day_03</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire ELS - Day 03</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_ELS_Day_03</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_ELS_Day_05</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire ELS - Day 05</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_ELS_Day_05</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_ELS_Day_14</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire ELS - Day 14</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_ELS_Day_14</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_ELS_Day_14_Manager</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire ELS - Day 14 (Manager)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__Client_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_ELS_Day_14_Mgr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Auto_Program</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (CA: Auto Program)</description>
        <protected>false</protected>
        <recipients>
            <recipient>lynn.colabella@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Auto_Program</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Buliding_Access</fullName>
        <ccEmails>Walkerville.Security@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (CA: Buliding Access)</description>
        <protected>false</protected>
        <recipients>
            <recipient>jesse.martinello@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.beattie@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Building_Access</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_CRM_Access</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (CA: CRM Access)</description>
        <protected>false</protected>
        <recipients>
            <recipient>james.saunders@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael.chu@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_CRM_Access</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Concur</fullName>
        <ccEmails>ConcurCanada@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (CA: Concur)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Concur</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Auto_Program</fullName>
        <ccEmails>PRUSAPayrollDistribution@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Auto Program)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Auto_Program</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Concur</fullName>
        <ccEmails>Concur.Support@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Concur)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Concur</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Dashiel_Duran</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Dashiel Duran)</description>
        <protected>false</protected>
        <recipients>
            <recipient>dashiel.duran@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Dashiel_Duran</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Directors</fullName>
        <ccEmails>PRTRADirectors@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Directors)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Directors</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Jeanette_Silva</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Jeanette Silva)</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeanette.silva@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Jeanette_Silva</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Joelle_Ferran</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Joelle Ferran)</description>
        <protected>false</protected>
        <recipients>
            <recipient>joelle.ferran@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Joelle_Ferran</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Veronica_Andrade</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: Veronica Andrade)</description>
        <protected>false</protected>
        <recipients>
            <recipient>veronica.andrade@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Veronica_Andrade</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_William_Evertz</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (PRTRA: William Evertz)</description>
        <protected>false</protected>
        <recipients>
            <recipient>william.evertz@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_William_Evertz</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Request</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Request</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Manager_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Hire_Mngr_Appr_Req</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Request_Reminders</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Request Reminders</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Manager_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Hire_Mngr_Appr_Req_Remind</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Response_Approved</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Response Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Hire_Mngr_Appr_Resp_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Response_Approved_Auto</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Response Approved (Auto)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Manager_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Hire_Mngr_Appr_Resp_Auto</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Response_Rejected</fullName>
        <description>BMC_RF_Incident New Hire Manager Approval Response Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_New_Hire_Mngr_Appr_Resp_Rejec</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_No_Staff_Notification</fullName>
        <description>BMC_RF_Incident No Staff Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Category_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_No_Staff_Notification_DL__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_No_Staff_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolution_Rejected_Notification_CGI</fullName>
        <description>BMC_RF_Incident Resolution Rejected Notification (CGI)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Category_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Resol_Rejec_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolution_Rejected_Notification_Queue</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Resolution Rejected Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Integration_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Resol_Rejec_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolution_Rejected_Notification_Queue_Category</fullName>
        <description>BMC_RF_Incident Resolution Rejected Notification (Queue - Category)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_Distribution__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_User_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Resol_Rejec_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolution_Rejected_Notification_Staff</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Resolution Rejected Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Resol_Rejec_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolved_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Resolved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Resolved_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Resolved_Notification_Non_IT</fullName>
        <description>BMC_RF_Incident Resolved Notification (Non-IT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>support@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_INC_Resolved_NonIT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Self_Service_Approval_Request</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Self Service Approval Request</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approver_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Approver_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Self_Serv_Appr_Req</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Self_Service_Approval_Response_Approved</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Self Service Approval Response Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Self_Serv_Appr_Resp_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Self_Service_Approval_Response_Approved_Auto</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Self Service Approval Response Approved (Auto)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approver_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Approver_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Self_Serv_Appr_Resp_Auto</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Self_Service_Approval_Response_Rejected</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Self Service Approval Response Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Self_Serv_Appr_Resp_Rejec</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Self_Service_Request_Reminders</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Self Service Approval Request Reminders</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approver_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Approver_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Inc_Self_Serv_Appr_Req_Remind</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Assigned_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Assigned Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_Assigned</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_In_Progress_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status In Progress Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_In_Progress</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Problem_Update_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Problem Update Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Update_Problem</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Waiting_for_User_Alert</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Waiting for User Alert</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_WFUA</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Waiting_for_User_Closed</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Waiting for User Closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_WFU_Closed</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Waiting_for_User_Final_Reminder</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Waiting for User Final Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_WFU_Final</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Waiting_for_User_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Waiting for User Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_WFU</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Status_Waiting_for_User_Reminder</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Status Waiting for User Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_User_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Demand_Sponsor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Status_WFU_Reminder</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Termination_Notifcation_CA_Building_Access</fullName>
        <ccEmails>Walkerville.Security@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Termination Notifcation (CA: Building Access)</description>
        <protected>false</protected>
        <recipients>
            <recipient>jesse.martinello@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john.beattie@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Termination_Notifcation_CA</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Termination_Notifcation_CA_CRM</fullName>
        <description>BMC_RF_Incident Termination Notifcation (CA: CRM)</description>
        <protected>false</protected>
        <recipients>
            <recipient>james.saunders@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael.chu@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Termination_Notifcation_CA</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Termination_Notifcation_CA_Concur</fullName>
        <ccEmails>ConcurCanada@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Termination Notifcation (CA: Concur)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Termination_Notifcation_CA</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Update_External_Vendor_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Update External Vendor Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMC_RF_Email_Templates_for_IT_Staff/BMC_RF_Incident_Update_Ext</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Update_External_Vendor_Notification_Auto_Close</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Update External Vendor Notification (Auto-Close)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMC_RF_Email_Templates_for_IT_Staff/BMC_RF_Incident_Update_Ext_Auto</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_Workday_Integration</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident Workday Integration</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__Client_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_Workday_Integration</template>
    </alerts>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_BBSA_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply BBSA Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_BSA_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply BSA Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Apply_EUEM_Template</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <name>Apply EUEM Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Asset_Core_Approval_Status_Approved</fullName>
        <description>Update Asset Core Approval Status with Approved after successful operational rule deployment</description>
        <field>BMCServiceDesk__ACApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Asset Core Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Asset_Core_Approval_Status_Rejected</fullName>
        <description>Update Asset Core Approval Status with Rejected after failed operational rule deployment</description>
        <field>BMCServiceDesk__ACApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Asset Core Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Update_Service_Request_as_Approved</fullName>
        <description>Updates the flag approved to TRUE on final approval</description>
        <field>BMCServiceDesk__Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Service Request as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</fullName>
        <field>BMCServiceDesk__ShowDueDateDialog__c</field>
        <literalValue>1</literalValue>
        <name>Update the ShowDueDateDialog Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Demand_Calculate_Final_Score</fullName>
        <field>BMC_RF_Final_Score__c</field>
        <formula>((BMC_RF_SF_Score__c * 0.4)+
(BMC_RF_DFB_Score__c * 0.35)+
(BMC_RF_Qualitative_Benefits_Score__c * 0.25)+
(BMC_RF_Level_of_Effort_Score__c * -0.3)+
(BMC_RF_DFC_Score__c * -0.35)+
(BMC_RF_Risk_and_Impact_Score__c* - 0.35))*20</formula>
        <name>BMC_RF_Demand Calculate Final Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Demand_Calculate_Total_Benefit</fullName>
        <field>BMC_RF_Total_Benefit__c</field>
        <formula>BMC_RF_DFB_Present_Value__c</formula>
        <name>BMC_RF_Demand Calculate Total Benefit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Demand_Calculate_Total_Cost</fullName>
        <field>BMC_RF_Total_Cost__c</field>
        <formula>BMC_RF_Total_Implementation_Costs__c + BMC_RF_Direct_Financial_Cost_Present__c</formula>
        <name>BMC_RF_Demand Calculate Total Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Closed_Notification_CGI</fullName>
        <field>BMC_RF_Category_Email__c</field>
        <formula>BMCServiceDesk__FKCategory__r.BMC_RF_Category_Email__c</formula>
        <name>BMC_RF_Incident Closed Notification (CGI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_New_Equipment_App_Auto</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;IDL New Hire Incident Template Approved&quot;</formula>
        <name>BMC_RF_Incident New Equipment App (Auto)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_New_Hire_Manager_App_Req</fullName>
        <field>BMC_RF_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>BMC_RF_Incident New Hire Manager App Req</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_New_Hire_Summary</fullName>
        <field>Summary__c</field>
        <formula>&quot;New Hire - &quot; &amp; LEFT(CCPE_Comments__c, 40)
 &amp; &quot; - Effective: &quot; &amp; TEXT(BMC_RF_Effective_Date__c)</formula>
        <name>BMC_RF_Incident New Hire Summary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_New_Hire_Update_Summary</fullName>
        <field>Summary__c</field>
        <formula>&quot;New Hire - &quot; &amp; LEFT(CCPE_Comments__c, 40)
 &amp; &quot; - Effective: &quot; &amp; TEXT(BMC_RF_Effective_Date__c)</formula>
        <name>BMC_RF_Incident New Hire Update Summary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Rejection_Resolved_By</fullName>
        <field>BMC_RF_Resolved_By__c</field>
        <name>BMC_RF_Incident Rejection Resolved By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Rejection_Resolved_Date</fullName>
        <field>BMC_RF_Resolved_Date__c</field>
        <name>BMC_RF_Incident Rejection Resolved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Rejection_Resolved_Queue</fullName>
        <field>BMC_RF_Resolved_by_Queue__c</field>
        <name>BMC_RF_Incident Rejection Resolved Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Resolved_Resolved_By</fullName>
        <field>BMC_RF_Resolved_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>BMC_RF_Incident Resolved Resolved By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Resolved_Resolved_Date</fullName>
        <field>BMC_RF_Resolved_Date__c</field>
        <formula>TODAY()</formula>
        <name>BMC_RF_Incident Resolved Resolved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Resolved_Resolved_Queue</fullName>
        <field>BMC_RF_Resolved_by_Queue__c</field>
        <formula>BMCServiceDesk__queueName__c</formula>
        <name>BMC_RF_Incident Resolved Resolved Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_BCO_L2_BAL</fullName>
        <field>OwnerId</field>
        <lookupValue>BCO_L2_Baltics</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: BCO - L2 BAL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_BCO_L2_IDL</fullName>
        <field>OwnerId</field>
        <lookupValue>BCO_L2_Irish_Distillers</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: BCO - L2 IDL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_BCO_L2_TAC</fullName>
        <field>OwnerId</field>
        <lookupValue>BCO_L2_TAC</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: BCO - L2 TAC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_BCO_Support</fullName>
        <field>OwnerId</field>
        <lookupValue>BCO_Support_Services</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: BCO - Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_FR_SD</fullName>
        <field>OwnerId</field>
        <lookupValue>FR_Service_Desk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: FR - SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_GTR_SD</fullName>
        <field>OwnerId</field>
        <lookupValue>GTR_L2_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: GTR - SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_NA_SOL_Data</fullName>
        <field>OwnerId</field>
        <lookupValue>AME_NA_SOL_Data_Warehouse</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: NA - SOL Data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_PRA_SD</fullName>
        <field>OwnerId</field>
        <lookupValue>AME_PRA_IT_Service_Bar</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: PRA - SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_PRG_Datacente</fullName>
        <field>OwnerId</field>
        <lookupValue>OPS_I_O_Compute_DC_E_A</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: PRG - Datacente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_PRG_Global</fullName>
        <field>OwnerId</field>
        <lookupValue>PRG_Global_Solutions_Support_Services</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: PRG - Global</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_PRG_INF_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>PRG_INF_Admin_External</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: PRG - INF Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_PRG_JDE_CNC</fullName>
        <field>OwnerId</field>
        <lookupValue>PRG_JDE_CNC_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: PRG - JDE CNC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_SSA_SD</fullName>
        <field>OwnerId</field>
        <lookupValue>SSA_L2_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: SSA - SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Routing_WEE_SD</fullName>
        <field>OwnerId</field>
        <lookupValue>WEE_L2_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>BMC_RF_Incident Routing: WEE - SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Termination_Summary</fullName>
        <field>Summary__c</field>
        <formula>&quot;Termination Request - &quot; &amp; CCPE_Comments__c 
 &amp; &quot; - Effective Date: &quot; &amp; TEXT(BMC_RF_Effective_Date__c)</formula>
        <name>BMC_RF_Incident Termination Summary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Affiliate</fullName>
        <field>BMC_RF_Affiliate__c</field>
        <formula>BMC_RF_Affiliates_Impacted_Text_I__c &amp; BMC_RF_Affiliates_Impacted_Text_II__c &amp; BMC_RF_Affiliates_Impacted_Text_III__c &amp;  BMC_RF_Affiliates_Impacted_Text_IV__c</formula>
        <name>BMC_RF_Incident Update Affiliate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Opened_Date</fullName>
        <field>BMCServiceDesk__openDateTime__c</field>
        <formula>BMC_RF_Received_Date__c</formula>
        <name>BMC_RF_Incident Update Opened Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Region</fullName>
        <field>BMC_RF_Region__c</field>
        <formula>IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;ASI&quot;), &quot;ASI &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;BALTICS&quot;), &quot;BALTICS &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;BCO&quot;), &quot;BCO &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;FR&quot;), &quot;FR &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;GTR&quot;), &quot;GTR &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;IBERIA&quot;), &quot;IBERIA &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;LATAM&quot;), &quot;LATAM &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;MENAT&quot;), &quot;MENAT &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;NA&quot;), &quot;NA &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRCE&quot;), &quot;PRCE &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PREE&quot;), &quot;PREE &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRNE&quot;), &quot;PRNE &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRSE&quot;), &quot;PRSE &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRUK&quot;), &quot;PRUK &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRW&quot;), &quot;PRW &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;SEA&quot;), &quot;SEA &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;SSA&quot;), &quot;SSA &quot;,&quot;&quot;) &amp;
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;WEE&quot;), &quot;WEE &quot;,&quot;&quot;)</formula>
        <name>BMC_RF_Incident Update Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Responded_Custom</fullName>
        <field>BMC_RF_Responded_Date__c</field>
        <formula>NOW()</formula>
        <name>BMC_RF_Incident Update Responded Custom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Responded_Date</fullName>
        <field>BMCServiceDesk__respondedDateTime__c</field>
        <formula>BMC_RF_Responded_Date__c</formula>
        <name>BMC_RF_Incident Update Responded Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Responded_Managed</fullName>
        <field>BMCServiceDesk__respondedDateTime__c</field>
        <formula>NOW()</formula>
        <name>BMC_RF_Incident Update Responded Managed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Status_Approved</fullName>
        <field>BMC_RF_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>BMC_RF_Incident Update Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Status_Not_Submit</fullName>
        <field>BMC_RF_Approval_Status__c</field>
        <literalValue>Not Submitted</literalValue>
        <name>BMC_RF_Incident Update Status Not Submit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Status_Rejected</fullName>
        <field>BMC_RF_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>BMC_RF_Incident Update Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Incident_Update_Status_Submitted</fullName>
        <field>BMC_RF_Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>BMC_RF_Incident Update Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Update_Responded_Date_Custom</fullName>
        <field>BMC_RF_Responded_Date__c</field>
        <formula>NOW()</formula>
        <name>BMC_RF_Update Responded Date (Custom)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Update_Responded_Date_Now</fullName>
        <field>BMC_RF_Responded_Date__c</field>
        <formula>NOW()</formula>
        <name>BMC_RF_Update Responded Date (Now)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__Apply template to BMC Server Automation created incident</fullName>
        <actions>
            <name>BMCServiceDesk__Apply_BSA_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Name:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job Group id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Job Run id:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Start Time:</value>
        </criteriaItems>
        <description>This workflow will apply a template to the incident created by BMC Server Automation</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Apply template to End User Experience Management created incident</fullName>
        <actions>
            <name>BMCServiceDesk__Apply_EUEM_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Date:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Source:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Incident type:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Incident detection rule:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Watchpoint:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Urgency rating:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Sessions:</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Description:</value>
        </criteriaItems>
        <description>This workflow will apply a template to the incident created by End User Experience Management</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify incident owner when each linked task is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_owner_when_linked_task_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies incident owner when each linked task of the incident is closed.</description>
        <formula>AND( ISCHANGED( BMCServiceDesk__Task_Closed_Controller__c), NOT(ISBLANK( BMCServiceDesk__Task_Closed_Controller__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify incident owner when final task linked to incident is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_Incident_Owner_when_final_Task_Linked_to_Incident_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify incident owner when final task linked to incident is closed</description>
        <formula>AND( BMCServiceDesk__state__c, NOT( BMCServiceDesk__inactive__c ), IF(BMCServiceDesk__AllTaskCloseController__c, ISCHANGED(BMCServiceDesk__AllTaskCloseController__c), false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff of incident due in 1 hour</fullName>
        <active>true</active>
        <description>Notify staff of incident due in 1 hour</description>
        <formula>BMCServiceDesk__state__c  = True  &amp;&amp;  NOT(ISBLANK(BMCServiceDesk__dueDateTime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff of incident nearing due date</fullName>
        <active>true</active>
        <description>Notify staff of incident nearing due date</description>
        <formula>BMCServiceDesk__state__c  = True  &amp;&amp;  NOT(ISBLANK(BMCServiceDesk__dueDateTime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify staff when no action has occurred for 24 hours</fullName>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notifies the assigned staff member if the staff member has not taken any action on the incident for 24 Hours</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident has been marked for follow up</fullName>
        <actions>
            <name>BMCServiceDesk__notify_assign_to_on_ticket_followup</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when an incident assigned to the staff member has been marked for follow up</description>
        <formula>BMCServiceDesk__followUp__c  = True &amp;&amp;  BMCServiceDesk__state__c  = False &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c )  = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is created and assigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when an incident is created and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is reassigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_incident_is_assigned_to_them</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when an incident is reassigned to the staff member</description>
        <formula>OwnerId &lt;&gt; $User.Id  &amp;&amp;  ISCHANGED( OwnerId )  &amp;&amp;   NOT(ISNEW() ) &amp;&amp; BMCServiceDesk__state__c  = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when an incident is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_assign_to_on_ticket_reopen</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when a closed incident is reopened and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is closed</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_service_request_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request is closed</description>
        <formula>(BMCServiceDesk__state__c  =  false) &amp;&amp; NOT( ISBLANK( BMCServiceDesk__FKRequestDetail__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is created</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_service_request_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the service request requested by the client is created</description>
        <formula>NOT( ISBLANK( BMCServiceDesk__FKRequestDetail__c ) || ISBLANK(  BMCServiceDesk__FKRequestDefinition__c  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_on_service_request_reopen</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request is reopened</description>
        <formula>BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False &amp;&amp;   NOT(ISBLANK( BMCServiceDesk__FKRequestDetail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a service request status is changed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_client_when_service_request_status_changes</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s service request status has changed</description>
        <formula>( BMCServiceDesk__FKStatus__c &lt;&gt; PRIORVALUE( BMCServiceDesk__FKStatus__c)) &amp;&amp; NOT(ISBLANK( BMCServiceDesk__FKRequestDetail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is closed</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_incident_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s incident is closed</description>
        <formula>(BMCServiceDesk__state__c  = False) &amp;&amp; (BMCServiceDesk__followUp__c = False) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is created</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_incident_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the incident requested by the client is created</description>
        <formula>(BMCServiceDesk__state__c = True) &amp;&amp; (ISBLANK( BMCServiceDesk__FKRequestDetail__c)  &amp;&amp; ISBLANK(  BMCServiceDesk__FKRequestDefinition__c  ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when an incident is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_on_ticket_reopen</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s incident is reopened</description>
        <formula>BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c ) = False &amp;&amp;  ISBLANK( BMCServiceDesk__FKRequestDetail__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Open popup dialog for recalculating due date when priority of incident changes</fullName>
        <actions>
            <name>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule has been deprecated. If the rule is active, deactivate it.</description>
        <formula>ISCHANGED( BMCServiceDesk__FKPriority__c ) &amp;&amp; IF( BMCServiceDesk__ShowDueDateDialog__c   = false,true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Update the incident%E2%80%99s status through email</fullName>
        <actions>
            <name>BMCServiceDesk__call_status_from_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends the status of the incident to the sender of the email</description>
        <formula>ISCHANGED( BMCServiceDesk__WorkflowController__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Demand Calculate Total Benefit %2B Total Cost</fullName>
        <actions>
            <name>BMC_RF_Demand_Calculate_Final_Score</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Demand_Calculate_Total_Benefit</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Demand_Calculate_Total_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Demand (Project - RF),Demand,Demand (Configuration),Demand (Emergency),Demand (Minor Enhancement),Demand (Project),Demand (Release)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Closed Notification %28CGI%29</fullName>
        <actions>
            <name>BMC_RF_Incident_Closed_Notification_CGI</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BMC_RF_Incident_Closed_Notification_CGI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Queue__c</field>
            <operation>equals</operation>
            <value>PRG - CGI Shared Service Center</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Creation Notification %28Client - CGI%29</fullName>
        <actions>
            <name>BMC_RF_Incident_Creation_Notification_Client_CGI</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OwnerId = &quot;00GD0000004mwzmMAA&quot;, ISCHANGED(BMCServiceDesk__FKClient__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28CA%3A Auto Program%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Auto_Program</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Auto Program: Car Allowance</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Auto Program: Fleet</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28CA%3A Building Access%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Buliding_Access</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Building Access Changes Required: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28CA%3A CRM%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_CRM_Access</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>CRM: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28CA%3A Concur%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_Concur</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Credit Card Requirements: Issue New Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Credit Card Requirements: Update Cost Center for Existing Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Concur: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28CA%3A General%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Response_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Auto Program%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Auto_Program</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Auto Program: Car Allowance</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Auto Program: Fleet</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Concur%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Concur</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Credit Card Requirements: Issue New Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Credit Card Requirements: Update Cost Center for Existing Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Concur: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Dashiel Duran%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Dashiel_Duran</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>DR Pros: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Directors%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Directors</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>E1: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Office Location: Fort Lauderdale,FL</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Jeanette Silva%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Jeanette_Silva</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>PRAM MDS PRATR HR: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Joelle Ferran%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Joelle_Ferran</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>A&amp;PO: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Hubble: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Price Structure: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>SmartView: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>PRAM MDS PRTRA FP&amp;A Analyst Stewards: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A Veronica Andrade%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_Veronica_Andrade</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>PRAM MDS PRTRA Commercial Business Analyst Stewards: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>PRAM MDS PRTRA Pricing Analyst Stewards: true</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Notification %28PRTRA%3A William Evertz%29</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_PRTRA_William_Evertz</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Company Name: Pernod Ricard Travel Retail Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>E1: true</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Office Location: Santo Domingo,DR</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Request</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_App_Req</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Summary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Status_ID__c</field>
            <operation>equals</operation>
            <value>WAITING FOR APPROVAL</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Request Reminders</fullName>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Status_ID__c</field>
            <operation>equals</operation>
            <value>WAITING FOR APPROVAL</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_New_Hire_Manager_Approval_Request_Reminders</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_New_Hire_Manager_Approval_Request_Reminders</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident New Hire Manager Approval Response Rejected</fullName>
        <actions>
            <name>BMC_RF_Incident_New_Hire_Manager_Approval_Response_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR New Hire</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Self Service Approval Request</fullName>
        <actions>
            <name>BMC_RF_Incident_Self_Service_Approval_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Process__c</field>
            <operation>equals</operation>
            <value>Self Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Send_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Status_ID__c</field>
            <operation>equals</operation>
            <value>WAITING FOR APPROVAL</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approver_I__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approver_II__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Self Service Approval Request Reminders</fullName>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Process__c</field>
            <operation>equals</operation>
            <value>Self Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Send_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Status_ID__c</field>
            <operation>equals</operation>
            <value>WAITING FOR APPROVAL</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Send_Approval_Reminders__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_Self_Service_Request_Reminders</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_Self_Service_Request_Reminders</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Self Service Approval Response Approved</fullName>
        <actions>
            <name>BMC_RF_Incident_Self_Service_Approval_Response_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Process__c</field>
            <operation>equals</operation>
            <value>Self Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Send_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Self Service Approval Response Rejected</fullName>
        <actions>
            <name>BMC_RF_Incident_Self_Service_Approval_Response_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Process__c</field>
            <operation>equals</operation>
            <value>Self Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_Send_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__Approval_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Termination %28CA%3A Building Access%29</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Office Location: Walkerville</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Office Location: Pike Creek</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_Termination_Notifcation_CA_Building_Access</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BMCServiceDesk__Incident__c.BMC_RF_Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Termination %28CA%3A Concur%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Cancel Employee Credit Card and/or Remove Concur Access?: Yes</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_Termination_Notifcation_CA_Concur</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BMCServiceDesk__Incident__c.BMC_RF_Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Termination %28CA%3A General%29</fullName>
        <actions>
            <name>BMC_RF_Incident_Termination_Summary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMC_RF_IT_Team__c</field>
            <operation>equals</operation>
            <value>PR Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>BMCServiceDesk__Incident__c.BMCServiceDesk__incidentDescription__c</field>
            <operation>contains</operation>
            <value>Country: Canada</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BMC_RF_Incident_Termination_Notifcation_CA_CRM</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BMCServiceDesk__Incident__c.BMC_RF_Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Update Affiliates Impacted</fullName>
        <actions>
            <name>BMC_RF_Incident_Update_Affiliate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(BMC_RF_Affiliates_Impacted__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Incident Update Regions Impacted</fullName>
        <actions>
            <name>BMC_RF_Incident_Update_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(BMC_RF_Regions_Impacted__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
