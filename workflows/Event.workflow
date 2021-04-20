<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PJ_ByFor_Email_CM_Agenda_Conf_reminder</fullName>
        <description>Email the Cellar Masterfor Agenda Confirmation (reminder)</description>
        <protected>false</protected>
        <recipients>
            <recipient>PJ_ByFor_Cellar_Master</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_status_Booked_waiting_Confirm</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Email_CM_Agenda_Conf_reminder_Local</fullName>
        <description>Email the Cellar Masterfor Agenda Confirmation (reminder)</description>
        <protected>false</protected>
        <recipients>
            <recipient>PJ_ByFor_Cellar_Master</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_status_Booked_waiting_Confirm_Local</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Email_End_User_confirmed_slot</fullName>
        <description>Email to End User if Cellar Master confirm tha slot time</description>
        <protected>false</protected>
        <recipients>
            <field>PJ_ByFor_Experience_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Cellar_Master_confirm_the_slot</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Event_Deleted</fullName>
        <description>PJ_ByFor_Event_Deleted</description>
        <protected>false</protected>
        <recipients>
            <field>PJ_ByFor_Experience_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Event_deleted_Email</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Event_status_booked_Email</fullName>
        <description>PJ ByFor Event status booked Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>PJ_ByFor_Cellar_Master</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Event_status_booked_Email</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Event_status_booked_Email_Local</fullName>
        <description>PJ ByFor Event status booked Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>PJ_ByFor_Cellar_Master</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Event_status_booked_Email_Local</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Event_status_free_Email</fullName>
        <description>PJ ByFor Event status free Email</description>
        <protected>false</protected>
        <recipients>
            <field>PJ_ByFor_Experience_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Event_status_free_Email</template>
    </alerts>
    <alerts>
        <fullName>PJ_ByFor_Experience_Email_CM_new_slot</fullName>
        <description>Email to Cellar Master fto find a new slot in his agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>PJ_ByFor_Cellar_Master</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PJ_ByFor_Email_templates/PJ_ByFor_Alert_CM_for_new_slot</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_Check_IsAchieved_Checkbox</fullName>
        <field>PR_Report_IsAchieved__c</field>
        <literalValue>1</literalValue>
        <name>ASI CRM Check IsAchieved Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Check_IsCancelled_Checkbox</fullName>
        <field>PR_Report_IsCancelled__c</field>
        <literalValue>1</literalValue>
        <name>ASI CRM Check IsCancelled Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Check_IsOutstanding_Checkbox</fullName>
        <field>PR_Report_IsOutstanding__c</field>
        <literalValue>1</literalValue>
        <name>ASI CRM Check IsOutstanding Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Uncheck_IsAchieved_Checkbox</fullName>
        <field>PR_Report_IsAchieved__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_Uncheck_IsAchieved_Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Uncheck_IsCancelled_Checkbox</fullName>
        <field>PR_Report_IsCancelled__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_Uncheck_IsCancelled_Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Uncheck_IsOutstanding_Checkbox</fullName>
        <field>PR_Report_IsOutstanding__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_Uncheck_IsOutstanding_Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EVT_TruncateDescription</fullName>
        <description>Setup - Truncate the Description field in the technical field Truncated Description to be used in the Timeline bubbles.</description>
        <field>TECH_TruncatedDescription__c</field>
        <formula>LEFT( Description , $Setup.CS001_TimelineConfig__c.TaskDescriptionTeaserLength__c ) + &quot;...&quot;</formula>
        <name>EVT_TruncateDescription</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>gvp__Past_Event</fullName>
        <field>gvp__Event_is_Past__c</field>
        <literalValue>1</literalValue>
        <name>Past Event</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_Check_IsAchieved</fullName>
        <actions>
            <name>ASI_CRM_Check_IsAchieved_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitation Schedule Event,Visitation Schedule Event (HK CRM),Visitation Schedule Event (SG CRM),Visitation Schedule Event (MO CRM)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PR_Activity_Status__c</field>
            <operation>equals</operation>
            <value>Achieved</value>
        </criteriaItems>
        <description>Updates IsAchieved checkbox when user changes Activity Status to Achieved.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_Check_IsCancelled</fullName>
        <actions>
            <name>ASI_CRM_Check_IsCancelled_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates IsCancelled checkbox when user changes Activity Status to Cancelled.</description>
        <formula>OR ( 	AND (   		OR ( 			CONTAINS(RecordType.DeveloperName, &quot;ASI_HK_CRM_Visitation_Schedule_Event&quot;), 			CONTAINS(RecordType.DeveloperName, &quot;ASI_CRM_MO_Visitation_Schedule_Event&quot;), 			CONTAINS(RecordType.DeveloperName, &quot;ASI_CRM_SG_Visitation_Schedule_Event&quot;) 		), 		ISPICKVAL( PR_Activity_Status__c , &quot;Cancelled&quot;) 	), 	AND ( 		CONTAINS(RecordType.DeveloperName, &quot;ASI_KOR_Visitation_Schedule_Event&quot;), 		ISPICKVAL( PR_Activity_Status__c , &quot;Cancelled&quot;), 		ISPICKVAL( PR_Report_Visit_Type__c , &quot;Planned&quot;) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_Check_IsOutstanding</fullName>
        <actions>
            <name>ASI_CRM_Check_IsOutstanding_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitation Schedule Event,Visitation Schedule Event (HK CRM),Visitation Schedule Event (SG CRM),Visitation Schedule Event (MO CRM)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PR_Activity_Status__c</field>
            <operation>equals</operation>
            <value>Outstanding</value>
        </criteriaItems>
        <description>Updates IsOutstanding checkbox when user changes Activity Status to Outstanding.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_UnCheck_IsAchieved</fullName>
        <actions>
            <name>ASI_CRM_Uncheck_IsAchieved_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitation Schedule Event,Visitation Schedule Event (HK CRM),Visitation Schedule Event (SG CRM),Visitation Schedule Event (MO CRM)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PR_Activity_Status__c</field>
            <operation>notEqual</operation>
            <value>Achieved</value>
        </criteriaItems>
        <description>Updates IsAchieved checkbox when user changes Activity Status to any value other than Achieved</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_UnCheck_IsCancelled</fullName>
        <actions>
            <name>ASI_CRM_Uncheck_IsCancelled_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitation Schedule Event,Visitation Schedule Event (HK CRM),Visitation Schedule Event (SG CRM),Visitation Schedule Event (MO CRM)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PR_Activity_Status__c</field>
            <operation>notEqual</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Updates IsAchieved checkbox when user changes Activity Status to any value other than Cancelled</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_UnCheck_IsOutstanding</fullName>
        <actions>
            <name>ASI_CRM_Uncheck_IsOutstanding_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Visitation Schedule Event,Visitation Schedule Event (HK CRM),Visitation Schedule Event (SG CRM),Visitation Schedule Event (MO CRM)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PR_Activity_Status__c</field>
            <operation>notEqual</operation>
            <value>Outstanding</value>
        </criteriaItems>
        <description>Updates IsAchieved checkbox when user changes Activity Status to any value other than Outstanding</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EVT_TruncateDescription</fullName>
        <actions>
            <name>EVT_TruncateDescription</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Setup - Truncate the Description field in the technical field Truncated Description to be used in the Timeline bubbles.</description>
        <formula>ISCHANGED( Description )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PJ_ByFor_Event_Deleted</fullName>
        <actions>
            <name>PJ_ByFor_Event_Deleted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWF__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PJ_ByFor_Event_deleted_by_Cellar_Master__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>PJ Byfor Event</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PJ_ByFor_Event_status_Confirmed</fullName>
        <actions>
            <name>PJ_ByFor_Email_End_User_confirmed_slot</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	NOT ($User.BypassWF__c), 	RecordType.DeveloperName = &apos;PJ_Byfor_Event&apos;,    	ISCHANGED(PJ_ByFor_Status__c), 	ISPICKVAL(PJ_ByFor_Status__c, &apos;Confirmed&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PJ_ByFor_Event_status_Pending</fullName>
        <actions>
            <name>PJ_ByFor_Event_status_booked_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWF__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>PJ Byfor Event</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PJ_ByFor_Status__c</field>
            <operation>equals</operation>
            <value>Pending Validation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PJ_ByFor_Place_of_the_experience__c</field>
            <operation>equals</operation>
            <value>Epernay</value>
        </criteriaItems>
        <description>Pending validation.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJ_ByFor_Email_CM_Agenda_Conf_reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJ_ByFor_Event_status_Pending_Local</fullName>
        <actions>
            <name>PJ_ByFor_Event_status_booked_Email_Local</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.BypassWF__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>PJ Byfor Event</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PJ_ByFor_Status__c</field>
            <operation>equals</operation>
            <value>Pending Validation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.PJ_ByFor_Place_of_the_experience__c</field>
            <operation>equals</operation>
            <value>Local</value>
        </criteriaItems>
        <description>Pending validation.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJ_ByFor_Email_CM_Agenda_Conf_reminder_Local</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJ_ByFor_Event_status_free</fullName>
        <actions>
            <name>PJ_ByFor_Event_status_free_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PJ_ByFor_Experience_Email_CM_new_slot</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	NOT ($User.BypassWF__c), 	RecordType.DeveloperName = &apos;PJ_Byfor_Event&apos;,     	ISPICKVAL(PJ_ByFor_Status__c, &apos;Free&apos;), 	ISCHANGED(PJ_ByFor_Status__c),  	OR( 		ISPICKVAL(PRIORVALUE(PJ_ByFor_Status__c), &apos;Pending Validation&apos;), 		ISPICKVAL(PRIORVALUE(PJ_ByFor_Status__c), &apos;Confirmed&apos;) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
