<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BMCServiceDesk__Notify_problem_owner_when_each_linked_task_is_closed</fullName>
        <description>Notify problem owner when each linked task is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__Linked_task_for_a_problem_is_closed</template>
    </alerts>
    <alerts>
        <fullName>BMCServiceDesk__Notify_problem_owner_when_final_task_linked_to_problem_is_closed</fullName>
        <description>Notify problem owner when final task linked to problem is closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMCServiceDesk__All_tasks_closed_for_problem</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Assignment_Notification_No_Queue</fullName>
        <description>BMC_RF_Problem Assignment Notification (No Queue)</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Assign_Notif_No_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Assignment_Notification_Queue</fullName>
        <description>BMC_RF_Problem Assignment Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Assign_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Assignment_Notification_Staff</fullName>
        <description>BMC_RF_Problem Assignment Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Assign_Notif_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Creation_Notification_Queue</fullName>
        <description>BMC_RF_Problem Creation Notification (Queue)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Creation_Notif_Queue</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Creation_Notification_Queue_Verification</fullName>
        <description>BMC_RF_Problem Creation Notification (Queue Verification)</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Creat_Notif_Queue_Verif</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Creation_Notification_Staff</fullName>
        <description>BMC_RF_Problem Creation Notification (Staff)</description>
        <protected>false</protected>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Creation_Notif_Staff</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Resolved_Updates_Status_to_Closed_5_Day_Rule</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Problem Resolved Updates Status to (Closed 5 Day Rule)</description>
        <protected>false</protected>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_Prob_Resol_Upd_Stat_Close_5_Day</template>
    </alerts>
    <alerts>
        <fullName>BMC_RF_Problem_Update_External_Vendor_Notification</fullName>
        <ccEmails>itbar@pernod-ricard.com</ccEmails>
        <description>BMC_RF_Problem Update External Vendor Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>BMC_RF_External_Vendor_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BMCServiceDesk__FKStaff__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itbar@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BMCServiceDesk__SDE_Emails/BMC_RF_PRB_Update_External_Vendor</template>
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
        <fullName>BMC_RF_Problem_Rejection_Resolved_By</fullName>
        <field>BMC_RF_Resolved_By__c</field>
        <name>BMC_RF_Problem Rejection Resolved By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Rejection_Resolved_Date</fullName>
        <field>BMC_RF_Resolved_Date__c</field>
        <name>BMC_RF_Problem Rejection Resolved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Rejection_Resolved_Queue</fullName>
        <field>BMC_RF_Resolved_by_Queue__c</field>
        <name>BMC_RF_Problem Rejection Resolved Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Resolved_Resolved_By</fullName>
        <field>BMC_RF_Resolved_By__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName</formula>
        <name>BMC_RF_Problem Resolved Resolved By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Resolved_Resolved_Date</fullName>
        <field>BMC_RF_Resolved_Date__c</field>
        <formula>NOW()</formula>
        <name>BMC_RF_Problem Resolved Resolved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Resolved_Resolved_Queue</fullName>
        <field>BMC_RF_Resolved_by_Queue__c</field>
        <formula>BMCServiceDesk__Queue__c</formula>
        <name>BMC_RF_Problem Resolved Resolved Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Update_Affiliate</fullName>
        <field>BMC_RF_Affiliate__c</field>
        <formula>BMC_RF_Affiliates_Impacted_Text_I__c &amp; BMC_RF_Affiliates_Impacted_Text_II__c &amp; BMC_RF_Affiliates_Impacted_Text_III__c &amp; BMC_RF_Affiliates_Impacted_Text_IV__c</formula>
        <name>BMC_RF_Problem Update Affiliate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BMC_RF_Problem_Update_Region</fullName>
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
        <name>BMC_RF_Problem Update Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BMCServiceDesk__Notify problem owner when each linked task is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_problem_owner_when_each_linked_task_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify problem owner when each linked task is closed</description>
        <formula>AND( ISCHANGED( BMCServiceDesk__Task_Closed_Controller__c), NOT(ISBLANK( BMCServiceDesk__Task_Closed_Controller__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Notify problem owner when final task linked to problem is closed</fullName>
        <actions>
            <name>BMCServiceDesk__Notify_problem_owner_when_final_task_linked_to_problem_is_closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify problem owner when final task linked to problem is closed</description>
        <formula>AND( BMCServiceDesk__State__c, NOT( BMCServiceDesk__Inactive__c ) , IF(BMCServiceDesk__AllTaskCloseController__c,  ISCHANGED(BMCServiceDesk__AllTaskCloseController__c) , false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMCServiceDesk__Open popup dialog for recalculating due date when priority of problem changes</fullName>
        <actions>
            <name>BMCServiceDesk__Update_the_ShowDueDateDialog_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule has been deprecated. If the rule is active, deactivate it.</description>
        <formula>ISCHANGED( BMCServiceDesk__FKPriority__c ) &amp;&amp; IF( BMCServiceDesk__ShowDueDateDialog__c  = false, true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Assignment Notification %28No Queue%29</fullName>
        <actions>
            <name>BMC_RF_Problem_Assignment_Notification_No_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(BMCServiceDesk__Queue__c) &amp;&amp;   BMCServiceDesk__UpdateCount__c  &lt;&gt; 1 &amp;&amp; BMCServiceDesk__State__c = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Assignment Notification %28Queue%29</fullName>
        <actions>
            <name>BMC_RF_Problem_Assignment_Notification_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; ISCHANGED(OwnerId) &amp;&amp; ISBLANK( BMCServiceDesk__FKStaff__c )&amp;&amp; BMCServiceDesk__State__c = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Assignment Notification %28Staff%29</fullName>
        <actions>
            <name>BMC_RF_Problem_Assignment_Notification_Staff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; ISCHANGED(BMCServiceDesk__FKStaff__c) &amp;&amp;  OwnerId &lt;&gt; LastModifiedById &amp;&amp; NOT(ISBLANK(BMCServiceDesk__FKStaff__c)) &amp;&amp; BMCServiceDesk__State__c = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Created Notification %28Queue%29</fullName>
        <actions>
            <name>BMC_RF_Problem_Creation_Notification_Queue</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BMC_RF_Problem_Creation_Notification_Queue_Verification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(BMCServiceDesk__Queue__c)) &amp;&amp; BMCServiceDesk__State__c = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Created Notification %28Staff%29</fullName>
        <actions>
            <name>BMC_RF_Problem_Creation_Notification_Staff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OwnerId &lt;&gt; LastModifiedById &amp;&amp; NOT(ISBLANK(BMCServiceDesk__FKStaff__c)) &amp;&amp; BMCServiceDesk__State__c = True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Resolution Rejected Clear Resolution Details</fullName>
        <actions>
            <name>BMC_RF_Problem_Rejection_Resolved_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Problem_Rejection_Resolved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Problem_Rejection_Resolved_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(BMC_RF_Resolved_Date__c))  &amp;&amp; (PRIORVALUE(BMCServiceDesk__Status__c) = &quot;RESOLVED&quot; ||             PRIORVALUE(BMCServiceDesk__Status__c) = &quot;CLOSED&quot;)  &amp;&amp; BMCServiceDesk__Status__c &lt;&gt; &quot;RESOLVED&quot;  &amp;&amp; BMCServiceDesk__Status__c &lt;&gt; &quot;CLOSED&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Resolved Set Resolution Details</fullName>
        <actions>
            <name>BMC_RF_Problem_Resolved_Resolved_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Problem_Resolved_Resolved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BMC_RF_Problem_Resolved_Resolved_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(BMC_RF_Resolved_Date__c)  &amp;&amp;  BMCServiceDesk__Status__c  = &quot;RESOLVED&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Update Affiliates Impacted</fullName>
        <actions>
            <name>BMC_RF_Problem_Update_Affiliate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(AND(BMCServiceDesk__UpdateCount__c = 0, NOT(ISBLANK(BMC_RF_Affiliates_Impacted__c))),ISCHANGED(BMC_RF_Affiliates_Impacted__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BMC_RF_Problem Update Regions Impacted</fullName>
        <actions>
            <name>BMC_RF_Problem_Update_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISBLANK(BMC_RF_Region__c),ISCHANGED(BMC_RF_Regions_Impacted__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
