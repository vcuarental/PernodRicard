<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_OCR_SG_Document_Send_Email_Notification</fullName>
        <description>ASI OCR SG Document Send Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_OCR_SG_Notification_Email_Receiver</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_MFM_CAP_Email_Folder/ASI_OCR_SG_Document_Notification_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_OCR_Reset_Email_Notification_Flag</fullName>
        <field>ASI_OCR_SYS_Send_Notification__c</field>
        <literalValue>0</literalValue>
        <name>Reset Email Notification Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_OCR_SG_Update_Verified_Flag</fullName>
        <field>ASI_OCR_Verified__c</field>
        <literalValue>1</literalValue>
        <name>ASI OCR SG Update Verified Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI OCR SG Send Notification Email</fullName>
        <actions>
            <name>ASI_OCR_SG_Document_Send_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_OCR_Reset_Email_Notification_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_OCR_Archived_Document__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>OCR SG Archived Document</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_OCR_Archived_Document__c.ASI_OCR_SYS_Send_Notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI OCR SG Update Verified Flag</fullName>
        <active>true</active>
        <formula>AND(RecordType.DeveloperName = &apos;ASI_OCR_SG_Archived_Document&apos;,   ASI_OCR_Verified__c = FALSE, ASI_OCR_Disputed__c = FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_OCR_SG_Update_Verified_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>ASI_OCR_Archived_Document__c.LastModifiedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
