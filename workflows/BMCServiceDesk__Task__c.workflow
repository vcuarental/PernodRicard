<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_an_task_is_reopened</fullName>
        <description>notify_client_when_an_task_is_reopened</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Task_Email_Template_2_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_task_is_closed</fullName>
        <description>notify_client_when_task_is_closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Task_Email_Template_3_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_client_when_task_is_created</fullName>
        <description>notify_client_when_task_is_created</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Task_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_a_task_has_been_assigned_to_them</fullName>
        <description>notify_staff_when_a_task_has_been_assigned_to_them</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Task_Email_Template_1_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__notify_staff_when_an_task_is_reopened</fullName>
        <description>notify_staff_when_an_task_is_reopened</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Task_Email_Template_2_Version_2</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_E1</fullName>
        <ccEmails>E1CanadaAB@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Incident New Hire Manager Approval Notification (CA: E1)</description>
        <protected>false</protected>
        <recipients>
            <recipient>erica.dean@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Incident_New_Hire_Manager_Approval_Notification_CA_E1</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Approval_Approved_Notification</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Approval Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Appr_Appr_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Approval_Rejected_Notification</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Approval Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Appr_Rejec_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Assignment_Notification_Queue</fullName>
        <description>BMC_RF_Task Assignment Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Assignment_Not_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Assignment_Notification_Staff</fullName>
        <description>BMC_RF_Task Assignment Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKOpenBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Assignment_Not_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Self_Service_Approval_Request_Reminders</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Self Service Approval Request Reminders</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approval_User_II__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Approval_User_I__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_SS_Approval_Request_Rem</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Self_Service_Approval_Response_Approved</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Self Service Approval Response Approved</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approval_Distribution_List__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_DL__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
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
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Self_Serv_App_Response_App</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Self_Service_Approval_Response_Rejected</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Self Service Approval Response Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Approval_Distribution_List__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMC_RF_Email_Notification_DL__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKClient__c</field>
            <type>userLookup</type>
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
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Self_Serv_App_Response_Rej</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Self_Service_Notification</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Self Service Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_DL__c</field>
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
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Self_Service_Notification</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Self_Service_Notification_with_Close_Option</fullName>
        <ccEmails>itservicedesk@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Self Service Notification (with Close Option)</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Email_Notification_DL__c</field>
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
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Self_Serv_Notification_Close</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Update_External_Vendor_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Update External Vendor Notification</description>
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
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Update_Ext</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Task_Update_External_Vendor_Notification_Auto_Close</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Task Update External Vendor Notification (Auto-Close)</description>
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
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Task_Update_Ext_Auto</template>
    </alerts>
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
        <fullName>BMC_RF_Task_Approval_Approved</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>IF(NOT(ISBLANK(BMC_RF_Task_Approval_Template__c)),BMC_RF_Task_Approval_Template__c, &quot;TS Generic Approval: Approved&quot;)</formula>
        <name>BMC_RF_Task Approval: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Task_Approval_Approved_INC</fullName>
        <field>BMC_RF_Incident_Approval_Template__c</field>
        <formula>IF(ISBLANK(BMC_RF_Incident_Approval_Template__c), &quot;IN Generic: Approved&quot;, BMC_RF_Incident_Approval_Template__c)</formula>
        <name>BMC_RF_Task Approval: Approved (INC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Task_Approval_Not_Submitted</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;TS Generic Approval: Not Submitted&quot;</formula>
        <name>BMC_RF_Task Approval: Not Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Task_Approval_Rejected</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>IF(NOT(ISBLANK(BMC_RF_Task_Rejection_Template__c)),BMC_RF_Task_Rejection_Template__c, &quot;TS Generic Approval: Rejected&quot;)</formula>
        <name>BMC_RF_Task Approval: Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Task_Approval_Rejected_INC</fullName>
        <field>BMC_RF_Incident_Rejection_Template__c</field>
        <formula>IF(ISBLANK(BMC_RF_Incident_Rejection_Template__c), &quot;IN Generic: Rejected&quot;, BMC_RF_Incident_Rejection_Template__c)</formula>
        <name>BMC_RF_Task Approval: Rejected (INC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Task_Approval_Submitted</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;TS Generic Approval: Submitted&quot;</formula>
        <name>BMC_RF_Task Approval: Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when a task is created and assigned to the staff member</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_a_task_has_been_assigned_to_them</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when a task is created and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the assigned staff member when a task is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_staff_when_an_task_is_reopened</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the staff member when a closed task is reopened and assigned to the staff member</description>
        <formula>$User.Id  &lt;&gt;  OwnerId  &amp;&amp;  BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c )  = False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a task is closed</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_task_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Task__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notifies the client that the client’s task is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a task is created</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_task_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BMCServiceDesk__Task__c.BMCServiceDesk__state__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notifies the client that the task requested by the client is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify the client when a task is reopened</fullName>
        <actions>
            <name>BMCServiceDesk__notify_client_when_an_task_is_reopened</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies the client that the client’s task is reopened</description>
        <formula>BMCServiceDesk__state__c  = True &amp;&amp;  PRIORVALUE( BMCServiceDesk__state__c )  = False</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Open popup dialog for recalculating due date when priority of task changes</fullName>
        <actions>
            <name>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule has been deprecated. If the rule is active, deactivate it.</description>
        <formula>ISCHANGED( BMCServiceDesk__FKPriority__c ) &amp;&amp;  IF( BMCServiceDesk__ShowDueDateDialog__c  = false,true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
