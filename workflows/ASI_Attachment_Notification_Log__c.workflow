<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_Attachment_Send_Notification_Alert</fullName>
        <description>ASI_Attachment_Send_Notification_Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Attachment_Email_From__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_Attachment_Notification/ASI_Attachment_CN_Email_Template</template>
    </alerts>
    <rules>
        <fullName>ASI_Attachment_Send_Notification</fullName>
        <actions>
            <name>ASI_Attachment_Send_Notification_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_Attachment_Notification_Log__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI Attachment CN Notification Log</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
