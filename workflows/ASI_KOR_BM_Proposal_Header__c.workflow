<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_KR_Remind_BM_Planning</fullName>
        <description>ASI CRM KR Remind BM Planning</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_KOR_Email_Templates/ASI_CRM_KR_Remind_BM_Planning</template>
    </alerts>
    <alerts>
        <fullName>ASI_KOR_BM_Proposal_Rejected</fullName>
        <description>ASI KOR BM Proposal Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_BM_Proposal_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_KOR_BM_Proposal_Rejection_Notification</fullName>
        <description>ASI KOR BM Proposal Rejection Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_BM_Proposal_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_KOR_BM_Proposal_Submission_Notification</fullName>
        <description>ASI KOR BM Proposal Submission Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_KOR_SYS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>ASI_CRM_KR_TMKT_Regional_Managers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_KOR_Email_Templates/ASI_KOR_BM_Proposal_Submitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_KR_Send_Reminder_False</fullName>
        <field>ASI_KOR_Send_Reminder__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM KR Send Reminder False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_KOR_Copy_BM_Manager_Email</fullName>
        <field>ASI_KOR_SYS_Manager_Email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>ASI KOR Copy BM Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI KOR BM Proposal Approved</fullName>
        <actions>
            <name>ASI_KOR_BM_Proposal_Rejection_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Approved by RSD</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR BM Proposal Created</fullName>
        <actions>
            <name>ASI_KOR_Copy_BM_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR BM Proposal Rejected</fullName>
        <actions>
            <name>ASI_KOR_BM_Proposal_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI KOR BM Proposal Submitted</fullName>
        <actions>
            <name>ASI_KOR_BM_Proposal_Submission_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_KR_BM_Planning_Reminder</fullName>
        <actions>
            <name>ASI_CRM_KR_Remind_BM_Planning</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_KR_Send_Reminder_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Send_Reminder__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_KR_BM_Planning_Reminder_Cutoff</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Cut_off_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_CRM_KR_Remind_BM_Planning</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_KOR_BM_Proposal_Header__c.ASI_KOR_Cut_off_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
