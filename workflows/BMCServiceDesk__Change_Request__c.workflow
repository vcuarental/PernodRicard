<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__Notify_Change_Request_Owner_when_Final_Task_Linked_to_Change_Request_is_Closed</fullName>
        <description>Notify change request owner when final task linked to change request is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__All_Tasks_closed_for_Change_Request</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_Owner_for_the_Change_Request_scheduled_during_Blackout</fullName>
        <description>Notify Owner for the Change Request scheduled during Blackout</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Change_Request_Scheduled_Blackout</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_All_Tasks_Closed</fullName>
        <description>BMC_RF_Change Request All Tasks Closed</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_IT_Functional_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Change_Request_All_Tasks_Closed</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Approval_Received_ABO_Notification</fullName>
        <description>BMC_RF_Change Request Approval Received - ABO Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_Application_Business_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Appr_Received_ABO_Notif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Approval_Received_Deployment_Approval</fullName>
        <description>BMC_RF_Change Request Approval Received - Deployment Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Appr_Reciev_Deploy_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Approval_Received_Deployment_Approval_no_UAT</fullName>
        <description>BMC_RF_Change Request Approval Received - Deployment Approval (no UAT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Appr_Rec_Dep_Appr_no_UAT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Approval_Received_Registration_Approval</fullName>
        <description>BMC_RF_Change Request Approval Received - Registration Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Requ_Appr_RecieV_Reg_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Approval_Received_UAT_Approval</fullName>
        <description>BMC_RF_Change Request Approval Received - UAT Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Requ_Appr_Reciev_UAT_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Assignment_Queue</fullName>
        <description>BMC_RF_Change Request Assignment (Queue)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Assignment_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Assignment_Staff</fullName>
        <description>BMC_RF_Change Request Assignment (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Assignment_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Cancelled</fullName>
        <description>BMC_RF_Change Request Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_IT_Functional_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Change_Request_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Closed</fullName>
        <description>BMC_RF_Change Request Closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>javier.alcibar@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Change_Request_Closed</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Deployment_Rescheduled</fullName>
        <description>BMC_RF_Change Request Deployment Rescheduled</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_IT_Functional_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Deploy_Rescheduled</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Rejection_Received_Deployment_Approval</fullName>
        <description>BMC_RF_Change Request Rejection Received - Deployment Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Rejec_Receiv_Deploy_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Rejection_Received_Deployment_Approval_no_UAT</fullName>
        <description>BMC_RF_Change Request Rejection Received - Deployment Approval (no UAT)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Rejec_Deploy_Appr_no_UAT</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Rejection_Received_Registration_Approval</fullName>
        <description>BMC_RF_Change Request Rejection Received - Registration Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Rejec_Received_Reg_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Rejection_Received_UAT_Approval</fullName>
        <description>BMC_RF_Change Request Rejection Received - UAT Approval</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKInitiator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Chng_Req_Rejec_Receiv_UAT_Appr</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Change_Request_Update_External_Vendor_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Change Request Update External Vendor Notification</description>
        <protected>false</protected>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BMC_RF_IT_Functional_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_CR_Update_Ext</template>
    </alerts>
    <fieldUpdates>
        <fullName>BMC_RF_Change_Request_Update_Affiliate</fullName>
        <field>BMC_RF_Affiliate__c</field>
        <formula>BMC_RF_Affiliates_Impacted_Text_I__c &amp; BMC_RF_Affiliates_Impacted_Text_II__c &amp; BMC_RF_Affiliates_Impacted_Text_III__c &amp; BMC_RF_Affiliates_Impacted_Text_IV__c</formula>
        <name>BMC_RF_Change Request Update Affiliate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Change_Request_Update_Region</fullName>
        <field>BMC_RF_Region__c</field>
        <formula>IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;ASI&quot;), &quot;ASI &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;BALTICS&quot;), &quot;BALTICS &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;BCO&quot;), &quot;BCO &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;EMEA&quot;), &quot;EMEA &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;FR&quot;), &quot;FR &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;GTR&quot;), &quot;GTR &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;IBERIA&quot;), &quot;IBERIA &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;LATAM&quot;), &quot;LATAM &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;NA&quot;), &quot;NA &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRCE&quot;), &quot;PRCE &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRNE&quot;), &quot;PRNE &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRSE&quot;), &quot;PRSE &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRUK&quot;), &quot;PRUK &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;PRW&quot;), &quot;PRW &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;RICPER&quot;), &quot;RICPER &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;SEA&quot;), &quot;SEA &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;SSA&quot;), &quot;SSA &quot;,&quot;&quot;) &amp; 
IF(INCLUDES(BMC_RF_Regions_Impacted__c, &quot;WEE&quot;), &quot;WEE &quot;,&quot;&quot;)</formula>
        <name>BMC_RF_Change Request Update Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_B_T_Deployment_Schedule</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>IF(ISPICKVAL(BMC_RF_UAT_Required__c, &quot;Yes&quot;),&quot;CR_Approval_Set Status to Deployment Schedule&quot;,
IF(ISPICKVAL(BMC_RF_UAT_Required__c, &quot;No&quot;),&quot;CR_Approval_Set Status to Build/Test&quot;,&quot;&quot;))</formula>
        <name>BMC_RF_Status: B/T + Deployment Schedule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Build_Test</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Build/Test&quot;</formula>
        <name>BMC_RF_Status: Build/Test</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Deployment_Schedule</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Deployment Schedule&quot;</formula>
        <name>BMC_RF_Status: Deployment Schedule</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Pending_Deployment</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Pending Deployment to Production&quot;</formula>
        <name>BMC_RF_Status: Pending Deployment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Pending_Deployment_App</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Pending Deployment Approval&quot;</formula>
        <name>BMC_RF_Status: Pending Deployment App</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Pending_ITSM_Approval</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Pending IT Service Manager Approval&quot;</formula>
        <name>BMC_RF_Status: Pending ITSM Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Pending_UAT_Sign_Off</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Pending UAT Sign-Off&quot;</formula>
        <name>BMC_RF_Status: Pending UAT Sign-Off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Status_Registration</fullName>
        <field>BMCServiceDesk__TemplateName__c</field>
        <formula>&quot;CR_Approval_Set Status to Registration&quot;</formula>
        <name>BMC_RF_Status: Registration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Update_Queue_Assignment</fullName>
        <field>BMC_RF_Update_Queue_Assignment__c</field>
        <literalValue>1</literalValue>
        <name>BMC_RF_Update Queue Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Update_Queue_Assignment_Reset</fullName>
        <field>BMC_RF_Update_Queue_Assignment__c</field>
        <literalValue>0</literalValue>
        <name>BMC_RF_Update Queue Assignment Reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__Check for all Change Request scheduled during blackout</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_Owner_for_the_Change_Request_scheduled_during_Blackout</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Check for all Change Requests scheduled during blackout</description>
        <formula>AND(OR(ISNEW(),ISCHANGED(BMCServiceDesk__Scheduled_during_Blackout__c)),BMCServiceDesk__Scheduled_during_Blackout__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify change request owner when final task linked to change request is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_Change_Request_Owner_when_Final_Task_Linked_to_Change_Request_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify change request owner when final task linked to change request is closed</description>
        <formula>AND( BMCServiceDesk__State__c,  NOT( BMCServiceDesk__Inactive__c ) , ISCHANGED(BMCServiceDesk__AllTaskCloseController__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Cancelled</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Change_Request__c.BMCServiceDesk__Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Deployment Rescheduled</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Deployment_Rescheduled</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BMC_RF_Status_Deployment_Schedule</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(BMC_RF_UAT_Required__c, &quot;Yes&quot;), BMCServiceDesk__FKStatus__r.Name = &quot;Pending Deployment to Production&quot;, OR(ISCHANGED(BMCServiceDesk__Scheduled_Start_Date__c ), ISCHANGED(BMCServiceDesk__Scheduled_End_Date__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Deployment Rescheduled No UAT</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Deployment_Rescheduled</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BMC_RF_Status_Build_Test</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(BMC_RF_UAT_Required__c, &quot;No&quot;), BMCServiceDesk__FKStatus__r.Name = &quot;Pending Deployment to Production&quot;, OR(ISCHANGED(BMCServiceDesk__Scheduled_Start_Date__c ), ISCHANGED(BMCServiceDesk__Scheduled_End_Date__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Notification All Tasks Closed</fullName>
        <actions>
            <name>BMC_RF_Change_Request_All_Tasks_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( BMCServiceDesk__State__c,  NOT( BMCServiceDesk__Inactive__c ) , ISCHANGED(BMCServiceDesk__AllTaskCloseController__c),BMCServiceDesk__AllTaskCloseController__c &lt;&gt; False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Notification on Assignment Change %28Queue%29</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Assignment_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OwnerId &lt;&gt; $User.Id  &amp;&amp; ISCHANGED(OwnerId)  &amp;&amp; NOT(ISNEW())  &amp;&amp; BMCServiceDesk__State__c = True  &amp;&amp; ISBLANK(BMCServiceDesk__FKStaff__c) &amp;&amp; PRIORVALUE(BMCServiceDesk__Status__c) &lt;&gt; &quot;Pending IT Service Manager Approval&quot; &amp;&amp; PRIORVALUE(BMCServiceDesk__Status__c) &lt;&gt; &quot;Pending Deployment Approval&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Notification on Assignment Change %28Staff%29</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Assignment_Staff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>BMCServiceDesk__FKStaff__c &lt;&gt; $User.Id  &amp;&amp; ISCHANGED(BMCServiceDesk__FKStaff__c)  &amp;&amp; NOT(ISNEW())  &amp;&amp; BMCServiceDesk__State__c = True  &amp;&amp; NOT(ISBLANK(BMCServiceDesk__FKStaff__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Notification on Creation %28Queue%29</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Assignment_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>$User.Id &lt;&gt; OwnerId  &amp;&amp; BMCServiceDesk__State__c = True  &amp;&amp; ISBLANK(BMCServiceDesk__FKStaff__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Notification on Creation %28Staff%29</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Assignment_Staff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>$User.Id &lt;&gt; BMCServiceDesk__FKStaff__c  &amp;&amp; BMCServiceDesk__State__c = True  &amp;&amp; NOT(ISBLANK(BMCServiceDesk__FKStaff__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Pre-Approved for Build %2F Test</fullName>
        <actions>
            <name>BMC_RF_Status_Build_Test</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BMCServiceDesk__Change_Request__c.BMC_RF_Pre_Approved_for_Build_Test__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Update Affiliates Impacted</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Update_Affiliate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(BMC_RF_Affiliates_Impacted__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Change Request Update Regions Impacted</fullName>
        <actions>
            <name>BMC_RF_Change_Request_Update_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISBLANK(BMC_RF_Region__c),ISCHANGED(BMC_RF_Regions_Impacted__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
